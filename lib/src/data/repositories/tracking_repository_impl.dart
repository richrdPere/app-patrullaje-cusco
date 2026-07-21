import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';

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
  // 2. ENVIAR UBICACIÓN POR SOCKET
  // =====================================================
  // =====================================================
  // 2. ENVIAR UBICACIÓN POR SOCKET
  // =====================================================
  @override
  Future<void> sendLocation(LocationEntity location, int patrullajeId) async {
    final socket = socketRepository.getSocket();

    if (!socket.connected) {
      throw StateError(
        'No se puede enviar la ubicación porque '
        'el socket no está conectado.',
      );
    }

    if (patrullajeId <= 0) {
      throw ArgumentError.value(
        patrullajeId,
        'patrullajeId',
        'El identificador del patrullaje debe ser válido.',
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

    debugPrint(
      '📡 Enviando ubicación por socket '
      'para patrullaje $patrullajeId: $payload',
    );

    socket.emit('tracking', payload);
  }
  // @override
  // Future<void> sendLocation(LocationEntity location, int patrullajeId) async {
  //   final socket = socketRepository.getSocket();

  //   if (!socket.connected) {
  //     throw StateError(
  //       'No se puede enviar la ubicación porque '
  //       'el socket no está conectado.',
  //     );
  //   }

  //   final payload = <String, dynamic>{
  //     'lat': location.latitud,
  //     'lng': location.longitud,
  //     'velocidad': location.velocidad,
  //     'precision': location.precision,
  //     'patrullaje_id': patrullajeId,
  //     'timestamp': location.fechaHora.toIso8601String(),
  //     'tipo': location.tipo,
  //   };

  //   debugPrint('📡 Enviando ubicación por socket: $payload');

  //   socket.emit('tracking', payload);
  // }
}
