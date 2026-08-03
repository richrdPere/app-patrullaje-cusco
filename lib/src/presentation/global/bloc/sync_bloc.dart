import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:flutter/foundation.dart';
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_manager.dart';

import 'sync_event.dart';
import 'sync_state.dart';

class SyncBloc extends Bloc<SyncEvent, SyncState> {
  final SyncManager syncManager;

  StreamSubscription<bool>? _connectionSubscription;

  SyncBloc({required this.syncManager}) : super(const SyncState()) {
    on<StartSyncEvent>(_onStart);
    on<SyncConnectionChangedEvent>(_onConnectionChanged);
    on<CheckConnectionEvent>(_onCheckConnection);
    on<SynchronizePendingDataEvent>(_onSynchronize);
    on<ClearSyncMessageEvent>(_onClearMessage);
  }

  // =====================================================
  // 1. INICIAR
  // =====================================================

  Future<void> _onStart(StartSyncEvent event, Emitter<SyncState> emit) async {
    if (_connectionSubscription != null) {
      debugPrint('⚠️ SyncBloc ya se encuentra escuchando conectividad.');

      return;
    }

    emit(
      state.copyWith(
        status: SyncStatus.checkingConnection,
        message: 'Comprobando conexión...',
        clearError: true,
      ),
    );

    try {
      /*
       * Nos suscribimos antes de start para no perder el primer
       * valor emitido por SyncManager.
       */
      _connectionSubscription = syncManager.connectionChanges.listen(
        (connected) {
          if (!isClosed) {
            add(SyncConnectionChangedEvent(connected: connected));
          }
        },
        onError: (Object error, StackTrace stackTrace) {
          debugPrint('❌ Error en el stream de SyncManager: $error');

          debugPrintStack(stackTrace: stackTrace);

          if (!isClosed) {
            add(const SyncConnectionChangedEvent(connected: false));
          }
        },
      );

      await syncManager.start();

      /*
       * Protección adicional si la implementación no emite
       * inmediatamente el estado inicial.
       */
      if (state.status == SyncStatus.checkingConnection) {
        add(SyncConnectionChangedEvent(connected: syncManager.isConnected));
      }
    } catch (error, stackTrace) {
      debugPrint('❌ No se pudo iniciar SyncBloc: $error');

      debugPrintStack(stackTrace: stackTrace);

      emit(
        state.copyWith(
          status: SyncStatus.failure,
          isConnected: false,
          isSynchronizing: false,
          error: _formatError(error),
          message: 'No se pudo iniciar el servicio de conectividad.',
        ),
      );
    }
  }

  // =====================================================
  // 2. CAMBIO DE CONEXIÓN
  // =====================================================

