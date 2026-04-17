import 'package:equatable/equatable.dart';

class SocketState extends Equatable {
  final bool isConnected;

  const SocketState({
    this.isConnected = false,
  });

  SocketState copyWith({bool? isConnected}) {
    return SocketState(isConnected: isConnected ?? this.isConnected);
  }

  @override
  List<Object?> get props => [isConnected];
}
