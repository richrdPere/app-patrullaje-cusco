import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_resumen_model.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Use cases
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

class AlertaBloc extends Bloc<AlertaEvent, AlertaState> {
  final AlertaNotificacionUsesCases alertaUsesCases;

  AlertaBloc(this.alertaUsesCases) : super(const AlertaState()) {
    on<GetMisAlertasEvent>(_onGetMisAlertas);
    on<RefreshMisAlertasEvent>(_onRefreshMisAlertas);
    on<LoadMoreAlertasEvent>(_onLoadMoreAlertas);
    on<FiltrarAlertasEvent>(_onFiltrarAlertas);
    on<LimpiarFiltrosAlertasEvent>(_onLimpiarFiltros);

    on<GetMisAlertasResumenEvent>(_onGetMisAlertasResumen);

    on<MarcarAlertaRecibidaEvent>(_onMarcarRecibida);
    on<MarcarAlertaLeidaEvent>(_onMarcarLeida);
    on<ResponderAlertaEvent>(_onResponderAlerta);
    on<MarcarAlertaAtendidaEvent>(_onMarcarAtendida);

    on<AlertaRemotaRecibidaEvent>(_onAlertaRemotaRecibida);
    on<ActualizarAlertaLocalEvent>(_onActualizarAlertaLocal);
    on<EliminarAlertaLocalEvent>(_onEliminarAlertaLocal);

    on<SeleccionarAlertaEvent>(_onSeleccionarAlerta);
    on<LimpiarAlertaSeleccionadaEvent>(_onLimpiarAlertaSeleccionada);

    on<ClearAlertaActionResponseEvent>(_onClearActionResponse);
    on<ResetAlertaEvent>(_onReset);

    on<NuevaAlertaRecibidaEvent>(_onNuevaAlertaRecibida);
    on<MarcarAlertasComoLeidasEvent>(_onMarcarAlertasComoLeidas);
    on<EstablecerAlertasNoLeidasEvent>(_onEstablecerAlertasNoLeidas);
  }

  // ============================================================
  // 1. OBTENER MIS ALERTAS
  // ============================================================
  Future<void> _onGetMisAlertas(
    GetMisAlertasEvent event,
    Emitter<AlertaState> emit,
  ) async {
    final isReset = event.reset || event.page == 1;

    emit(
      state.copyWith(
        listStatus: isReset
            ? AlertaListStatus.loading
            : AlertaListStatus.loadingMore,
        clearErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.getMisAlertas.run(
      page: event.page,
      limit: event.limit,
      estado: event.estado,
      tipo: event.tipo,
      prioridad: event.prioridad,
      requiereConfirmacion: event.requiereConfirmacion,
    );

    if (response is Success<AlertaPaginated>) {
      final data = response.data;

      final nuevasAlertas = data.alertas;

      final alertasFinales = isReset
          ? nuevasAlertas
          : _combinarSinDuplicados(state.alertas, nuevasAlertas);

      emit(
        state.copyWith(
          listStatus: alertasFinales.isEmpty
              ? AlertaListStatus.empty
              : AlertaListStatus.success,
          alertas: alertasFinales,
          page: data.page,
          limit: data.limit,
          total: data.total,
          totalPages: data.totalPages,
          hasNextPage: data.hasNextPage,
          hasPreviousPage: data.hasPreviousPage,
          filtroEstado: event.estado,
          clearFiltroEstado: event.estado == null,
          filtroTipo: event.tipo,
          clearFiltroTipo: event.tipo == null,
          filtroPrioridad: event.prioridad,
          clearFiltroPrioridad: event.prioridad == null,
          filtroRequiereConfirmacion: event.requiereConfirmacion,
          clearFiltroRequiereConfirmacion: event.requiereConfirmacion == null,
          clearErrorMessage: true,
        ),
      );

      return;
    }

    if (response is ErrorData<AlertaPaginated>) {
      emit(
        state.copyWith(
          listStatus: state.alertas.isEmpty
              ? AlertaListStatus.error
              : AlertaListStatus.success,
          errorMessage: response.message,
        ),
      );
    }
  }

  // ============================================================
  // 2. REFRESCAR MIS ALERTAS
  // ============================================================
  Future<void> _onRefreshMisAlertas(
    RefreshMisAlertasEvent event,
    Emitter<AlertaState> emit,
  ) async {
    final response = await alertaUsesCases.getMisAlertas.run(
      page: 1,
      limit: state.limit,
      estado: state.filtroEstado,
      tipo: state.filtroTipo,
      prioridad: state.filtroPrioridad,
      requiereConfirmacion: state.filtroRequiereConfirmacion,
    );

    if (response is Success<AlertaPaginated>) {
      final data = response.data;

      emit(
        state.copyWith(
          listStatus: data.alertas.isEmpty
              ? AlertaListStatus.empty
              : AlertaListStatus.success,
          alertas: data.alertas,
          page: data.page,
          limit: data.limit,
          total: data.total,
          totalPages: data.totalPages,
          hasNextPage: data.hasNextPage,
          hasPreviousPage: data.hasPreviousPage,
          clearErrorMessage: true,
        ),
      );

      add(const GetMisAlertasResumenEvent());

      return;
    }

    if (response is ErrorData<AlertaPaginated>) {
      emit(
        state.copyWith(
          listStatus: state.alertas.isEmpty
              ? AlertaListStatus.error
              : AlertaListStatus.success,
          errorMessage: response.message,
        ),
      );
    }
  }

  // ============================================================
  // 3. CARGAR MÁS ALERTAS
  // ============================================================
  Future<void> _onLoadMoreAlertas(
    LoadMoreAlertasEvent event,
    Emitter<AlertaState> emit,
  ) async {
    if (!state.hasNextPage ||
        state.listStatus == AlertaListStatus.loading ||
        state.listStatus == AlertaListStatus.loadingMore) {
      return;
    }

    add(
      GetMisAlertasEvent(
        page: state.page + 1,
        limit: state.limit,
        estado: state.filtroEstado,
        tipo: state.filtroTipo,
        prioridad: state.filtroPrioridad,
        requiereConfirmacion: state.filtroRequiereConfirmacion,
        reset: false,
      ),
    );
  }

  // ============================================================
  // 4. FILTRAR ALERTAS
  // ============================================================
  Future<void> _onFiltrarAlertas(
    FiltrarAlertasEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        filtroEstado: event.estado,
        clearFiltroEstado: event.estado == null,
        filtroTipo: event.tipo,
        clearFiltroTipo: event.tipo == null,
        filtroPrioridad: event.prioridad,
        clearFiltroPrioridad: event.prioridad == null,
        filtroRequiereConfirmacion: event.requiereConfirmacion,
        clearFiltroRequiereConfirmacion: event.requiereConfirmacion == null,
      ),
    );

    add(
      GetMisAlertasEvent(
        page: 1,
        limit: state.limit,
        estado: event.estado,
        tipo: event.tipo,
        prioridad: event.prioridad,
        requiereConfirmacion: event.requiereConfirmacion,
        reset: true,
      ),
    );
  }

