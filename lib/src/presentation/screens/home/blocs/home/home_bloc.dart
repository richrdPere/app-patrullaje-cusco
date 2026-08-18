import 'dart:async';

import 'package:bloc/bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';

import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  final PatrullajeUseCases patrullajeUseCases;

  StreamSubscription? _nuevoPatrullajeSub;
  StreamSubscription? _actualizadoSub;

  HomeBloc(this.patrullajeUseCases) : super(const HomeState()) {
    // ========================================================
    // HTTP
    // ========================================================
    on<LoadPatrullajeActivo>(_onLoadPatrullajeActivo);
    on<LoadMisPatrullajes>(_onLoadMisPatrullajes);
    on<RefreshMisPatrullajes>(_onRefreshMisPatrullajes);
    on<LimpiarFiltrosMisPatrullajes>(_onLimpiarFiltrosMisPatrullajes);

    // ========================================================
    // SOCKET
    // ========================================================
    on<InitSocketListeners>(_onInitSocketListeners);
    on<NuevoPatrullajeRecibido>(_onNuevoPatrullaje);
    on<PatrullajeActualizadoRecibido>(_onPatrullajeActualizado);

    // ========================================================
    // USER
    // ========================================================
    on<AceptarPatrullaje>(_onAceptarPatrullaje);
    on<FinalizarPatrullaje>(_onFinalizarPatrullaje);
    on<LimpiarPatrullajeFinalizado>(_onLimpiarPatrullajeFinalizado);
  }

  // ==========================================================
  // 1. INICIALIZAR SOCKET LISTENERS
  // ==========================================================
  Future<void> _onInitSocketListeners(
    InitSocketListeners event,
    Emitter<HomeState> emit,
  ) async {
    await _nuevoPatrullajeSub?.cancel();
    await _actualizadoSub?.cancel();

    // Nuevo patrullaje
    _nuevoPatrullajeSub = patrullajeUseCases.listenNewPatrullaje.run().listen((
      patrullaje,
    ) {
      add(NuevoPatrullajeRecibido(patrullaje));
    });

    // Patrullaje actualizado
    _actualizadoSub = patrullajeUseCases.listenPatrullajeActualizado
        .run()
        .listen((patrullaje) {
          add(PatrullajeActualizadoRecibido(patrullaje));
        });
  }

  // ==========================================================
  // 2. OBTENER PATRULLAJE ACTIVO
  // ==========================================================
  Future<void> _onLoadPatrullajeActivo(
    LoadPatrullajeActivo event,
    Emitter<HomeState> emit,
  ) async {
    emit(state.copyWith(isLoading: true, clearError: true));

    final response = await patrullajeUseCases.getPatrullajeActivo.run();

    if (response is Success<PatrullajeData?>) {
      final patrullaje = response.data;

      if (patrullaje == null) {
        emit(
          state.copyWith(
            isLoading: false,
            clearPatrullaje: true,
            clearError: true,
            status: PatrullajeStatus.sinAsignacion,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          patrullaje: patrullaje,
          clearError: true,
          status: mapEstado(patrullaje.estado),
        ),
      );

      return;
    }

    if (response is ErrorData<PatrullajeData?>) {
      emit(
        state.copyWith(
          isLoading: false,
          clearPatrullaje: true,
          error: response.fullMessage,
          status: PatrullajeStatus.error,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        isLoading: false,
        clearPatrullaje: true,
        error: 'Respuesta desconocida al obtener el patrullaje activo.',
        status: PatrullajeStatus.error,
      ),
    );
  }

  // ==========================================================
  // 3. OBTENER MIS PATRULLAJES PAGINADOS
  // ==========================================================
  Future<void> _onLoadMisPatrullajes(
    LoadMisPatrullajes event,
    Emitter<HomeState> emit,
  ) async {
    await _getMisPatrullajes(params: event.params, emit: emit);
  }

  Future<void> _getMisPatrullajes({
    required PatrullajeSerenoQueryParams params,
    required Emitter<HomeState> emit,
  }) async {
    emit(
      state.copyWith(
        isLoadingMisPatrullajes: true,
        misPatrullajesParams: params,
        clearMisPatrullajesError: true,
      ),
    );

    try {
      final response = await patrullajeUseCases.getMisPatrullajesPaginados.run(
        params: params,
      );

      if (response is Success<ApiResponse<PatrullajeSerenoPaginated>>) {
        final apiResponse = response.data;
        final paginated = apiResponse.data;

        emit(
          state.copyWith(
            isLoadingMisPatrullajes: false,
            misPatrullajes: paginated,
            misPatrullajesParams: params,
            clearMisPatrullajesError: true,
          ),
        );

        return;
      }

      if (response is ErrorData<ApiResponse<PatrullajeSerenoPaginated>>) {
        emit(
          state.copyWith(
            isLoadingMisPatrullajes: false,
            misPatrullajesParams: params,
            misPatrullajesError: response.fullMessage,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          isLoadingMisPatrullajes: false,
          misPatrullajesParams: params,
          misPatrullajesError:
              'Respuesta desconocida al obtener los patrullajes.',
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoadingMisPatrullajes: false,
          misPatrullajesParams: params,
          misPatrullajesError:
              'Ocurrió un error al obtener los patrullajes: $error',
        ),
      );
    }
  }

  // ==========================================================
  // 4. REFRESCAR MIS PATRULLAJES
  // ==========================================================
  Future<void> _onRefreshMisPatrullajes(
    RefreshMisPatrullajes event,
    Emitter<HomeState> emit,
  ) async {
    final params = state.misPatrullajesParams.copyWith(page: 1);

    await _getMisPatrullajes(params: params, emit: emit);
  }

  // ==========================================================
  // 5. LIMPIAR FILTROS
  // ==========================================================
  Future<void> _onLimpiarFiltrosMisPatrullajes(
    LimpiarFiltrosMisPatrullajes event,
    Emitter<HomeState> emit,
  ) async {
    const params = PatrullajeSerenoQueryParams(
      page: 1,
      limit: 10,
      orderBy: PatrullajeOrderBy.fecha,
      orderDirection: OrderDirection.desc,
    );

    emit(
      state.copyWith(
        clearMisPatrullajes: true,
        clearMisPatrullajesError: true,
        misPatrullajesParams: params,
      ),
    );

    await _getMisPatrullajes(params: params, emit: emit);
  }

  // ==========================================================
  // 6. NUEVO PATRULLAJE POR SOCKET
  // ==========================================================
  void _onNuevoPatrullaje(
    NuevoPatrullajeRecibido event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        patrullaje: event.patrullaje,
        status: mapEstado(event.patrullaje.estado),
        isLoading: false,
        clearError: true,
      ),
    );
  }

  // ==========================================================
  // 7. PATRULLAJE ACTUALIZADO POR SOCKET
  // ==========================================================
  void _onPatrullajeActualizado(
    PatrullajeActualizadoRecibido event,
    Emitter<HomeState> emit,
  ) {
    final nuevoEstado = mapEstado(event.patrullaje.estado);

    if (nuevoEstado == PatrullajeStatus.finalizado) {
      emit(
        state.copyWith(
          clearPatrullaje: true,
          status: PatrullajeStatus.finalizado,
          isLoading: false,
          clearError: true,
        ),
      );

      // Actualizamos la primera página del historial.
      add(
        LoadMisPatrullajes(
          params: state.misPatrullajesParams.copyWith(page: 1),
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        patrullaje: event.patrullaje,
        status: nuevoEstado,
        isLoading: false,
        clearError: true,
      ),
    );
  }

  // ==========================================================
  // 8. ACEPTAR PATRULLAJE
  // ==========================================================
  void _onAceptarPatrullaje(AceptarPatrullaje event, Emitter<HomeState> emit) {
    if (state.isLoading) return;

    emit(
      state.copyWith(
        isLoading: true,
        status: PatrullajeStatus.aceptando,
        clearError: true,
      ),
    );

    patrullajeUseCases.startPatrullajeSocket.run(event.patrullajeId);

    patrullajeUseCases.joinPatrullaje.run(event.patrullajeId);
  }

  // ==========================================================
  // 9. FINALIZAR PATRULLAJE
  // ==========================================================
  Future<void> _onFinalizarPatrullaje(
    FinalizarPatrullaje event,
    Emitter<HomeState> emit,
  ) async {
    if (state.isLoading) return;

    emit(state.copyWith(isLoading: true, clearError: true));

    try {
      final observacionFinal = event.observacionFinal?.trim();

      final response = await patrullajeUseCases.endPatrullaje.run(
        patrullajeId: event.patrullajeId,
        observacionFinal: observacionFinal == null || observacionFinal.isEmpty
            ? null
            : observacionFinal,
      );

      if (response is Success<PatrullajeData>) {
        final patrullajeFinalizado = response.data;

        emit(
          state.copyWith(
            isLoading: false,
            patrullaje: patrullajeFinalizado,
            status: PatrullajeStatus.finalizado,
            clearError: true,
          ),
        );

        // Se vuelve a cargar la primera página
        // porque el registro finalizado debe aparecer
        // al inicio del historial.
        add(
          LoadMisPatrullajes(
            params: state.misPatrullajesParams.copyWith(page: 1),
          ),
        );

        return;
      }

      if (response is ErrorData<PatrullajeData>) {
        emit(
          state.copyWith(
            isLoading: false,
            error: response.fullMessage,
            status: PatrullajeStatus.error,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          isLoading: false,
          error: 'Respuesta desconocida al finalizar el patrullaje.',
          status: PatrullajeStatus.error,
        ),
      );
    } catch (error) {
      emit(
        state.copyWith(
          isLoading: false,
          error: 'Ocurrió un error al finalizar el patrullaje: $error',
          status: PatrullajeStatus.error,
        ),
      );
    }
  }

  // ==========================================================
  // 10. LIMPIAR PATRULLAJE FINALIZADO
  // ==========================================================
  void _onLimpiarPatrullajeFinalizado(
    LimpiarPatrullajeFinalizado event,
    Emitter<HomeState> emit,
  ) {
    emit(
      state.copyWith(
        clearPatrullaje: true,
        clearError: true,
        isLoading: false,
        status: PatrullajeStatus.sinAsignacion,
      ),
    );
  }

  // ==========================================================
  // MAPEAR ESTADO
  // ==========================================================
  PatrullajeStatus mapEstado(String estado) {
    switch (estado) {
      case 'ASIGNADO':
        return PatrullajeStatus.asignado;

      case 'ACEPTADO':
        return PatrullajeStatus.aceptando;

      case 'EN_CURSO':
        return PatrullajeStatus.enCurso;

      case 'FINALIZADO':
        return PatrullajeStatus.finalizado;

      default:
        return PatrullajeStatus.sinAsignacion;
    }
  }

  // ==========================================================
  // CLEANUP
  // ==========================================================
  @override
  Future<void> close() async {
    await _nuevoPatrullajeSub?.cancel();
    await _actualizadoSub?.cancel();

    return super.close();
  }
}