  Future<void> _onConnectionChanged(
    SyncConnectionChangedEvent event,
    Emitter<SyncState> emit,
  ) async {
    final now = DateTime.now().toUtc();

    if (!event.connected) {
      emit(
        state.copyWith(
          status: SyncStatus.offline,
          isConnected: false,
          isSynchronizing: false,
          message: 'Sin conexión. Los datos se guardarán localmente.',
          lastConnectionChangeAt: now,
          clearError: true,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status: SyncStatus.online,
        isConnected: true,
        isSynchronizing: false,
        message: 'Conexión disponible.',
        lastConnectionChangeAt: now,
        clearError: true,
      ),
    );

    /*
     * Al recuperar conexión se intenta sincronizar
     * automáticamente.
     */
    if (!syncManager.isSynchronizing) {
      add(const SynchronizePendingDataEvent(automatic: true));
    }
  }

  // =====================================================
  // 3. COMPROBAR CONEXIÓN MANUALMENTE
  // =====================================================

  Future<void> _onCheckConnection(
    CheckConnectionEvent event,
    Emitter<SyncState> emit,
  ) async {
    emit(
      state.copyWith(
        status: SyncStatus.checkingConnection,
        message: 'Comprobando conexión...',
        clearError: true,
      ),
    );

    final connected = await syncManager.refreshConnection();

    /*
     * refreshConnection solo emite si cambia el valor.
     * Por eso emitimos directamente cuando no hubo cambio.
     */
    if (connected == state.isConnected) {
      emit(
        state.copyWith(
          status: connected ? SyncStatus.online : SyncStatus.offline,
          isConnected: connected,
          isSynchronizing: false,
          message: connected ? 'Conexión disponible.' : 'No existe conexión.',
          lastConnectionChangeAt: DateTime.now().toUtc(),
          clearError: true,
        ),
      );
    }
  }

  // =====================================================
  // 4. SINCRONIZAR
  // =====================================================

  Future<void> _onSynchronize(
    SynchronizePendingDataEvent event,
    Emitter<SyncState> emit,
  ) async {
    if (state.isSynchronizing || syncManager.isSynchronizing) {
      debugPrint('⚠️ Se ignoró una sincronización duplicada.');

      return;
    }

    final connected = await syncManager.refreshConnection();

    if (!connected) {
      emit(
        state.copyWith(
          status: SyncStatus.offline,
          isConnected: false,
          isSynchronizing: false,
          message: 'No existe conexión para sincronizar los datos.',
          clearError: true,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        status: SyncStatus.synchronizing,
        isConnected: true,
        isSynchronizing: true,
        message: event.automatic
            ? 'Sincronizando datos pendientes...'
            : 'Iniciando sincronización...',
        clearError: true,
      ),
    );

    try {
      final summary = await syncManager.synchronizeAll();

      final synchronized = summary.totalSynchronized;
      final failed = summary.totalFailed;

      emit(
        state.copyWith(
          status: failed > 0 ? SyncStatus.failure : SyncStatus.synchronized,
          isConnected: true,
          isSynchronizing: false,
          lastSynchronizationAt: summary.completedAt,
          lastSummary: summary,
          message: _buildSummaryMessage(
            synchronized: synchronized,
            failed: failed,
          ),
          error: failed > 0
              ? 'Algunos registros no pudieron sincronizarse.'
              : null,
          clearError: failed == 0,
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('❌ Error durante la sincronización global: $error');

      debugPrintStack(stackTrace: stackTrace);

      final connectedNow = await syncManager.refreshConnection();

      emit(
        state.copyWith(
          status: connectedNow ? SyncStatus.failure : SyncStatus.offline,
          isConnected: connectedNow,
          isSynchronizing: false,
          error: _formatError(error),
          message: connectedNow
              ? 'No se pudo completar la sincronización.'
              : 'La conexión se perdió durante la sincronización.',
        ),
      );
    }
  }

  // =====================================================
  // 5. LIMPIAR MENSAJE
  // =====================================================

  void _onClearMessage(ClearSyncMessageEvent event, Emitter<SyncState> emit) {
    emit(state.copyWith(clearMessage: true, clearError: true));
  }

  // =====================================================
  // UTILS
  // =====================================================

  String _buildSummaryMessage({
    required int synchronized,
    required int failed,
  }) {
    if (synchronized == 0 && failed == 0) {
      return 'No existen datos pendientes para sincronizar.';
    }

    if (failed == 0) {
      return '$synchronized registros sincronizados correctamente.';
    }

    return '$synchronized registros sincronizados y '
        '$failed con error.';
  }

  String _formatError(Object error) {
    if (error is StateError) {
      return error.message;
    }

    final message = error.toString();

    if (message.startsWith('Exception: ')) {
      return message.replaceFirst('Exception: ', '');
    }

    if (message.startsWith('Bad state: ')) {
      return message.replaceFirst('Bad state: ', '');
    }

    return message;
  }

  // =====================================================
  // CLOSE
  // =====================================================

  @override
  Future<void> close() async {
    await _connectionSubscription?.cancel();
    _connectionSubscription = null;

    /*
     * SyncManager será singleton. No lo eliminamos aquí porque puede
     * ser utilizado durante toda la vida de la aplicación.
     */
    return super.close();
  }
}
