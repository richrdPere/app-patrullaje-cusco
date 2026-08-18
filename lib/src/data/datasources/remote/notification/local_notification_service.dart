import 'dart:async';
import 'dart:convert';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

// ============================================================
// CALLBACK
// ============================================================

typedef LocalNotificationTap = Future<void> Function(Map<String, dynamic> data);

class LocalNotificationService {
  LocalNotificationService._();

  static final LocalNotificationService instance = LocalNotificationService._();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  // ==========================================================
  // CANAL
  // ==========================================================

  static const AndroidNotificationChannel alertChannel =
      AndroidNotificationChannel(
        'alertas_criticas',
        'Alertas críticas',
        description: 'Alertas operativas y emergencias de serenazgo.',
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
      );

  // ==========================================================
  // ESTADO
  // ==========================================================

  bool _initialized = false;

  LocalNotificationTap? _onNotificationTap;

  Map<String, dynamic>? _pendingLaunchData;

  bool get isInitialized => _initialized;

  // ==========================================================
  // INICIALIZAR
  // ==========================================================

  Future<void> initialize({LocalNotificationTap? onNotificationTap}) async {
    /*
     * Aunque ya esté inicializado, permitimos actualizar el
     * callback porque AuthListener puede reconstruirse.
     */
    if (onNotificationTap != null) {
      _onNotificationTap = onNotificationTap;
    }

    if (_initialized) {
      return;
    }

    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );

    const darwinSettings = DarwinInitializationSettings(
      requestAlertPermission: false,
      requestBadgePermission: false,
      requestSoundPermission: false,
    );

    const initializationSettings = InitializationSettings(
      android: androidSettings,
      iOS: darwinSettings,
    );

    await _plugin.initialize(
      settings: initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );

    await _createAndroidChannel();
    await _requestAndroidPermission();
    await _loadLaunchNotification();

    _initialized = true;

