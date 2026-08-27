import 'package:equatable/equatable.dart';

class TrackingSyncResult extends Equatable {
  final int total;
  final int synchronized;
  final int failed;
  final int pending;

  const TrackingSyncResult({
    required this.total,
    required this.synchronized,
    required this.failed,
    required this.pending,
  });

  const TrackingSyncResult.empty()
    : total = 0,
      synchronized = 0,
      failed = 0,
      pending = 0;

  bool get hasPending => pending > 0;

  bool get hasFailures => failed > 0;

  bool get isCompleted =>
      total > 0 && synchronized == total && failed == 0 && pending == 0;

  @override
  List<Object?> get props => [total, synchronized, failed, pending];
}
