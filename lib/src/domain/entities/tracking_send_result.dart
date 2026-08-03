import 'package:equatable/equatable.dart';

class TrackingSendResult extends Equatable {
  final bool success;
  final String message;
  final DateTime confirmedAt;
  final bool omitted;

  /// La ubicación no llegó al backend, pero fue guardada en SQLite.
  final bool storedOffline;

  /// UUID asignado al registro local.
  final String? localUuid;

  const TrackingSendResult({
    required this.success,
    required this.message,
    required this.confirmedAt,
    this.omitted = false,
    this.storedOffline = false,
    this.localUuid,
  });

  @override
  List<Object?> get props => [
    success,
    message,
    confirmedAt,
    omitted,
    storedOffline,
    localUuid,
  ];
}

class TrackingRemoteRejectedException implements Exception {
  final String message;

  const TrackingRemoteRejectedException(this.message);

  @override
  String toString() => message;
}
