import 'dart:async';

import 'package:flutter/foundation.dart';

// Sync
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_operation.dart';
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_result.dart';

// DAO
import 'package:sis_patrullaje_cusco/src/data/datasources/local/dao/ubicacion_pendiente_dao.dart';

// Modelo local
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_ubicacion_pendiente_model.dart';

// Repositorio Socket
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

class UbicacionesSyncOperation implements SyncOperation {
  final UbicacionPendienteDao ubicacionPendienteDao;
  final SocketRepository socketRepository;

  const UbicacionesSyncOperation({
    required this.ubicacionPendienteDao,
    required this.socketRepository,
  });

  @override
  String get name => 'UBICACIONES';

  @override
  int get priority => 10;

  @override
  Future<SyncOperationResult> execute() async {
    debugPrint('🔄 Iniciando sincronización de ubicaciones...');

    /*
     * Recupera ubicaciones que pudieron quedar en SINCRONIZANDO
     * si la aplicación se cerró inesperadamente.
     */
    await ubicacionPendienteDao.recuperarSincronizacionesInterrumpidas();

    final pendientes = await ubicacionPendienteDao.obtenerPendientes(
      limite: 100,
    );

    if (pendientes.isEmpty) {
      debugPrint('✅ No existen ubicaciones pendientes.');

      return const SyncOperationResult(
        operationName: 'UBICACIONES',
        processed: 0,
        synchronized: 0,
        failed: 0,
        message: 'No existen ubicaciones pendientes.',
      );
    }

    final socket = socketRepository.getSocket();

    if (!socket.connected) {
      throw StateError(
        'El socket no está conectado. No se pueden sincronizar ubicaciones.',
      );
    }

    var sincronizadas = 0;
    var fallidas = 0;

    for (final ubicacion in pendientes) {
      /*
       * Si el socket se desconecta en medio del proceso,
       * detenemos la sincronización.
       */
      if (!socket.connected) {
        debugPrint('⚠️ Socket desconectado durante la sincronización.');

        break;
      }

      try {
        await ubicacionPendienteDao.marcarSincronizando([ubicacion.uuidLocal]);

        await _enviarUbicacion(socket: socket, ubicacion: ubicacion);

        await ubicacionPendienteDao.marcarSincronizada(ubicacion.uuidLocal);

        sincronizadas++;

        debugPrint('✅ Ubicación sincronizada: ${ubicacion.uuidLocal}');
      } catch (error, stackTrace) {
        fallidas++;

        final message = _formatError(error);

        debugPrint(
          '❌ Error sincronizando ubicación '
          '${ubicacion.uuidLocal}: $message',
        );

        debugPrintStack(stackTrace: stackTrace);

        await ubicacionPendienteDao.marcarError(
          uuidLocal: ubicacion.uuidLocal,
          error: message,
        );
      }
    }

    return SyncOperationResult(
      operationName: name,
      processed: sincronizadas + fallidas,
      synchronized: sincronizadas,
      failed: fallidas,
      message:
          '$sincronizadas ubicaciones sincronizadas y '
          '$fallidas con error.',
    );
  }

  // =====================================================
  // ENVIAR UBICACIÓN MEDIANTE SOCKET
  // =====================================================

  Future<void> _enviarUbicacion({
    required dynamic socket,
    required UbicacionPendienteModel ubicacion,
  }) async {
    final completer = Completer<void>();

    final payload = <String, dynamic>{
      /*
       * Conservamos los nombres que utiliza actualmente
       * tu evento "tracking".
       */
      'patrullajeId': ubicacion.patrullajeId,
      'latitud': ubicacion.latitud,
      'longitud': ubicacion.longitud,
      'velocidad': ubicacion.velocidad,
      'precision': ubicacion.precision,
      'fechaHora': ubicacion.fechaHora.toUtc().toIso8601String(),
      'tipo': ubicacion.tipo,

      /*
       * Datos adicionales para sincronización offline.
       */
      'uuidLocal': ubicacion.uuidLocal,
      'usuarioId': ubicacion.usuarioId,
      'registradaOffline': true,
    };

    debugPrint(
      '📤 Sincronizando ubicación: '
      '${ubicacion.uuidLocal}',
    );

    final timeout = Timer(const Duration(seconds: 8), () {
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'El servidor no confirmó la sincronización '
            'de la ubicación.',
          ),
        );
      }
    });

    socket.emitWithAck(
      'tracking',
      payload,
      ack: (response) {
        if (completer.isCompleted) return;

        timeout.cancel();

        debugPrint(
          '📥 ACK sincronización tracking: '
          '${response.runtimeType} → $response',
        );

        try {
          if (response is! Map) {
            throw const FormatException(
              'La respuesta del servidor no tiene un formato válido.',
            );
          }

          final data = Map<String, dynamic>.from(response);

          final success = data['success'] == true;

          final message =
              data['message']?.toString() ??
              data['error']?.toString() ??
              'El servidor no proporcionó una respuesta válida.';

          if (!success) {
            throw StateError(message);
          }

          completer.complete();
        } catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
      },
    );

    try {
      await completer.future;
    } finally {
      timeout.cancel();
    }
  }

  String _formatError(Object error) {
    if (error is TimeoutException) {
      return error.message ?? 'El servidor no confirmó la ubicación.';
    }

    if (error is StateError) {
      return error.message;
    }

    if (error is FormatException) {
      return error.message;
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
