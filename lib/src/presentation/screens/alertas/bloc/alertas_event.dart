import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';

abstract class AlertaEvent extends Equatable {
  const AlertaEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// 1. CARGAR ALERTAS
// ============================================================
class GetMisAlertasEvent extends AlertaEvent {
  final int page;
  final int limit;
  final String? estado;
  final String? tipo;
  final String? prioridad;
  final bool? requiereConfirmacion;
  final bool reset;

  const GetMisAlertasEvent({
    this.page = 1,
    this.limit = 10,
    this.estado,
    this.tipo,
    this.prioridad,
    this.requiereConfirmacion,
    this.reset = true,
  });

  @override
  List<Object?> get props => [
    page,
    limit,
    estado,
    tipo,
    prioridad,
    requiereConfirmacion,
    reset,
  ];
}

// ============================================================
// 2. REFRESCAR ALERTAS
// ============================================================
class RefreshMisAlertasEvent extends AlertaEvent {
  const RefreshMisAlertasEvent();
}

// ============================================================
// 3. CARGAR SIGUIENTE PÁGINA
// ============================================================
class LoadMoreAlertasEvent extends AlertaEvent {
  const LoadMoreAlertasEvent();
}

// ============================================================
// 4. APLICAR FILTROS
// ============================================================
class FiltrarAlertasEvent extends AlertaEvent {
  final String? estado;
  final String? tipo;
  final String? prioridad;
  final bool? requiereConfirmacion;

  const FiltrarAlertasEvent({
    this.estado,
    this.tipo,
    this.prioridad,
    this.requiereConfirmacion,
  });

  @override
  List<Object?> get props => [estado, tipo, prioridad, requiereConfirmacion];
}

// ============================================================
// 5. LIMPIAR FILTROS
// ============================================================
class LimpiarFiltrosAlertasEvent extends AlertaEvent {
  const LimpiarFiltrosAlertasEvent();
}

// ============================================================
// 6. OBTENER RESUMEN
// ============================================================
class GetMisAlertasResumenEvent extends AlertaEvent {
  const GetMisAlertasResumenEvent();
}

// ============================================================
// 7. MARCAR COMO RECIBIDA
// ============================================================
class MarcarAlertaRecibidaEvent extends AlertaEvent {
  final int alertaId;

  const MarcarAlertaRecibidaEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ============================================================
// 8. MARCAR COMO LEÍDA
// ============================================================
class MarcarAlertaLeidaEvent extends AlertaEvent {
  final int alertaId;

  const MarcarAlertaLeidaEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ============================================================
// 9. RESPONDER ALERTA
// ============================================================
class ResponderAlertaEvent extends AlertaEvent {
  final int alertaId;
  final String respuesta;
  final String? observacion;

  const ResponderAlertaEvent({
    required this.alertaId,
    required this.respuesta,
    this.observacion,
  });

  @override
  List<Object?> get props => [alertaId, respuesta, observacion];
}

// ============================================================
// 10. MARCAR COMO ATENDIDA
// ============================================================
class MarcarAlertaAtendidaEvent extends AlertaEvent {
  final int alertaId;
  final String? observacion;

  const MarcarAlertaAtendidaEvent({required this.alertaId, this.observacion});

  @override
  List<Object?> get props => [alertaId, observacion];
}

// ============================================================
// 11. ALERTA RECIBIDA POR SOCKET O FCM
// ============================================================
class AlertaRemotaRecibidaEvent extends AlertaEvent {
  final AlertaDestinatarioModel alerta;

  const AlertaRemotaRecibidaEvent({required this.alerta});

  @override
  List<Object?> get props => [alerta];
}

// ============================================================
// 12. ACTUALIZAR ALERTA EN MEMORIA
// ============================================================
class ActualizarAlertaLocalEvent extends AlertaEvent {
  final AlertaDestinatarioModel alerta;

  const ActualizarAlertaLocalEvent({required this.alerta});

  @override
  List<Object?> get props => [alerta];
}

// ============================================================
// 13. ELIMINAR ALERTA LOCAL
// ============================================================
class EliminarAlertaLocalEvent extends AlertaEvent {
  final int alertaId;

  const EliminarAlertaLocalEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ============================================================
// 14. SELECCIONAR ALERTA
// ============================================================
class SeleccionarAlertaEvent extends AlertaEvent {
  final AlertaDestinatarioModel alerta;

  const SeleccionarAlertaEvent({required this.alerta});

  @override
  List<Object?> get props => [alerta];
}

// ============================================================
// 15. LIMPIAR ALERTA SELECCIONADA
// ============================================================
class LimpiarAlertaSeleccionadaEvent extends AlertaEvent {
  const LimpiarAlertaSeleccionadaEvent();
}

// ============================================================
// 16. LIMPIAR RESPUESTA DE ACCIÓN
// ============================================================
class ClearAlertaActionResponseEvent extends AlertaEvent {
  const ClearAlertaActionResponseEvent();
}

// ============================================================
// 17. REINICIAR BLOC
// ============================================================
class ResetAlertaEvent extends AlertaEvent {
  const ResetAlertaEvent();
}

// ============================================================
// 18. N! DE NUEVAS ALERTAS
// ============================================================
class NuevaAlertaRecibidaEvent extends AlertaEvent {
  const NuevaAlertaRecibidaEvent();
}

class MarcarAlertasComoLeidasEvent extends AlertaEvent {
  const MarcarAlertasComoLeidasEvent();
}

class EstablecerAlertasNoLeidasEvent extends AlertaEvent {
  final int cantidad;

  const EstablecerAlertasNoLeidasEvent(this.cantidad);

  @override
  List<Object?> get props => [cantidad];
}
