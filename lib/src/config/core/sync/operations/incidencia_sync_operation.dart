import 'dart:async';

import 'package:flutter/foundation.dart';

// Sync
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_operation.dart';
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_result.dart';

// Request remoto
import 'package:sis_patrullaje_cusco/src/data/models/incidencia/register_incidencia_req.dart';

// DAO
import 'package:sis_patrullaje_cusco/src/data/datasources/local/dao/incidencia_pendiente_dao.dart';

// Modelo local
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_incidencia_pendiente_model.dart';

// Repository
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

// Modelos de dominio
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class IncidenciasSyncOperation implements SyncOperation {
  final IncidenciaPendienteDao incidenciaPendienteDao;
  final IncidenteRepository incidenteRepository;

  const IncidenciasSyncOperation({
    required this.incidenciaPendienteDao,
    required this.incidenteRepository,
  });

  @override
  String get name => 'INCIDENCIAS';

  @override
  int get priority => 20;

  @override
  Future<SyncOperationResult> execute() async {
    debugPrint('🔄 Iniciando sincronización de incidencias...');

    await incidenciaPendienteDao.recuperarSincronizacionesInterrumpidas();

    final pendientes = await incidenciaPendienteDao.obtenerPendientes(
      limite: 20,
    );

    if (pendientes.isEmpty) {
      debugPrint('✅ No existen incidencias pendientes.');

      return const SyncOperationResult(
        operationName: 'INCIDENCIAS',
        processed: 0,
        synchronized: 0,
        failed: 0,
        message: 'No existen incidencias pendientes.',
      );
    }

    var procesadas = 0;
    var sincronizadas = 0;
    var fallidas = 0;

    for (final incidencia in pendientes) {
      procesadas++;

      /*
       * Si ya tiene un ID remoto, la incidencia fue creada
       * anteriormente. No se debe volver a crear.
       *
       * La operación de evidencias continuará con ella.
       */
      final incidenciaServidorId = incidencia.incidenciaServidorId;

      if (incidenciaServidorId != null && incidenciaServidorId > 0) {
        debugPrint(
          'ℹ️ Incidencia ${incidencia.uuidLocal} ya creada '
          'en el servidor con ID $incidenciaServidorId.',
        );

        sincronizadas++;
        continue;
      }

      try {
        await incidenciaPendienteDao.marcarSincronizando(incidencia.uuidLocal);

        final request = _crearRequest(incidencia);

        final resource = await incidenteRepository.newIncidencia(request);

        final incidenciaRemota = _obtenerIncidenciaRemota(resource);

        final idServidor = incidenciaRemota.id;

        if (idServidor == null || idServidor <= 0) {
          throw StateError(
            'El backend no devolvió un ID válido para la incidencia.',
          );
        }

        /*
         * La incidencia ya fue creada en el servidor.
         *
         * Todavía no se marca como completamente SINCRONIZADA,
         * porque la operación de evidencias debe subir sus archivos.
         */
        await incidenciaPendienteDao.guardarIdServidor(
          uuidLocal: incidencia.uuidLocal,
          incidenciaServidorId: idServidor,
        );

        sincronizadas++;

        debugPrint(
          '✅ Incidencia sincronizada: '
          '${incidencia.uuidLocal} → servidor=$idServidor',
        );
      } catch (error, stackTrace) {
        fallidas++;

        final message = _formatError(error);

        debugPrint(
          '❌ Error sincronizando incidencia '
          '${incidencia.uuidLocal}: $message',
        );

        debugPrintStack(stackTrace: stackTrace);

        await incidenciaPendienteDao.marcarError(
          uuidLocal: incidencia.uuidLocal,
          error: message,
        );
      }
    }

    return SyncOperationResult(
      operationName: name,
      processed: procesadas,
      synchronized: sincronizadas,
      failed: fallidas,
      message:
          '$sincronizadas incidencias procesadas y '
          '$fallidas con error.',
    );
  }

  // =====================================================
  // CONSTRUIR REQUEST
  // =====================================================

  RegisterIncidenciaRequest _crearRequest(IncidenciaPendienteModel incidencia) {
    /*
     * Ajusta los nombres de estos parámetros a la definición
     * exacta de tu RegisterIncidenciaRequest.
     *
     * En esta fase NO enviamos archivos. Las evidencias se
     * sincronizan posteriormente.
     */
    return RegisterIncidenciaRequest(
      patrullajeId: incidencia.patrullajeId ?? 0,
      // zonaId: incidencia.zonaId,
      tipo: incidencia.tipo,
      descripcion: incidencia.descripcion,
      latitud: incidencia.latitud,
      longitud: incidencia.longitud,
      // fechaHora: incidencia.fechaHora,
      // origen: incidencia.origen,
      archivos: const [],
    );
  }

  // =====================================================
  // EXTRAER RESPUESTA DEL RESOURCE
  // =====================================================

  IncidenteModel _obtenerIncidenciaRemota(Resource<IncidenteModel> resource) {
    if (resource is Success<IncidenteModel>) {
      /*
       * En la mayoría de tus Resources el atributo es data.
       * Si en tu clase se llama diferente, ajusta esta línea.
       */
      final incidencia = resource.data;

      return incidencia;
    }

    if (resource is ErrorData<IncidenteModel>) {
      /*
       * Ajusta message si ErrorData usa error, errorMessage
       * u otra propiedad.
       */
      throw StateError(resource.message);
    }

    throw StateError('La respuesta del registro de incidencia no es válida.');
  }

  String _formatError(Object error) {
    if (error is TimeoutException) {
      return error.message ?? 'El servidor no confirmó la incidencia.';
    }

    if (error is StateError) {
      return error.message;
    }

    if (error is ArgumentError) {
      return error.message?.toString() ??
          'Los datos de la incidencia no son válidos.';
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
