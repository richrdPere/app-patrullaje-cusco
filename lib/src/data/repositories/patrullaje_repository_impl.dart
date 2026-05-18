import 'dart:async';

import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
//import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';

class PatrullajeRepositoryImpl implements PatrullajeRepository {
  final PatrullajeService remote;
  final SocketRepository socketRepository;

  PatrullajeRepositoryImpl(this.remote, this.socketRepository);

  @override
  Future<PatrullajeModel?> getPatrullajeActivo() {
    return remote.getPatrullajeActivo();
  }

  @override
  Future<void> endPatrullaje(int patrullajeId) {
    return remote.endPatrullaje(patrullajeId);
  }

  @override
  Future<void> startPatrullaje(int patrullajeId) {
    return remote.startPatrullaje(patrullajeId);
  }

  @override
  Future<void> sendLocation(LocationEntity location) {
    return remote.sendLocation(location);
  }

  // Socket
  @override
  Stream<PatrullajeModel> listenNuevoPatrullaje() {
    final controller = StreamController<PatrullajeModel>.broadcast();

    final socket = socketRepository.getSocket();

    void handler(data) {
      print("RAW SOCKET DATA (nuevo_patrullaje):");
      print(data);
      print("🔍 TYPE: ${data.runtimeType}");

      try {
        final patrullaje = PatrullajeModel.fromJson(data);

        print("🎯 PARSE OK:");
        print("ID: ${patrullaje.id}");
        print("Estado: ${patrullaje.estado}");
        print("Descripcion: ${patrullaje.descripcion}");
        print("Zona: ${patrullaje.zona.nombre}");

        controller.add(patrullaje);
      } catch (e) {
        controller.addError(e);
      }
    }

    socket.on('nuevo_patrullaje', handler);

    controller.onCancel = () {
      socket.off('nuevo_patrullaje', handler);
    };

    return controller.stream;
  }

  @override
  Stream<int> listenPatrullajeFinalizado() {
    final controller = StreamController<int>.broadcast();

    final socket = socketRepository.getSocket();

    void handler(data) {
      try {
        controller.add(data['patrullajeId']);
      } catch (e) {
        controller.addError(e);
      }
    }

    socket.on('patrullaje_finalizado', handler);

    controller.onCancel = () {
      socket.off('patrullaje_finalizado', handler);
    };

    return controller.stream;
  }

  @override
  Stream<PatrullajeModel> listenPatrullajeActualizado() {
    final controller = StreamController<PatrullajeModel>.broadcast();
    final socket = socketRepository.getSocket();

    void handler(data) {
      try {
        print("📡 SOCKET patrullaje_actualizado:");
        print(data);

        final patrullaje = PatrullajeModel.fromJson(data);

        controller.add(patrullaje);
      } catch (e) {
        controller.addError(e);
      }
    }

    socket.on('patrullaje_actualizado', handler);

    controller.onCancel = () {
      socket.off('patrullaje_actualizado', handler);
    };

    return controller.stream;
  }

  @override
  void iniciarPatrullajeSocket(int patrullajeId) {
    final socket = socketRepository.getSocket();

    socket.emit('iniciar_patrullaje', {'patrullajeId': patrullajeId});
  }

  @override
  void finalizarPatrullajeSocket(int patrullajeId) {
    final socket = socketRepository.getSocket();

    socket.emit('finalizar_patrullaje', {'patrullajeId': patrullajeId});
  }

  @override
  void joinPatrullaje(int patrullajeId) {
    final socket = socketRepository.getSocket();

    socket.emit('join_patrullaje', {'patrullajeId': patrullajeId});
  }

  @override
  void leavePatrullaje(int patrullajeId) {
    final socket = socketRepository.getSocket();

    socket.emit('leave_patrullaje', {'patrullajeId': patrullajeId});
  }
}
