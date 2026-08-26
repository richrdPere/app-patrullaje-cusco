import 'package:flutter_bloc/flutter_bloc.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// Uses Cases
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'ocurrencia_event.dart';
import 'ocurrencia_state.dart';

class OcurrenciaBloc extends Bloc<OcurrenciaEvent, OcurrenciaState> {
  final OcurrenciaUsesCases ocurrenciaUsesCases;

  OcurrenciaBloc(this.ocurrenciaUsesCases) : super(OcurrenciaState.initial()) {
    // ========================================================
    // OPERACIONES DEL BACKEND
    // ========================================================

    on<CreateOcurrencia>(_onCreateOcurrencia);

    on<GetOcurrenciasPaginado>(_onGetOcurrenciasPaginado);

    on<GetOcurrenciaById>(_onGetOcurrenciaById);

    on<GetOcurrenciaPdf>(_onGetOcurrenciaPdf);

    on<GetIncidenciasSelector>(_onGetIncidenciasSelector);

    on<LoadMoreIncidenciasSelector>(_onLoadMoreIncidenciasSelector);

    // ========================================================
    // SELECCIÓN DE INCIDENCIA
    // ========================================================

    on<SelectIncidenciaOcurrencia>(_onSelectIncidenciaOcurrencia);

    on<ClearSelectedIncidenciaOcurrencia>(_onClearSelectedIncidencia);

    on<RemoveIncidenciaFromSelector>(_onRemoveIncidenciaFromSelector);

    // ========================================================
    // LIMPIEZA DE RESPUESTAS
    // ========================================================

    on<ClearOcurrenciaCreateResponse>(_onClearCreateResponse);

    on<ClearOcurrenciaDetailResponse>(_onClearDetailResponse);

    on<ClearOcurrenciaPdfResponse>(_onClearPdfResponse);

    on<ClearOcurrenciaPaginatedResponse>(_onClearPaginatedResponse);

    on<ClearIncidenciasSelector>(_onClearIncidenciasSelector);

    on<ClearIncidenciasSelectorError>(_onClearIncidenciasSelectorError);

    // ========================================================
    // RESTABLECER BLOC
    // ========================================================

    on<ResetOcurrenciaState>(_onResetState);

    // ========================================================
    // FORM STEPS
    // ========================================================

    on<InitializeOcurrenciaForm>(_onInitializeForm);

    on<GoToOcurrenciaFormStep>(_onGoToFormStep);

    on<NextOcurrenciaFormStep>(_onNextFormStep);

    on<PreviousOcurrenciaFormStep>(_onPreviousFormStep);

    on<CompleteOcurrenciaFormStep>(_onCompleteFormStep);

    on<ResetOcurrenciaForm>(_onResetForm);
  }

  // *********************************************************
  // 1.- Crear ocurrencia
  // *********************************************************

  Future<void> _onCreateOcurrencia(
    CreateOcurrencia event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        createResponse: Loading<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );

    final response = await ocurrenciaUsesCases.createOcurrenciaUC.run(
      request: event.request,
    );

