import 'dart:async';

import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/tracking/tracking_sync_result.dart';
import 'package:sis_patrullaje_cusco/src/data/utils/estado_sync.dart';

import 'package:uuid/uuid.dart';

// Entidades
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/tracking_send_result.dart';

// Repositorios
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

// DAO
import 'package:sis_patrullaje_cusco/src/data/datasources/local/dao/ubicacion_pendiente_dao.dart';

// Modelo local
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_ubicacion_pendiente_model.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final GeolocatorRepository geolocatorRepository;
  final SocketRepository socketRepository;

  final AuthRepository authRepository;
  final UbicacionPendienteDao ubicacionPendienteDao;

  final Uuid uuid;

  TrackingRepositoryImpl(
    this.geolocatorRepository,
    this.socketRepository,
    this.authRepository,
    this.ubicacionPendienteDao, {
    Uuid? uuid,
  }) : uuid = uuid ?? const Uuid();

  // =====================================================
  // 1. OBTENER STREAM GPS
  // =====================================================
  @override
  Stream<LocationEntity> getLocationStream({
    String tipo = 'TRACKING',
    int distanceFilter = 5,
    Duration interval = const Duration(seconds: 5),
  }) {
    debugPrint(
      '📍 TrackingRepositoryImpl.getLocationStream '
      'tipo=$tipo, '
      'distanceFilter=$distanceFilter, '
      'interval=$interval',
    );

    return geolocatorRepository.getLocationStream(
      tipo: tipo,
      distanceFilter: distanceFilter,
      interval: interval,
    );
  }

  // =====================================================
  // 2. ENVIAR UBICACIÓN
  // =====================================================
  // @override
  Future<TrackingSendResult> sendLocation(
    LocationEntity location,
    int patrullajeId,
  ) async {
    _validarDatos(location: location, patrullajeId: patrullajeId);

    /*
   * El UUID se genera antes de intentar el envío.
   * Si falla, se conserva en SQLite.
   */
    final trackingUuid = uuid.v4();

    final stopwatch = Stopwatch()..start();

    try {
      final result = await _enviarUbicacionRemota(
        location: location,
        patrullajeId: patrullajeId,
        trackingUuid: trackingUuid,
      );

      stopwatch.stop();

      debugPrint(
        result.omitted
            ? '🟡 Tracking confirmado pero omitido. '
                  'uuid=$trackingUuid, '
                  'duracion=${stopwatch.elapsedMilliseconds}ms'
            : '✅ Tracking confirmado por backend. '
                  'uuid=$trackingUuid, '
                  'duracion=${stopwatch.elapsedMilliseconds}ms',
      );

      return result;
    } on TrackingRemoteRejectedException {
      stopwatch.stop();
      rethrow;
    } catch (error, stackTrace) {
      stopwatch.stop();

      debugPrint(
        '⚠️ Tracking no confirmado remotamente. '
        'uuid=$trackingUuid, '
        'patrullaje=$patrullajeId, '
        'duracion=${stopwatch.elapsedMilliseconds}ms, '
        'motivo=$error',
      );

      debugPrintStack(stackTrace: stackTrace);

      return _guardarUbicacionOffline(
        location: location,
        patrullajeId: patrullajeId,
        trackingUuid: trackingUuid,
        errorTransmision: error,
      );
    }
  }
  // @override
  // Future<TrackingSendResult> sendLocation(
  //   LocationEntity location,
  //   int patrullajeId,
  // ) async {
  //   _validarDatos(location: location, patrullajeId: patrullajeId);

  //   try {
  //     return await _enviarUbicacionRemota(
  //       location: location,
  //       patrullajeId: patrullajeId,
  //     );
  //   } on TrackingRemoteRejectedException {
  //     /*
  //      * El backend recibió la solicitud, pero rechazó los datos.
  //      *
  //      * No se guarda en SQLite porque volver a enviarla después
  //      * produciría el mismo error.
  //      */
  //     rethrow;
  //   } catch (error, stackTrace) {
  //     debugPrint(
  //       '⚠️ No se pudo transmitir la ubicación. '
  //       'Se intentará guardar localmente.',
  //     );

  //     debugPrint('Motivo: $error');
  //     debugPrintStack(stackTrace: stackTrace);

  //     return _guardarUbicacionOffline(
  //       location: location,
  //       patrullajeId: patrullajeId,
  //       errorTransmision: error,
  //     );
  //   }
  // }

  // =====================================================
  // 3. SYNC PENDIENTES
  // =====================================================
  @override
  @override
  Future<TrackingSyncResult> syncPendingLocations({int limit = 100}) async {
    if (limit <= 0) {
      throw ArgumentError.value(
        limit,
        'limit',
        'El límite debe ser mayor que cero.',
      );
    }

    /*
   * Recupera registros que quedaron en SINCRONIZANDO
   * debido a un cierre inesperado.
   */
    await ubicacionPendienteDao.recuperarSincronizacionesInterrumpidas();

    final usuarioId = await _obtenerUsuarioId();

    /*
   * Para evitar enviar ubicaciones pertenecientes a otro
   * usuario que haya iniciado sesión en el dispositivo,
   * la sincronización requiere un usuario válido.
   */
    if (usuarioId == null || usuarioId <= 0) {
      throw StateError(
        'No se pudo identificar al usuario para '
        'sincronizar sus ubicaciones pendientes.',
      );
    }

    final pendingLocations = await ubicacionPendienteDao.obtenerPendientes(
      limite: limit,
      usuarioId: usuarioId,
    );

    if (pendingLocations.isEmpty) {
      debugPrint(
        '✅ No existen ubicaciones pendientes '
        'de tracking.',
      );

      return const TrackingSyncResult.empty();
    }

    final socket = socketRepository.getSocket();

    if (!socket.connected) {
      final pending = await ubicacionPendienteDao.contarPendientes(
        usuarioId: usuarioId,
      );

      debugPrint(
        '⚠️ No se sincronizaron ubicaciones: '
        'Socket.IO está desconectado. '
        'pendientes=$pending',
      );

      return TrackingSyncResult(
        total: pendingLocations.length,
        synchronized: 0,
        failed: 0,
        pending: pending,
      );
    }

    debugPrint(
      '🔄 Iniciando sincronización de '
      '${pendingLocations.length} ubicaciones...',
    );

    var synchronized = 0;
    var failed = 0;

    for (final pendingLocation in pendingLocations) {
      /*
     * La conexión puede perderse durante el lote.
     */
      final currentSocket = socketRepository.getSocket();

      if (!currentSocket.connected) {
        debugPrint(
          '⚠️ Sincronización interrumpida: '
          'Socket.IO se desconectó.',
        );

        break;
      }

      final pendingUuid = pendingLocation.uuidLocal;

      /*
     * Se marca un registro por vez.
     *
     * Así, si la conexión se pierde, los registros todavía
     * no procesados permanecen en PENDIENTE o ERROR.
     */
      await ubicacionPendienteDao.marcarSincronizando(<String>[pendingUuid]);

      final location = LocationEntity(
        latitud: pendingLocation.latitud,
        longitud: pendingLocation.longitud,
        velocidad: pendingLocation.velocidad,
        precision: pendingLocation.precision,
        fechaHora: pendingLocation.fechaHora.toUtc(),
        tipo: pendingLocation.tipo,
      );

      try {
        _validarDatos(
          location: location,
          patrullajeId: pendingLocation.patrullajeId,
        );

        final result = await _enviarUbicacionRemota(
          location: location,
          patrullajeId: pendingLocation.patrullajeId,
          trackingUuid: pendingUuid,
        );

        /*
       * Tanto una ubicación almacenada como una omitida
       * fueron confirmadas por el backend.
       */
        await ubicacionPendienteDao.marcarSincronizada(pendingUuid);

        synchronized++;

        debugPrint(
          result.omitted
              ? '🟡 Ubicación pendiente confirmada '
                    'pero omitida. uuid=$pendingUuid'
              : '✅ Ubicación pendiente sincronizada. '
                    'uuid=$pendingUuid',
        );
      } on TrackingRemoteRejectedException catch (error, stackTrace) {
        failed++;

        await ubicacionPendienteDao.marcarError(
          uuidLocal: pendingUuid,
          error: _formatearError(error),
        );

        debugPrint(
          '❌ Ubicación rechazada por backend. '
          'uuid=$pendingUuid, '
          'motivo=$error',
        );

        debugPrintStack(stackTrace: stackTrace);

        /*
       * Un rechazo se limita a este registro.
       * Los demás puntos pueden continuar.
       */
      } catch (error, stackTrace) {
        failed++;

        await ubicacionPendienteDao.marcarError(
          uuidLocal: pendingUuid,
          error: _formatearError(error),
        );

        debugPrint(
          '⚠️ No se pudo sincronizar ubicación. '
          'uuid=$pendingUuid, '
          'motivo=$error',
        );

        debugPrintStack(stackTrace: stackTrace);

        /*
       * Si el socket se desconectó o expiró el ACK,
       * detenemos el lote para evitar repetir el mismo
       * fallo con todos los registros.
       */
        final isConnectionFailure =
            error is TimeoutException ||
            !socketRepository.getSocket().connected;

        if (isConnectionFailure) {
          break;
        }
      }
    }

    /*
   * Si la aplicación se cerró o una excepción dejó algún
   * registro en SINCRONIZANDO, lo recuperamos.
   */
    await ubicacionPendienteDao.recuperarSincronizacionesInterrumpidas();

    final remaining = await ubicacionPendienteDao.contarPendientes(
      usuarioId: usuarioId,
    );

    debugPrint(
      '🏁 Sincronización de tracking terminada: '
      'total=${pendingLocations.length}, '
      'sincronizadas=$synchronized, '
      'fallidas=$failed, '
      'pendientes=$remaining.',
    );

    /*
   * Limpieza opcional de registros correctamente
   * sincronizados con más de siete días.
   */
    final cleanupLimit = DateTime.now().toUtc().subtract(
      const Duration(days: 7),
    );

    final deleted = await ubicacionPendienteDao.eliminarSincronizadasAntiguas(
      cleanupLimit,
    );

    if (deleted > 0) {
      debugPrint(
        '🧹 Ubicaciones sincronizadas antiguas '
        'eliminadas: $deleted.',
      );
    }

    return TrackingSyncResult(
      total: pendingLocations.length,
      synchronized: synchronized,
      failed: failed,
      pending: remaining,
    );
  }

  // =====================================================
  // 3. ENVÍO REMOTO MEDIANTE SOCKET.IO
  // =====================================================
  Future<TrackingSendResult> _enviarUbicacionRemota({
    required LocationEntity location,
    required int patrullajeId,
    required String trackingUuid,
  }) async {
    final socket = socketRepository.getSocket();

    debugPrint(
      '🔌 Socket para tracking: '
      'connected=${socket.connected}, '
      'id=${socket.id}, '
      'uuid=$trackingUuid',
    );

    if (!socket.connected) {
      throw StateError('El dispositivo no está conectado al servidor.');
    }

    final payload = <String, dynamic>{
      'uuid': trackingUuid,
      'patrullajeId': patrullajeId,
      'latitud': location.latitud,
      'longitud': location.longitud,
      'velocidad': location.velocidad,
      'precision': location.precision,
      'fechaHora': location.fechaHora.toUtc().toIso8601String(),
      'tipo': location.tipo,
    };

    debugPrint('📡 Enviando tracking: $payload');

    final completer = Completer<TrackingSendResult>();

    final timeout = Timer(const Duration(seconds: 8), () {
      if (completer.isCompleted) return;

      completer.completeError(
        TimeoutException(
          'El servidor no confirmó la '
          'recepción de la ubicación.',
        ),
      );
    });

    socket.emitWithAck(
      'tracking',
      payload,
      ack: (response) {
        debugPrint(
          '📥 ACK tracking: '
          '${response.runtimeType} → $response',
        );

        if (completer.isCompleted) return;

        timeout.cancel();

        try {
          if (response is! Map) {
            throw const FormatException(
              'La respuesta del servidor '
              'no tiene un formato válido.',
            );
          }

          final responseMap = Map<String, dynamic>.from(response);

          final success = responseMap['success'] == true;

          final message =
              responseMap['message']?.toString() ??
              responseMap['error']?.toString() ??
              'El servidor no proporcionó '
                  'información sobre el tracking.';

          if (!success) {
            throw TrackingRemoteRejectedException(message);
          }

          final responseData = responseMap['data'];

          final data = responseData is Map
              ? Map<String, dynamic>.from(responseData)
              : const <String, dynamic>{};

          final omitted =
              data['omitted'] == true ||
              (responseData == null &&
                  message.toLowerCase().contains('omitida'));

          final storedAt = DateTime.tryParse(
            data['storedAt']?.toString() ?? '',
          );

          completer.complete(
            TrackingSendResult(
              success: true,
              message: message,
              confirmedAt: storedAt?.toUtc() ?? DateTime.now().toUtc(),
              omitted: omitted,
              storedOffline: false,
              localUuid: trackingUuid,
            ),
          );
        } catch (error) {
          if (!completer.isCompleted) {
            completer.completeError(error);
          }
        }
      },
    );

    try {
      return await completer.future;
    } finally {
      timeout.cancel();
    }
  }
  // Future<TrackingSendResult> _enviarUbicacionRemota({
  //   required LocationEntity location,
  //   required int patrullajeId,
  // }) async {
  //   final socket = socketRepository.getSocket();

  //   if (!socket.connected) {
  //     throw StateError('El dispositivo no está conectado al servidor.');
  //   }

  //   final payload = <String, dynamic>{
  //     'patrullajeId': patrullajeId,
  //     'latitud': location.latitud,
  //     'longitud': location.longitud,
  //     'velocidad': location.velocidad,
  //     'precision': location.precision,
  //     'fechaHora': location.fechaHora.toUtc().toIso8601String(),
  //     'tipo': location.tipo,
  //   };

  //   debugPrint('📡 Enviando tracking: $payload');

  //   final completer = Completer<TrackingSendResult>();

  //   final timeout = Timer(const Duration(seconds: 8), () {
  //     if (!completer.isCompleted) {
  //       completer.completeError(
  //         TimeoutException(
  //           'El servidor no confirmó la recepción de la ubicación.',
  //         ),
  //       );
  //     }
  //   });

  //   socket.emitWithAck(
  //     'tracking',
  //     payload,
  //     ack: (response) {
  //       debugPrint(
  //         '📥 ACK tracking: '
  //         '${response.runtimeType} → $response',
  //       );

  //       if (completer.isCompleted) return;

  //       timeout.cancel();

  //       try {
  //         if (response is! Map) {
  //           throw const FormatException(
  //             'La respuesta del servidor no tiene un formato válido.',
  //           );
  //         }

  //         final data = Map<String, dynamic>.from(response);

  //         final success = data['success'] == true;

  //         final message =
  //             data['message']?.toString() ??
  //             data['error']?.toString() ??
  //             'El servidor no proporcionó información sobre el tracking.';

  //         if (!success) {
  //           /*
  //            * El backend respondió, por lo tanto no es un problema
  //            * de conectividad. No se debe guardar automáticamente.
  //            */
  //           throw TrackingRemoteRejectedException(message);
  //         }

  //         final omitted =
  //             data['data'] == null && message.toLowerCase().contains('omitida');

  //         completer.complete(
  //           TrackingSendResult(
  //             success: true,
  //             message: message,
  //             confirmedAt: DateTime.now().toUtc(),
  //             omitted: omitted,
  //             storedOffline: false,
  //           ),
  //         );
  //       } catch (error) {
  //         if (!completer.isCompleted) {
  //           completer.completeError(error);
  //         }
  //       }
  //     },
  //   );

  //   try {
  //     return await completer.future;
  //   } finally {
  //     timeout.cancel();
  //   }
  // }

  // =====================================================
  // 4. GUARDAR UBICACIÓN OFFLINE
  // =====================================================
  Future<TrackingSendResult> _guardarUbicacionOffline({
    required LocationEntity location,
    required int patrullajeId,
    required String trackingUuid,
    required Object errorTransmision,
  }) async {
    final ahora = DateTime.now().toUtc();

    final usuarioId = await _obtenerUsuarioId();

    final ubicacionPendiente = UbicacionPendienteModel(
      uuidLocal: trackingUuid,
      patrullajeId: patrullajeId,
      usuarioId: usuarioId,
      latitud: location.latitud,
      longitud: location.longitud,
      velocidad: location.velocidad,
      precision: location.precision,
      tipo: location.tipo,
      fechaHora: location.fechaHora.toUtc(),
      estadoSync: EstadoSync.pendiente,
      intentos: 0,
      ultimoError: _formatearError(errorTransmision),
      fechaCreacionLocal: ahora,
      fechaUltimoIntento: ahora,
    );

    final resultado = await ubicacionPendienteDao.insertar(ubicacionPendiente);

    if (resultado <= 0) {
      /*
     * ConflictAlgorithm.ignore también devuelve cero
     * si el UUID ya estaba almacenado.
     */
      final existente = await ubicacionPendienteDao.obtenerPorUuid(
        trackingUuid,
      );

      if (existente == null) {
        throw StateError(
          'No se pudo almacenar la ubicación '
          'pendiente en SQLite.',
        );
      }

      debugPrint(
        '⚠️ La ubicación ya estaba guardada '
        'offline. uuid=$trackingUuid',
      );
    }

    debugPrint(
      '💾 Ubicación guardada offline. '
      'uuid=$trackingUuid, '
      'patrullaje=$patrullajeId, '
      'usuario=$usuarioId',
    );

    return TrackingSendResult(
      success: true,
      message:
          'Sin conexión. La ubicación fue guardada '
          'localmente y se sincronizará posteriormente.',
      confirmedAt: ahora,
      omitted: false,
      storedOffline: true,
      localUuid: trackingUuid,
    );
  }

  // =====================================================
  // 5. OBTENER USUARIO AUTENTICADO
  // =====================================================
  Future<int?> _obtenerUsuarioId() async {
    try {
      final session = await authRepository.getUserSession();

      if (session == null) {
        debugPrint('⚠️ No existe una sesión local para obtener usuarioId.');

        return null;
      }

      /*
       * Ajusta esta línea de acuerdo con la estructura real
       * de AuthResponse.
       *
       * Ejemplos posibles:
       *
       * session.user.id
       * session.usuario.id
       * session.data.id
       */
      final usuarioId = session.data.usuario.id;

      if (usuarioId <= 0) {
        debugPrint(
          '⚠️ El ID del usuario almacenado no es válido: '
          '$usuarioId',
        );

        return null;
      }

      return usuarioId;
    } catch (error, stackTrace) {
      debugPrint('⚠️ No se pudo obtener el usuario autenticado: $error');

      debugPrintStack(stackTrace: stackTrace);

      /*
       * ubc_usuario_id es nullable, por lo que la ubicación
       * todavía puede almacenarse.
       */
      return null;
    }
  }

  // =====================================================
  // 6. VALIDACIONES
  // =====================================================
  void _validarDatos({
    required LocationEntity location,
    required int patrullajeId,
  }) {
    if (patrullajeId <= 0) {
      throw ArgumentError.value(
        patrullajeId,
        'patrullajeId',
        'El identificador del patrullaje no es válido.',
      );
    }

    if (!location.hasValidCoordinates) {
      throw ArgumentError('Las coordenadas de ubicación no son válidas.');
    }

    if (location.fechaHora.isAfter(
      DateTime.now().add(const Duration(minutes: 5)),
    )) {
      throw ArgumentError('La fecha de la ubicación no puede ser futura.');
    }
  }

  // =====================================================
  // 7. FORMATEAR ERROR
  // =====================================================
  String _formatearError(Object error) {
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