  // ============================================================
  // 5. LIMPIAR FILTROS
  // ============================================================
  Future<void> _onLimpiarFiltros(
    LimpiarFiltrosAlertasEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        clearFiltroEstado: true,
        clearFiltroTipo: true,
        clearFiltroPrioridad: true,
        clearFiltroRequiereConfirmacion: true,
      ),
    );

    add(GetMisAlertasEvent(page: 1, limit: state.limit, reset: true));
  }

  // ============================================================
  // 6. OBTENER RESUMEN
  // ============================================================
  Future<void> _onGetMisAlertasResumen(
    GetMisAlertasResumenEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        resumenStatus: AlertaResumenStatus.loading,
        clearErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.getMisAlertasResumen.run();

    if (response is Success<AlertaResumenModel>) {
      final resumen = response.data;

      debugPrint('🔔 Alertas no leídas recibidas: ${resumen.noLeidas}');

      emit(
        state.copyWith(
          resumenStatus: AlertaResumenStatus.success,
          resumen: resumen,

          // Cantidad que utiliza el badge
          alertasNoLeidas: resumen.noLeidas,

          clearErrorMessage: true,
        ),
      );

      return;
    }

    if (response is ErrorData<AlertaResumenModel>) {
      emit(
        state.copyWith(
          resumenStatus: AlertaResumenStatus.error,
          errorMessage: response.message,
        ),
      );
    }
  }

  // ============================================================
  // 7. MARCAR COMO RECIBIDA
  // ============================================================
  Future<void> _onMarcarRecibida(
    MarcarAlertaRecibidaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.loading,
        actionType: AlertaActionType.marcarRecibida,
        clearActionMessage: true,
        clearErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.marcarRecibida.run(
      alertaId: event.alertaId,
    );

    if (response is Success<AlertaDestinatarioModel>) {
      final actualizado = response.data;

      emit(
        state.copyWith(
          actionStatus: AlertaActionStatus.success,
          actionType: AlertaActionType.marcarRecibida,
          actionMessage: 'Alerta marcada como recibida.',
          alertas: _actualizarEnLista(actualizado),
          alertaSelected: _actualizarSeleccionada(actualizado),
          clearErrorMessage: true,
        ),
      );

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, AlertaActionType.marcarRecibida);
  }

  // ============================================================
  // 8. MARCAR COMO LEÍDA
  // ============================================================
  Future<void> _onMarcarLeida(
    MarcarAlertaLeidaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.loading,
        actionType: AlertaActionType.marcarLeida,
        clearActionMessage: true,
        clearErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.marcarLeida.run(
      alertaId: event.alertaId,
    );

    if (response is Success<AlertaDestinatarioModel>) {
      final actualizado = response.data;

      emit(
        state.copyWith(
          actionStatus: AlertaActionStatus.success,
          actionType: AlertaActionType.marcarLeida,
          actionMessage: 'Alerta marcada como leída.',
          alertas: _actualizarEnLista(actualizado),
          alertaSelected: _actualizarSeleccionada(actualizado),
          clearErrorMessage: true,
        ),
      );

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, AlertaActionType.marcarLeida);
  }

  // ============================================================
  // 9. RESPONDER ALERTA
  // ============================================================
  Future<void> _onResponderAlerta(
    ResponderAlertaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    final respuestaNormalizada = event.respuesta.trim().toUpperCase();

    final actionType = respuestaNormalizada == 'ACEPTADA'
        ? AlertaActionType.aceptar
        : AlertaActionType.rechazar;

    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.loading,
        actionType: actionType,
        clearActionMessage: true,
        clearErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.responderAlerta.run(
      alertaId: event.alertaId,
      respuesta: respuestaNormalizada,
      observacion: event.observacion,
    );

    if (response is Success<AlertaDestinatarioModel>) {
      final actualizado = response.data;

      emit(
        state.copyWith(
          actionStatus: AlertaActionStatus.success,
          actionType: actionType,
          actionMessage: respuestaNormalizada == 'ACEPTADA'
              ? 'Alerta aceptada correctamente.'
              : 'Alerta rechazada correctamente.',
          alertas: _actualizarEnLista(actualizado),
          alertaSelected: _actualizarSeleccionada(actualizado),
          clearErrorMessage: true,
        ),
      );

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, actionType);
  }

  // ============================================================
  // 10. MARCAR COMO ATENDIDA
  // ============================================================
  Future<void> _onMarcarAtendida(
    MarcarAlertaAtendidaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.loading,
        actionType: AlertaActionType.marcarAtendida,
        clearActionMessage: true,
        clearErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.marcarAtendida.run(
      alertaId: event.alertaId,
      observacion: event.observacion,
    );

    if (response is Success<AlertaDestinatarioModel>) {
      final actualizado = response.data;

      emit(
        state.copyWith(
          actionStatus: AlertaActionStatus.success,
          actionType: AlertaActionType.marcarAtendida,
          actionMessage: 'Alerta marcada como atendida.',
          alertas: _actualizarEnLista(actualizado),
          alertaSelected: _actualizarSeleccionada(actualizado),
          clearErrorMessage: true,
        ),
      );

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, AlertaActionType.marcarAtendida);
  }

  // ============================================================
  // 11. ALERTA REMOTA RECIBIDA
  // ============================================================
  void _onAlertaRemotaRecibida(
    AlertaRemotaRecibidaEvent event,
    Emitter<AlertaState> emit,
  ) {
    final alertaNueva = event.alerta;

    final index = state.alertas.indexWhere(
      (item) => item.alertaId == alertaNueva.alertaId,
    );

    final List<AlertaDestinatarioModel> actualizadas;

    if (index >= 0) {
      actualizadas = List<AlertaDestinatarioModel>.from(state.alertas);

      actualizadas[index] = alertaNueva;
    } else {
      actualizadas = [alertaNueva, ...state.alertas];
    }

    emit(
      state.copyWith(
        listStatus: AlertaListStatus.success,
        alertas: actualizadas,
        ultimaAlertaRecibida: alertaNueva,
        total: index >= 0 ? state.total : state.total + 1,
      ),
    );

    add(const GetMisAlertasResumenEvent());

    /*
     * Al recibirla por Socket o Firebase, se puede informar al
     * backend que llegó al dispositivo.
     *
     * Evitamos repetirlo si ya tiene un estado posterior.
     */
    if (alertaNueva.estado == 'PENDIENTE') {
      add(MarcarAlertaRecibidaEvent(alertaId: alertaNueva.alertaId));
    }
  }

  // ============================================================
  // 12. ACTUALIZAR ALERTA LOCAL
  // ============================================================
  void _onActualizarAlertaLocal(
    ActualizarAlertaLocalEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(
      state.copyWith(
        alertas: _actualizarEnLista(event.alerta),
        alertaSelected: _actualizarSeleccionada(event.alerta),
      ),
    );
  }

  // ============================================================
  // 13. ELIMINAR ALERTA LOCAL
  // ============================================================
  void _onEliminarAlertaLocal(
    EliminarAlertaLocalEvent event,
    Emitter<AlertaState> emit,
  ) {
    final alertasActualizadas = state.alertas
        .where((item) => item.alertaId != event.alertaId)
        .toList();

    final selected = state.alertaSelected?.alertaId == event.alertaId
        ? null
        : state.alertaSelected;

    emit(
      state.copyWith(
        listStatus: alertasActualizadas.isEmpty
            ? AlertaListStatus.empty
            : AlertaListStatus.success,
        alertas: alertasActualizadas,
        total: state.total > 0 ? state.total - 1 : 0,
        alertaSelected: selected,
        clearAlertaSelected: selected == null,
      ),
    );
  }

  // ============================================================
  // 14. SELECCIONAR ALERTA
  // ============================================================
  void _onSeleccionarAlerta(
    SeleccionarAlertaEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(state.copyWith(alertaSelected: event.alerta));

    if (!event.alerta.fueLeida) {
      add(MarcarAlertaLeidaEvent(alertaId: event.alerta.alertaId));
    }
  }

  // ============================================================
  // 15. LIMPIAR SELECCIÓN
  // ============================================================
  void _onLimpiarAlertaSeleccionada(
    LimpiarAlertaSeleccionadaEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(state.copyWith(clearAlertaSelected: true));
  }

  // ============================================================
  // 16. LIMPIAR RESPUESTA
  // ============================================================
  void _onClearActionResponse(
    ClearAlertaActionResponseEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.initial,
        actionType: AlertaActionType.none,
        clearActionMessage: true,
        clearErrorMessage: true,
        clearUltimaAlertaRecibida: true,
      ),
    );
  }

  // ============================================================
  // 17. RESET
  // ============================================================
  void _onReset(ResetAlertaEvent event, Emitter<AlertaState> emit) {
    emit(const AlertaState());
  }

  // ============================================================
  // 18. CANTIDAD DE ALERTAS RECIBIDAS
  // ============================================================
  void _onNuevaAlertaRecibida(
    NuevaAlertaRecibidaEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(state.copyWith(alertasNoLeidas: state.alertasNoLeidas + 1));
  }

  void _onMarcarAlertasComoLeidas(
    MarcarAlertasComoLeidasEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(state.copyWith(alertasNoLeidas: 0));
  }

  void _onEstablecerAlertasNoLeidas(
    EstablecerAlertasNoLeidasEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(state.copyWith(alertasNoLeidas: event.cantidad));
  }

  // ============================================================
  // HELPERS
  // ============================================================
  List<AlertaDestinatarioModel> _combinarSinDuplicados(
    List<AlertaDestinatarioModel> actuales,
    List<AlertaDestinatarioModel> nuevas,
  ) {
    final mapa = <int, AlertaDestinatarioModel>{};

    for (final item in actuales) {
      mapa[item.alertaId] = item;
    }

    for (final item in nuevas) {
      mapa[item.alertaId] = item;
    }

    return mapa.values.toList();
  }

  List<AlertaDestinatarioModel> _actualizarEnLista(
    AlertaDestinatarioModel alertaActualizada,
  ) {
    final index = state.alertas.indexWhere(
      (item) => item.alertaId == alertaActualizada.alertaId,
    );

    if (index < 0) {
      return [alertaActualizada, ...state.alertas];
    }

    final copia = List<AlertaDestinatarioModel>.from(state.alertas);

    copia[index] = alertaActualizada;

    return copia;
  }

  AlertaDestinatarioModel? _actualizarSeleccionada(
    AlertaDestinatarioModel alertaActualizada,
  ) {
    if (state.alertaSelected?.alertaId == alertaActualizada.alertaId) {
      return alertaActualizada;
    }

    return state.alertaSelected;
  }

  void _emitActionError(
    Emitter<AlertaState> emit,
    Resource<dynamic> response,
    AlertaActionType actionType,
  ) {
    if (response is ErrorData) {
      emit(
        state.copyWith(
          actionStatus: AlertaActionStatus.error,
          actionType: actionType,
          actionMessage: response.message,
          errorMessage: response.message,
        ),
      );

      return;
    }

    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.error,
        actionType: actionType,
        actionMessage: 'No se pudo completar la operación.',
        errorMessage: 'No se pudo completar la operación.',
      ),
    );
  }
}
