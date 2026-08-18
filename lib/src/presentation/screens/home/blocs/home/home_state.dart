import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

class HomeState extends Equatable {
  // ==========================================================
  // PATRULLAJE ACTIVO
  // ==========================================================
  final PatrullajeData? patrullaje;
  final PatrullajeStatus status;
  final bool isLoading;
  final String? error;

  // ==========================================================
  // MIS PATRULLAJES PAGINADOS
  // ==========================================================
  final PatrullajeSerenoPaginated? misPatrullajes;
  final PatrullajeSerenoQueryParams misPatrullajesParams;

  final bool isLoadingMisPatrullajes;
  final String? misPatrullajesError;

  const HomeState({
    // Patrullaje activo
    this.patrullaje,
    this.status = PatrullajeStatus.sinAsignacion,
    this.isLoading = false,
    this.error,

    // Mis patrullajes paginados
    this.misPatrullajes,
    this.misPatrullajesParams = const PatrullajeSerenoQueryParams(),
    this.isLoadingMisPatrullajes = false,
    this.misPatrullajesError,
  });

  HomeState copyWith({
    // Patrullaje activo
    PatrullajeData? patrullaje,
    PatrullajeStatus? status,
    bool? isLoading,
    String? error,
    bool clearPatrullaje = false,
    bool clearError = false,

    // Mis patrullajes paginados
    PatrullajeSerenoPaginated? misPatrullajes,
    PatrullajeSerenoQueryParams? misPatrullajesParams,
    bool? isLoadingMisPatrullajes,
    String? misPatrullajesError,
    bool clearMisPatrullajes = false,
    bool clearMisPatrullajesError = false,
  }) {
    return HomeState(
      // Patrullaje activo
      patrullaje: clearPatrullaje ? null : patrullaje ?? this.patrullaje,
      status: status ?? this.status,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : error ?? this.error,

      // Mis patrullajes paginados
      misPatrullajes: clearMisPatrullajes
          ? null
          : misPatrullajes ?? this.misPatrullajes,
      misPatrullajesParams: misPatrullajesParams ?? this.misPatrullajesParams,
      isLoadingMisPatrullajes:
          isLoadingMisPatrullajes ?? this.isLoadingMisPatrullajes,
      misPatrullajesError: clearMisPatrullajesError
          ? null
          : misPatrullajesError ?? this.misPatrullajesError,
    );
  }

  // ==========================================================
  // GETTERS: PATRULLAJE ACTIVO
  // ==========================================================
  bool get tienePatrullajeActivo {
    return patrullaje != null;
  }

  bool get patrullajeEnCurso {
    return status == PatrullajeStatus.enCurso;
  }

  // ==========================================================
  // GETTERS: MIS PATRULLAJES
  // ==========================================================
  List<PatrullajeListadoData> get patrullajes {
    return misPatrullajes?.items ?? const [];
  }

  PatrullajePagination? get pagination {
    return misPatrullajes?.pagination;
  }

  bool get tienePatrullajes {
    return patrullajes.isNotEmpty;
  }

  bool get misPatrullajesVacio {
    return !isLoadingMisPatrullajes &&
        misPatrullajesError == null &&
        patrullajes.isEmpty;
  }

  // ==========================================================
  // GETTERS: PAGINACIÓN
  // ==========================================================
  int get currentPage {
    return pagination?.page ?? misPatrullajesParams.page;
  }

  int get pageLimit {
    return pagination?.limit ?? misPatrullajesParams.limit;
  }

  int get totalItems {
    return pagination?.totalItems ?? 0;
  }

  int get totalPages {
    return pagination?.totalPages ?? 0;
  }

  bool get hasPreviousPage {
    return pagination?.hasPreviousPage ?? false;
  }

  bool get hasNextPage {
    return pagination?.hasNextPage ?? false;
  }

  bool get puedeIrPaginaAnterior {
    return hasPreviousPage && !isLoadingMisPatrullajes;
  }

  bool get puedeIrPaginaSiguiente {
    return hasNextPage && !isLoadingMisPatrullajes;
  }

  bool get mostrarPaginacion {
    return totalItems > 0 && totalPages > 1;
  }

  String get paginationLabel {
    if (totalItems == 0) {
      return 'Sin registros';
    }

    return 'Página $currentPage de $totalPages';
  }

  // ==========================================================
  // EQUATABLE
  // ==========================================================

  @override
  List<Object?> get props => [
    // Patrullaje activo
    patrullaje,
    status,
    isLoading,
    error,

    // Mis patrullajes paginados
    misPatrullajes,
    misPatrullajesParams,
    isLoadingMisPatrullajes,
    misPatrullajesError,
  ];
}
