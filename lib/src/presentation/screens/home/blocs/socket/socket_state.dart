import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/socket_connection_status.dart';

class SocketState extends Equatable {
  // =====================================================
  // ESTADO DE CONEXIÓN
  // =====================================================
  final SocketConnectionStatus status;

  // =====================================================
  // MENSAJE / ERROR
  // =====================================================
  final String? message;
  final String? error;

  // =====================================================
  // ÚLTIMA CONEXIÓN EXITOSA
  // =====================================================
  final DateTime? lastConnectedAt;

  const SocketState({
    this.status = SocketConnectionStatus.disconnected,
    this.message,
    this.error,
    this.lastConnectedAt,
  });

  // =====================================================
  // HELPERS
  // =====================================================
  bool get isConnected => status == SocketConnectionStatus.connected;

  bool get isConnecting => status == SocketConnectionStatus.connecting;

  bool get isReconnecting => status == SocketConnectionStatus.reconnecting;

  bool get isDisconnected => status == SocketConnectionStatus.disconnected;

  bool get hasError =>
      status == SocketConnectionStatus.error ||
      (error != null && error!.trim().isNotEmpty);

  // =====================================================
  // COPY WITH
  // =====================================================
  SocketState copyWith({
    SocketConnectionStatus? status,

    String? message,
    bool clearMessage = false,

    String? error,
    bool clearError = false,

    DateTime? lastConnectedAt,
    bool clearLastConnectedAt = false,
  }) {
    return SocketState(
      status: status ?? this.status,

      message: clearMessage ? null : message ?? this.message,

      error: clearError ? null : error ?? this.error,

      lastConnectedAt: clearLastConnectedAt
          ? null
          : lastConnectedAt ?? this.lastConnectedAt,
    );
  }

  // =====================================================
  // RESET
  // =====================================================
  SocketState reset() {
    return const SocketState();
  }

  @override
  List<Object?> get props => [status, message, error, lastConnectedAt];
}
