import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Session
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';

// Firebase
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/firebase/firebase_messaging_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/notification/fcm_token_service.dart';

// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Home
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';

// Socket
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';

// Tracking
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';

class AuthListener extends StatefulWidget {
  final Widget child;

  const AuthListener({super.key, required this.child});

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener>
    with WidgetsBindingObserver {
  final FirebaseMessagingService _firebaseMessagingService =
      FirebaseMessagingService.instance;

  final FcmTokenService _fcmTokenService = FcmTokenService();

  Timer? _tokenExpirationTimer;

  String? _jwtRegistrado;

  bool _inicializandoFcm = false;
  bool _procesandoSesionExpirada = false;
  bool _procesandoSesionAutenticada = false;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    /*
     * BlocListener solo escucha cambios posteriores.
     *
     * Si la sesión ya fue restaurada antes de construir este widget,
     * debemos revisarla manualmente.
     */
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final sessionState = context.read<SessionBloc>().state;

      if (sessionState.isAuthenticated) {
        unawaited(_procesarSesionAutenticada(sessionState));
      }
    });
  }

  // ============================================================
  // CICLO DE VIDA
  // ============================================================
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    /*
     * Los temporizadores pueden no ejecutarse con exactitud
     * cuando Android suspende la aplicación.
     *
     * Por eso volvemos a comprobar el token al regresar.
     */
    if (state == AppLifecycleState.resumed) {
      unawaited(_validarSesionActual());
    }
  }

  // ============================================================
  // PROCESAR USUARIO AUTENTICADO
  // ============================================================
  Future<void> _procesarSesionAutenticada(SessionState state) async {
    if (_procesandoSesionAutenticada || _procesandoSesionExpirada) {
      return;
    }

    _procesandoSesionAutenticada = true;

    try {
      final authToken = state.user?.data.token;

      if (authToken == null || authToken.trim().isEmpty) {
        debugPrint('⚠️ La sesión está autenticada, pero no contiene JWT.');

        await _cerrarSesionPorTokenInvalido(
          motivo: 'TOKEN_AUSENTE',
          authToken: null,
        );

        return;
      }

      final tokenValido = _esJwtValido(authToken);

      if (!tokenValido) {
        await _cerrarSesionPorTokenInvalido(
          motivo: 'TOKEN_EXPIRADO_O_INVALIDO',
          authToken: authToken,
        );

        return;
      }

      debugPrint('🟢 Usuario autenticado');
      debugPrint('✅ JWT válido');

      /*
       * Programa el cierre automático de la sesión.
       */
      _programarExpiracionJwt(authToken);

      /*
       * Inicializa y registra FCM.
       */
      await _inicializarFcm(state, authToken);

      if (!mounted) return;

      /*
       * FCM no debe bloquear Socket.IO.
       */
      context.read<SocketBloc>().add(const ConnectSocketEvent());
    } finally {
      _procesandoSesionAutenticada = false;
    }
  }

  // ============================================================
  // VALIDAR JWT
  // ============================================================

  bool _esJwtValido(String token) {
    try {
      final tokenLimpio = token.trim();

      if (tokenLimpio.isEmpty) {
        return false;
      }

      /*
       * Un JWT normalmente contiene:
       *
       * header.payload.signature
       */
      if (tokenLimpio.split('.').length != 3) {
        debugPrint('⚠️ El token no tiene formato JWT.');

        return false;
      }

      if (JwtDecoder.isExpired(tokenLimpio)) {
        debugPrint('⌛ El JWT ya expiró.');

        return false;
      }

      return true;
    } catch (error) {
      debugPrint('❌ No se pudo interpretar el JWT: $error');

      return false;
    }
  }

  Future<void> _validarSesionActual() async {
    if (!mounted || _procesandoSesionExpirada) {
      return;
    }

    final sessionState = context.read<SessionBloc>().state;

    if (!sessionState.isAuthenticated) {
      return;
    }

    final authToken = sessionState.user?.data.token;

    if (authToken == null || !_esJwtValido(authToken)) {
      await _cerrarSesionPorTokenInvalido(
        motivo: 'TOKEN_EXPIRADO_AL_REANUDAR',
        authToken: authToken,
      );

      return;
    }

    /*
     * Reprogramamos el timer por si la aplicación estuvo suspendida.
     */
    _programarExpiracionJwt(authToken);

    /*
     * Si por alguna razón FCM no quedó registrado,
     * intentamos inicializarlo nuevamente.
     */
    if (_jwtRegistrado != authToken) {
      await _inicializarFcm(sessionState, authToken);
    }
  }

  // ============================================================
  // PROGRAMAR EXPIRACIÓN
  // ============================================================
  void _programarExpiracionJwt(String token) {
    _tokenExpirationTimer?.cancel();

    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);

      final now = DateTime.now();

      final remainingTime = expirationDate.difference(now);

      debugPrint('🕒 JWT expira en: $expirationDate');

      debugPrint(
        '🕒 Tiempo restante: '
        '${remainingTime.inMinutes} minutos',
      );

      if (remainingTime <= Duration.zero) {
        unawaited(
          _cerrarSesionPorTokenInvalido(
            motivo: 'TOKEN_EXPIRADO',
            authToken: token,
          ),
        );

        return;
      }

      /*
       * Puedes cerrar exactamente al expirar.
       *
       * Se agrega un pequeño margen para evitar diferencias
       * de milisegundos entre el dispositivo y el servidor.
       */
      final duracionTimer = remainingTime + const Duration(seconds: 1);

      _tokenExpirationTimer = Timer(duracionTimer, () {
        unawaited(
          _cerrarSesionPorTokenInvalido(
            motivo: 'TOKEN_EXPIRADO_POR_TIEMPO',
            authToken: token,
          ),
        );
      });
    } catch (error) {
      debugPrint(
        '❌ No se pudo programar la expiración del JWT: '
        '$error',
      );

      unawaited(
        _cerrarSesionPorTokenInvalido(
          motivo: 'JWT_SIN_EXPIRACION_VALIDA',
          authToken: token,
        ),
      );
    }
  }

  // ============================================================
  // FIREBASE
  // ============================================================
  Future<void> _inicializarFcm(SessionState state, String authToken) async {
    if (_inicializandoFcm) {
      return;
    }

    if (_jwtRegistrado == authToken) {
      debugPrint('ℹ️ FCM ya fue inicializado para esta sesión.');

      return;
    }

    _inicializandoFcm = true;

    try {
      debugPrint('🔔 Inicializando Firebase Messaging...');

      await _firebaseMessagingService.initialize(
        onTokenChanged: (fcmToken) async {
          debugPrint('📱 Registrando dispositivo FCM en backend...');

          final result = await _fcmTokenService.registrarActualizarToken(
            token: authToken,
            fcmToken: fcmToken,
          );

          if (result is Success<Map<String, dynamic>>) {
            debugPrint('✅ Dispositivo FCM registrado correctamente.');

            return;
          }

          if (result is ErrorData<Map<String, dynamic>>) {
            debugPrint(
              '❌ No se pudo registrar el dispositivo FCM: '
              '${result.message}',
            );

            /*
             * No cerramos la sesión por un error de FCM.
             * FCM es complementario a la autenticación.
             */
            return;
          }
        },
      );

      _jwtRegistrado = authToken;

      debugPrint('✅ Firebase Messaging inicializado.');
    } catch (error, stackTrace) {
      debugPrint(
        '❌ Error inicializando Firebase Messaging: '
        '$error\n$stackTrace',
      );

      /*
       * No se bloquea el inicio de sesión.
       */
    } finally {
      _inicializandoFcm = false;
    }
  }

  // ============================================================
  // DESACTIVAR DISPOSITIVO FCM
  // ============================================================
  Future<void> _desactivarDispositivoFcm({required String? authToken}) async {
    if (authToken == null || authToken.trim().isEmpty) {
      return;
    }

    final fcmToken = _firebaseMessagingService.currentToken;

    if (fcmToken == null || fcmToken.trim().isEmpty) {
      return;
    }

    try {
      final result = await _fcmTokenService.desactivarToken(
        token: authToken,
        fcmToken: fcmToken,
      );

      if (result is Success<Map<String, dynamic>>) {
        debugPrint('✅ Dispositivo FCM desactivado.');

        return;
      }

      if (result is ErrorData<Map<String, dynamic>>) {
        debugPrint(
          '⚠️ No se pudo desactivar el dispositivo FCM: '
          '${result.message}',
        );
      }
    } catch (error) {
      debugPrint('⚠️ Error desactivando dispositivo FCM: $error');
    }
  }

  // ============================================================
  // SESIÓN EXPIRADA
  // ============================================================
  Future<void> _cerrarSesionPorTokenInvalido({
    required String motivo,
    required String? authToken,
  }) async {
    if (_procesandoSesionExpirada) {
      return;
    }

    _procesandoSesionExpirada = true;

    debugPrint('🔐 Cerrando sesión. Motivo: $motivo');

    _tokenExpirationTimer?.cancel();
    _tokenExpirationTimer = null;

    /*
     * Intentamos desactivar el dispositivo antes de limpiar
     * el estado de sesión.
     *
     * Si el JWT ya expiró, el backend probablemente responderá
     * 401. Ese fallo no debe impedir el logout local.
     */
    await _desactivarDispositivoFcm(authToken: authToken);

    if (!mounted) {
      _procesandoSesionExpirada = false;
      return;
    }

    context.read<TrackingBloc>().add(const StopTrackingEvent());

    context.read<SocketBloc>().add(const DisconnectSocketEvent());

    await _limpiarFcmLocal();

    if (!mounted) {
      _procesandoSesionExpirada = false;
      return;
    }

    /*
     * Esto debe provocar que tu GoRouter/authRedirect
     * redirija a /login.
     */
    context.read<SessionBloc>().logout();

    _procesandoSesionExpirada = false;
  }

  // ============================================================
  // CIERRE DE SESIÓN NORMAL
  // ============================================================
  Future<void> _procesarSesionCerrada({required String? tokenAnterior}) async {
    debugPrint('🔴 Usuario deslogueado');

    _tokenExpirationTimer?.cancel();
    _tokenExpirationTimer = null;

    /*
     * En un logout normal, idealmente el token FCM debe
     * desactivarse antes de ejecutar SessionBloc.logout().
     *
     * Este intento sirve como respaldo si todavía conservamos
     * el JWT anterior.
     */
    await _desactivarDispositivoFcm(authToken: tokenAnterior);

    if (!mounted) return;

    context.read<TrackingBloc>().add(const StopTrackingEvent());

    context.read<SocketBloc>().add(const DisconnectSocketEvent());

    await _limpiarFcmLocal();
  }

  // ============================================================
  // LIMPIAR FCM LOCAL
  // ============================================================
  Future<void> _limpiarFcmLocal() async {
    try {
      await _firebaseMessagingService.dispose();

      _jwtRegistrado = null;

      debugPrint('🧹 Listener FCM limpiado.');
    } catch (error, stackTrace) {
      debugPrint(
        '⚠️ Error limpiando FCM: '
        '$error\n$stackTrace',
      );
    }
  }

  // ============================================================
  // BUILD
  // ============================================================
  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ======================================================
        // SESSION LISTENER
        // ======================================================
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) {
            return previous.isAuthenticated != current.isAuthenticated ||
                previous.user != current.user;
          },
          listener: (context, state) async {
            final previousState = context.read<SessionBloc>().state;

            /*
             * Usuario autenticado.
             */
            if (state.isAuthenticated) {
              await _procesarSesionAutenticada(state);

              return;
            }

            /*
             * La sesión ya no está autenticada.
             *
             * En este punto el estado actual posiblemente ya no
             * conserva el JWT, por lo que este método solo realiza
             * la limpieza local.
             */
            await _procesarSesionCerrada(
              tokenAnterior: previousState.user?.data.token,
            );
          },
        ),

        // ======================================================
        // SOCKET LISTENER
        // ======================================================
        BlocListener<SocketBloc, SocketState>(
          listenWhen: (previous, current) {
            return previous.isConnected != current.isConnected;
          },
          listener: (context, state) {
            final homeBloc = context.read<HomeBloc>();

            if (state.isConnected) {
              debugPrint('🟢 Socket conectado → Inicializando Home');

              homeBloc.add(InitSocketListeners());

              homeBloc.add(LoadPatrullajeActivo());

              return;
            }

            debugPrint('🔴 Socket desconectado');
          },
        ),
      ],
      child: widget.child,
    );
  }

  // ============================================================
  // DISPOSE
  // ============================================================

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);

    _tokenExpirationTimer?.cancel();

    super.dispose();
  }
}
