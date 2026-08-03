import 'package:equatable/equatable.dart';

class SyncOperationResult extends Equatable {
  final String operationName;

  final int processed;
  final int synchronized;
  final int failed;

  final String? message;

  const SyncOperationResult({
    required this.operationName,
    this.processed = 0,
    this.synchronized = 0,
    this.failed = 0,
    this.message,
  });

  bool get success => failed == 0;

  @override
  List<Object?> get props => [
    operationName,
    processed,
    synchronized,
    failed,
    message,
  ];
}

class SyncSummary extends Equatable {
  final List<SyncOperationResult> operations;

  final DateTime startedAt;
  final DateTime completedAt;

  const SyncSummary({
    required this.operations,
    required this.startedAt,
    required this.completedAt,
  });

  int get totalProcessed {
    return operations.fold(
      0,
      (total, operation) => total + operation.processed,
    );
  }

  int get totalSynchronized {
    return operations.fold(
      0,
      (total, operation) => total + operation.synchronized,
    );
  }

  int get totalFailed {
    return operations.fold(0, (total, operation) => total + operation.failed);
  }

  bool get success => totalFailed == 0;

  @override
  List<Object?> get props => [operations, startedAt, completedAt];
}
