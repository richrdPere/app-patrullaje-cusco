import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';
import 'package:socket_io_client/socket_io_client.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketUseCases socketUseCases;
  final AuthUsesCases authUsesCases;
  late Socket socket;

  bool _isConnecting = false;

  SocketBloc(this.socketUseCases, this.authUsesCases) : super(SocketState()) {
    print("🔥 SocketBloc instance: ${this.hashCode}");

    on<ConnectSocketEvent>(_onConnect);
    on<DisconnectSocketEvent>(_onDisconnect);

    on<SocketConnected>((event, emit) {
      _isConnecting = false; // liberar
      emit(state.copyWith(isConnected: true));
    });

    on<SocketDisconnected>((event, emit) {
      emit(state.copyWith(isConnected: false));
    });
  }

  Future<void> _onConnect(
    ConnectSocketEvent event,
    Emitter<SocketState> emit,
  ) async {
    if (_isConnecting) return;

    _isConnecting = true;

    try {
      final session = await authUsesCases.getUserSession.run();
      final token = session?.token;

      if (token == null) {
        print("No hay token");
        return;
      }

      // SIEMPRE limpiar antes de conectar
      await socketUseCases.disconnetSocket.run();

      socket = socketUseCases.connectSocket.run(token);

      // limpiar listeners previos
      socket.off('connect');
      socket.off('disconnect');

      socket.onConnect((_) {
        print("🟢 CONECTADO AL BACKEND");
        add(SocketConnected());
      });

      socket.onDisconnect((_) {
        print("🔴 DESCONECTADO");
        add(SocketDisconnected());
      });
    } catch (e) {
      print("❌ Error en conexión socket: $e");
    } finally {
      _isConnecting = false;
    }
  }

  Future<void> _onDisconnect(
    DisconnectSocketEvent event,
    Emitter<SocketState> emit,
  ) async {
    await socketUseCases.disconnetSocket.run();

    _isConnecting = false;

    emit(const SocketState());
    // emit(state.copyWith(isConnected: false));
  }
}
