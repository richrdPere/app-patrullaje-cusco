import 'sync_result.dart';

abstract class SyncOperation {
  /// Identificador de la operación.
  ///
  /// Ejemplos:
  /// - UBICACIONES
  /// - INCIDENCIAS
  /// - EVIDENCIAS
  String get name;

  /// Menor número significa mayor prioridad.
  ///
  /// Orden sugerido:
  /// - Ubicaciones: 10
  /// - Incidencias: 20
  /// - Evidencias: 30
  int get priority;

  Future<SyncOperationResult> execute();
}
