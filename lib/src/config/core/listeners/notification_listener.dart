import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';

import 'package:sis_patrullaje_cusco/src/config/router/app_router.dart';

import 'package:sis_patrullaje_cusco/src/data/datasources/remote/firebase/firebase_messaging_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/notification/fcm_token_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/notification/local_notification_service.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';

class NotificationListener extends StatefulWidget {
  final Widget child;

  const NotificationListener({super.key, required this.child});

  @override
  State<NotificationListener> createState() => _NotificationListenerState();
}

class _NotificationListenerState extends State<NotificationListener>
    with WidgetsBindingObserver {
  // ==========================================================
  // SERVICES
  // ==========================================================

  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService.instance;

  final FcmTokenService _fcmTokenService = FcmTokenService();

  // ==========================================================
  // CONTROL DE SESIÓN FCM
  // ==========================================================

  /// JWT para el cual Firebase Messaging fue inicializado
  /// y el dispositivo quedó registrado en el backend.
  String? _registeredJwt;

  /// Último JWT autenticado conocido.
  ///
  /// Se conserva para poder desactivar el token FCM cuando
  /// SessionBloc ya haya eliminado el usuario de su estado.
  String? _lastAuthToken;

  bool _isInitializing = false;
  bool _isClosingNotificationSession = false;

  // ==========================================================
  // CICLO DE VIDA
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    /*
     * BlocListener únicamente detecta cambios posteriores.
     * Si la sesión fue restaurada antes de construir este widget,
     * debemos procesarla manualmente.
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final sessionState = context.read<SessionBloc>().state;

      if (!sessionState.isAuthenticated) {
        return;
      }

      unawaited(_processAuthenticatedSession(sessionState));
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state != AppLifecycleState.resumed) {
      return;
    }

    /*
     * Si la inicialización o el registro del token fallaron,
     * se intenta nuevamente cuando la app vuelve a primer plano.
     */
    unawaited(_retryInitialization());
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return BlocListener<SessionBloc, SessionState>(
      listenWhen: (previous, current) {
        final previousToken = _getAuthToken(previous);

        final currentToken = _getAuthToken(current);

        return previous.isAuthenticated != current.isAuthenticated ||
            previousToken != currentToken;
      },
      listener: (context, state) async {
        if (state.isAuthenticated) {
          await _processAuthenticatedSession(state);

          return;
        }

        await _processClosedSession(previousAuthToken: _lastAuthToken);
      },
      child: widget.child,
    );
  }

  // ==========================================================
  // SESIÓN AUTENTICADA
  // ==========================================================

  Future<void> _processAuthenticatedSession(SessionState state) async {
    if (_isInitializing || _isClosingNotificationSession) {
      return;
    }

    final authToken = _getAuthToken(state);

    if (authToken == null) {
      debugPrint('No se inicializó FCM: la sesión no contiene JWT.');

      return;
    }

    _lastAuthToken = authToken;

    /*
     * Evita volver a registrar FCM para la misma sesión.
     */
    if (_registeredJwt == authToken &&
        _firebaseMessagingService.isInitialized) {
      debugPrint(
        'Firebase Messaging ya está inicializado '
        'para la sesión actual.',
      );

      return;
    }

    await _initializeFirebaseMessaging(authToken: authToken);
  }

  // ==========================================================
  // INICIALIZAR FIREBASE MESSAGING
  // ==========================================================

  Future<void> _initializeFirebaseMessaging({required String authToken}) async {
    if (_isInitializing) return;

    _isInitializing = true;

    try {
      debugPrint('Inicializando Firebase Messaging...');

      await _firebaseMessagingService.initialize(
        // ====================================================
        // TOKEN NUEVO O RENOVADO
        // ====================================================
        onTokenChanged: (String fcmToken) async {
          await _registerOrUpdateToken(
            authToken: authToken,
            fcmToken: fcmToken,
          );
        },

        // ====================================================
        // MENSAJE CON APP ABIERTA
        // ====================================================
        onForegroundMessage: (RemoteMessage message) async {
          await _processForegroundMessage(message);
        },

        // ====================================================
        // NOTIFICACIÓN ABIERTA
        // ====================================================
        onMessageOpened: (RemoteMessage message) async {
          await _openRemoteNotification(message);
        },
      );

      if (!mounted) return;

      /*
       * Verificamos que la sesión no haya cambiado mientras
       * Firebase estaba inicializándose.
       */
      final currentState = context.read<SessionBloc>().state;

      final currentToken = _getAuthToken(currentState);

      if (!currentState.isAuthenticated || currentToken != authToken) {
        debugPrint('La sesión cambió durante la inicialización de FCM.');

        return;
      }

      _registeredJwt = authToken;
      _lastAuthToken = authToken;

      /*
       * Procesa la notificación que abrió la aplicación
       * desde un estado completamente cerrado.
       */
      await _firebaseMessagingService.processInitialMessage(
        onMessageOpened: _openRemoteNotification,
      );

      debugPrint('Firebase Messaging inicializado correctamente.');
    } catch (error, stackTrace) {
      /*
       * Al mantenerse null, el ciclo de vida podrá volver
       * a intentar la inicialización.
       */
      _registeredJwt = null;

      debugPrint(
        'Error inicializando Firebase Messaging: '
        '$error\n$stackTrace',
      );
    } finally {
      _isInitializing = false;
    }
  }

  // ==========================================================
  // REGISTRAR TOKEN EN BACKEND
  // ==========================================================

  Future<void> _registerOrUpdateToken({
    required String authToken,
    required String fcmToken,
  }) async {
    final normalizedFcmToken = fcmToken.trim();

    if (normalizedFcmToken.isEmpty) {
      throw StateError('Firebase devolvió un token FCM vacío.');
    }

    debugPrint('Registrando dispositivo FCM en el backend...');

    final result = await _fcmTokenService.registrarActualizarToken(
      token: authToken,
      fcmToken: normalizedFcmToken,

      /*
       * Puede sustituirse cuando tengas un servicio
       * de identificador persistente de instalación.
       */
      deviceId: null,
    );

    if (result is Success<Map<String, dynamic>>) {
      debugPrint('Dispositivo FCM registrado correctamente.');

      return;
    }

    if (result is ErrorData<Map<String, dynamic>>) {
      throw Exception(result.message);
    }

    throw StateError('Respuesta desconocida al registrar el dispositivo FCM.');
  }

  // ==========================================================
  // MENSAJE EN PRIMER PLANO
  // ==========================================================

  Future<void> _processForegroundMessage(RemoteMessage message) async {
    if (!_isAlertMessage(message)) {
      debugPrint('Mensaje FCM ignorado: ${message.data}');

      return;
    }

    /*
     * Android normalmente no muestra automáticamente una
     * notificación FCM cuando la aplicación está abierta.
     */
    await LocalNotificationService.instance.showRemoteMessage(message);

    if (!mounted) return;

    final alertaBloc = context.read<AlertaBloc>();

    /*
     * Actualización inmediata del badge.
     */
    alertaBloc.add(const NuevaAlertaRecibidaEvent());

    /*
     * Después se consulta el estado oficial del backend.
     */
    alertaBloc.add(const RefreshMisAlertasEvent());

    alertaBloc.add(const GetMisAlertasResumenEvent());
  }

  // ==========================================================
  // ABRIR NOTIFICACIÓN
  // ==========================================================

  Future<void> _openRemoteNotification(RemoteMessage message) async {
    if (!_isAlertMessage(message)) {
      return;
    }

    final alertId = int.tryParse(
      message.data['alerta_id']?.toString().trim() ?? '',
    );

    if (!mounted) return;

    final sessionState = context.read<SessionBloc>().state;

    /*
     * No debe navegar al área privada si la sesión
     * ya no está autenticada.
     */
    if (!sessionState.isAuthenticated) {
      debugPrint(
        'No se abrió la alerta porque no existe '
        'una sesión autenticada.',
      );

      return;
    }

    final alertaBloc = context.read<AlertaBloc>();

    alertaBloc.add(const RefreshMisAlertasEvent());

    alertaBloc.add(const GetMisAlertasResumenEvent());

    appRouter.goNamed(
      'alertas',
      queryParameters: {if (alertId != null) 'alertaId': alertId.toString()},
    );
  }

  // ==========================================================
  // VALIDAR TIPO DE MENSAJE
  // ==========================================================

  bool _isAlertMessage(RemoteMessage message) {
    final type = message.data['type']?.toString().trim().toUpperCase();

    return type == 'ALERTA';
  }

  // ==========================================================
  // REINTENTAR INICIALIZACIÓN
  // ==========================================================

  Future<void> _retryInitialization() async {
    if (!mounted || _isInitializing || _isClosingNotificationSession) {
      return;
    }

    final sessionState = context.read<SessionBloc>().state;

    if (!sessionState.isAuthenticated) {
      return;
    }

    final authToken = _getAuthToken(sessionState);

    if (authToken == null) {
      return;
    }

    /*
     * Si ya está correctamente inicializado para este JWT,
     * no es necesario repetir el proceso.
     */
    if (_registeredJwt == authToken &&
        _firebaseMessagingService.isInitialized) {
      return;
    }

    await _initializeFirebaseMessaging(authToken: authToken);
  }

  // ==========================================================
  // SESIÓN CERRADA
  // ==========================================================

  Future<void> _processClosedSession({
    required String? previousAuthToken,
  }) async {
    if (_isClosingNotificationSession) {
      return;
    }

    _isClosingNotificationSession = true;

    try {
      final tokenToDeactivate = previousAuthToken ?? _lastAuthToken;

      await _deactivateFcmDevice(authToken: tokenToDeactivate);

      await _clearLocalFcm();

      _lastAuthToken = null;
    } finally {
      _isClosingNotificationSession = false;
    }
  }

  // ==========================================================
  // DESACTIVAR DISPOSITIVO EN BACKEND
  // ==========================================================

  Future<void> _deactivateFcmDevice({required String? authToken}) async {
    final normalizedAuthToken = authToken?.trim();

    if (normalizedAuthToken == null || normalizedAuthToken.isEmpty) {
      return;
    }

    final fcmToken = _firebaseMessagingService.currentToken;

    if (fcmToken == null || fcmToken.trim().isEmpty) {
      return;
    }

    try {
      final result = await _fcmTokenService.desactivarToken(
        token: normalizedAuthToken,
        fcmToken: fcmToken.trim(),
        deviceId: null,
      );

      if (result is Success<Map<String, dynamic>>) {
        debugPrint('Dispositivo FCM desactivado.');

        return;
      }

      if (result is ErrorData<Map<String, dynamic>>) {
        debugPrint(
          'No se pudo desactivar el dispositivo FCM: '
          '${result.message}',
        );
      }
    } catch (error, stackTrace) {
      /*
       * Un error al desactivar FCM no debe impedir
       * el cierre de la sesión.
       */
      debugPrint(
        'Error desactivando dispositivo FCM: '
        '$error\n$stackTrace',
      );
    }
  }

  // ==========================================================
  // LIMPIAR FCM LOCAL
  // ==========================================================

  Future<void> _clearLocalFcm() async {
    try {
      await _firebaseMessagingService.dispose();

      _registeredJwt = null;

      debugPrint('Listeners locales de Firebase Messaging eliminados.');
    } catch (error, stackTrace) {
      debugPrint(
        'Error limpiando Firebase Messaging: '
        '$error\n$stackTrace',
      );
    }
  }

  // ==========================================================
  // OBTENER JWT
  // ==========================================================

  String? _getAuthToken(SessionState state) {
    final token = state.user?.data.token.trim();

    if (token == null || token.isEmpty) {
      return null;
    }

    return token;
  }

  // ==========================================================
  // DISPOSE
  // ==========================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    /*
     * dispose no puede ser async. Aquí solo eliminamos
     * listeners locales; no desactivamos el dispositivo en
     * el backend porque esto también sucede al reconstruir
     * widgets durante el uso normal.
     */
    unawaited(_firebaseMessagingService.dispose());

    super.dispose();
  }
}
