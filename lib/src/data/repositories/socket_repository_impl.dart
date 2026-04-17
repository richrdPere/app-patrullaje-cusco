// import 'package:injectable/injectable.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';
import 'package:socket_io_client/socket_io_client.dart';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

// @LazySingleton(as: SocketRepository)
class SocketRepositoryImpl extends SocketRepository {
  Socket? _socket;

  SocketRepositoryImpl() {
    print("🧠 SocketRepository instance: ${this.hashCode}");
  }

  @override
  Socket connect(String token) {
    if (_socket != null && _socket!.connected) {
      print("⚠️ Reutilizando socket conectado");
      return _socket!;
    }

    // ⚠️ SI EXISTE PERO NO ESTÁ CONECTADO → ELIMINARLO
    if (_socket != null) {
      print("♻️ Eliminando socket anterior");
      _socket!.clearListeners();
      _socket!.dispose();
      _socket = null;
    }

    print("CREANDO NUEVO SOCKET CON TOKEN");
    print("CONNECT usando repo: ${this.hashCode}");

    _socket = io(
      url_backend.Environment.socketUrl,
      OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .setAuth({'token': token})
          .enableReconnection()
          .setReconnectionAttempts(5)
          .setReconnectionDelay(2000)
          .build(),
    );

    _socket!.connect();

    return _socket!;
  }

  @override
  void disconnect() {
    print("DESCONECTANDO SOCKET...");
    print("DISCONNECT usando repo: ${this.hashCode}");
    print("_socket disconent: ${_socket}");

    if (_socket != null) {
      try {
        // 1. Desactivar reconexión automática
        _socket!.io.options?['reconnection'] = false;

        // 2. Remover todos los listeners
        _socket!.clearListeners();

        // 3. Desconectar
        _socket!.disconnect();

        // 4. Liberar recursos
        _socket!.dispose();
      } catch (e) {
        print("Error al cerrar socket: $e");
      }
    }

    // 5. Limpiar instancia
    _socket = null;
  }

  @override
  Socket getSocket() {
    print("GET SOCKET usando repo: ${this.hashCode}");

    if (_socket == null) {
      throw Exception("Socket no inicializado");
    }
    return _socket!;
  }
}
