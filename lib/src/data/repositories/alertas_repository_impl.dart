// Datasources
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/notification/fcm_token_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/alerta_service.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_resumen_model.dart';

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

  // ============================================================
  // 1. OBTENER MIS ALERTAS
  // ============================================================
  @override
  Future<Resource<AlertaPaginated>> getMisAlertas({
    int page = 1,
    int limit = 10,
    String? estado,
    String? tipo,
    String? prioridad,
    bool? requiereConfirmacion,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData<AlertaPaginated>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return alertaService.getMisAlertas(
      token: token,
      page: page,
      limit: limit,
      estado: estado,
      tipo: tipo,
      prioridad: prioridad,
      requiereConfirmacion: requiereConfirmacion,
    );
  }

  // ============================================================
  // 2. OBTENER RESUMEN DE MIS ALERTAS
  // ============================================================
  @override
  Future<Resource<AlertaResumenModel>> getMisAlertasResumen() async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<AlertaResumenModel>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return alertaService.getMisAlertasResumen(token: token);
  }

  // ============================================================
  // 3. MARCAR ALERTA COMO RECIBIDA
  // ============================================================
  @override
  Future<Resource<AlertaDestinatarioModel>> marcarRecibida({
    required int alertaId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return alertaService.marcarRecibida(token: token, alertaId: alertaId);
  }

  // ============================================================
  // 4. MARCAR ALERTA COMO LEÍDA
  // ============================================================
  @override
  Future<Resource<AlertaDestinatarioModel>> marcarLeida({
    required int alertaId,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return alertaService.marcarLeida(token: token, alertaId: alertaId);
  }

  // ============================================================
  // 5. RESPONDER ALERTA
  // ============================================================
  @override
  Future<Resource<AlertaDestinatarioModel>> responderAlerta({
    required int alertaId,
    required String respuesta,
    String? observacion,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return alertaService.responderAlerta(
      token: token,
      alertaId: alertaId,
      respuesta: respuesta,
      observacion: observacion,
    );
  }

  // ============================================================
  // 6. MARCAR ALERTA COMO ATENDIDA
  // ============================================================
  @override
  Future<Resource<AlertaDestinatarioModel>> marcarAtendida({
    required int alertaId,
    String? observacion,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData<AlertaDestinatarioModel>(
        message: 'No existe una sesión iniciada.',
      );
    }

    return alertaService.marcarAtendida(
      token: token,
      alertaId: alertaId,
      observacion: observacion,
    );
  }

  // ============================================================
  // 7. REGISTRAR O ACTUALIZAR DISPOSITIVO FCM
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
  // 8. DESACTIVAR DISPOSITIVO FCM
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
