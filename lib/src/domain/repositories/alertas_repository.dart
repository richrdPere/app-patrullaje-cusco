// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class AlertaRepository {
  // ============================================================
  // ALERTAS DEL USUARIO
  // ============================================================

  /// 1. OBTENER MIS ALERTAS

  Future<Resource<ApiResponse<MisAlertasPaginated>>> getMisAlertas({
    required MisAlertasQueryParams params,
  });

  /// 2. OBTENER RESUMEN DE MIS ALERTAS
  Future<Resource<ApiResponse<MisAlertasResumenData>>> getMisAlertasResumen();

  /// 3. MARCAR ALERTA COMO RECIBIDA
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarRecibida({
    required int alertaId,
  });

  /// 4. MARCAR ALERTA COMO LEÍDA
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarLeida({
    required int alertaId,
  });

  /// 5. RESPONDER ALERTA
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> responderAlerta({
    required int alertaId,
    required String respuesta,
    String? observacion,
  });

  /// 6. MARCAR ALERTA COMO ATENDIDA
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarAtendida({
    required int alertaId,
    String? observacion,
  });

  /// 7. ACTIVAR BOTÓN DE ALERTA
  Future<Resource<ApiResponse<ActivarAlertaData>>> activarAlerta({
    required ActivarAlertaRequest request,
  });

  /// 8. OBTENER ALERTA ACTIVA
  Future<Resource<ApiResponse<AlertaActivaData>>> getAlertaActiva();

  /// 9. CANCELAR ALERTA ACTIVA
  Future<Resource<ApiResponse<CancelarAlertaData>>> cancelarAlerta({
    required int alertaId,
  });

  /// 10. OBTENER DETALLE DE ALERTA
  Future<Resource<ApiResponse<AlertaDetalleData>>> getAlertaDetalle({
    required int alertaId,
  });

  // ============================================================
  // USUARIO DISPOSITIVO
  // ============================================================

  /// 1. REGISTRAR O ACTUALIZAR DISPOSITIVO FCM
  Future<Resource<Map<String, dynamic>>> registrarDispositivo({
    required String fcmToken,
    String? deviceId,
  });

  /// 2. DESACTIVAR DISPOSITIVO FCM
  Future<Resource<Map<String, dynamic>>> desactivarDispositivo({
    required String fcmToken,
    String? deviceId,
  });
}
