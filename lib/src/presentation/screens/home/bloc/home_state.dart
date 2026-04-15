import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';

class HomeState extends Equatable {
  final PatrullajeModel? patrullaje;
  final bool isLoading;
  final String? error;
  final bool success;

  const HomeState({
    this.patrullaje,
    this.isLoading = false,
    this.success = false,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    PatrullajeModel? patrullaje,
    bool? success,
    String? error,
  }) {
    return HomeState(
      patrullaje: patrullaje ?? this.patrullaje,
      isLoading: isLoading ?? this.isLoading,
      success: success ?? this.success,
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [patrullaje, isLoading, success, error];
}