    emit(state.copyWith(createResponse: response));
  }

  // *********************************************************
  // 2.- Obtener ocurrencias paginadas
  // *********************************************************

  Future<void> _onGetOcurrenciasPaginado(
    GetOcurrenciasPaginado event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        paginatedResponse: Loading<ApiResponse<OcurrenciaPaginated>>(),
      ),
    );

    final response = await ocurrenciaUsesCases.getOcurrenciasPaginadoUC.run(
      params: event.params,
    );

    emit(state.copyWith(paginatedResponse: response));
  }

  // *********************************************************
  // 3.- Obtener ocurrencia por ID
  // *********************************************************

  Future<void> _onGetOcurrenciaById(
    GetOcurrenciaById event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        detailResponse: Loading<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );

    final response = await ocurrenciaUsesCases.getOcurrenciaByIdUC.run(
      ocurrenciaId: event.ocurrenciaId,
    );

    emit(state.copyWith(detailResponse: response));
  }

  // *********************************************************
  // 4.- Obtener PDF
  // *********************************************************

  Future<void> _onGetOcurrenciaPdf(
    GetOcurrenciaPdf event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(state.copyWith(pdfResponse: Loading<OcurrenciaPdfData>()));

    final response = await ocurrenciaUsesCases.getOcurrenciaPdfUC.run(
      ocurrenciaId: event.ocurrenciaId,
    );

    emit(state.copyWith(pdfResponse: response));
  }

  // *********************************************************
  // 5.- Obtener incidencias para el selector
  // *********************************************************

  Future<void> _onGetIncidenciasSelector(
    GetIncidenciasSelector event,
    Emitter<OcurrenciaState> emit,
  ) async {
    final params = event.params;

    final cargarDesdeInicio = params.page == 1 || event.refresh;

    /*
     * Evita dos cargas iniciales simultáneas.
     */
    if (cargarDesdeInicio && state.isLoadingIncidenciasSelector) {
      return;
    }

    /*
     * Evita cargar dos páginas adicionales simultáneamente.
     */
    if (!cargarDesdeInicio && state.isLoadingMoreIncidenciasSelector) {
      return;
    }

    emit(
      state.copyWith(
        incidenciasSelectorResponse: cargarDesdeInicio
            ? Loading<ApiResponse<IncidenciasSelectorPaginated>>()
            : state.incidenciasSelectorResponse,
        incidenciasSelectorParams: params,
        incidenciasSelectorPage: params.page,
        incidenciasSelectorLimit: params.limit,
        incidenciasSelectorHasMore: cargarDesdeInicio
            ? true
            : state.incidenciasSelectorHasMore,
        isLoadingMoreIncidenciasSelector: !cargarDesdeInicio,
      ),
    );

    try {
      final response = await ocurrenciaUsesCases.getIncidenciasSelectorUC.run(
        params: params,
      );

      if (response is Success<ApiResponse<IncidenciasSelectorPaginated>>) {
        final paginated = response.data.data;

        if (paginated == null) {
          emit(
            state.copyWith(
              incidenciasSelectorResponse:
                  ErrorData<ApiResponse<IncidenciasSelectorPaginated>>(
                    message:
                        'La respuesta no contiene incidencias disponibles.',
                  ),
              isLoadingMoreIncidenciasSelector: false,
            ),
          );

          return;
        }

        final pagination = paginated.pagination;

        final incidenciasActualizadas = cargarDesdeInicio
            ? paginated.items
            : _combinarIncidenciasSinDuplicados(
                state.incidenciasSelector,
                paginated.items,
              );

        emit(
          state.copyWith(
            incidenciasSelectorResponse: response,
            incidenciasSelector: incidenciasActualizadas,
            incidenciasSelectorParams: params,
            incidenciasSelectorPage: pagination.page,
            incidenciasSelectorLimit: pagination.limit,
            incidenciasSelectorTotalItems: pagination.totalItems,
            incidenciasSelectorTotalPages: pagination.totalPages,
            incidenciasSelectorHasMore: pagination.hasNextPage,
            isLoadingMoreIncidenciasSelector: false,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          incidenciasSelectorResponse: response,
          isLoadingMoreIncidenciasSelector: false,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          incidenciasSelectorResponse:
              ErrorData<ApiResponse<IncidenciasSelectorPaginated>>(
                message: 'No se pudieron obtener las incidencias disponibles.',
                error: error.toString(),
              ),
          isLoadingMoreIncidenciasSelector: false,
        ),
      );
    }
  }

  // *********************************************************
  // 6.- Cargar más incidencias del selector
  // *********************************************************

  Future<void> _onLoadMoreIncidenciasSelector(
    LoadMoreIncidenciasSelector event,
    Emitter<OcurrenciaState> emit,
  ) async {
    if (!state.canLoadMoreIncidenciasSelector) {
      return;
    }

    final currentParams = state.incidenciasSelectorParams;

    if (currentParams == null) {
      return;
    }

    final nextPage = state.incidenciasSelectorPage + 1;

    final nextParams = currentParams.copyWith(page: nextPage);

    await _onGetIncidenciasSelector(
      GetIncidenciasSelector(params: nextParams),
      emit,
    );
  }

  // *********************************************************
  // 7.- Seleccionar incidencia
  // *********************************************************

  void _onSelectIncidenciaOcurrencia(
    SelectIncidenciaOcurrencia event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(state.copyWith(selectedIncidencia: event.incidencia));
  }

  // *********************************************************
  // 8.- Limpiar incidencia seleccionada
  // *********************************************************

  void _onClearSelectedIncidencia(
    ClearSelectedIncidenciaOcurrencia event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(state.copyWith(clearSelectedIncidencia: true));
  }

  // *********************************************************
  // 9.- Remover incidencia del selector
  // *********************************************************

  void _onRemoveIncidenciaFromSelector(
    RemoveIncidenciaFromSelector event,
    Emitter<OcurrenciaState> emit,
  ) {
    final incidenciasActualizadas = state.incidenciasSelector
        .where((incidencia) => incidencia.id != event.incidenciaId)
        .toList(growable: false);

    final isSelected = state.selectedIncidencia?.id == event.incidenciaId;

    final totalItems = state.incidenciasSelectorTotalItems;

    emit(
      state.copyWith(
        incidenciasSelector: incidenciasActualizadas,
        incidenciasSelectorTotalItems: totalItems > 0 ? totalItems - 1 : 0,
        clearSelectedIncidencia: isSelected,
      ),
    );
  }

  // *********************************************************
  // 10.- Limpiar respuesta de creación
  // *********************************************************

  void _onClearCreateResponse(
    ClearOcurrenciaCreateResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(
      state.copyWith(
        createResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );
  }

  // *********************************************************
  // 11.- Limpiar detalle
  // *********************************************************

  void _onClearDetailResponse(
    ClearOcurrenciaDetailResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(
      state.copyWith(
        detailResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );
  }

  // *********************************************************
  // 12.- Limpiar PDF
  // *********************************************************

  void _onClearPdfResponse(
    ClearOcurrenciaPdfResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(state.copyWith(pdfResponse: Initial<OcurrenciaPdfData>()));
  }

  // *********************************************************
  // 13.- Limpiar paginado
  // *********************************************************

  void _onClearPaginatedResponse(
    ClearOcurrenciaPaginatedResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(
      state.copyWith(
        paginatedResponse: Initial<ApiResponse<OcurrenciaPaginated>>(),
      ),
    );
  }

  // *********************************************************
  // 14.- Limpiar selector de incidencias
  // *********************************************************

  void _onClearIncidenciasSelector(
    ClearIncidenciasSelector event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(
      state.copyWith(
        incidenciasSelectorResponse:
            Initial<ApiResponse<IncidenciasSelectorPaginated>>(),
        incidenciasSelector: const [],
        clearIncidenciasSelectorParams: true,
        incidenciasSelectorPage: 1,
        incidenciasSelectorLimit: 20,
        incidenciasSelectorTotalItems: 0,
        incidenciasSelectorTotalPages: 0,
        incidenciasSelectorHasMore: true,
        isLoadingMoreIncidenciasSelector: false,
        clearSelectedIncidencia: true,
      ),
    );
  }

  // *********************************************************
  // 15.- Limpiar error del selector
  // *********************************************************

  void _onClearIncidenciasSelectorError(
    ClearIncidenciasSelectorError event,
    Emitter<OcurrenciaState> emit,
  ) {
    if (state.incidenciasSelectorResponse
        is! ErrorData<ApiResponse<IncidenciasSelectorPaginated>>) {
      return;
    }

    emit(
      state.copyWith(
        incidenciasSelectorResponse:
            Initial<ApiResponse<IncidenciasSelectorPaginated>>(),
      ),
    );
  }

  // *********************************************************
  // 16.- Restablecer BLoC
  // *********************************************************

  void _onResetState(
    ResetOcurrenciaState event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(OcurrenciaState.initial());
  }

  // *********************************************************
  // 17.- Form Steps
  // *********************************************************

  void _onInitializeForm(
    InitializeOcurrenciaForm event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(state.copyWith(currentFormStep: 0, clearCompletedFormSteps: true));
  }

  void _onGoToFormStep(
    GoToOcurrenciaFormStep event,
    Emitter<OcurrenciaState> emit,
  ) {
    if (!state.canOpenFormStep(event.step)) {
      return;
    }

    emit(state.copyWith(currentFormStep: event.step));
  }

  void _onNextFormStep(
    NextOcurrenciaFormStep event,
    Emitter<OcurrenciaState> emit,
  ) {
    if (!state.canGoNextFormStep) {
      return;
    }

    emit(state.copyWith(currentFormStep: state.currentFormStep + 1));
  }

  void _onPreviousFormStep(
    PreviousOcurrenciaFormStep event,
    Emitter<OcurrenciaState> emit,
  ) {
    if (!state.canGoPreviousFormStep) {
      return;
    }

    emit(state.copyWith(currentFormStep: state.currentFormStep - 1));
  }

  void _onCompleteFormStep(
    CompleteOcurrenciaFormStep event,
    Emitter<OcurrenciaState> emit,
  ) {
    if (event.step < 0 || event.step >= state.totalFormSteps) {
      return;
    }

    final completed = {...state.completedFormSteps, event.step}.toList()
      ..sort();

    emit(state.copyWith(completedFormSteps: List.unmodifiable(completed)));
  }

  void _onResetForm(ResetOcurrenciaForm event, Emitter<OcurrenciaState> emit) {
    emit(state.copyWith(currentFormStep: 0, clearCompletedFormSteps: true));
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  /// Combina páginas sin repetir incidencias por ID.
  List<IncidenciaSelectorData> _combinarIncidenciasSinDuplicados(
    List<IncidenciaSelectorData> actuales,
    List<IncidenciaSelectorData> nuevas,
  ) {
    final incidenciasPorId = <int, IncidenciaSelectorData>{
      for (final incidencia in actuales) incidencia.id: incidencia,
    };

    for (final incidencia in nuevas) {
      incidenciasPorId[incidencia.id] = incidencia;
    }

    return List<IncidenciaSelectorData>.unmodifiable(incidenciasPorId.values);
  }
}
