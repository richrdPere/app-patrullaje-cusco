import 'package:flutter_bloc/flutter_bloc.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

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
    // Listado
    on<GetMisAlertasEvent>(_onGetMisAlertas);
    on<RefreshMisAlertasEvent>(_onRefreshMisAlertas);
    on<LoadMoreAlertasEvent>(_onLoadMoreAlertas);
    on<FiltrarAlertasEvent>(_onFiltrarAlertas);
    on<LimpiarFiltrosAlertasEvent>(_onLimpiarFiltros);

    // Resumen
    on<GetMisAlertasResumenEvent>(_onGetMisAlertasResumen);

    // Acciones del destinatario
    on<MarcarAlertaRecibidaEvent>(_onMarcarRecibida);
    on<MarcarAlertaLeidaEvent>(_onMarcarLeida);
    on<ResponderAlertaEvent>(_onResponderAlerta);
    on<MarcarAlertaAtendidaEvent>(_onMarcarAtendida);

    // Botón de alerta
    on<ActivarAlertaEvent>(_onActivarAlerta);
    on<GetAlertaActivaEvent>(_onGetAlertaActiva);
    on<CancelarAlertaEvent>(_onCancelarAlerta);
    on<LimpiarAlertaActivaEvent>(_onLimpiarAlertaActiva);

    // Detalle
    on<GetAlertaDetalleEvent>(_onGetAlertaDetalle);
    on<LimpiarAlertaDetalleEvent>(_onLimpiarAlertaDetalle);

    // Actualizaciones locales, Socket y FCM
    on<AlertaRemotaRecibidaEvent>(_onAlertaRemotaRecibida);
    on<ActualizarAlertaLocalEvent>(_onActualizarAlertaLocal);
    on<EliminarAlertaLocalEvent>(_onEliminarAlertaLocal);

    // Selección
    on<SeleccionarAlertaEvent>(_onSeleccionarAlerta);
    on<LimpiarAlertaSeleccionadaEvent>(_onLimpiarAlertaSeleccionada);

    // Respuestas y reset
    on<ClearAlertaActionResponseEvent>(_onClearActionResponse);
    on<ResetAlertaEvent>(_onReset);

    // Contador
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
        clearListErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.getMisAlertas.run(
      params: event.params,
    );

    if (response is Success<ApiResponse<MisAlertasPaginated>>) {
      final apiResponse = response.data;
      final data = apiResponse.data;

      if (data == null) {
        emit(
          state.copyWith(
            listStatus: state.alertas.isEmpty
                ? AlertaListStatus.error
                : AlertaListStatus.success,
            listErrorMessage: apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'El servidor no devolvió las alertas.',
          ),
        );

        return;
      }

      final nuevasAlertas = data.items;

      final alertasFinales = isReset
          ? nuevasAlertas
          : _combinarSinDuplicados(state.alertas, nuevasAlertas);

      final pagination = data.pagination;

      emit(
        state.copyWith(
          listStatus: alertasFinales.isEmpty
              ? AlertaListStatus.empty
              : AlertaListStatus.success,
          alertas: alertasFinales,
          alertasNoLeidas: data.noLeidas,
          page: pagination.page,
          limit: pagination.limit,
          total: pagination.total,
          totalPages: pagination.totalPages,
          hasNextPage: pagination.hasNextPage,
          hasPreviousPage: pagination.hasPreviousPage,
          filtroEstado: event.estado,
          clearFiltroEstado: event.estado == null,
          filtroTipo: event.tipo,
          clearFiltroTipo: event.tipo == null,
          filtroPrioridad: event.prioridad,
          clearFiltroPrioridad: event.prioridad == null,
          filtroNoLeidas: event.noLeidas,
          clearFiltroNoLeidas: event.noLeidas == null,
          clearListErrorMessage: true,
        ),
      );

      return;
    }

    _emitListError(emit, response);
  }

  // ============================================================
  // 2. REFRESCAR MIS ALERTAS
  // ============================================================

  Future<void> _onRefreshMisAlertas(
    RefreshMisAlertasEvent event,
    Emitter<AlertaState> emit,
  ) async {
    final params = MisAlertasQueryParams(
      page: 1,
      limit: state.limit,
      estado: state.filtroEstado,
      tipo: state.filtroTipo,
      prioridad: state.filtroPrioridad,
      noLeidas: state.filtroNoLeidas,
    );

    final response = await alertaUsesCases.getMisAlertas.run(params: params);

    if (response is Success<ApiResponse<MisAlertasPaginated>>) {
      final apiResponse = response.data;
      final data = apiResponse.data;

      if (data == null) {
        emit(
          state.copyWith(
            listStatus: state.alertas.isEmpty
                ? AlertaListStatus.error
                : AlertaListStatus.success,
            listErrorMessage: apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'El servidor no devolvió las alertas.',
          ),
        );

        return;
      }

      final pagination = data.pagination;

      emit(
        state.copyWith(
          listStatus: data.items.isEmpty
              ? AlertaListStatus.empty
              : AlertaListStatus.success,
          alertas: data.items,
          alertasNoLeidas: data.noLeidas,
          page: pagination.page,
          limit: pagination.limit,
          total: pagination.total,
          totalPages: pagination.totalPages,
          hasNextPage: pagination.hasNextPage,
          hasPreviousPage: pagination.hasPreviousPage,
          clearListErrorMessage: true,
        ),
      );

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitListError(emit, response);
  }

  // ============================================================
  // 3. CARGAR MÁS ALERTAS
  // ============================================================

  void _onLoadMoreAlertas(
    LoadMoreAlertasEvent event,
    Emitter<AlertaState> emit,
  ) {
    if (!state.puedeCargarMas) {
      return;
    }

    add(
      GetMisAlertasEvent(
        page: state.page + 1,
        limit: state.limit,
        estado: state.filtroEstado,
        tipo: state.filtroTipo,
        prioridad: state.filtroPrioridad,
        noLeidas: state.filtroNoLeidas,
        reset: false,
      ),
    );
  }

  // ============================================================
  // 4. FILTRAR ALERTAS
  // ============================================================

  void _onFiltrarAlertas(FiltrarAlertasEvent event, Emitter<AlertaState> emit) {
    emit(
      state.copyWith(
        filtroEstado: event.estado,
        clearFiltroEstado: event.estado == null,
        filtroTipo: event.tipo,
        clearFiltroTipo: event.tipo == null,
        filtroPrioridad: event.prioridad,
        clearFiltroPrioridad: event.prioridad == null,
        filtroNoLeidas: event.noLeidas,
        clearFiltroNoLeidas: event.noLeidas == null,
      ),
    );

    add(
      GetMisAlertasEvent(
        page: 1,
        limit: state.limit,
        estado: event.estado,
        tipo: event.tipo,
        prioridad: event.prioridad,
        noLeidas: event.noLeidas,
        reset: true,
      ),
    );
  }

  // ============================================================
  // 5. LIMPIAR FILTROS
  // ============================================================

  void _onLimpiarFiltros(
    LimpiarFiltrosAlertasEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(
      state.copyWith(
        clearFiltroEstado: true,
        clearFiltroTipo: true,
        clearFiltroPrioridad: true,
        clearFiltroNoLeidas: true,
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
        clearResumenErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.getMisAlertasResumen.run();

    if (response is Success<ApiResponse<MisAlertasResumenData>>) {
      final apiResponse = response.data;
      final resumen = apiResponse.data;

      if (resumen == null) {
        emit(
          state.copyWith(
            resumenStatus: AlertaResumenStatus.error,
            resumenErrorMessage: apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'El servidor no devolvió el resumen.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          resumenStatus: AlertaResumenStatus.success,
          resumen: resumen,
          alertasNoLeidas: resumen.noLeidas,
          clearResumenErrorMessage: true,
        ),
      );

      return;
    }

    _emitResumenError(emit, response);
  }

  // ============================================================
  // 7. MARCAR ALERTA COMO RECIBIDA
  // ============================================================

  Future<void> _onMarcarRecibida(
    MarcarAlertaRecibidaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    _emitActionLoading(emit, AlertaActionType.marcarRecibida);

    final response = await alertaUsesCases.marcarRecibida.run(
      alertaId: event.alertaId,
    );

    if (response is Success<ApiResponse<AlertaUsuarioEstadoData>>) {
      final apiResponse = response.data;
      final actualizado = apiResponse.data;

      if (actualizado == null) {
        _emitActionDataMissing(
          emit,
          AlertaActionType.marcarRecibida,
          apiResponse.message,
        );

        return;
      }

      _emitUsuarioActualizado(
        emit: emit,
        actualizado: actualizado,
        actionType: AlertaActionType.marcarRecibida,
        message: apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Alerta marcada como recibida.',
      );

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, AlertaActionType.marcarRecibida);
  }

  // ============================================================
  // 8. MARCAR ALERTA COMO LEÍDA
  // ============================================================

  Future<void> _onMarcarLeida(
    MarcarAlertaLeidaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    _emitActionLoading(emit, AlertaActionType.marcarLeida);

    final response = await alertaUsesCases.marcarLeida.run(
      alertaId: event.alertaId,
    );

    if (response is Success<ApiResponse<AlertaUsuarioEstadoData>>) {
      final apiResponse = response.data;
      final actualizado = apiResponse.data;

      if (actualizado == null) {
        _emitActionDataMissing(
          emit,
          AlertaActionType.marcarLeida,
          apiResponse.message,
        );

        return;
      }

      final noLeidasActualizadas = state.alertasNoLeidas > 0
          ? state.alertasNoLeidas - 1
          : 0;

      _emitUsuarioActualizado(
        emit: emit,
        actualizado: actualizado,
        actionType: AlertaActionType.marcarLeida,
        message: apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Alerta marcada como leída.',
        alertasNoLeidas: noLeidasActualizadas,
      );

      _refreshDetalleIfNecessary(actualizado.alertaId);

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

    _emitActionLoading(emit, actionType);

    final response = await alertaUsesCases.responderAlerta.run(
      alertaId: event.alertaId,
      respuesta: respuestaNormalizada,
      observacion: event.observacion,
    );

    if (response is Success<ApiResponse<AlertaUsuarioEstadoData>>) {
      final apiResponse = response.data;
      final actualizado = apiResponse.data;

      if (actualizado == null) {
        _emitActionDataMissing(emit, actionType, apiResponse.message);

        return;
      }

      _emitUsuarioActualizado(
        emit: emit,
        actualizado: actualizado,
        actionType: actionType,
        message: apiResponse.message.isNotEmpty
            ? apiResponse.message
            : respuestaNormalizada == 'ACEPTADA'
            ? 'Alerta aceptada correctamente.'
            : 'Alerta rechazada correctamente.',
      );

      _refreshDetalleIfNecessary(actualizado.alertaId);

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, actionType);
  }

  // ============================================================
  // 10. MARCAR ALERTA COMO ATENDIDA
  // ============================================================

  Future<void> _onMarcarAtendida(
    MarcarAlertaAtendidaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    _emitActionLoading(emit, AlertaActionType.marcarAtendida);

    final response = await alertaUsesCases.marcarAtendida.run(
      alertaId: event.alertaId,
      observacion: event.observacion,
    );

    if (response is Success<ApiResponse<AlertaUsuarioEstadoData>>) {
      final apiResponse = response.data;
      final actualizado = apiResponse.data;

      if (actualizado == null) {
        _emitActionDataMissing(
          emit,
          AlertaActionType.marcarAtendida,
          apiResponse.message,
        );

        return;
      }

      _emitUsuarioActualizado(
        emit: emit,
        actualizado: actualizado,
        actionType: AlertaActionType.marcarAtendida,
        message: apiResponse.message.isNotEmpty
            ? apiResponse.message
            : 'Alerta marcada como atendida.',
      );

      _refreshDetalleIfNecessary(actualizado.alertaId);

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, AlertaActionType.marcarAtendida);
  }

  // ============================================================
  // 11. ACTIVAR BOTÓN DE ALERTA
  // ============================================================

  Future<void> _onActivarAlerta(
    ActivarAlertaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    _emitActionLoading(emit, AlertaActionType.activarAlerta);

    final response = await alertaUsesCases.activarAlertaUC.run(
      request: event.request,
    );

    if (response is Success<ApiResponse<ActivarAlertaData>>) {
      final apiResponse = response.data;
      final alertaActivada = apiResponse.data;

      if (alertaActivada == null) {
        _emitActionDataMissing(
          emit,
          AlertaActionType.activarAlerta,
          apiResponse.message,
        );

        return;
      }

      emit(
        state.copyWith(
          actionStatus: AlertaActionStatus.success,
          actionType: AlertaActionType.activarAlerta,
          actionMessage: apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'La alerta fue activada correctamente.',
          alertaActivada: alertaActivada,
          clearAlertaCancelada: true,
        ),
      );

      /*
       * La respuesta de activación y la respuesta del endpoint
       * de alerta activa tienen estructuras diferentes.
       * Se consulta nuevamente para obtener AlertaActivaData.
       */
      add(const GetAlertaActivaEvent());
      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, AlertaActionType.activarAlerta);
  }

  // ============================================================
  // 12. OBTENER ALERTA ACTIVA
  // ============================================================

  Future<void> _onGetAlertaActiva(
    GetAlertaActivaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        alertaActivaStatus: AlertaActivaStatus.loading,
        clearAlertaActivaErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.getAlertaActivaUC.run();

    if (response is Success<ApiResponse<AlertaActivaData>>) {
      final apiResponse = response.data;
      final alertaActiva = apiResponse.data;

      if (alertaActiva == null) {
        emit(
          state.copyWith(
            alertaActivaStatus: AlertaActivaStatus.empty,
            clearAlertaActiva: true,
            clearAlertaActivaErrorMessage: true,
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          alertaActivaStatus: AlertaActivaStatus.success,
          alertaActiva: alertaActiva,
          clearAlertaActivaErrorMessage: true,
        ),
      );

      return;
    }

    _emitAlertaActivaError(emit, response);
  }

  // ============================================================
  // 13. CANCELAR ALERTA ACTIVA
  // ============================================================

  Future<void> _onCancelarAlerta(
    CancelarAlertaEvent event,
    Emitter<AlertaState> emit,
  ) async {
    _emitActionLoading(emit, AlertaActionType.cancelarAlerta);

    final response = await alertaUsesCases.cancelarAlertaUC.run(
      alertaId: event.alertaId,
    );

    if (response is Success<ApiResponse<CancelarAlertaData>>) {
      final apiResponse = response.data;
      final alertaCancelada = apiResponse.data;

      if (alertaCancelada == null) {
        _emitActionDataMissing(
          emit,
          AlertaActionType.cancelarAlerta,
          apiResponse.message,
        );

        return;
      }

      emit(
        state.copyWith(
          actionStatus: AlertaActionStatus.success,
          actionType: AlertaActionType.cancelarAlerta,
          actionMessage: apiResponse.message.isNotEmpty
              ? apiResponse.message
              : 'La alerta fue cancelada correctamente.',
          alertaCancelada: alertaCancelada,
          clearAlertaActivada: true,
          alertaActivaStatus: AlertaActivaStatus.empty,
          clearAlertaActiva: true,
          clearAlertaActivaErrorMessage: true,
        ),
      );

      _refreshDetalleIfNecessary(alertaCancelada.id);

      add(const GetMisAlertasResumenEvent());

      return;
    }

    _emitActionError(emit, response, AlertaActionType.cancelarAlerta);
  }

  // ============================================================
  // 14. LIMPIAR ALERTA ACTIVA LOCAL
  // ============================================================

  void _onLimpiarAlertaActiva(
    LimpiarAlertaActivaEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(
      state.copyWith(
        alertaActivaStatus: AlertaActivaStatus.initial,
        clearAlertaActiva: true,
        clearAlertaActivaErrorMessage: true,
      ),
    );
  }

  // ============================================================
  // 15. OBTENER DETALLE DE ALERTA
  // ============================================================

  Future<void> _onGetAlertaDetalle(
    GetAlertaDetalleEvent event,
    Emitter<AlertaState> emit,
  ) async {
    emit(
      state.copyWith(
        detalleStatus: AlertaDetalleStatus.loading,
        clearAlertaDetalle: true,
        clearDetalleErrorMessage: true,
      ),
    );

    final response = await alertaUsesCases.getAlertaDetalleUC.run(
      alertaId: event.alertaId,
    );

    if (response is Success<ApiResponse<AlertaDetalleData>>) {
      final apiResponse = response.data;
      final detalle = apiResponse.data;

      if (detalle == null) {
        emit(
          state.copyWith(
            detalleStatus: AlertaDetalleStatus.error,
            detalleErrorMessage: apiResponse.message.isNotEmpty
                ? apiResponse.message
                : 'El servidor no devolvió el detalle.',
          ),
        );

        return;
      }

      emit(
        state.copyWith(
          detalleStatus: AlertaDetalleStatus.success,
          alertaDetalle: detalle,
          clearDetalleErrorMessage: true,
        ),
      );

      return;
    }

    _emitDetalleError(emit, response);
  }

  // ============================================================
  // 16. LIMPIAR DETALLE
  // ============================================================

  void _onLimpiarAlertaDetalle(
    LimpiarAlertaDetalleEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(
      state.copyWith(
        detalleStatus: AlertaDetalleStatus.initial,
        clearAlertaDetalle: true,
        clearDetalleErrorMessage: true,
      ),
    );
  }

  // ============================================================
  // 17. ALERTA REMOTA RECIBIDA
  // ============================================================

  void _onAlertaRemotaRecibida(
    AlertaRemotaRecibidaEvent event,
    Emitter<AlertaState> emit,
  ) {
    final alertaNueva = event.alerta;

    final index = state.alertas.indexWhere(
      (item) => item.alertaId == alertaNueva.alertaId,
    );

    final List<MisAlertasData> actualizadas;

    if (index >= 0) {
      actualizadas = List<MisAlertasData>.from(state.alertas);

      actualizadas[index] = alertaNueva;
    } else {
      actualizadas = [alertaNueva, ...state.alertas];
    }

    final debeIncrementar =
        index < 0 &&
        alertaNueva.fechaLeida == null &&
        alertaNueva.estado != 'LEIDA';

    emit(
      state.copyWith(
        listStatus: AlertaListStatus.success,
        alertas: actualizadas,
        ultimaAlertaRecibida: alertaNueva,
        total: index >= 0 ? state.total : state.total + 1,
        alertasNoLeidas: debeIncrementar
            ? state.alertasNoLeidas + 1
            : state.alertasNoLeidas,
      ),
    );

    /*
     * Si todavía está pendiente, se informa al backend que
     * la alerta llegó al dispositivo.
     */
    if (alertaNueva.estado == 'PENDIENTE') {
      add(MarcarAlertaRecibidaEvent(alertaId: alertaNueva.alertaId));
    }

    add(const GetMisAlertasResumenEvent());
  }

  // ============================================================
  // 18. ACTUALIZAR ALERTA LOCAL
  // ============================================================

  void _onActualizarAlertaLocal(
    ActualizarAlertaLocalEvent event,
    Emitter<AlertaState> emit,
  ) {
    final actualizado = event.alertaUsuario;

    emit(
      state.copyWith(
        alertas: _actualizarEnLista(actualizado),
        alertaSelected: _actualizarSeleccionada(actualizado),
        ultimaActualizacionUsuario: actualizado,
      ),
    );

    _refreshDetalleIfNecessary(actualizado.alertaId);
  }

  // ============================================================
  // 19. ELIMINAR ALERTA LOCAL
  // ============================================================

  void _onEliminarAlertaLocal(
    EliminarAlertaLocalEvent event,
    Emitter<AlertaState> emit,
  ) {
    final alertasActualizadas = state.alertas
        .where((item) => item.alertaId != event.alertaId)
        .toList();

    final debeLimpiarSeleccion =
        state.alertaSelected?.alertaId == event.alertaId;

    emit(
      state.copyWith(
        listStatus: alertasActualizadas.isEmpty
            ? AlertaListStatus.empty
            : AlertaListStatus.success,
        alertas: alertasActualizadas,
        total: state.total > 0 ? state.total - 1 : 0,
        clearAlertaSelected: debeLimpiarSeleccion,
      ),
    );
  }

  // ============================================================
  // 20. SELECCIONAR ALERTA
  // ============================================================

  void _onSeleccionarAlerta(
    SeleccionarAlertaEvent event,
    Emitter<AlertaState> emit,
  ) {
    final alerta = event.alerta;

    emit(state.copyWith(alertaSelected: alerta));

    /*
     * Se obtiene el detalle completo de la alerta.
     */
    add(GetAlertaDetalleEvent(alertaId: alerta.alertaId));

    /*
     * Se marca como leída únicamente si todavía no lo está.
     */
    final fueLeida = alerta.fechaLeida != null || alerta.estado == 'LEIDA';

    if (!fueLeida) {
      add(MarcarAlertaLeidaEvent(alertaId: alerta.alertaId));
    }
  }

  // ============================================================
  // 21. LIMPIAR ALERTA SELECCIONADA
  // ============================================================

  void _onLimpiarAlertaSeleccionada(
    LimpiarAlertaSeleccionadaEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(
      state.copyWith(
        clearAlertaSelected: true,
        detalleStatus: AlertaDetalleStatus.initial,
        clearAlertaDetalle: true,
        clearDetalleErrorMessage: true,
      ),
    );
  }

  // ============================================================
  // 22. LIMPIAR RESPUESTA DE ACCIÓN
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
        clearUltimaActualizacionUsuario: true,
        clearAlertaActivada: true,
        clearAlertaCancelada: true,
      ),
    );
  }

  // ============================================================
  // 23. REINICIAR BLOC
  // ============================================================

  void _onReset(ResetAlertaEvent event, Emitter<AlertaState> emit) {
    emit(const AlertaState());
  }

  // ============================================================
  // 24. INCREMENTAR ALERTAS NO LEÍDAS
  // ============================================================

  void _onNuevaAlertaRecibida(
    NuevaAlertaRecibidaEvent event,
    Emitter<AlertaState> emit,
  ) {
    final cantidad = event.cantidad < 1 ? 1 : event.cantidad;

    emit(state.copyWith(alertasNoLeidas: state.alertasNoLeidas + cantidad));
  }

  // ============================================================
  // 25. REINICIAR CONTADOR DE NO LEÍDAS
  // ============================================================

  void _onMarcarAlertasComoLeidas(
    MarcarAlertasComoLeidasEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(state.copyWith(alertasNoLeidas: 0));
  }

  // ============================================================
  // 26. ESTABLECER CONTADOR DE NO LEÍDAS
  // ============================================================

  void _onEstablecerAlertasNoLeidas(
    EstablecerAlertasNoLeidasEvent event,
    Emitter<AlertaState> emit,
  ) {
    emit(
      state.copyWith(alertasNoLeidas: event.cantidad < 0 ? 0 : event.cantidad),
    );
  }

  // ============================================================
  // HELPERS DEL LISTADO
  // ============================================================
  List<MisAlertasData> _combinarSinDuplicados(
    List<MisAlertasData> actuales,
    List<MisAlertasData> nuevas,
  ) {
    final mapa = <int, MisAlertasData>{};

    for (final item in actuales) {
      mapa[item.alertaId] = item;
    }

    for (final item in nuevas) {
      mapa[item.alertaId] = item;
    }

    return mapa.values.toList();
  }

  List<MisAlertasData> _actualizarEnLista(
    AlertaUsuarioEstadoData actualizacion,
  ) {
    return state.alertas.map((item) {
      if (item.alertaId != actualizacion.alertaId) {
        return item;
      }

      return _combinarItemConEstado(item, actualizacion);
    }).toList();
  }

  MisAlertasData? _actualizarSeleccionada(
    AlertaUsuarioEstadoData actualizacion,
  ) {
    final seleccionada = state.alertaSelected;

    if (seleccionada == null ||
        seleccionada.alertaId != actualizacion.alertaId) {
      return seleccionada;
    }

    return _combinarItemConEstado(seleccionada, actualizacion);
  }

  /*
   * MisAlertasData contiene la alerta principal y el estado
   * del destinatario.
   *
   * AlertaUsuarioEstadoData solo contiene el estado actualizado.
   * Por eso se combinan ambos JSON conservando "alerta".
   */
  MisAlertasData _combinarItemConEstado(
    MisAlertasData item,
    AlertaUsuarioEstadoData actualizacion,
  ) {
    final json = <String, dynamic>{
      ...item.toJson(),
      ...actualizacion.toJson(),
      'alerta': item.alerta.toJson(),
    };

    return MisAlertasData.fromJson(json);
  }

  void _refreshDetalleIfNecessary(int alertaId) {
    if (state.alertaDetalle?.id == alertaId ||
        state.alertaSelected?.alertaId == alertaId) {
      add(GetAlertaDetalleEvent(alertaId: alertaId));
    }
  }

  // ============================================================
  // HELPERS DE EMISIÓN
  // ============================================================
  void _emitUsuarioActualizado({
    required Emitter<AlertaState> emit,
    required AlertaUsuarioEstadoData actualizado,
    required AlertaActionType actionType,
    required String message,
    int? alertasNoLeidas,
  }) {
    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.success,
        actionType: actionType,
        actionMessage: message,
        ultimaActualizacionUsuario: actualizado,
        alertas: _actualizarEnLista(actualizado),
        alertaSelected: _actualizarSeleccionada(actualizado),
        alertasNoLeidas: alertasNoLeidas ?? state.alertasNoLeidas,
      ),
    );
  }

  void _emitActionLoading(
    Emitter<AlertaState> emit,
    AlertaActionType actionType,
  ) {
    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.loading,
        actionType: actionType,
        clearActionMessage: true,
        clearUltimaActualizacionUsuario: true,
        clearAlertaActivada: true,
        clearAlertaCancelada: true,
      ),
    );
  }

  void _emitActionDataMissing(
    Emitter<AlertaState> emit,
    AlertaActionType actionType,
    String backendMessage,
  ) {
    final message = backendMessage.isNotEmpty
        ? backendMessage
        : 'El servidor no devolvió los datos actualizados.';

    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.error,
        actionType: actionType,
        actionMessage: message,
      ),
    );
  }

  // ============================================================
  // HELPERS DE ERRORES
  // ============================================================
  void _emitListError(Emitter<AlertaState> emit, Resource<dynamic> response) {
    final message = response is ErrorData
        ? response.message
        : 'No se pudieron obtener las alertas.';

    emit(
      state.copyWith(
        listStatus: state.alertas.isEmpty
            ? AlertaListStatus.error
            : AlertaListStatus.success,
        listErrorMessage: message,
      ),
    );
  }

  void _emitResumenError(
    Emitter<AlertaState> emit,
    Resource<dynamic> response,
  ) {
    final message = response is ErrorData
        ? response.message
        : 'No se pudo obtener el resumen de alertas.';

    emit(
      state.copyWith(
        resumenStatus: AlertaResumenStatus.error,
        resumenErrorMessage: message,
      ),
    );
  }

  void _emitAlertaActivaError(
    Emitter<AlertaState> emit,
    Resource<dynamic> response,
  ) {
    final message = response is ErrorData
        ? response.message
        : 'No se pudo obtener la alerta activa.';

    emit(
      state.copyWith(
        alertaActivaStatus: AlertaActivaStatus.error,
        alertaActivaErrorMessage: message,
      ),
    );
  }

  void _emitDetalleError(
    Emitter<AlertaState> emit,
    Resource<dynamic> response,
  ) {
    final message = response is ErrorData
        ? response.message
        : 'No se pudo obtener el detalle de la alerta.';

    emit(
      state.copyWith(
        detalleStatus: AlertaDetalleStatus.error,
        detalleErrorMessage: message,
      ),
    );
  }

  void _emitActionError(
    Emitter<AlertaState> emit,
    Resource<dynamic> response,
    AlertaActionType actionType,
  ) {
    final message = response is ErrorData
        ? response.message
        : 'No se pudo completar la operación.';

    emit(
      state.copyWith(
        actionStatus: AlertaActionStatus.error,
        actionType: actionType,
        actionMessage: message,
      ),
    );
  }
}
