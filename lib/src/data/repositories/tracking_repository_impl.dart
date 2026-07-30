import 'dart:async';
import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/tracking_send_result.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

class TrackingRepositoryImpl implements TrackingRepository {
  final GeolocatorRepository geolocatorRepository;
  final SocketRepository socketRepository;

  TrackingRepositoryImpl(this.geolocatorRepository, this.socketRepository);

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
      'tipo=$tipo, distanceFilter=$distanceFilter, interval=$interval',
    );

    return geolocatorRepository.getLocationStream(
      tipo: tipo,
      distanceFilter: distanceFilter,
      interval: interval,
    );
  }

  // =====================================================
  // 2. ENVIAR UBICACIÓN Y ESPERAR CONFIRMACIÓN
  // =====================================================
  @override
  Future<TrackingSendResult> sendLocation(
    LocationEntity location,
    int patrullajeId,
  ) async {
    final socket = socketRepository.getSocket();

    if (!socket.connected) {
      throw StateError('El dispositivo no está conectado al servidor.');
    }

    if (patrullajeId <= 0) {
      throw ArgumentError.value(
        patrullajeId,
        'patrullajeId',
        'El identificador del patrullaje no es válido.',
      );
    }

    final payload = <String, dynamic>{
      'patrullajeId': patrullajeId,
      'latitud': location.latitud,
      'longitud': location.longitud,
      'velocidad': location.velocidad,
      'precision': location.precision,
      'fechaHora': location.fechaHora.toIso8601String(),
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
            completer.completeError(StateError(message));

            return;
          }

          final omitted =
              data['data'] == null && message.toLowerCase().contains('omitida');

          completer.complete(
            TrackingSendResult(
              success: true,
              message: message,
              confirmedAt: DateTime.now(),
              omitted: omitted,
            ),
          );
        } catch (error) {
          completer.completeError(error);
        }
      },
    );

    try {
      return await completer.future;
    } finally {
      timeout.cancel();
    }
  }
}
