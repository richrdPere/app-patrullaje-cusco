import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/incidencia_entity.dart';

class IncidenteState extends Equatable {
  final bool isLoading;
  final bool success;
  final String? error;
  final IncidenciaEntity? incidencia;

  const IncidenteState({
    this.isLoading = false,
    this.success = false,
    this.error,
    this.incidencia,
  });

  IncidenteState copyWith({
    bool? isLoading,
    bool? success,
    String? error,
    IncidenciaEntity? incidencia,
  }) {
    return IncidenteState(
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error,
      incidencia: incidencia ?? this.incidencia,
    );
  }

  @override
  List<Object?> get props => [isLoading, success, error, incidencia];
}
