import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:socket_io_client/socket_io_client.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/socket_connection_status.dart';

class SocketBloc extends Bloc<SocketEvent, SocketState> {
  final SocketUseCases socketUseCases;
  final AuthUsesCases authUsesCases;

  Socket? _socket;

  bool _isConnecting = false;
  bool _manualDisconnect = false;

  SocketBloc(this.socketUseCases, this.authUsesCases)
    : super(const SocketState()) {
    debugPrint('🔥 SocketBloc instance: $hashCode');

    // =====================================================
    // EVENTOS PÚBLICOS
    // =====================================================
    on<ConnectSocketEvent>(_onConnect);
    on<DisconnectSocketEvent>(_onDisconnect);

    // =====================================================
    // EVENTOS INTERNOS
    // =====================================================
    on<SocketConnected>(_onSocketConnected);
    on<SocketDisconnected>(_onSocketDisconnected);
    on<SocketReconnecting>(_onSocketReconnecting);
    on<SocketConnectionError>(_onSocketConnectionError);
  }

  // =====================================================
  // 1. CONECTAR SOCKET
  // =====================================================
  Future<void> _onConnect(
    ConnectSocketEvent event,
    Emitter<SocketState> emit,
  ) async {
    /*
     * Si ya está conectado, no es necesario volver
     * a crear la conexión.
     */
    if (state.isConnected && _socket?.connected == true) {
      debugPrint('⚠️ Socket ya está conectado.');

      return;
    }

    /*
     * Evita ejecutar dos conexiones al mismo tiempo.
     */
    if (_isConnecting) {
      debugPrint('⚠️ Ya existe un intento de conexión en curso.');

      return;
    }

    _isConnecting = true;
    _manualDisconnect = false;

    emit(
      state.copyWith(
        status: SocketConnectionStatus.connecting,
        message: 'Conectando con el servidor...',
        clearError: true,
      ),
    );

    try {
      final session = await authUsesCases.getUserSession.run();

      final token = session?.data.token;

      if (token == null || token.trim().isEmpty) {
        throw StateError(
          'No se encontró una sesión válida para conectar con el servidor.',
        );
      }

      /*
       * Limpia cualquier conexión anterior.
       */
      await _clearCurrentSocket();

      /*
       * Crea una nueva conexión.
       */
      final socket = socketUseCases.connectSocket.run(token);

      _socket = socket;

      _registerSocketListeners(socket);

      /*
       * Dependiendo de la configuración del repositorio,
       * connectSocket puede devolver un socket todavía
       * desconectado.
       */
      if (!socket.connected) {
        socket.connect();
      } else {
        add(const SocketConnected());
      }
    } catch (error, stackTrace) {
      debugPrint('❌ Error conectando Socket.IO: $error');

      debugPrintStack(stackTrace: stackTrace);

      add(SocketConnectionError(message: _formatError(error)));
    } finally {
      _isConnecting = false;
    }
  }

  // =====================================================
  // 2. DESCONECTAR SOCKET
  // =====================================================
  Future<void> _onDisconnect(
    DisconnectSocketEvent event,
    Emitter<SocketState> emit,
  ) async {
    debugPrint('🔴 Desconectando socket manualmente...');

    _manualDisconnect = true;
    _isConnecting = false;

    await _clearCurrentSocket();

    emit(
      const SocketState(
        status: SocketConnectionStatus.disconnected,
        message: 'Desconectado del servidor.',
      ),
    );
  }

  // =====================================================
  // 3. SOCKET CONECTADO
  // =====================================================
  void _onSocketConnected(SocketConnected event, Emitter<SocketState> emit) {
    _isConnecting = false;
    _manualDisconnect = false;

    debugPrint('🟢 CONECTADO AL BACKEND');

    emit(
      state.copyWith(
        status: SocketConnectionStatus.connected,
        message: 'Conectado al servidor.',
        lastConnectedAt: DateTime.now(),
        clearError: true,
      ),
    );
  }

