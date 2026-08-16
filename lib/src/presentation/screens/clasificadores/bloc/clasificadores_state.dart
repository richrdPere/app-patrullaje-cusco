import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_arbol_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_query_params.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class ClasificadoresState {
  // 1.- Árbol
  final Resource<ApiResponse<ClasificadorArbolData>> clasificadorArbolResponse;

  // 2.- Clasificador por código
  final Resource<ApiResponse<ClasificadorCodigoData>>
  clasificadorCodigoResponse;

  // 3.- Clasificadores paginados
  final Resource<ApiResponse<ClasificadorPaginated>>
  clasificadoresPaginadoResponse;

  // Últimos parámetros utilizados
  final ClasificadorQueryParams? currentParams;

  ClasificadoresState({
    required this.clasificadorArbolResponse,
    required this.clasificadorCodigoResponse,
    required this.clasificadoresPaginadoResponse,
    this.currentParams,
  });

  factory ClasificadoresState.initial() {
    return ClasificadoresState(
      clasificadorArbolResponse: Initial<ApiResponse<ClasificadorArbolData>>(),
      clasificadorCodigoResponse:
          Initial<ApiResponse<ClasificadorCodigoData>>(),
      clasificadoresPaginadoResponse:
          Initial<ApiResponse<ClasificadorPaginated>>(),
      currentParams: null,
    );
  }

  ClasificadoresState copyWith({
    Resource<ApiResponse<ClasificadorArbolData>>? clasificadorArbolResponse,

    Resource<ApiResponse<ClasificadorCodigoData>>? clasificadorCodigoResponse,

    Resource<ApiResponse<ClasificadorPaginated>>?
    clasificadoresPaginadoResponse,

    ClasificadorQueryParams? currentParams,

    bool clearCurrentParams = false,
  }) {
    return ClasificadoresState(
      clasificadorArbolResponse:
          clasificadorArbolResponse ?? this.clasificadorArbolResponse,
      clasificadorCodigoResponse:
          clasificadorCodigoResponse ?? this.clasificadorCodigoResponse,
      clasificadoresPaginadoResponse:
          clasificadoresPaginadoResponse ?? this.clasificadoresPaginadoResponse,
      currentParams: clearCurrentParams
          ? null
          : currentParams ?? this.currentParams,
    );
  }

  // ========================================================
  // DATA
  // ========================================================
  ClasificadorArbolData? get arbol {
    final response = clasificadorArbolResponse;

    if (response is Success<ApiResponse<ClasificadorArbolData>>) {
      return response.data.data;
    }

    return null;
  }

  ClasificadorCodigoData? get clasificadorSeleccionado {
    final response = clasificadorCodigoResponse;

    if (response is Success<ApiResponse<ClasificadorCodigoData>>) {
      return response.data.data;
    }

    return null;
  }

  ClasificadorPaginated? get paginated {
    final response = clasificadoresPaginadoResponse;

    if (response is Success<ApiResponse<ClasificadorPaginated>>) {
      return response.data.data;
    }

    return null;
  }

  // ========================================================
  // LISTADO Y PAGINACIÓN
  // ========================================================
  List<ClasificadorCodigoData> get clasificadores {
    return paginated?.items ?? <ClasificadorCodigoData>[];
  }

  bool get hasNextPage {
    return paginated?.pagination.hasNextPage ?? false;
  }

  bool get hasPreviousPage {
    return paginated?.pagination.hasPreviousPage ?? false;
  }

  int get currentPage {
    return paginated?.pagination.currentPage ?? currentParams?.page ?? 1;
  }

  int get totalPages {
    return paginated?.pagination.totalPages ?? 0;
  }

  int get totalItems {
    return paginated?.pagination.totalItems ?? 0;
  }

  // ========================================================
  // LOADING
  // ========================================================
  bool get isLoadingArbol {
    return clasificadorArbolResponse
        is Loading<ApiResponse<ClasificadorArbolData>>;
  }

  bool get isLoadingCodigo {
    return clasificadorCodigoResponse
        is Loading<ApiResponse<ClasificadorCodigoData>>;
  }

  bool get isLoadingPaginado {
    return clasificadoresPaginadoResponse
        is Loading<ApiResponse<ClasificadorPaginated>>;
  }

  // ========================================================
  // ERRORES
  // ========================================================
  ErrorData<ApiResponse<ClasificadorArbolData>>? get arbolError {
    final response = clasificadorArbolResponse;

    if (response is ErrorData<ApiResponse<ClasificadorArbolData>>) {
      return response;
    }

    return null;
  }

  ErrorData<ApiResponse<ClasificadorCodigoData>>? get codigoError {
    final response = clasificadorCodigoResponse;

    if (response is ErrorData<ApiResponse<ClasificadorCodigoData>>) {
      return response;
    }

    return null;
  }

  ErrorData<ApiResponse<ClasificadorPaginated>>? get paginadoError {
    final response = clasificadoresPaginadoResponse;

    if (response is ErrorData<ApiResponse<ClasificadorPaginated>>) {
      return response;
    }

    return null;
  }
}
