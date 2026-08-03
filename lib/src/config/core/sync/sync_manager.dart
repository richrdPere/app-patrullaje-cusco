import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/connectivity_service.dart';

import 'sync_operation.dart';
import 'sync_result.dart';

class SyncManager {
  final ConnectivityService connectivityService;

  final List<SyncOperation> _operations = [];

  StreamSubscription<bool>? _connectivitySubscription;

  final StreamController<bool> _connectionController =
      StreamController<bool>.broadcast();

  bool _started = false;
  bool _isConnected = false;
  bool _isSynchronizing = false;

  SyncManager({required this.connectivityService});

  // =====================================================
  // GETTERS
  // =====================================================

  bool get isConnected => _isConnected;

  bool get isSynchronizing => _isSynchronizing;

  bool get isStarted => _started;

  Stream<bool> get connectionChanges => _connectionController.stream;

  List<SyncOperation> get operations => List.unmodifiable(_operations);

  // =====================================================
  // 1. REGISTRAR OPERACIÓN
  // =====================================================
  void registerOperation(SyncOperation operation) {
    final alreadyRegistered = _operations.any(
      (item) => item.name == operation.name,
    );

    if (alreadyRegistered) {
      debugPrint(
        '⚠️ SyncManager: la operación '
        '${operation.name} ya está registrada.',
      );

      return;
    }

    _operations.add(operation);

    _operations.sort(
      (first, second) => first.priority.compareTo(second.priority),
    );

    debugPrint(
      '✅ SyncManager: operación registrada '
      '${operation.name}, prioridad=${operation.priority}.',
    );
  }

  // =====================================================
  // 2. ELIMINAR OPERACIÓN
  // =====================================================
  void unregisterOperation(String operationName) {
    _operations.removeWhere((operation) => operation.name == operationName);
  }

  // =====================================================
  // 3. INICIAR MONITOREO
  // =====================================================
  Future<void> start() async {
    if (_started) {
      debugPrint('⚠️ SyncManager ya se encuentra iniciado.');

      return;
    }

    _started = true;

    try {
      _isConnected = await connectivityService.hasConnection();

      _notifyConnection(_isConnected);

      debugPrint(
        _isConnected
            ? '🌐 SyncManager iniciado con conexión.'
            : '📴 SyncManager iniciado sin conexión.',
      );

      _connectivitySubscription = connectivityService.connectionChanges
          .distinct()
          .listen(
            _handleConnectionChange,
            onError: (Object error, StackTrace stackTrace) {
              debugPrint('❌ Error escuchando conectividad: $error');

              debugPrintStack(stackTrace: stackTrace);

              _isConnected = false;
              _notifyConnection(false);
            },
          );
    } catch (error, stackTrace) {
      _started = false;
      _isConnected = false;

      debugPrint('❌ No se pudo iniciar SyncManager: $error');

      debugPrintStack(stackTrace: stackTrace);

      rethrow;
    }
  }

  // =====================================================
  // 4. CAMBIO DE CONECTIVIDAD
  // =====================================================
  void _handleConnectionChange(bool connected) {
    final previousValue = _isConnected;

    _isConnected = connected;

    debugPrint(
      connected ? '🌐 Conectividad restablecida.' : '📴 Conectividad perdida.',
    );

    /*
     * Aunque el valor sea el mismo, distinct() normalmente evita
     * repeticiones. Esta validación protege ante otras
     * implementaciones del servicio.
     */
    if (previousValue == connected) {
      return;
    }

    _notifyConnection(connected);
  }

  void _notifyConnection(bool connected) {
    if (!_connectionController.isClosed) {
      _connectionController.add(connected);
    }
  }

  // =====================================================
  // 5. CONSULTAR CONECTIVIDAD ACTUAL
  // =====================================================
  Future<bool> refreshConnection() async {
    try {
      final connected = await connectivityService.hasConnection();

      final changed = connected != _isConnected;

      _isConnected = connected;

      if (changed) {
        _notifyConnection(connected);
      }

      return connected;
    } catch (error, stackTrace) {
      debugPrint('❌ Error comprobando conectividad: $error');

      debugPrintStack(stackTrace: stackTrace);

      if (_isConnected) {
        _isConnected = false;
        _notifyConnection(false);
      }

      return false;
    }
  }

  // =====================================================
  // 6. SINCRONIZAR TODO
  // =====================================================
  Future<SyncSummary> synchronizeAll() async {
    if (_isSynchronizing) {
      throw StateError('Ya existe una sincronización en ejecución.');
    }

    final connected = await refreshConnection();

    if (!connected) {
      throw StateError('No existe conexión para iniciar la sincronización.');
    }

    _isSynchronizing = true;

    final startedAt = DateTime.now().toUtc();
    final results = <SyncOperationResult>[];

    debugPrint(
      '🔄 Iniciando sincronización de '
      '${_operations.length} operaciones...',
    );

    try {
      for (final operation in _operations) {
        /*
         * Antes de cada operación volvemos a verificar la conexión.
         * Esto evita continuar si la red se perdió durante el proceso.
         */
        final stillConnected = await connectivityService.hasConnection();

        if (!stillConnected) {
          _isConnected = false;
          _notifyConnection(false);

          throw StateError('La conexión se perdió durante la sincronización.');
        }

        debugPrint(
          '🔄 Ejecutando sincronización: '
          '${operation.name}.',
        );

        try {
          final result = await operation.execute();

          results.add(result);

          debugPrint(
            '✅ ${operation.name}: '
            'procesados=${result.processed}, '
            'sincronizados=${result.synchronized}, '
            'fallidos=${result.failed}.',
          );
        } catch (error, stackTrace) {
          debugPrint(
            '❌ Error sincronizando '
            '${operation.name}: $error',
          );

          debugPrintStack(stackTrace: stackTrace);

          results.add(
            SyncOperationResult(
              operationName: operation.name,
              failed: 1,
              message: _formatError(error),
            ),
          );

          /*
           * Continuamos con las siguientes operaciones.
           *
           * Posteriormente puedes cambiar esta decisión si una
           * operación depende estrictamente de la anterior.
           */
        }
      }

      final summary = SyncSummary(
        operations: results,
        startedAt: startedAt,
        completedAt: DateTime.now().toUtc(),
      );

      debugPrint(
        '🏁 Sincronización terminada: '
        'sincronizados=${summary.totalSynchronized}, '
        'fallidos=${summary.totalFailed}.',
      );

      return summary;
    } finally {
      _isSynchronizing = false;
    }
  }

  // =====================================================
  // 7. DETENER
  // =====================================================
  Future<void> stop() async {
    await _connectivitySubscription?.cancel();
    _connectivitySubscription = null;

    _started = false;
    _isSynchronizing = false;

    debugPrint('🛑 SyncManager detenido.');
  }

  // =====================================================
  // 8. CERRAR
  // =====================================================
  Future<void> dispose() async {
    await stop();

    if (!_connectionController.isClosed) {
      await _connectionController.close();
    }
  }

  // =====================================================
  // UTILS
  // =====================================================
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
}