  // =====================================================
  // 4. SOCKET DESCONECTADO
  // =====================================================
  void _onSocketDisconnected(
    SocketDisconnected event,
    Emitter<SocketState> emit,
  ) {
    _isConnecting = false;

    debugPrint(
      '🔴 Socket desconectado. Motivo: '
      '${event.reason ?? 'desconocido'}',
    );

    /*
     * Si la desconexión fue solicitada por logout o cierre
     * de sesión, no se muestra como reconexión.
     */
    if (_manualDisconnect) {
      emit(
        const SocketState(
          status: SocketConnectionStatus.disconnected,
          message: 'Desconectado del servidor.',
        ),
      );

      return;
    }

    /*
     * Socket.IO normalmente intentará reconectarse
     * automáticamente.
     */
    emit(
      state.copyWith(
        status: SocketConnectionStatus.reconnecting,
        message: 'Conexión perdida. Intentando reconectar...',
        error: event.reason,
      ),
    );
  }

  // =====================================================
  // 5. SOCKET RECONECTANDO
  // =====================================================
  void _onSocketReconnecting(
    SocketReconnecting event,
    Emitter<SocketState> emit,
  ) {
    debugPrint('🟠 Intento de reconexión #${event.attempt}');

    emit(
      state.copyWith(
        status: SocketConnectionStatus.reconnecting,
        message:
            'Reconectando con el servidor '
            '(intento ${event.attempt})...',
        clearError: true,
      ),
    );
  }

  // =====================================================
  // 6. ERROR DE CONEXIÓN
  // =====================================================
  void _onSocketConnectionError(
    SocketConnectionError event,
    Emitter<SocketState> emit,
  ) {
    _isConnecting = false;

    debugPrint(
      '❌ Error de conexión Socket.IO: '
      '${event.message}',
    );

    emit(
      state.copyWith(
        status: SocketConnectionStatus.error,
        message: 'No se pudo conectar con el servidor.',
        error: event.message,
      ),
    );
  }

  // =====================================================
  // 7. REGISTRAR LISTENERS
  // =====================================================
  void _registerSocketListeners(Socket socket) {
    /*
     * Limpia listeners anteriores para evitar que se
     * disparen varias veces.
     */
    _removeSocketListeners(socket);

    socket.onConnect((_) {
      add(const SocketConnected());
    });

    socket.onDisconnect((reason) {
      add(SocketDisconnected(reason: reason?.toString()));
    });

    socket.onConnectError((error) {
      add(SocketConnectionError(message: _formatError(error)));
    });

    socket.onError((error) {
      debugPrint('❌ Error general del socket: $error');
    });

    /*
     * Eventos del Manager de Socket.IO.
     *
     * En socket_io_client, los eventos de reconexión
     * generalmente se escuchan desde socket.io.
     */
    socket.io.on('reconnect_attempt', (attempt) {
      final parsedAttempt = int.tryParse(attempt?.toString() ?? '') ?? 1;

      add(SocketReconnecting(attempt: parsedAttempt));
    });

    socket.io.on('reconnect', (_) {
      add(const SocketConnected());
    });

    socket.io.on('reconnect_error', (error) {
      add(SocketConnectionError(message: _formatError(error)));
    });

    socket.io.on('reconnect_failed', (_) {
      add(
        const SocketConnectionError(
          message: 'No fue posible restablecer la conexión con el servidor.',
        ),
      );
    });
  }

  // =====================================================
  // 8. QUITAR LISTENERS
  // =====================================================
  void _removeSocketListeners(Socket socket) {
    socket.off('connect');
    socket.off('disconnect');
    socket.off('connect_error');
    socket.off('error');

    socket.io.off('reconnect_attempt');
    socket.io.off('reconnect');
    socket.io.off('reconnect_error');
    socket.io.off('reconnect_failed');
  }

  // =====================================================
  // 9. LIMPIAR SOCKET ACTUAL
  // =====================================================
  Future<void> _clearCurrentSocket() async {
    final currentSocket = _socket;

    if (currentSocket != null) {
      _removeSocketListeners(currentSocket);

      if (currentSocket.connected) {
        currentSocket.disconnect();
      }

      currentSocket.dispose();
      _socket = null;
    }

    /*
     * También limpia el socket almacenado dentro
     * del repositorio.
     */
    await socketUseCases.disconnetSocket.run();
  }

  // =====================================================
  // 10. FORMATEAR ERROR
  // =====================================================
  String _formatError(Object? error) {
    if (error == null) {
      return 'Ocurrió un error desconocido en la conexión.';
    }

    if (error is StateError) {
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

  // =====================================================
  // CLEANUP
  // =====================================================
  @override
  Future<void> close() async {
    _manualDisconnect = true;
    _isConnecting = false;

    await _clearCurrentSocket();

    return super.close();
  }
}
