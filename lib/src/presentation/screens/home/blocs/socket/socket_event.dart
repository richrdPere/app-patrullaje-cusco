abstract class SocketEvent {}

// Conectar a Socket
class ConnectSocketEvent extends SocketEvent {}

// Desconectar a Socket
class DisconnectSocketEvent extends SocketEvent {}

class SocketConnected extends SocketEvent {}

class SocketDisconnected extends SocketEvent {}