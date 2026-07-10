import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

class HomeState extends Equatable {
  final PatrullajeData? patrullaje;
  final PatrullajeStatus   status;
  final bool isLoading;
  final String? error;

  const HomeState({
    this.patrullaje,
    this.status = PatrullajeStatus.sinAsignacion,
    this.isLoading = false,
    this.error,
  });

  HomeState copyWith({
    bool? isLoading,
    PatrullajeData? patrullaje,
    PatrullajeStatus? status,
    String? error,
    bool clearPatrullaje = false,
    bool clearError = false,
  }) {
    return HomeState(
      patrullaje: clearPatrullaje
          ? null
          : patrullaje ?? this.patrullaje,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        patrullaje,
        status,
        isLoading,
        error,
      ];
}