import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

abstract class AlertaEvent extends Equatable {
  const AlertaEvent();

  @override
  List<Object?> get props => [];
}

// ============================================================
// ALERTAS DEL USUARIO
// ============================================================

// ************************************************************
// 1. OBTENER MIS ALERTAS
// ************************************************************
class GetMisAlertasEvent extends AlertaEvent {
  final int page;
  final int limit;

  final String? estado;
  final String? tipo;
  final String? prioridad;
  final bool? noLeidas;

  /*
   * true:
   * reemplaza el listado actual.
   *
   * false:
   * agrega los resultados al listado existente.
   */
  final bool reset;

  const GetMisAlertasEvent({
    this.page = 1,
    this.limit = 10,
    this.estado,
    this.tipo,
    this.prioridad,
    this.noLeidas,
    this.reset = true,
  });

  MisAlertasQueryParams get params {
    return MisAlertasQueryParams(
      page: page,
      limit: limit,
      estado: estado,
      tipo: tipo,
      prioridad: prioridad,
      noLeidas: noLeidas,
    );
  }

  @override
  List<Object?> get props => [
    page,
    limit,
    estado,
    tipo,
    prioridad,
    noLeidas,
    reset,
  ];
}

// ************************************************************
// 2. REFRESCAR MIS ALERTAS
// ************************************************************
class RefreshMisAlertasEvent extends AlertaEvent {
  const RefreshMisAlertasEvent();
}

// ************************************************************
// 3. CARGAR SIGUIENTE PÁGINA
// ************************************************************
class LoadMoreAlertasEvent extends AlertaEvent {
  const LoadMoreAlertasEvent();
}

// ************************************************************
// 4. APLICAR FILTROS
// ************************************************************
class FiltrarAlertasEvent extends AlertaEvent {
  final String? estado;
  final String? tipo;
  final String? prioridad;
  final bool? noLeidas;

  const FiltrarAlertasEvent({
    this.estado,
    this.tipo,
    this.prioridad,
    this.noLeidas,
  });

  @override
  List<Object?> get props => [estado, tipo, prioridad, noLeidas];
}

// ************************************************************
// 5. LIMPIAR FILTROS
// ************************************************************
class LimpiarFiltrosAlertasEvent extends AlertaEvent {
  const LimpiarFiltrosAlertasEvent();
}

// ************************************************************
// 6. OBTENER RESUMEN DE MIS ALERTAS
// ************************************************************
class GetMisAlertasResumenEvent extends AlertaEvent {
  const GetMisAlertasResumenEvent();
}

// ************************************************************
// 7. MARCAR ALERTA COMO RECIBIDA
// ************************************************************
class MarcarAlertaRecibidaEvent extends AlertaEvent {
  final int alertaId;

  const MarcarAlertaRecibidaEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ************************************************************
// 8. MARCAR ALERTA COMO LEÍDA
// ************************************************************
class MarcarAlertaLeidaEvent extends AlertaEvent {
  final int alertaId;

  const MarcarAlertaLeidaEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ************************************************************
// 9. RESPONDER ALERTA
// ************************************************************
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

// ************************************************************
// 10. MARCAR ALERTA COMO ATENDIDA
// ************************************************************
class MarcarAlertaAtendidaEvent extends AlertaEvent {
  final int alertaId;
  final String? observacion;

  const MarcarAlertaAtendidaEvent({required this.alertaId, this.observacion});

  @override
  List<Object?> get props => [alertaId, observacion];
}

// ============================================================
// BOTÓN DE ALERTA DEL SERENO
// ============================================================

// ************************************************************
// 11. ACTIVAR BOTÓN DE ALERTA
// ************************************************************
class ActivarAlertaEvent extends AlertaEvent {
  final ActivarAlertaRequest request;

  const ActivarAlertaEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

// ************************************************************
// 12. OBTENER ALERTA ACTIVA
// ************************************************************
class GetAlertaActivaEvent extends AlertaEvent {
  const GetAlertaActivaEvent();
}

// ************************************************************
// 13. CANCELAR ALERTA ACTIVA
// ************************************************************
class CancelarAlertaEvent extends AlertaEvent {
  final int alertaId;

