import 'dart:async';

import 'package:flutter/material.dart';

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
  @override
  Future<TrackingSendResult> sendLocation(
    LocationEntity location,
    int patrullajeId,
  ) async {
    _validarDatos(location: location, patrullajeId: patrullajeId);

    try {
      return await _enviarUbicacionRemota(
        location: location,
        patrullajeId: patrullajeId,
      );
    } on TrackingRemoteRejectedException {
      /*
       * El backend recibió la solicitud, pero rechazó los datos.
       *
       * No se guarda en SQLite porque volver a enviarla después
       * produciría el mismo error.
       */
      rethrow;
    } catch (error, stackTrace) {
      debugPrint(
        '⚠️ No se pudo transmitir la ubicación. '
        'Se intentará guardar localmente.',
      );

      debugPrint('Motivo: $error');
      debugPrintStack(stackTrace: stackTrace);

      return _guardarUbicacionOffline(
        location: location,
        patrullajeId: patrullajeId,
        errorTransmision: error,
      );
    }
  }

  // =====================================================
  // 3. ENVÍO REMOTO MEDIANTE SOCKET.IO
  // =====================================================
  Future<TrackingSendResult> _enviarUbicacionRemota({
    required LocationEntity location,
    required int patrullajeId,
  }) async {
    final socket = socketRepository.getSocket();

    if (!socket.connected) {
      throw StateError('El dispositivo no está conectado al servidor.');
    }

    final payload = <String, dynamic>{
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
      if (!completer.isCompleted) {
        completer.completeError(
          TimeoutException(
            'El servidor no confirmó la recepción de la ubicación.',
          ),
        );
      }
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
              'La respuesta del servidor no tiene un formato válido.',
            );
          }

          final data = Map<String, dynamic>.from(response);

          final success = data['success'] == true;

          final message =
              data['message']?.toString() ??
              data['error']?.toString() ??
              'El servidor no proporcionó información sobre el tracking.';

          if (!success) {
            /*
             * El backend respondió, por lo tanto no es un problema
             * de conectividad. No se debe guardar automáticamente.
             */
            throw TrackingRemoteRejectedException(message);
          }

          final omitted =
              data['data'] == null && message.toLowerCase().contains('omitida');

          completer.complete(
            TrackingSendResult(
              success: true,
              message: message,
              confirmedAt: DateTime.now().toUtc(),
              omitted: omitted,
              storedOffline: false,
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

  // =====================================================
  // 4. GUARDAR UBICACIÓN OFFLINE
  // =====================================================
  Future<TrackingSendResult> _guardarUbicacionOffline({
    required LocationEntity location,
    required int patrullajeId,
    required Object errorTransmision,
  }) async {
    final ahora = DateTime.now().toUtc();
    final uuidLocal = uuid.v4();

    final usuarioId = await _obtenerUsuarioId();

    final ubicacionPendiente = UbicacionPendienteModel(
      uuidLocal: uuidLocal,
      patrullajeId: patrullajeId,
      usuarioId: usuarioId,
      latitud: location.latitud,
      longitud: location.longitud,
      velocidad: location.velocidad,
      precision: location.precision,
      tipo: location.tipo,
      fechaHora: location.fechaHora.toUtc(),
      estadoSync: 'PENDIENTE',
      intentos: 0,
      ultimoError: _formatearError(errorTransmision),
      fechaCreacionLocal: ahora,
      fechaUltimoIntento: ahora,
    );

    final resultado = await ubicacionPendienteDao.insertar(ubicacionPendiente);

    /*
     * ConflictAlgorithm.ignore devuelve 0 si no insertó.
     *
     * Como cada registro usa un UUID nuevo, normalmente debe
     * devolver un ID mayor que cero.
     */
    if (resultado <= 0) {
      throw StateError(
        'No se pudo almacenar la ubicación pendiente en SQLite.',
      );
    }

    debugPrint(
      '💾 Ubicación guardada offline. '
      'uuid=$uuidLocal, '
      'patrullaje=$patrullajeId, '
      'usuario=$usuarioId',
    );

    return TrackingSendResult(
      success: true,
      message:
          'Sin conexión. La ubicación fue guardada localmente '
          'y se sincronizará posteriormente.',
      confirmedAt: ahora,
      omitted: false,
      storedOffline: true,
      localUuid: uuidLocal,
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
