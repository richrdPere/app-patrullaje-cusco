import 'package:equatable/equatable.dart';

import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';

enum HistorialListStatus { initial, loading, success, empty, error }

enum HistorialDetailStatus { initial, loading, success, error }

enum HistorialActionStatus { initial, loading, success, error }

class HistorialPatrullajeState extends Equatable {
  // ======================================================
  // LISTADO
  // ======================================================
  final HistorialListStatus listStatus;
  final List<HistorialPatrullajeModel> historial;

  // ======================================================
  // DETALLE
  // ======================================================
  final HistorialDetailStatus detailStatus;
  final HistorialPatrullajeModel? historialSelected;

  // ======================================================
  // ACCIONES
  // ======================================================
  final HistorialActionStatus actionStatus;
  final String? actionMessage;

  // ======================================================
  // ERROR
  // ======================================================
  final String? errorMessage;
  final String? errorDetail;

  const HistorialPatrullajeState({
    this.listStatus = HistorialListStatus.initial,
    this.historial = const [],
    this.detailStatus = HistorialDetailStatus.initial,
    this.historialSelected,
    this.actionStatus = HistorialActionStatus.initial,
    this.actionMessage,
    this.errorMessage,
    this.errorDetail,
  });

  HistorialPatrullajeState copyWith({
    HistorialListStatus? listStatus,
    List<HistorialPatrullajeModel>? historial,
    HistorialDetailStatus? detailStatus,
    HistorialPatrullajeModel? historialSelected,
    bool clearHistorialSelected = false,
    HistorialActionStatus? actionStatus,
    String? actionMessage,
    bool clearActionMessage = false,
    String? errorMessage,
    String? errorDetail,
    bool clearError = false,
  }) {
    return HistorialPatrullajeState(
      listStatus: listStatus ?? this.listStatus,
      historial: historial ?? this.historial,
      detailStatus: detailStatus ?? this.detailStatus,
      historialSelected: clearHistorialSelected
          ? null
          : historialSelected ?? this.historialSelected,
      actionStatus: actionStatus ?? this.actionStatus,
      actionMessage: clearActionMessage
          ? null
          : actionMessage ?? this.actionMessage,
      errorMessage: clearError ? null : errorMessage ?? this.errorMessage,
      errorDetail: clearError ? null : errorDetail ?? this.errorDetail,
    );
  }

  @override
  List<Object?> get props => [
    listStatus,
    historial,
    detailStatus,
    historialSelected,
    actionStatus,
    actionMessage,
    errorMessage,
    errorDetail,
  ];
}