  const CancelarAlertaEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ************************************************************
// 14. LIMPIAR ALERTA ACTIVA LOCAL
// ************************************************************
class LimpiarAlertaActivaEvent extends AlertaEvent {
  const LimpiarAlertaActivaEvent();
}

// ============================================================
// DETALLE DE ALERTA
// ============================================================

// ************************************************************
// 15. OBTENER DETALLE DE ALERTA
// ************************************************************
class GetAlertaDetalleEvent extends AlertaEvent {
  final int alertaId;

  const GetAlertaDetalleEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ************************************************************
// 16. LIMPIAR DETALLE DE ALERTA
// ************************************************************
class LimpiarAlertaDetalleEvent extends AlertaEvent {
  const LimpiarAlertaDetalleEvent();
}

// ============================================================
// ACTUALIZACIONES LOCALES, SOCKET Y FCM
// ============================================================

// ************************************************************
// 17. ALERTA RECIBIDA POR SOCKET O FCM
// ************************************************************
class AlertaRemotaRecibidaEvent extends AlertaEvent {
  /*
   * Se usa MisAlertasData porque representa exactamente
   * un elemento del listado "Mis alertas":
   *
   * - datos de recepción del usuario
   * - información principal dentro de alerta
   */
  final MisAlertasData alerta;

  const AlertaRemotaRecibidaEvent({required this.alerta});

  @override
  List<Object?> get props => [alerta];
}

// ************************************************************
// 18. ACTUALIZAR ESTADO DE ALERTA EN MEMORIA
// ************************************************************
class ActualizarAlertaLocalEvent extends AlertaEvent {
  /*
   * Este modelo es retornado por:
   *
   * - marcarRecibida
   * - marcarLeida
   * - responderAlerta
   * - marcarAtendida
   */
  final AlertaUsuarioEstadoData alertaUsuario;

  const ActualizarAlertaLocalEvent({required this.alertaUsuario});

  @override
  List<Object?> get props => [alertaUsuario];
}

// ************************************************************
// 19. ELIMINAR ALERTA DEL LISTADO LOCAL
// ************************************************************
class EliminarAlertaLocalEvent extends AlertaEvent {
  /*
   * Corresponde a alerta_id, no al id del destinatario.
   */
  final int alertaId;

  const EliminarAlertaLocalEvent({required this.alertaId});

  @override
  List<Object?> get props => [alertaId];
}

// ************************************************************
// 20. SELECCIONAR ALERTA DEL LISTADO
// ************************************************************
class SeleccionarAlertaEvent extends AlertaEvent {
  final MisAlertasData alerta;

  const SeleccionarAlertaEvent({required this.alerta});

  @override
  List<Object?> get props => [alerta];
}

// ************************************************************
// 21. LIMPIAR ALERTA SELECCIONADA
// ************************************************************
class LimpiarAlertaSeleccionadaEvent extends AlertaEvent {
  const LimpiarAlertaSeleccionadaEvent();
}

// ============================================================
// RESPUESTAS Y ESTADO GENERAL
// ============================================================

// ************************************************************
// 22. LIMPIAR RESPUESTA DE ACCIÓN
// ************************************************************
class ClearAlertaActionResponseEvent extends AlertaEvent {
  const ClearAlertaActionResponseEvent();
}

// ************************************************************
// 23. REINICIAR BLOC
// ************************************************************
class ResetAlertaEvent extends AlertaEvent {
  const ResetAlertaEvent();
}

// ============================================================
// CONTADOR DE ALERTAS NO LEÍDAS
// ============================================================

// ************************************************************
// 24. INCREMENTAR ALERTAS NO LEÍDAS
// ************************************************************
class NuevaAlertaRecibidaEvent extends AlertaEvent {
  final int cantidad;

  const NuevaAlertaRecibidaEvent({this.cantidad = 1});

  @override
  List<Object?> get props => [cantidad];
}

// ************************************************************
// 25. MARCAR CONTADOR COMO LEÍDO
// ************************************************************
class MarcarAlertasComoLeidasEvent extends AlertaEvent {
  const MarcarAlertasComoLeidasEvent();
}

// ************************************************************
// 26. ESTABLECER CANTIDAD DE ALERTAS NO LEÍDAS
// ************************************************************
class EstablecerAlertasNoLeidasEvent extends AlertaEvent {
  final int cantidad;

  const EstablecerAlertasNoLeidasEvent(this.cantidad);

  @override
  List<Object?> get props => [cantidad];
}
