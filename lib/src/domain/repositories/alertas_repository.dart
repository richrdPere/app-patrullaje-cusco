// Models
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_destinatario_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_resumen_model.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class AlertaRepository {

  // ============================================================
  // 1. OBTENER MIS ALERTAS
  // ============================================================
  Future<Resource<AlertaPaginated>> getMisAlertas({
    int page = 1,
    int limit = 10,
    String? estado,
    String? tipo,
    String? prioridad,
    bool? requiereConfirmacion,
  });

  // ============================================================
  // 2. OBTENER RESUMEN DE MIS ALERTAS
  // ============================================================
  Future<Resource<AlertaResumenModel>> getMisAlertasResumen();

  // ============================================================
  // 3. MARCAR ALERTA COMO RECIBIDA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> marcarRecibida({
    required int alertaId,
  });

  // ============================================================
  // 4. MARCAR ALERTA COMO LEÍDA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> marcarLeida({
    required int alertaId,
  });

  // ============================================================
  // 5. RESPONDER ALERTA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> responderAlerta({
    required int alertaId,
    required String respuesta,
    String? observacion,
  });

  // ============================================================
  // 6. MARCAR ALERTA COMO ATENDIDA
  // ============================================================
  Future<Resource<AlertaDestinatarioModel>> marcarAtendida({
    required int alertaId,
    String? observacion,
  });

  // ============================================================
  // 7. REGISTRAR O ACTUALIZAR DISPOSITIVO FCM
  // ============================================================
  Future<Resource<Map<String, dynamic>>> registrarDispositivo({
    required String fcmToken,
    String? deviceId,
  });

  // ============================================================
  // 8. DESACTIVAR DISPOSITIVO FCM
  // ============================================================
  Future<Resource<Map<String, dynamic>>> desactivarDispositivo({
    required String fcmToken,
    String? deviceId,
  });
}
