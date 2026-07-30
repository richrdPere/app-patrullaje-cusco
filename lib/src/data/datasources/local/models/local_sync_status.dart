enum LocalSyncStatus { pending, syncing, synced, failed }

extension LocalSyncStatusExtension on LocalSyncStatus {
  String get value {
    switch (this) {
      case LocalSyncStatus.pending:
        return 'PENDING';

      case LocalSyncStatus.syncing:
        return 'SYNCING';

      case LocalSyncStatus.synced:
        return 'SYNCED';

      case LocalSyncStatus.failed:
        return 'FAILED';
    }
  }

  bool get isPending {
    return this == LocalSyncStatus.pending || this == LocalSyncStatus.failed;
  }

  static LocalSyncStatus fromValue(String value) {
    switch (value.toUpperCase()) {
      case 'SYNCING':
        return LocalSyncStatus.syncing;

      case 'SYNCED':
        return LocalSyncStatus.synced;

      case 'FAILED':
        return LocalSyncStatus.failed;

      case 'PENDING':
      default:
        return LocalSyncStatus.pending;
    }
  }
}
