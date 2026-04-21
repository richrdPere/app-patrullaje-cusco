import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';

class HomeState extends Equatable {
  final PatrullajeModel? patrullaje;
  final bool isLoading;
  final String? error;
  final bool success;
  final bool activo; // o estado: "INICIADO", "FINALIZADO"

  const HomeState({
    this.patrullaje,
    this.isLoading = false,
    this.success = false,
    this.activo = false,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    PatrullajeModel? patrullaje,
    bool? success,
    bool? activo,
    String? error,
  }) {
    return HomeState(
      patrullaje: patrullaje ?? this.patrullaje,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      activo: activo ?? this.activo,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [patrullaje, isLoading, success, activo, error];
}
