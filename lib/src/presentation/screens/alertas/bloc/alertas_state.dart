import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// ============================================================
// ESTADOS DEL LISTADO
// ============================================================

enum AlertaListStatus { initial, loading, loadingMore, success, empty, error }

// ============================================================
// ESTADOS DEL RESUMEN
// ============================================================

enum AlertaResumenStatus { initial, loading, success, error }

// ============================================================
// ESTADOS DE ACCIONES
// ============================================================

enum AlertaActionStatus { initial, loading, success, error }

// ============================================================
// ESTADOS DE ALERTA ACTIVA
// ============================================================

enum AlertaActivaStatus { initial, loading, success, empty, error }

// ============================================================
// ESTADOS DEL DETALLE
// ============================================================

enum AlertaDetalleStatus { initial, loading, success, error }

// ============================================================
// TIPOS DE ACCIONES
// ============================================================

enum AlertaActionType {
  none,
  marcarRecibida,
  marcarLeida,
  aceptar,
  rechazar,
  marcarAtendida,
  activarAlerta,
  cancelarAlerta,
}

// ============================================================
// STATE
// ============================================================

class AlertaState extends Equatable {
  // ==========================================================
  // LISTADO
  // ==========================================================

  final AlertaListStatus listStatus;
  final List<MisAlertasData> alertas;

  /*
   * Cantidad total de alertas no leídas retornada por
   * el backend.
   */
  final int alertasNoLeidas;

  // ==========================================================
  // RESUMEN
  // ==========================================================

  final AlertaResumenStatus resumenStatus;
  final MisAlertasResumenData? resumen;

  // ==========================================================
  // ACCIONES
  // ==========================================================

  final AlertaActionStatus actionStatus;
  final AlertaActionType actionType;
  final String? actionMessage;

  /*
   * Resultado de:
   *
   * - marcar recibida
   * - marcar leída
   * - responder
   * - marcar atendida
   */
  final AlertaUsuarioEstadoData? ultimaActualizacionUsuario;

  /*
   * Resultado de activar el botón de alerta.
   */
  final ActivarAlertaData? alertaActivada;

  /*
   * Resultado de cancelar la alerta activa.
   */
  final CancelarAlertaData? alertaCancelada;

  // ==========================================================
  // ALERTA ACTIVA
  // ==========================================================

  final AlertaActivaStatus alertaActivaStatus;
  final AlertaActivaData? alertaActiva;
  final String? alertaActivaErrorMessage;

  // ==========================================================
  // DETALLE
  // ==========================================================

  final AlertaDetalleStatus detalleStatus;
  final AlertaDetalleData? alertaDetalle;
  final String? detalleErrorMessage;

  // ==========================================================
  // ALERTA SELECCIONADA DEL LISTADO
  // ==========================================================

  final MisAlertasData? alertaSelected;

  // ==========================================================
  // ÚLTIMA ALERTA RECIBIDA POR SOCKET O FCM
  // ==========================================================

  final MisAlertasData? ultimaAlertaRecibida;

  // ==========================================================
  // PAGINACIÓN
  // ==========================================================

  final int page;
  final int limit;
  final int total;
  final int totalPages;
  final bool hasNextPage;
  final bool hasPreviousPage;

  // ==========================================================
  // FILTROS
  // ==========================================================

  final String? filtroEstado;
  final String? filtroTipo;
  final String? filtroPrioridad;
  final bool? filtroNoLeidas;

  // ==========================================================
  // ERRORES
  // ==========================================================

  final String? listErrorMessage;
  final String? resumenErrorMessage;

  const AlertaState({
    // Listado
    this.listStatus = AlertaListStatus.initial,
    this.alertas = const [],
    this.alertasNoLeidas = 0,

    // Resumen
    this.resumenStatus = AlertaResumenStatus.initial,
    this.resumen,

    // Acciones
    this.actionStatus = AlertaActionStatus.initial,
    this.actionType = AlertaActionType.none,
    this.actionMessage,
    this.ultimaActualizacionUsuario,
    this.alertaActivada,
    this.alertaCancelada,

    // Alerta activa
    this.alertaActivaStatus = AlertaActivaStatus.initial,
    this.alertaActiva,
    this.alertaActivaErrorMessage,

    // Detalle
    this.detalleStatus = AlertaDetalleStatus.initial,
    this.alertaDetalle,
    this.detalleErrorMessage,

    // Selección y recepción remota
    this.alertaSelected,
    this.ultimaAlertaRecibida,

    // Paginación
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,

    // Filtros
    this.filtroEstado,
    this.filtroTipo,
    this.filtroPrioridad,
    this.filtroNoLeidas,

    // Errores
    this.listErrorMessage,
    this.resumenErrorMessage,
  });

  // ==========================================================
  // HELPERS DEL LISTADO
  // ==========================================================

  bool get tieneAlertas => alertas.isNotEmpty;

  bool get listadoVacio {
    return listStatus == AlertaListStatus.empty ||
        (listStatus == AlertaListStatus.success && alertas.isEmpty);
  }

  bool get isLoading {
    return listStatus == AlertaListStatus.loading;
  }

