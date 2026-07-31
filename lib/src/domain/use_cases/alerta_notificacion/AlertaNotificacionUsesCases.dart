import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/DesactivarDispositivoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/GetMisAlertasResumenUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/GetMisAlertasUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/MarcarAtendidaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/MarcarLeidaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/MarcarRecibidaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/RegistrarDispositivoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/ResponderAlertaUseCase.dart';

class AlertaNotificacionUsesCases {
  DesactivarDispositivoUseCase desactivarDispositivo;
  GetMisAlertasResumenUseCase getMisAlertasResumen;
  GetMisAlertasUseCase getMisAlertas;
  MarcarAtendidaUseCase marcarAtendida;
  MarcarLeidaUseCase marcarLeida;
  MarcarRecibidaUseCase marcarRecibida;
  RegistrarDispositivoUseCase registrarDispositivo;
  ResponderAlertaUseCase responderAlerta;

  AlertaNotificacionUsesCases({
    required this.desactivarDispositivo,
    required this.getMisAlertasResumen,
    required this.getMisAlertas,
    required this.marcarAtendida,
    required this.marcarLeida,
    required this.marcarRecibida,
    required this.registrarDispositivo,
    required this.responderAlerta,
  });
}
