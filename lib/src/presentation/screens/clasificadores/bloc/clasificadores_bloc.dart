import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_arbol_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';

// Use cases
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// BLoC
import 'clasificadores_event.dart';
import 'clasificadores_state.dart';

class ClasificadoresBloc
    extends Bloc<ClasificadoresEvent, ClasificadoresState> {
  final ClasificadoresUsesCases clasificadoresUsesCases;

  ClasificadoresBloc(this.clasificadoresUsesCases)
    : super(ClasificadoresState.initial()) {
    on<GetClasificadorArbol>(_onGetClasificadorArbol);
    on<GetClasificadorByCodigo>(_onGetClasificadorByCodigo);
    on<GetClasificadoresPaginado>(_onGetClasificadoresPaginado);
    on<ClearClasificadorSeleccionado>(_onClearClasificadorSeleccionado);
    on<ClearClasificadoresPaginado>(_onClearClasificadoresPaginado);
    on<ClearClasificadoresState>(_onClearClasificadoresState);
  }

  // *********************************************************
  // 1.- Obtener árbol de clasificadores
  // *********************************************************
  Future<void> _onGetClasificadorArbol(
    GetClasificadorArbol event,
    Emitter<ClasificadoresState> emit,
  ) async {
    if (state.isLoadingArbol) {
      return;
    }

    emit(
      state.copyWith(
        clasificadorArbolResponse:
            Loading<ApiResponse<ClasificadorArbolData>>(),
      ),
    );

    try {
      final response = await clasificadoresUsesCases.getClasificadorArbolUC
          .run();

      debugPrint('Arbol: $response');

      emit(state.copyWith(clasificadorArbolResponse: response));
    } catch (error, stackTrace) {
      debugPrint('Error obteniendo árbol: $error');

      debugPrintStack(stackTrace: stackTrace);

      emit(
        state.copyWith(
          clasificadorArbolResponse:
              ErrorData<ApiResponse<ClasificadorArbolData>>(
                message: 'No se pudo obtener el árbol de clasificadores.',
                error: error.toString(),
              ),
        ),
      );
    }
  }

  // *********************************************************
  // 2.- Obtener clasificador por código
  // *********************************************************
  Future<void> _onGetClasificadorByCodigo(
    GetClasificadorByCodigo event,
    Emitter<ClasificadoresState> emit,
  ) async {
    final codigo = event.codigo.trim();

    if (codigo.isEmpty) {
      emit(
        state.copyWith(
          clasificadorCodigoResponse:
              ErrorData<ApiResponse<ClasificadorCodigoData>>(
                message: 'Debe proporcionar el código del clasificador.',
                statusCode: 400,
              ),
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        clasificadorCodigoResponse:
            Loading<ApiResponse<ClasificadorCodigoData>>(),
      ),
    );

    final response = await clasificadoresUsesCases.getClasificadorByCodigoUC
        .run(codigo: codigo);

    emit(state.copyWith(clasificadorCodigoResponse: response));
  }

  // *********************************************************
  // 3.- Obtener clasificadores paginados
  // *********************************************************
  Future<void> _onGetClasificadoresPaginado(
    GetClasificadoresPaginado event,
    Emitter<ClasificadoresState> emit,
  ) async {
    emit(
      state.copyWith(
        clasificadoresPaginadoResponse:
            Loading<ApiResponse<ClasificadorPaginated>>(),
        currentParams: event.params,
      ),
    );

    final response = await clasificadoresUsesCases.getClasificadoresPaginadoUC
        .run(params: event.params);

    emit(
      state.copyWith(
        clasificadoresPaginadoResponse: response,
        currentParams: event.params,
      ),
    );
  }

  // *********************************************************
  // 4.- Limpiar clasificador seleccionado
  // *********************************************************
  void _onClearClasificadorSeleccionado(
    ClearClasificadorSeleccionado event,
    Emitter<ClasificadoresState> emit,
  ) {
    emit(
      state.copyWith(
        clasificadorCodigoResponse:
            Initial<ApiResponse<ClasificadorCodigoData>>(),
      ),
    );
  }

  // *********************************************************
  // 5.- Limpiar listado paginado
  // *********************************************************
  void _onClearClasificadoresPaginado(
    ClearClasificadoresPaginado event,
    Emitter<ClasificadoresState> emit,
  ) {
    emit(
      state.copyWith(
        clasificadoresPaginadoResponse:
            Initial<ApiResponse<ClasificadorPaginated>>(),
        clearCurrentParams: true,
      ),
    );
  }

  // *********************************************************
  // 6.- Limpiar todo el state
  // *********************************************************
  void _onClearClasificadoresState(
    ClearClasificadoresState event,
    Emitter<ClasificadoresState> emit,
  ) {
    emit(ClasificadoresState.initial());
  }
}