  bool get isLoadingMore {
    return listStatus == AlertaListStatus.loadingMore;
  }

  bool get puedeCargarMas {
    return hasNextPage &&
        listStatus != AlertaListStatus.loading &&
        listStatus != AlertaListStatus.loadingMore;
  }

  // ==========================================================
  // HELPERS DE FILTROS
  // ==========================================================

  bool get tieneFiltros {
    return filtroEstado != null ||
        filtroTipo != null ||
        filtroPrioridad != null ||
        filtroNoLeidas != null;
  }

  MisAlertasQueryParams get currentQueryParams {
    return MisAlertasQueryParams(
      page: page,
      limit: limit,
      estado: filtroEstado,
      tipo: filtroTipo,
      prioridad: filtroPrioridad,
      noLeidas: filtroNoLeidas,
    );
  }

  // ==========================================================
  // HELPERS DEL CONTADOR
  // ==========================================================

  /*
   * Valor global enviado por el backend.
   */
  int get totalNoLeidas => alertasNoLeidas;

  /*
   * Valor calculado únicamente con los elementos cargados
   * actualmente en memoria.
   */
  int get totalNoLeidasEnListado {
    return alertas.where((item) {
      return item.fechaLeida == null && item.estado != 'LEIDA';
    }).length;
  }

  int get totalPendientesEnListado {
    return alertas.where((item) {
      return item.estado == 'PENDIENTE';
    }).length;
  }

  int get totalRequierenRespuestaEnListado {
    return alertas.where((item) {
      final estado = item.estado.toUpperCase();

      final yaRespondida =
          estado == 'ACEPTADA' || estado == 'RECHAZADA' || estado == 'ATENDIDA';

      return item.alerta.requiereConfirmacion && !yaRespondida;
    }).length;
  }

  // ==========================================================
  // HELPERS DEL RESUMEN
  // ==========================================================

  bool get isResumenLoading {
    return resumenStatus == AlertaResumenStatus.loading;
  }

  bool get tieneResumen {
    return resumenStatus == AlertaResumenStatus.success && resumen != null;
  }

  // ==========================================================
  // HELPERS DE ACCIONES
  // ==========================================================

  bool get isActionLoading {
    return actionStatus == AlertaActionStatus.loading;
  }

  bool get isActionSuccess {
    return actionStatus == AlertaActionStatus.success;
  }

  bool get isActionError {
    return actionStatus == AlertaActionStatus.error;
  }

  bool get isActivandoAlerta {
    return isActionLoading && actionType == AlertaActionType.activarAlerta;
  }

  bool get isCancelandoAlerta {
    return isActionLoading && actionType == AlertaActionType.cancelarAlerta;
  }

  bool get isMarcandoRecibida {
    return isActionLoading && actionType == AlertaActionType.marcarRecibida;
  }

  bool get isMarcandoLeida {
    return isActionLoading && actionType == AlertaActionType.marcarLeida;
  }

  bool get isRespondiendoAlerta {
    return isActionLoading &&
        (actionType == AlertaActionType.aceptar ||
            actionType == AlertaActionType.rechazar);
  }

  bool get isMarcandoAtendida {
    return isActionLoading && actionType == AlertaActionType.marcarAtendida;
  }

  // ==========================================================
  // HELPERS DE ALERTA ACTIVA
  // ==========================================================

  bool get isAlertaActivaLoading {
    return alertaActivaStatus == AlertaActivaStatus.loading;
  }

  bool get tieneAlertaActiva {
    return alertaActivaStatus == AlertaActivaStatus.success &&
        alertaActiva != null;
  }

  bool get noTieneAlertaActiva {
    return alertaActivaStatus == AlertaActivaStatus.empty ||
        (alertaActivaStatus == AlertaActivaStatus.success &&
            alertaActiva == null);
  }

  // ==========================================================
  // HELPERS DEL DETALLE
  // ==========================================================

  bool get isDetalleLoading {
    return detalleStatus == AlertaDetalleStatus.loading;
  }

  bool get tieneDetalle {
    return detalleStatus == AlertaDetalleStatus.success &&
        alertaDetalle != null;
  }

  bool get puedeCancelarAlertaDetalle {
    return alertaDetalle?.permisos.puedeCancelar == true;
  }

