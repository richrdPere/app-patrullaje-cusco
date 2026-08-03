import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart';

// Sync
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_operation.dart';
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_result.dart';

// DAO
import 'package:sis_patrullaje_cusco/src/data/datasources/local/index_local.dart';

// Modelos locales
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_evidencia_pendiente_model.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_incidencia_pendiente_model.dart';

// Repository
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class EvidenciasSyncOperation implements SyncOperation {
  final IncidenciaPendienteDao incidenciaPendienteDao;
  final EvidenciaPendienteDao evidenciaPendienteDao;
  final IncidenteRepository incidenteRepository;

  const EvidenciasSyncOperation({
    required this.incidenciaPendienteDao,
    required this.evidenciaPendienteDao,
    required this.incidenteRepository,
  });

  @override
  String get name => 'EVIDENCIAS';

  @override
  int get priority => 30;

  @override
  Future<SyncOperationResult> execute() async {
    debugPrint('🔄 Iniciando sincronización de evidencias...');

    await evidenciaPendienteDao.recuperarSincronizacionesInterrumpidas();

    final incidencias = await incidenciaPendienteDao.obtenerPendientes(
      limite: 20,
    );

    if (incidencias.isEmpty) {
      debugPrint('✅ No existen incidencias con evidencias pendientes.');

      return const SyncOperationResult(
        operationName: 'EVIDENCIAS',
        processed: 0,
        synchronized: 0,
        failed: 0,
        message: 'No existen evidencias pendientes.',
      );
    }

    var procesadas = 0;
    var sincronizadas = 0;
    var fallidas = 0;

    for (final incidencia in incidencias) {
      final servidorId = incidencia.incidenciaServidorId;

      if (servidorId == null || servidorId <= 0) {
        debugPrint(
          '⚠️ Incidencia ${incidencia.uuidLocal} '
          'sin ID remoto válido.',
        );

        continue;
      }

      final evidencias = await evidenciaPendienteDao
          .obtenerPendientesPorIncidencia(incidencia.uuidLocal);

      /*
       * Si la incidencia no tiene evidencias pendientes,
       * puede marcarse como completamente sincronizada.
       *
       * Esto también cubre incidencias registradas sin archivos.
       */
      if (evidencias.isEmpty) {
        await _marcarIncidenciaFinalizada(
          incidencia: incidencia,
          incidenciaServidorId: servidorId,
        );

        continue;
      }

      var incidenciaConErrores = false;

      /*
       * Enviamos una evidencia por llamada.
       *
       * Aunque el repositorio acepta List<File>, enviar una
       * por una permite reintentos independientes.
       */
      for (final evidencia in evidencias) {
        procesadas++;

        try {
          await _sincronizarEvidencia(
            incidenciaServidorId: servidorId,
            evidencia: evidencia,
          );

          sincronizadas++;
        } catch (error, stackTrace) {
          fallidas++;
          incidenciaConErrores = true;

          final message = _formatError(error);

          debugPrint(
            '❌ Error sincronizando evidencia '
            '${evidencia.uuidLocal}: $message',
          );

          debugPrintStack(stackTrace: stackTrace);

          await evidenciaPendienteDao.marcarError(
            uuidLocal: evidencia.uuidLocal,
            error: message,
          );
        }
      }

      /*
       * Verificamos el estado real en SQLite, no solamente
       * la variable local. Esto permite contemplar evidencias
       * sincronizadas en intentos anteriores.
       */
      if (!incidenciaConErrores) {
        final todasSincronizadas = await evidenciaPendienteDao
            .todasSincronizadas(incidencia.uuidLocal);

        if (todasSincronizadas) {
          await _marcarIncidenciaFinalizada(
            incidencia: incidencia,
            incidenciaServidorId: servidorId,
          );
        }
      }
    }

    return SyncOperationResult(
      operationName: name,
      processed: procesadas,
      synchronized: sincronizadas,
      failed: fallidas,
      message:
          '$sincronizadas evidencias sincronizadas y '
          '$fallidas con error.',
    );
  }

  // =====================================================
  // SINCRONIZAR UNA EVIDENCIA
  // =====================================================

  Future<void> _sincronizarEvidencia({
    required int incidenciaServidorId,
    required EvidenciaPendienteModel evidencia,
  }) async {
    final archivo = File(evidencia.rutaLocal);

    if (!await archivo.exists()) {
      throw StateError('El archivo local no existe: ${evidencia.rutaLocal}');
    }

    final length = await archivo.length();

    if (length <= 0) {
      throw StateError('El archivo local está vacío: ${evidencia.rutaLocal}');
    }

    await evidenciaPendienteDao.marcarSincronizando(evidencia.uuidLocal);

    final resource = await incidenteRepository.addArchivosIncidencia(
      incidenciaId: incidenciaServidorId,
      archivos: [archivo],
    );

    final agregado = _obtenerResultadoCarga(resource);

    if (!agregado) {
      throw StateError('El servidor no confirmó la carga de la evidencia.');
    }

    /*
     * addArchivosIncidencia devuelve bool, por lo que no tenemos
     * la URL remota individual. Se guarda null en evp_url_remota.
     */
    await evidenciaPendienteDao.marcarSincronizada(
      uuidLocal: evidencia.uuidLocal,
      urlRemota: null,
    );

    debugPrint(
      '✅ Evidencia sincronizada: '
      '${evidencia.uuidLocal} → incidencia=$incidenciaServidorId',
    );
  }

  // =====================================================
  // EXTRAER RESULTADO DEL RESOURCE
  // =====================================================

  bool _obtenerResultadoCarga(Resource<bool> resource) {
    if (resource is Success<bool>) {
      /*
       * Ajusta resource.data si tu Success utiliza otra
       * propiedad.
       */
      return resource.data == true;
    }

    if (resource is ErrorData<bool>) {
      throw StateError(resource.message);
    }

    throw StateError('La respuesta de carga de evidencias no es válida.');
  }

  // =====================================================
  // FINALIZAR INCIDENCIA LOCAL
  // =====================================================

  Future<void> _marcarIncidenciaFinalizada({
    required IncidenciaPendienteModel incidencia,
    required int incidenciaServidorId,
  }) async {
    await incidenciaPendienteDao.marcarSincronizada(
      uuidLocal: incidencia.uuidLocal,
      incidenciaServidorId: incidenciaServidorId,
    );

    debugPrint(
      '✅ Incidencia completamente sincronizada: '
      '${incidencia.uuidLocal}',
    );
  }

  String _formatError(Object error) {
    if (error is TimeoutException) {
      return error.message ?? 'El servidor no confirmó la evidencia.';
    }

    if (error is StateError) {
      return error.message;
    }

    if (error is FileSystemException) {
      return error.message;
    }

    if (error is ArgumentError) {
      return error.message?.toString() ??
          'La evidencia contiene datos no válidos.';
    }

    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    if (message.startsWith('Bad state: ')) {
      return message.replaceFirst('Bad state: ', '');
    }

    return message;
  }
}
