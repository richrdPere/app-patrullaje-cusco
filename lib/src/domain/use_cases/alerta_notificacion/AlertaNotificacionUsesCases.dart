import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

class AlertaNotificacionUsesCases {
  ActivarAlertaUC activarAlertaUC;
  CancelarAlertaUC cancelarAlertaUC;
  DesactivarDispositivoUC desactivarDispositivo;
  GetAlertaActivaUC getAlertaActivaUC;
  GetAlertaDetalleUC getAlertaDetalleUC;
  GetMisAlertasResumenUC getMisAlertasResumen;
  GetMisAlertasUC getMisAlertas;
  MarcarAtendidaUC marcarAtendida;
  MarcarLeidaUC marcarLeida;
  MarcarRecibidaUC marcarRecibida;
  RegistrarDispositivoUC registrarDispositivo;
  ResponderAlertaUC responderAlerta;

  AlertaNotificacionUsesCases({
    required this.activarAlertaUC,
    required this.cancelarAlertaUC,
    required this.desactivarDispositivo,
    required this.getAlertaActivaUC,
    required this.getAlertaDetalleUC,
    required this.getMisAlertasResumen,
    required this.getMisAlertas,
    required this.marcarAtendida,
    required this.marcarLeida,
    required this.marcarRecibida,
    required this.registrarDispositivo,
    required this.responderAlerta,
  });
}
