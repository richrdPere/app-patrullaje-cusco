import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_result.dart';

enum SyncStatus {
  initial,
  checkingConnection,
  online,
  offline,
  synchronizing,
  synchronized,
  failure,
}

class SyncState extends Equatable {
  final SyncStatus status;

  final bool isConnected;
  final bool isSynchronizing;

  final String? message;
  final String? error;

  final DateTime? lastConnectionChangeAt;
  final DateTime? lastSynchronizationAt;

  final SyncSummary? lastSummary;

  const SyncState({
    this.status = SyncStatus.initial,
    this.isConnected = false,
    this.isSynchronizing = false,
    this.message,
    this.error,
    this.lastConnectionChangeAt,
    this.lastSynchronizationAt,
    this.lastSummary,
  });

  bool get isOnline => isConnected;

  bool get isOffline => !isConnected;

  SyncState copyWith({
    SyncStatus? status,
    bool? isConnected,
    bool? isSynchronizing,
    String? message,
    String? error,
    DateTime? lastConnectionChangeAt,
    DateTime? lastSynchronizationAt,
    SyncSummary? lastSummary,
    bool clearMessage = false,
    bool clearError = false,
    bool clearSummary = false,
  }) {
    return SyncState(
      status: status ?? this.status,
      isConnected: isConnected ?? this.isConnected,
      isSynchronizing: isSynchronizing ?? this.isSynchronizing,
      message: clearMessage ? null : message ?? this.message,
      error: clearError ? null : error ?? this.error,
      lastConnectionChangeAt:
          lastConnectionChangeAt ?? this.lastConnectionChangeAt,
      lastSynchronizationAt:
          lastSynchronizationAt ?? this.lastSynchronizationAt,
      lastSummary: clearSummary ? null : lastSummary ?? this.lastSummary,
    );
  }

  @override
  List<Object?> get props => [
    status,
    isConnected,
    isSynchronizing,
    message,
    error,
    lastConnectionChangeAt,
    lastSynchronizationAt,
    lastSummary,
  ];
}
