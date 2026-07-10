import 'dart:async';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Repo
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

class PatrullajeRepositoryImpl implements PatrullajeRepository {
  final PatrullajeService remote;
  final AuthRepository authRepository;
  final SocketRepository socketRepository;

  PatrullajeRepositoryImpl(
    this.remote,
    this.authRepository,
    this.socketRepository,
  );

  // API REST
  @override
  Future<Resource<PatrullajeData?>> getPatrullajeActivo() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<PatrullajeData?>(
        message: 'No existe una sesión iniciada.',
        statusCode: 401,
      );
    }

    return await remote.getPatrullajeActivo(token: token);
  }

  @override
  Future<Resource<bool>> endPatrullaje(int patrullajeId) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.endPatrullaje(patrullajeId: patrullajeId, token: token);
  }

  @override
  Future<Resource<bool>> startPatrullaje(int patrullajeId) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return await remote.startPatrullaje(
      patrullajeId: patrullajeId,
      token: token,
    );
  }

  @override
  Future<Resource<bool>> sendLocation(LocationEntity location) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: "No existe una sesión iniciada.");
    }

    return remote.sendLocation(location: location, token: token);
  }

  // Socket
  @override
  Stream<PatrullajeData> listenNuevoPatrullaje() {
    final controller = StreamController<PatrullajeData>.broadcast();

    final socket = socketRepository.getSocket();

    void handler(data) {
      try {
        final patrullaje = PatrullajeData.fromJson(data);
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
  Stream<PatrullajeData> listenPatrullajeActualizado() {
    final controller = StreamController<PatrullajeData>.broadcast();
    final socket = socketRepository.getSocket();

    void handler(data) {
      try {
        final patrullaje = PatrullajeData.fromJson(data);

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

  // Socket - emit
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