  bool get puedeResponderAlertaDetalle {
    return alertaDetalle?.permisos.puedeResponder == true;
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================

  AlertaState copyWith({
    // Listado
    AlertaListStatus? listStatus,
    List<MisAlertasData>? alertas,
    int? alertasNoLeidas,

    // Resumen
    AlertaResumenStatus? resumenStatus,
    MisAlertasResumenData? resumen,
    bool clearResumen = false,

    // Acciones
    AlertaActionStatus? actionStatus,
    AlertaActionType? actionType,
    String? actionMessage,
    bool clearActionMessage = false,
    AlertaUsuarioEstadoData? ultimaActualizacionUsuario,
    bool clearUltimaActualizacionUsuario = false,
    ActivarAlertaData? alertaActivada,
    bool clearAlertaActivada = false,
    CancelarAlertaData? alertaCancelada,
    bool clearAlertaCancelada = false,

    // Alerta activa
    AlertaActivaStatus? alertaActivaStatus,
    AlertaActivaData? alertaActiva,
    bool clearAlertaActiva = false,
    String? alertaActivaErrorMessage,
    bool clearAlertaActivaErrorMessage = false,

    // Detalle
    AlertaDetalleStatus? detalleStatus,
    AlertaDetalleData? alertaDetalle,
    bool clearAlertaDetalle = false,
    String? detalleErrorMessage,
    bool clearDetalleErrorMessage = false,

    // Selección
    MisAlertasData? alertaSelected,
    bool clearAlertaSelected = false,

    // Última alerta remota
    MisAlertasData? ultimaAlertaRecibida,
    bool clearUltimaAlertaRecibida = false,

    // Paginación
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,

    // Filtros
    String? filtroEstado,
    bool clearFiltroEstado = false,
    String? filtroTipo,
    bool clearFiltroTipo = false,
    String? filtroPrioridad,
    bool clearFiltroPrioridad = false,
    bool? filtroNoLeidas,
    bool clearFiltroNoLeidas = false,

    // Errores
    String? listErrorMessage,
    bool clearListErrorMessage = false,
    String? resumenErrorMessage,
    bool clearResumenErrorMessage = false,
  }) {
    return AlertaState(
      // Listado
      listStatus: listStatus ?? this.listStatus,
      alertas: alertas ?? this.alertas,
      alertasNoLeidas: alertasNoLeidas ?? this.alertasNoLeidas,

      // Resumen
      resumenStatus: resumenStatus ?? this.resumenStatus,
      resumen: clearResumen ? null : resumen ?? this.resumen,

      // Acciones
      actionStatus: actionStatus ?? this.actionStatus,
      actionType: actionType ?? this.actionType,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      ultimaActualizacionUsuario: clearUltimaActualizacionUsuario
          ? null
          : ultimaActualizacionUsuario ?? this.ultimaActualizacionUsuario,
      alertaActivada: clearAlertaActivada
          ? null
          : alertaActivada ?? this.alertaActivada,
      alertaCancelada: clearAlertaCancelada
          ? null
          : alertaCancelada ?? this.alertaCancelada,

      // Alerta activa
      alertaActivaStatus: alertaActivaStatus ?? this.alertaActivaStatus,
      alertaActiva: clearAlertaActiva
          ? null
          : alertaActiva ?? this.alertaActiva,
      alertaActivaErrorMessage: clearAlertaActivaErrorMessage
          ? null
          : alertaActivaErrorMessage ?? this.alertaActivaErrorMessage,

      // Detalle
      detalleStatus: detalleStatus ?? this.detalleStatus,
      alertaDetalle: clearAlertaDetalle
          ? null
          : alertaDetalle ?? this.alertaDetalle,
      detalleErrorMessage: clearDetalleErrorMessage
          ? null
          : detalleErrorMessage ?? this.detalleErrorMessage,

      // Selección
      alertaSelected: clearAlertaSelected
          ? null
          : alertaSelected ?? this.alertaSelected,

      // Última alerta remota
      ultimaAlertaRecibida: clearUltimaAlertaRecibida
          ? null
          : ultimaAlertaRecibida ?? this.ultimaAlertaRecibida,

      // Paginación
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,

      // Filtros
      filtroEstado: clearFiltroEstado
          ? null
          : filtroEstado ?? this.filtroEstado,
      filtroTipo: clearFiltroTipo ? null : filtroTipo ?? this.filtroTipo,
      filtroPrioridad: clearFiltroPrioridad
          ? null
          : filtroPrioridad ?? this.filtroPrioridad,
      filtroNoLeidas: clearFiltroNoLeidas
          ? null
          : filtroNoLeidas ?? this.filtroNoLeidas,

      // Errores
      listErrorMessage: clearListErrorMessage
          ? null
          : listErrorMessage ?? this.listErrorMessage,
      resumenErrorMessage: clearResumenErrorMessage
          ? null
          : resumenErrorMessage ?? this.resumenErrorMessage,
    );
  }

  // ==========================================================
  // EQUATABLE
  // ==========================================================

  @override
  List<Object?> get props => [
    // Listado
    listStatus,
    alertas,
    alertasNoLeidas,

    // Resumen
    resumenStatus,
    resumen,

    // Acciones
    actionStatus,
    actionType,
    actionMessage,
    ultimaActualizacionUsuario,
    alertaActivada,
    alertaCancelada,

    // Alerta activa
    alertaActivaStatus,
    alertaActiva,
    alertaActivaErrorMessage,

    // Detalle
    detalleStatus,
    alertaDetalle,
    detalleErrorMessage,

    // Selección
    alertaSelected,

    // Última alerta remota
    ultimaAlertaRecibida,

    // Paginación
    page,
    limit,
    total,
    totalPages,
    hasNextPage,
    hasPreviousPage,

    // Filtros
    filtroEstado,
    filtroTipo,
    filtroPrioridad,
    filtroNoLeidas,

    // Errores
    listErrorMessage,
    resumenErrorMessage,
  ];
}