    debugPrint('LocalNotificationService inicializado.');
  }

  // ==========================================================
  // ACTUALIZAR CALLBACK
  // ==========================================================

  void setOnNotificationTap(LocalNotificationTap? callback) {
    _onNotificationTap = callback;
  }

  void clearOnNotificationTap() {
    _onNotificationTap = null;
  }

  // ==========================================================
  // CREAR CANAL ANDROID
  // ==========================================================

  Future<void> _createAndroidChannel() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    await androidPlugin?.createNotificationChannel(alertChannel);
  }

  // ==========================================================
  // PERMISO ANDROID
  // ==========================================================

  Future<void> _requestAndroidPermission() async {
    final androidPlugin = _plugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();

    final granted = await androidPlugin?.requestNotificationsPermission();

    debugPrint('Permiso local notification Android: $granted');
  }

  // ==========================================================
  // NOTIFICACIÓN QUE ABRIÓ LA APP
  // ==========================================================

  Future<void> _loadLaunchNotification() async {
    final launchDetails = await _plugin.getNotificationAppLaunchDetails();

    final launchedFromNotification =
        launchDetails?.didNotificationLaunchApp ?? false;

    if (!launchedFromNotification) {
      return;
    }

    final payload = launchDetails?.notificationResponse?.payload;

    final data = _decodePayload(payload);

    if (data == null) {
      return;
    }

    /*
     * El router y la sesión pueden no estar listos todavía.
     * Guardamos temporalmente la navegación.
     */
    _pendingLaunchData = data;
  }

  // ==========================================================
  // RESPUESTA AL PULSAR NOTIFICACIÓN
  // ==========================================================

  void _onDidReceiveNotificationResponse(NotificationResponse response) {
    final data = _decodePayload(response.payload);

    if (data == null) {
      return;
    }

    unawaited(_dispatchNotificationTap(data));
  }

  Future<void> _dispatchNotificationTap(Map<String, dynamic> data) async {
    final callback = _onNotificationTap;

    if (callback == null) {
      /*
       * AuthListener todavía no configuró la navegación.
       */
      _pendingLaunchData = data;
      return;
    }

    try {
      await callback(data);
    } catch (error, stackTrace) {
      debugPrint(
        'Error procesando local notification: '
        '$error\n$stackTrace',
      );
    }
  }

  // ==========================================================
  // CONSUMIR NAVEGACIÓN PENDIENTE
  // ==========================================================

  Future<void> processPendingLaunchData() async {
    final data = _pendingLaunchData;

    if (data == null) {
      return;
    }

    final callback = _onNotificationTap;

    if (callback == null) {
      return;
    }

    /*
     * Se limpia antes de ejecutar para evitar doble navegación.
     */
    _pendingLaunchData = null;

    try {
      await callback(data);
    } catch (error, stackTrace) {
      /*
       * Si falla la navegación, conservamos el payload para
       * poder intentarlo posteriormente.
       */
      _pendingLaunchData = data;

      debugPrint(
        'Error procesando notificación pendiente: '
        '$error\n$stackTrace',
      );
    }
  }

  // ==========================================================
  // MOSTRAR MENSAJE REMOTO EN FOREGROUND
  // ==========================================================

  Future<void> showRemoteMessage(RemoteMessage message) async {
    if (!_initialized) {
      await initialize();
    }

    final notification = message.notification;

    final title =
        _firstNonEmpty([
          notification?.title,
          message.data['title']?.toString(),
          message.data['titulo']?.toString(),
        ]) ??
        'Nueva alerta';

    final body =
        _firstNonEmpty([
          notification?.body,
          message.data['body']?.toString(),
          message.data['mensaje']?.toString(),
          message.data['descripcion']?.toString(),
        ]) ??
        'Tienes una nueva alerta de serenazgo.';

    final alertaId = int.tryParse(message.data['alerta_id']?.toString() ?? '');

    final notificationId =
        alertaId ?? DateTime.now().millisecondsSinceEpoch.remainder(2147483647);

    final payloadData = <String, dynamic>{
      ...message.data,

      /*
       * Garantizamos que siempre pueda identificarse como alerta.
       */
      'type': message.data['type']?.toString() ?? 'ALERTA',

      if (alertaId != null) 'alerta_id': alertaId.toString(),
    };

    await _plugin.show(
      id: notificationId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          alertChannel.id,
          alertChannel.name,
          channelDescription: alertChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.alarm,
          icon: '@mipmap/ic_launcher',
          visibility: NotificationVisibility.public,
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payloadData),
    );
  }

  // ==========================================================
  // MOSTRAR NOTIFICACIÓN MANUAL
  // ==========================================================

  Future<void> showAlert({
    required int alertaId,
    required String title,
    required String body,
    Map<String, dynamic> data = const {},
  }) async {
    if (!_initialized) {
      await initialize();
    }

    final payload = <String, dynamic>{
      ...data,
      'type': 'ALERTA',
      'alerta_id': alertaId.toString(),
    };

    await _plugin.show(
      id: alertaId,
      title: title,
      body: body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          alertChannel.id,
          alertChannel.name,
          channelDescription: alertChannel.description,
          importance: Importance.max,
          priority: Priority.high,
          playSound: true,
          enableVibration: true,
          category: AndroidNotificationCategory.alarm,
          icon: '@mipmap/ic_launcher',
          autoCancel: true,
        ),
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
      payload: jsonEncode(payload),
    );
  }

  // ==========================================================
  // CANCELAR
  // ==========================================================

  Future<void> cancel(int notificationId) {
    return _plugin.cancel(id: notificationId);
  }

  Future<void> cancelAll() {
    return _plugin.cancelAll();
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  Map<String, dynamic>? _decodePayload(String? payload) {
    if (payload == null || payload.trim().isEmpty) {
      return null;
    }

    try {
      final decoded = jsonDecode(payload);

      if (decoded is Map<String, dynamic>) {
        return decoded;
      }

      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }

      return null;
    } catch (error, stackTrace) {
      debugPrint(
        'Payload de notificación inválido: '
        '$error\n$stackTrace',
      );

      return null;
    }
  }

  String? _firstNonEmpty(List<String?> values) {
    for (final value in values) {
      final normalized = value?.trim();

      if (normalized != null && normalized.isNotEmpty) {
        return normalized;
      }
    }

    return null;
  }
}
