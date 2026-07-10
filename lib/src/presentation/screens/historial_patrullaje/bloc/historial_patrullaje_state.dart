import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';

class HistorialPatrullajeState extends Equatable {
  final bool loading;
  final List<HistorialPatrullajeModel> historial;
  final PatrullajeData? patrullaje;
  final HistorialPatrullajeModel? historialDetalle;
  final String? error;

  const HistorialPatrullajeState({
    this.loading = false,
    this.historial = const [],
    this.patrullaje,
    this.historialDetalle,
    this.error,
  });

  HistorialPatrullajeState copyWith({
    bool? loading,
    List<HistorialPatrullajeModel>? historial,
    PatrullajeData? patrullaje,
    HistorialPatrullajeModel? historialDetalle,
    String? error,
  }) {
    return HistorialPatrullajeState(
      loading: loading ?? this.loading,
      historial: historial ?? this.historial,
      patrullaje: patrullaje ?? this.patrullaje,
      historialDetalle: historialDetalle ?? this.historialDetalle,
      error: error,
    );
  }

  @override
  List<Object?> get props => [loading, historial, patrullaje, historialDetalle, error];
}
