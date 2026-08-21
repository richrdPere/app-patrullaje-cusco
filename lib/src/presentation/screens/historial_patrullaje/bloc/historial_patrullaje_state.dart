import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// ==========================================================
// ESTADO DEL LISTADO
// ==========================================================
enum HistorialListStatus { initial, loading, success, empty, error }

// ==========================================================
// ESTADO DEL DETALLE
// ==========================================================
enum HistorialDetailStatus { initial, loading, success, error }

// ==========================================================
// ESTADO DEL CONTEXTO DE ZONA
// ==========================================================
enum HistorialContextoZonaStatus { initial, loading, success, empty, error }

// ==========================================================
// ESTADO DEL SIGUIENTE TURNO
// ==========================================================
enum HistorialSiguienteTurnoStatus { initial, loading, success, empty, error }

// ==========================================================
// ESTADO DE ACCIONES
// ==========================================================
enum HistorialActionStatus { initial, loading, success, error }

class HistorialPatrullajeState extends Equatable {
  // ========================================================
  // 1. LISTADO POR PATRULLAJE
  // ========================================================
  final HistorialListStatus listStatus;

  final List<HistorialPatrullajeData> historial;

  // ========================================================
  // 2. DETALLE SELECCIONADO
  // ========================================================
  final HistorialDetailStatus detailStatus;

  final HistorialDetalleData? historialSelected;

  // ========================================================
  // 3. CONTEXTO OPERATIVO DE ZONA
  // ========================================================
  final HistorialContextoZonaStatus contextoZonaStatus;

  final ContextoZonaData? contextoZona;

  // ========================================================
  // 4. INFORMACIÓN PARA EL SIGUIENTE TURNO
  // ========================================================
  final HistorialSiguienteTurnoStatus siguienteTurnoStatus;

  final SiguienteTurnoData? siguienteTurno;

  // ========================================================
  // 5. ACCIONES
  // ========================================================
  /*
   * Se utiliza para:
   *
   * - Crear historial.
   * - Crear observación con archivos.
   * - Actualizar historial.
   * - Archivar historial.
   */
  final HistorialActionStatus actionStatus;

  final HistorialData? actionData;

  final String? actionMessage;

  // ========================================================
  // 6. ERROR
  // ========================================================
  final String? errorMessage;

  final String? errorDetail;

  const HistorialPatrullajeState({
    this.listStatus = HistorialListStatus.initial,
    this.historial = const [],
    this.detailStatus = HistorialDetailStatus.initial,
    this.historialSelected,
    this.contextoZonaStatus = HistorialContextoZonaStatus.initial,
    this.contextoZona,
    this.siguienteTurnoStatus = HistorialSiguienteTurnoStatus.initial,
    this.siguienteTurno,
    this.actionStatus = HistorialActionStatus.initial,
    this.actionData,
    this.actionMessage,
    this.errorMessage,
    this.errorDetail,
  });

  // ========================================================
  // GETTERS DEL LISTADO
  // ========================================================
  bool get isLoadingList {
    return listStatus == HistorialListStatus.loading;
  }

  bool get hasHistorial {
    return historial.isNotEmpty;
  }

  bool get isHistorialEmpty {
    return listStatus == HistorialListStatus.empty;
  }

  // ========================================================
  // GETTERS DEL DETALLE
  // ========================================================
  bool get isLoadingDetail {
    return detailStatus == HistorialDetailStatus.loading;
  }

  bool get hasHistorialSelected {
    return historialSelected != null;
  }

  // ========================================================
  // GETTERS DEL CONTEXTO DE ZONA
  // ========================================================
  bool get isLoadingContextoZona {
    return contextoZonaStatus == HistorialContextoZonaStatus.loading;
  }

  bool get hasContextoZona {
    return contextoZona != null;
  }

  bool get isContextoZonaEmpty {
    return contextoZonaStatus == HistorialContextoZonaStatus.empty;
  }

  // ========================================================
  // GETTERS DEL SIGUIENTE TURNO
  // ========================================================
  bool get isLoadingSiguienteTurno {
    return siguienteTurnoStatus == HistorialSiguienteTurnoStatus.loading;
  }

  bool get hasSiguienteTurno {
    return siguienteTurno != null;
  }

  bool get tieneContextoAnterior {
    return siguienteTurno?.tieneContextoAnterior ?? false;
  }

  bool get isSiguienteTurnoEmpty {
    return siguienteTurnoStatus == HistorialSiguienteTurnoStatus.empty;
  }

  // ========================================================
  // GETTERS DE ACCIONES
  // ========================================================
  bool get isProcessingAction {
    return actionStatus == HistorialActionStatus.loading;
  }

  bool get isActionSuccess {
    return actionStatus == HistorialActionStatus.success;
  }

  bool get isActionError {
    return actionStatus == HistorialActionStatus.error;
  }

  // ========================================================
  // GETTERS DE ERROR
  // ========================================================
  bool get hasError {
    return errorMessage != null && errorMessage!.trim().isNotEmpty;
  }

  // ========================================================
  // COPY WITH
  // ========================================================
  HistorialPatrullajeState copyWith({
    // Listado
    HistorialListStatus? listStatus,
    List<HistorialPatrullajeData>? historial,

    // Detalle
    HistorialDetailStatus? detailStatus,
    HistorialDetalleData? historialSelected,
    bool clearHistorialSelected = false,

    // Contexto de zona
    HistorialContextoZonaStatus? contextoZonaStatus,
    ContextoZonaData? contextoZona,
    bool clearContextoZona = false,

    // Siguiente turno
    HistorialSiguienteTurnoStatus? siguienteTurnoStatus,
    SiguienteTurnoData? siguienteTurno,
    bool clearSiguienteTurno = false,

    // Acción
    HistorialActionStatus? actionStatus,
    HistorialData? actionData,
    bool clearActionData = false,
    String? actionMessage,
    bool clearActionMessage = false,

    // Error
    String? errorMessage,
    String? errorDetail,
    bool clearError = false,
  }) {
    return HistorialPatrullajeState(
      // Listado
      listStatus: listStatus ?? this.listStatus,
      historial: historial ?? this.historial,

      // Detalle
      detailStatus: detailStatus ?? this.detailStatus,
      historialSelected: clearHistorialSelected
          ? null
          : historialSelected ?? this.historialSelected,

      // Contexto de zona
      contextoZonaStatus: contextoZonaStatus ?? this.contextoZonaStatus,
      contextoZona: clearContextoZona
          ? null
          : contextoZona ?? this.contextoZona,

      // Siguiente turno
      siguienteTurnoStatus: siguienteTurnoStatus ?? this.siguienteTurnoStatus,
      siguienteTurno: clearSiguienteTurno
          ? null
          : siguienteTurno ?? this.siguienteTurno,

      // Acción
      actionStatus: actionStatus ?? this.actionStatus,
      actionData: clearActionData ? null : actionData ?? this.actionData,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,

      // Error
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorDetail: clearError ? null : errorDetail ?? this.errorDetail,
    );
  }

  // ========================================================
  // EQUATABLE
  // ========================================================
  @override
  List<Object?> get props => [
    listStatus,
    historial,
    detailStatus,
    historialSelected,
    contextoZonaStatus,
    contextoZona,
    siguienteTurnoStatus,
    siguienteTurno,
    actionStatus,
    actionData,
    actionMessage,
    errorMessage,
    errorDetail,
  ];
}
