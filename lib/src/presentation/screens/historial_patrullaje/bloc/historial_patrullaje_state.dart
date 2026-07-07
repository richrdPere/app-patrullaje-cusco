import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';

class HistorialPatrullajeState extends Equatable {
  final bool loading;

  final List<HistorialPatrullajeModel> historial;

  final HistorialPatrullajeModel? historialDetalle;

  final String? error;

  const HistorialPatrullajeState({
    this.loading = false,
    this.historial = const [],
    this.historialDetalle,
    this.error,
  });

  HistorialPatrullajeState copyWith({
    bool? loading,
    List<HistorialPatrullajeModel>? historial,
    HistorialPatrullajeModel? historialDetalle,
    String? error,
  }) {
    return HistorialPatrullajeState(
      loading: loading ?? this.loading,
      historial: historial ?? this.historial,
      historialDetalle: historialDetalle ?? this.historialDetalle,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, historial, historialDetalle, error];
}
