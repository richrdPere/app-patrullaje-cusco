import 'package:equatable/equatable.dart';

sealed class SyncEvent extends Equatable {
  const SyncEvent();

  @override
  List<Object?> get props => [];
}

/// Inicializa el monitoreo global.
class StartSyncEvent extends SyncEvent {
  const StartSyncEvent();
}

/// Evento interno producido por SyncManager.
class SyncConnectionChangedEvent extends SyncEvent {
  final bool connected;

  const SyncConnectionChangedEvent({required this.connected});

  @override
  List<Object?> get props => [connected];
}

/// Solicita una comprobación manual.
class CheckConnectionEvent extends SyncEvent {
  const CheckConnectionEvent();
}

/// Solicita sincronización.
///
/// Puede ejecutarse manualmente o automáticamente cuando
/// se recupera la conexión.
class SynchronizePendingDataEvent extends SyncEvent {
  final bool automatic;

  const SynchronizePendingDataEvent({this.automatic = false});

  @override
  List<Object?> get props => [automatic];
}

/// Limpia mensajes de error o información.
class ClearSyncMessageEvent extends SyncEvent {
  const ClearSyncMessageEvent();
}
