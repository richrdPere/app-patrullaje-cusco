// Services
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/notification/fcm_token_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/alerta_service.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// Domain
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class AlertaRepositoryImpl implements AlertaRepository {
  final AlertaService alertaService;
  final FcmTokenService fcmTokenService;
  final AuthRepository authRepository;

  const AlertaRepositoryImpl(
    this.alertaService,
    this.fcmTokenService,
    this.authRepository,
  );

  // *********************************************************
  // 1. OBTENER MIS ALERTAS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<MisAlertasPaginated>>> getMisAlertas({
    required MisAlertasQueryParams params,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return alertaService.getMisAlertas(token: token, params: params);
  }

  // *********************************************************
  // 2. OBTENER RESUMEN DE MIS ALERTAS
  // *********************************************************
  @override
  Future<Resource<ApiResponse<MisAlertasResumenData>>>
  getMisAlertasResumen() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return alertaService.getMisAlertasResumen(token: token);
  }

  // *********************************************************
  // 3. MARCAR ALERTA COMO RECIBIDA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarRecibida({
    required int alertaId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return alertaService.marcarAlertaRecibida(token: token, alertaId: alertaId);
  }

  // *********************************************************
  // 4. MARCAR ALERTA COMO LEÍDA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarLeida({
    required int alertaId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return alertaService.marcarAlertaLeida(token: token, alertaId: alertaId);
  }

  // *********************************************************
  // 5. RESPONDER ALERTA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> responderAlerta({
    required int alertaId,
    required String respuesta,
    String? observacion,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return alertaService.responderAlerta(
      token: token,
      alertaId: alertaId,
      respuesta: respuesta,
      observacion: observacion,
    );
  }

  // *********************************************************
  // 6. MARCAR ALERTA COMO ATENDIDA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<AlertaUsuarioEstadoData>>> marcarAtendida({
    required int alertaId,
    String? observacion,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return alertaService.marcarAlertaAtendida(
      token: token,
      alertaId: alertaId,
      observacion: observacion,
    );
  }

  // *********************************************************
  // 7. ACTIVAR BOTÓN DE ALERTA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ActivarAlertaData>>> activarAlerta({
    required ActivarAlertaRequest request,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await alertaService.activarAlerta(token: token, request: request);
  }

  // *********************************************************
  // 8. OBTENER ALERTA ACTIVA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<AlertaActivaData>>> getAlertaActiva() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await alertaService.getAlertaActiva(token: token);
  }

  // *********************************************************
  // 9. CANCELAR ALERTA ACTIVA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<CancelarAlertaData>>> cancelarAlerta({
    required int alertaId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await alertaService.cancelarAlerta(token: token, alertaId: alertaId);
  }

  // *********************************************************
  // 10. OBTENER DETALLE DE ALERTA
  // *********************************************************
  @override
  Future<Resource<ApiResponse<AlertaDetalleData>>> getAlertaDetalle({
    required int alertaId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(message: 'No existe una sesión iniciada.');
    }

    return await alertaService.getAlertaDetalle(
      token: token,
      alertaId: alertaId,
    );
  }
 

  // *********************************************************
  // PARA DISPOSITIVOS USUARIO
  // *********************************************************

  // ============================================================
  // 1. REGISTRAR O ACTUALIZAR DISPOSITIVO FCM
  // ============================================================
  @override
  Future<Resource<Map<String, dynamic>>> registrarDispositivo({
    required String fcmToken,
    String? deviceId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<Map<String, dynamic>>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return fcmTokenService.registrarActualizarToken(
      token: token,
      fcmToken: fcmToken,
      deviceId: deviceId,
    );
  }

  // ============================================================
  // 2. DESACTIVAR DISPOSITIVO FCM
  // ============================================================
  @override
  Future<Resource<Map<String, dynamic>>> desactivarDispositivo({
    required String fcmToken,
    String? deviceId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<Map<String, dynamic>>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return fcmTokenService.desactivarToken(
      token: token,
      fcmToken: fcmToken,
      deviceId: deviceId,
    );
  }
}
