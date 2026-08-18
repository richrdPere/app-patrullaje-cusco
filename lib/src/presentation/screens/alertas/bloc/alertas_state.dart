import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_resumen_model.dart';

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
// TIPOS DE ACCIONES
// ============================================================

enum AlertaActionType {
  none,
  marcarRecibida,
  marcarLeida,
  aceptar,
  rechazar,
  marcarAtendida,
}

// ============================================================
// STATE
// ============================================================

class AlertaState extends Equatable {
  // ==========================================================
  // LISTADO
  // ==========================================================
  final AlertaListStatus listStatus;
  final List<AlertaDestinatarioModel> alertas;
  final int alertasNoLeidas;

  // ==========================================================
  // RESUMEN
  // ==========================================================
  final AlertaResumenStatus resumenStatus;
  final AlertaResumenModel? resumen;

  // ==========================================================
  // ACCIONES
  // ==========================================================
  final AlertaActionStatus actionStatus;
  final AlertaActionType actionType;
  final String? actionMessage;

  // ==========================================================
  // ALERTA SELECCIONADA
  // ==========================================================
  final AlertaDestinatarioModel? alertaSelected;

  // ==========================================================
  // ÚLTIMA ALERTA REMOTA
  // ==========================================================
  final AlertaDestinatarioModel? ultimaAlertaRecibida;

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
  final bool? filtroRequiereConfirmacion;

  // ==========================================================
  // ERROR
  // ==========================================================
  final String? errorMessage;

  const AlertaState({
    this.listStatus = AlertaListStatus.initial,
    this.alertas = const [],
    this.alertasNoLeidas = 0,
    this.resumenStatus = AlertaResumenStatus.initial,
    this.resumen,
    this.actionStatus = AlertaActionStatus.initial,
    this.actionType = AlertaActionType.none,
    this.actionMessage,
    this.alertaSelected,
    this.ultimaAlertaRecibida,
    this.page = 1,
    this.limit = 10,
    this.total = 0,
    this.totalPages = 1,
    this.hasNextPage = false,
    this.hasPreviousPage = false,
    this.filtroEstado,
    this.filtroTipo,
    this.filtroPrioridad,
    this.filtroRequiereConfirmacion,
    this.errorMessage,
  });

  // ==========================================================
  // HELPERS
  // ==========================================================
  bool get tieneAlertas => alertas.isNotEmpty;

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

  bool get tieneFiltros {
    return filtroEstado != null ||
        filtroTipo != null ||
        filtroPrioridad != null ||
        filtroRequiereConfirmacion != null;
  }

  int get totalNoLeidas {
    return alertas.where((item) => !item.fueLeida).length;
  }

  int get totalPendientes {
    return alertas.where((item) => item.estaPendiente).length;
  }

  int get totalRequierenRespuesta {
    return alertas.where((item) => item.requiereRespuesta).length;
  }

  // ==========================================================
  // COPY WITH
  // ==========================================================
  AlertaState copyWith({
    AlertaListStatus? listStatus,
    List<AlertaDestinatarioModel>? alertas,
    int? alertasNoLeidas,
    AlertaResumenStatus? resumenStatus,
    AlertaResumenModel? resumen,
    bool clearResumen = false,
    AlertaActionStatus? actionStatus,
    AlertaActionType? actionType,
    String? actionMessage,
    bool clearActionMessage = false,
    AlertaDestinatarioModel? alertaSelected,
    bool clearAlertaSelected = false,
    AlertaDestinatarioModel? ultimaAlertaRecibida,
    bool clearUltimaAlertaRecibida = false,
    int? page,
    int? limit,
    int? total,
    int? totalPages,
    bool? hasNextPage,
    bool? hasPreviousPage,
    String? filtroEstado,
    bool clearFiltroEstado = false,
    String? filtroTipo,
    bool clearFiltroTipo = false,
    String? filtroPrioridad,
    bool clearFiltroPrioridad = false,
    bool? filtroRequiereConfirmacion,
    bool clearFiltroRequiereConfirmacion = false,
    String? errorMessage,
    bool clearErrorMessage = false,
  }) {
    return AlertaState(
      listStatus: listStatus ?? this.listStatus,
      alertas: alertas ?? this.alertas,
      alertasNoLeidas: alertasNoLeidas ?? this.alertasNoLeidas,
      resumenStatus: resumenStatus ?? this.resumenStatus,
      resumen: clearResumen ? null : resumen ?? this.resumen,
      actionStatus: actionStatus ?? this.actionStatus,
      actionType: actionType ?? this.actionType,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      alertaSelected: clearAlertaSelected
          ? null
          : alertaSelected ?? this.alertaSelected,
      ultimaAlertaRecibida: clearUltimaAlertaRecibida
          ? null
          : ultimaAlertaRecibida ?? this.ultimaAlertaRecibida,
      page: page ?? this.page,
      limit: limit ?? this.limit,
      total: total ?? this.total,
      totalPages: totalPages ?? this.totalPages,
      hasNextPage: hasNextPage ?? this.hasNextPage,
      hasPreviousPage: hasPreviousPage ?? this.hasPreviousPage,
      filtroEstado: clearFiltroEstado
          ? null
          : filtroEstado ?? this.filtroEstado,
      filtroTipo: clearFiltroTipo ? null : filtroTipo ?? this.filtroTipo,
      filtroPrioridad: clearFiltroPrioridad
          ? null
          : filtroPrioridad ?? this.filtroPrioridad,
      filtroRequiereConfirmacion: clearFiltroRequiereConfirmacion
          ? null
          : filtroRequiereConfirmacion ?? this.filtroRequiereConfirmacion,
      errorMessage: clearErrorMessage
          ? null
          : errorMessage ?? this.errorMessage,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    alertas,
    alertasNoLeidas,
    resumenStatus,
    resumen,
    actionStatus,
    actionType,
    actionMessage,
    alertaSelected,
    ultimaAlertaRecibida,
    page,
    limit,
    total,
    totalPages,
    hasNextPage,
    hasPreviousPage,
    filtroEstado,
    filtroTipo,
    filtroPrioridad,
    filtroRequiereConfirmacion,
    errorMessage,
  ];
}
