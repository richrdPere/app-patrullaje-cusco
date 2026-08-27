import 'package:equatable/equatable.dart';

abstract class SocketEvent extends Equatable {
  const SocketEvent();

  @override
  List<Object?> get props => [];
}

// =====================================================
// EVENTOS PÚBLICOS
// =====================================================
class ConnectSocketEvent extends SocketEvent {
  const ConnectSocketEvent();
}

class DisconnectSocketEvent extends SocketEvent {
  const DisconnectSocketEvent();
}

// =====================================================
// EVENTOS INTERNOS
// =====================================================
class SocketConnected extends SocketEvent {
  const SocketConnected();
}

class SocketDisconnected extends SocketEvent {
  final String? reason;

  const SocketDisconnected({this.reason});

  @override
  List<Object?> get props => [reason];
}

class SocketReconnecting extends SocketEvent {
  final int attempt;

  const SocketReconnecting({required this.attempt});

  @override
  List<Object?> get props => [attempt];
}

class SocketConnectionError extends SocketEvent {
  final String message;

  const SocketConnectionError({required this.message});

  @override
  List<Object?> get props => [message];
}

