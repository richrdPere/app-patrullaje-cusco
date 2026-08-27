import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jwt_decoder/jwt_decoder.dart';

// Session
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';

// Home
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';

// Socket
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';

class AuthListener extends StatefulWidget {
  final Widget child;

  const AuthListener({super.key, required this.child});

  @override
  State<AuthListener> createState() => _AuthListenerState();
}

class _AuthListenerState extends State<AuthListener>
    with WidgetsBindingObserver {
  // ==========================================================
  // JWT
  // ==========================================================

  Timer? _tokenExpirationTimer;

  // ==========================================================
  // CONTROL DE PROCESOS
  // ==========================================================

  bool _processingAuthenticatedSession = false;
  bool _processingExpiredSession = false;
  bool _processingClosedSession = false;

  // ==========================================================
  // INIT
  // ==========================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addObserver(this);

    /*
     * BlocListener solamente escucha cambios posteriores.
     *
     * Si SessionBloc restauró la sesión antes de construir
     * AuthListener, debemos procesarla manualmente.
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

  // ==========================================================
  // CICLO DE VIDA
  // ==========================================================

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    if (state == AppLifecycleState.resumed) {
      unawaited(_validateCurrentSession());
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ====================================================
        // SESIÓN
        // ====================================================
        BlocListener<SessionBloc, SessionState>(
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

            await _processClosedSession();
          },
        ),

        // ====================================================
        // SOCKET
        // ====================================================
        BlocListener<SocketBloc, SocketState>(
          listenWhen: (previous, current) {
            return previous.isConnected != current.isConnected;
          },
          listener: _listenSocket,
        ),
      ],
      child: widget.child,
    );
  }

  // ==========================================================
  // PROCESAR SESIÓN AUTENTICADA
  // ==========================================================

  Future<void> _processAuthenticatedSession(SessionState state) async {
    if (_processingAuthenticatedSession ||
        _processingExpiredSession ||
        _processingClosedSession) {
      return;
    }

    _processingAuthenticatedSession = true;

    try {
      final authToken = _getAuthToken(state);

      if (authToken == null) {
        debugPrint(
          'La sesión está autenticada, '
          'pero no contiene JWT.',
        );

        await _closeSessionDueToInvalidToken(reason: 'TOKEN_AUSENTE');

        return;
      }

      if (!_isJwtValid(authToken)) {
        await _closeSessionDueToInvalidToken(
          reason: 'TOKEN_EXPIRADO_O_INVALIDO',
        );

        return;
      }

      debugPrint('Usuario autenticado.');
      debugPrint('JWT válido.');

      _scheduleJwtExpiration(authToken);

      if (!mounted) return;

      /*
       * NotificationListener inicializa FCM.
       *
       * PatrullajeRuntimeListener recupera el patrullaje
       * y coordina TrackingBloc.
       *
       * AuthListener solamente conecta Socket.IO.
       */
      context.read<SocketBloc>().add(const ConnectSocketEvent());
    } finally {
      _processingAuthenticatedSession = false;
    }
  }

  // ==========================================================
  // VALIDAR SESIÓN ACTUAL
  // ==========================================================

  Future<void> _validateCurrentSession() async {
    if (!mounted || _processingExpiredSession || _processingClosedSession) {
      return;
    }

    final sessionState = context.read<SessionBloc>().state;

    if (!sessionState.isAuthenticated) {
      return;
    }

    final authToken = _getAuthToken(sessionState);

    if (authToken == null || !_isJwtValid(authToken)) {
      await _closeSessionDueToInvalidToken(
        reason: 'TOKEN_EXPIRADO_AL_REANUDAR',
      );

      return;
    }

    /*
     * Reprograma la expiración porque la aplicación pudo
     * permanecer suspendida durante un periodo prolongado.
     */
    _scheduleJwtExpiration(authToken);

    if (!mounted) return;

    /*
     * Si el socket perdió su conexión mientras la aplicación
     * estaba suspendida, se solicita nuevamente la conexión.
     */
    final socketBloc = context.read<SocketBloc>();

    if (!socketBloc.state.isConnected) {
      socketBloc.add(const ConnectSocketEvent());
    }
  }

  // ==========================================================
  // VALIDAR JWT
  // ==========================================================

  bool _isJwtValid(String token) {
    try {
      final normalizedToken = token.trim();

      if (normalizedToken.isEmpty) {
        return false;
      }

      if (normalizedToken.split('.').length != 3) {
        debugPrint('El token no tiene formato JWT.');

        return false;
      }

      if (JwtDecoder.isExpired(normalizedToken)) {
        debugPrint('El JWT ya expiró.');

        return false;
      }

      return true;
    } catch (error) {
      debugPrint('No se pudo interpretar el JWT: $error');

      return false;
    }
  }

  // ==========================================================
  // PROGRAMAR EXPIRACIÓN JWT
  // ==========================================================

  void _scheduleJwtExpiration(String token) {
    _tokenExpirationTimer?.cancel();
    _tokenExpirationTimer = null;

    try {
      final expirationDate = JwtDecoder.getExpirationDate(token);

      final remainingTime = expirationDate.difference(DateTime.now());

      debugPrint('JWT expira en: $expirationDate');

      debugPrint(
        'Tiempo restante: '
        '${remainingTime.inMinutes} minutos',
      );

      if (remainingTime <= Duration.zero) {
        unawaited(_closeSessionDueToInvalidToken(reason: 'TOKEN_EXPIRADO'));

        return;
      }

      /*
       * Se agrega un segundo para evitar que pequeñas
       * diferencias de reloj disparen la validación antes
       * de la expiración efectiva.
       */
      final timerDuration = remainingTime + const Duration(seconds: 1);

      _tokenExpirationTimer = Timer(timerDuration, () {
        unawaited(
          _closeSessionDueToInvalidToken(reason: 'TOKEN_EXPIRADO_POR_TIEMPO'),
        );
      });
    } catch (error) {
      debugPrint(
        'No se pudo programar la expiración '
        'del JWT: $error',
      );

      unawaited(
        _closeSessionDueToInvalidToken(reason: 'JWT_SIN_EXPIRACION_VALIDA'),
      );
    }
  }

  // ==========================================================
  // CIERRE POR TOKEN INVÁLIDO
  // ==========================================================

  Future<void> _closeSessionDueToInvalidToken({required String reason}) async {
    if (_processingExpiredSession) {
      return;
    }

    _processingExpiredSession = true;

    try {
      debugPrint('Cerrando sesión. Motivo: $reason');

      _tokenExpirationTimer?.cancel();
      _tokenExpirationTimer = null;

      if (!mounted) return;

      /*
       * PatrullajeRuntimeListener detendrá TrackingBloc
       * cuando SessionBloc emita isAuthenticated = false.
       *
       * NotificationListener desactivará FCM.
       */
      context.read<SocketBloc>().add(const DisconnectSocketEvent());

      context.read<SessionBloc>().logout();
    } finally {
      _processingExpiredSession = false;
    }
  }

  // ==========================================================
  // SESIÓN CERRADA
  // ==========================================================

  Future<void> _processClosedSession() async {
    if (_processingClosedSession || _processingExpiredSession) {
      return;
    }

    _processingClosedSession = true;

    try {
      debugPrint('Usuario deslogueado.');

      _tokenExpirationTimer?.cancel();
      _tokenExpirationTimer = null;

      if (!mounted) return;

      /*
       * No se detiene TrackingBloc aquí porque esa tarea
       * pertenece a PatrullajeRuntimeListener.
       *
       * No se limpia FCM aquí porque esa tarea pertenece
       * a NotificationListener.
       */
      context.read<SocketBloc>().add(const DisconnectSocketEvent());
    } finally {
      _processingClosedSession = false;
    }
  }

  // ==========================================================
  // SOCKET
  // ==========================================================

  void _listenSocket(BuildContext context, SocketState state) {
    if (!state.isConnected) {
      debugPrint('Socket desconectado.');

      return;
    }

    debugPrint(
      'Socket conectado → '
      'inicializando listeners.',
    );

    /*
     * AuthListener únicamente inicializa los eventos
     * recibidos mediante Socket.IO.
     *
     * PatrullajeRuntimeListener recupera el patrullaje
     * activo mediante HomeBloc.
     */
    context.read<HomeBloc>().add(InitSocketListeners());
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

    _tokenExpirationTimer?.cancel();
    _tokenExpirationTimer = null;

    super.dispose();
  }
}
// import 'dart:async';

// import 'package:firebase_messaging/firebase_messaging.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:jwt_decoder/jwt_decoder.dart';

// // Session
// import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';

// // Router
// import 'package:sis_patrullaje_cusco/src/config/router/app_router.dart';

// // Firebase
// import 'package:sis_patrullaje_cusco/src/data/datasources/remote/firebase/firebase_messaging_service.dart';
// import 'package:sis_patrullaje_cusco/src/data/datasources/remote/notification/fcm_token_service.dart';

// // Ajustar este import a la ubicación real.
// import 'package:sis_patrullaje_cusco/src/data/datasources/remote/notification/local_notification_service.dart';

// // Resource
// import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// // Alertas
// import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';

// // Home
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';

// // Socket
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';

// // Tracking
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';

// class AuthListener extends StatefulWidget {
//   final Widget child;

//   const AuthListener({
//     super.key,
//     required this.child,
//   });

//   @override
//   State<AuthListener> createState() =>
//       _AuthListenerState();
// }

// class _AuthListenerState extends State<AuthListener>
//     with WidgetsBindingObserver {
//   // ==========================================================
//   // SERVICES
//   // ==========================================================

//   final FirebaseMessagingService
//       _firebaseMessagingService =
//       FirebaseMessagingService.instance;

//   final FcmTokenService _fcmTokenService =
//       FcmTokenService();

//   // ==========================================================
//   // SESSION
//   // ==========================================================

//   Timer? _tokenExpirationTimer;

//   /// JWT para el cual FCM fue registrado correctamente.
//   String? _jwtRegistrado;

//   /// Último JWT válido conocido. Se conserva para desactivar
//   /// el dispositivo antes o después del logout.
//   String? _ultimoAuthToken;

//   bool _inicializandoFcm = false;
//   bool _procesandoSesionExpirada = false;
//   bool _procesandoSesionAutenticada = false;
//   bool _procesandoSesionCerrada = false;

//   // ==========================================================
//   // INIT
//   // ==========================================================

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addObserver(this);

//     /*
//      * BlocListener solo escucha cambios posteriores.
//      * Si la sesión se restauró antes de construir AuthListener,
//      * debemos procesarla manualmente.
//      */
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       final sessionState =
//           context.read<SessionBloc>().state;

//       if (sessionState.isAuthenticated) {
//         unawaited(
//           _procesarSesionAutenticada(
//             sessionState,
//           ),
//         );
//       }
//     });
//   }

//   // ==========================================================
//   // CICLO DE VIDA
//   // ==========================================================

//   @override
//   void didChangeAppLifecycleState(
//     AppLifecycleState state,
//   ) {
//     super.didChangeAppLifecycleState(state);

//     if (state == AppLifecycleState.resumed) {
//       unawaited(_validarSesionActual());
//     }
//   }

//   // ==========================================================
//   // PROCESAR SESIÓN AUTENTICADA
//   // ==========================================================
//   Future<void> _procesarSesionAutenticada(
//     SessionState state,
//   ) async {
//     if (_procesandoSesionAutenticada ||
//         _procesandoSesionExpirada ||
//         _procesandoSesionCerrada) {
//       return;
//     }

//     _procesandoSesionAutenticada = true;

//     try {
//       final authToken =
//           state.user?.data.token.trim();

//       if (authToken == null ||
//           authToken.isEmpty) {
//         debugPrint(
//           'La sesión está autenticada, '
//           'pero no contiene JWT.',
//         );

//         await _cerrarSesionPorTokenInvalido(
//           motivo: 'TOKEN_AUSENTE',
//           authToken: null,
//         );

//         return;
//       }

//       if (!_esJwtValido(authToken)) {
//         await _cerrarSesionPorTokenInvalido(
//           motivo:
//               'TOKEN_EXPIRADO_O_INVALIDO',
//           authToken: authToken,
//         );

//         return;
//       }

//       /*
//        * Guardamos el último JWT válido antes de cualquier
//        * operación asíncrona.
//        */
//       _ultimoAuthToken = authToken;

//       debugPrint('Usuario autenticado.');
//       debugPrint('JWT válido.');

//       _programarExpiracionJwt(authToken);

//       /*
//        * FCM es complementario. Si falla, no bloquea Socket.IO
//        * ni cierra la sesión.
//        */
//       await _inicializarFcm(authToken);

//       if (!mounted) return;

//       context.read<SocketBloc>().add(
//             const ConnectSocketEvent(),
//           );
//     } finally {
//       _procesandoSesionAutenticada = false;
//     }
//   }

//   // ==========================================================
//   // VALIDAR JWT
//   // ==========================================================
//   bool _esJwtValido(String token) {
//     try {
//       final tokenLimpio = token.trim();

//       if (tokenLimpio.isEmpty) {
//         return false;
//       }

//       if (tokenLimpio.split('.').length != 3) {
//         debugPrint(
//           'El token no tiene formato JWT.',
//         );

//         return false;
//       }

//       if (JwtDecoder.isExpired(tokenLimpio)) {
//         debugPrint('El JWT ya expiró.');

//         return false;
//       }

//       return true;
//     } catch (error) {
//       debugPrint(
//         'No se pudo interpretar el JWT: $error',
//       );

//       return false;
//     }
//   }

//   Future<void> _validarSesionActual() async {
//     if (!mounted ||
//         _procesandoSesionExpirada ||
//         _procesandoSesionCerrada) {
//       return;
//     }

//     final sessionState =
//         context.read<SessionBloc>().state;

//     if (!sessionState.isAuthenticated) {
//       return;
//     }

//     final authToken =
//         sessionState.user?.data.token.trim();

//     if (authToken == null ||
//         !_esJwtValido(authToken)) {
//       await _cerrarSesionPorTokenInvalido(
//         motivo:
//             'TOKEN_EXPIRADO_AL_REANUDAR',
//         authToken: authToken,
//       );

//       return;
//     }

//     _ultimoAuthToken = authToken;

//     _programarExpiracionJwt(authToken);

//     /*
//      * Si el registro inicial falló, _jwtRegistrado será null
//      * y se intentará nuevamente.
//      */
//     if (_jwtRegistrado != authToken) {
//       await _inicializarFcm(authToken);
//     }
//   }

//   // ==========================================================
//   // PROGRAMAR EXPIRACIÓN JWT
//   // ==========================================================
//   void _programarExpiracionJwt(
//     String token,
//   ) {
//     _tokenExpirationTimer?.cancel();

//     try {
//       final expirationDate =
//           JwtDecoder.getExpirationDate(token);

//       final remainingTime =
//           expirationDate.difference(
//         DateTime.now(),
//       );

//       debugPrint(
//         'JWT expira en: $expirationDate',
//       );

//       debugPrint(
//         'Tiempo restante: '
//         '${remainingTime.inMinutes} minutos',
//       );

//       if (remainingTime <= Duration.zero) {
//         unawaited(
//           _cerrarSesionPorTokenInvalido(
//             motivo: 'TOKEN_EXPIRADO',
//             authToken: token,
//           ),
//         );

//         return;
//       }

//       final timerDuration =
//           remainingTime +
//               const Duration(seconds: 1);

//       _tokenExpirationTimer = Timer(
//         timerDuration,
//         () {
//           unawaited(
//             _cerrarSesionPorTokenInvalido(
//               motivo:
//                   'TOKEN_EXPIRADO_POR_TIEMPO',
//               authToken: token,
//             ),
//           );
//         },
//       );
//     } catch (error) {
//       debugPrint(
//         'No se pudo programar la expiración '
//         'del JWT: $error',
//       );

//       unawaited(
//         _cerrarSesionPorTokenInvalido(
//           motivo:
//               'JWT_SIN_EXPIRACION_VALIDA',
//           authToken: token,
//         ),
//       );
//     }
//   }

//   // ==========================================================
//   // INICIALIZAR FCM
//   // ==========================================================
//   Future<void> _inicializarFcm(
//     String authToken,
//   ) async {
//     if (_inicializandoFcm) {
//       return;
//     }

//     if (_jwtRegistrado == authToken &&
//         _firebaseMessagingService
//             .isInitialized) {
//       debugPrint(
//         'FCM ya fue inicializado '
//         'para esta sesión.',
//       );

//       return;
//     }

//     _inicializandoFcm = true;

//     try {
//       debugPrint(
//         'Inicializando Firebase Messaging...',
//       );

//       await _firebaseMessagingService.initialize(
//         // ====================================================
//         // REGISTRAR O RENOVAR TOKEN
//         // ====================================================
//         onTokenChanged: (
//           String fcmToken,
//         ) async {
//           debugPrint(
//             'Registrando dispositivo FCM '
//             'en backend...',
//           );

//           final result = await _fcmTokenService
//               .registrarActualizarToken(
//             token: authToken,
//             fcmToken: fcmToken,

//             /*
//              * Actualmente tu service admite deviceId,
//              * pero todavía no tienes un servicio que genere un
//              * identificador persistente de instalación.
//              */
//             deviceId: null,
//           );

//           if (result
//               is Success<
//                   Map<String, dynamic>>) {
//             debugPrint(
//               'Dispositivo FCM registrado '
//               'correctamente.',
//             );

//             return;
//           }

//           if (result
//               is ErrorData<
//                   Map<String, dynamic>>) {
//             throw Exception(result.message);
//           }

//           throw StateError(
//             'Respuesta desconocida al '
//             'registrar el dispositivo.',
//           );
//         },

//         // ====================================================
//         // MENSAJE EN PRIMER PLANO
//         // ====================================================
//         onForegroundMessage: (
//           RemoteMessage message,
//         ) async {
//           await _procesarMensajeForeground(
//             message,
//           );
//         },

//         // ====================================================
//         // ABRIR DESDE SEGUNDO PLANO
//         // ====================================================
//         onMessageOpened: (
//           RemoteMessage message,
//         ) async {
//           await _abrirNotificacionRemota(
//             message,
//           );
//         },
//       );

//       /*
//        * Solo se asigna después de registrar correctamente el
//        * token en el backend.
//        */
//       _jwtRegistrado = authToken;

//       /*
//        * Comprueba si la app fue abierta desde estado cerrado.
//        */
//       await _firebaseMessagingService
//           .processInitialMessage(
//         onMessageOpened:
//             _abrirNotificacionRemota,
//       );

//       debugPrint(
//         'Firebase Messaging inicializado.',
//       );
//     } catch (error, stackTrace) {
//       /*
//        * Permitimos que AppLifecycleState.resumed vuelva a
//        * intentar el registro.
//        */
//       _jwtRegistrado = null;

//       debugPrint(
//         'Error inicializando Firebase Messaging: '
//         '$error\n$stackTrace',
//       );
//     } finally {
//       _inicializandoFcm = false;
//     }
//   }

//   // ==========================================================
//   // MENSAJE FOREGROUND
//   // ==========================================================

//   Future<void> _procesarMensajeForeground(
//     RemoteMessage message,
//   ) async {
//     if (!_esMensajeAlerta(message)) {
//       debugPrint(
//         'Mensaje FCM ignorado: '
//         '${message.data}',
//       );

//       return;
//     }

//     /*
//      * Muestra visualmente la notificación mientras la app está
//      * abierta.
//      */
//     await LocalNotificationService.instance
//         .showRemoteMessage(message);

//     if (!mounted) return;

//     final alertaBloc =
//         context.read<AlertaBloc>();

//     /*
//      * El badge responde inmediatamente.
//      */
//     alertaBloc.add(
//       const NuevaAlertaRecibidaEvent(),
//     );

//     /*
//      * Después se consulta la fuente oficial en MySQL.
//      */
//     alertaBloc.add(
//       const RefreshMisAlertasEvent(),
//     );

//     alertaBloc.add(
//       const GetMisAlertasResumenEvent(),
//     );
//   }

//   // ==========================================================
//   // ABRIR PUSH
//   // ==========================================================

//   Future<void> _abrirNotificacionRemota(
//     RemoteMessage message,
//   ) async {
//     if (!_esMensajeAlerta(message)) {
//       return;
//     }

//     final alertaId = int.tryParse(
//       message.data['alerta_id']
//               ?.toString() ??
//           '',
//     );

//     if (!mounted) {
//       return;
//     }

//     final alertaBloc =
//         context.read<AlertaBloc>();

//     alertaBloc.add(
//       const RefreshMisAlertasEvent(),
//     );

//     alertaBloc.add(
//       const GetMisAlertasResumenEvent(),
//     );

//     /*
//      * Se abre el módulo. El query parameter podrá utilizarse
//      * luego para seleccionar la alerta correspondiente.
//      */
//     appRouter.goNamed(
//       'alertas',
//       queryParameters: {
//         if (alertaId != null)
//           'alertaId': alertaId.toString(),
//       },
//     );
//   }

//   // ==========================================================
//   // VALIDAR TIPO DE MENSAJE
//   // ==========================================================

//   bool _esMensajeAlerta(
//     RemoteMessage message,
//   ) {
//     final type =
//         message.data['type']
//             ?.toString()
//             .trim()
//             .toUpperCase();

//     return type == 'ALERTA';
//   }

//   // ==========================================================
//   // DESACTIVAR DISPOSITIVO FCM
//   // ==========================================================

//   Future<void> _desactivarDispositivoFcm({
//     required String? authToken,
//   }) async {
//     final normalizedAuthToken =
//         authToken?.trim();

//     if (normalizedAuthToken == null ||
//         normalizedAuthToken.isEmpty) {
//       return;
//     }

//     final fcmToken =
//         _firebaseMessagingService.currentToken;

//     if (fcmToken == null ||
//         fcmToken.trim().isEmpty) {
//       return;
//     }

//     try {
//       final result =
//           await _fcmTokenService.desactivarToken(
//         token: normalizedAuthToken,
//         fcmToken: fcmToken,
//         deviceId: null,
//       );

//       if (result
//           is Success<Map<String, dynamic>>) {
//         debugPrint(
//           'Dispositivo FCM desactivado.',
//         );

//         return;
//       }

//       if (result
//           is ErrorData<Map<String, dynamic>>) {
//         debugPrint(
//           'No se pudo desactivar el '
//           'dispositivo FCM: ${result.message}',
//         );
//       }
//     } catch (error, stackTrace) {
//       debugPrint(
//         'Error desactivando dispositivo FCM: '
//         '$error\n$stackTrace',
//       );
//     }
//   }

//   // ==========================================================
//   // CIERRE POR TOKEN INVÁLIDO
//   // ==========================================================

//   Future<void> _cerrarSesionPorTokenInvalido({
//     required String motivo,
//     required String? authToken,
//   }) async {
//     if (_procesandoSesionExpirada) {
//       return;
//     }

//     _procesandoSesionExpirada = true;

//     try {
//       debugPrint(
//         'Cerrando sesión. Motivo: $motivo',
//       );

//       _tokenExpirationTimer?.cancel();
//       _tokenExpirationTimer = null;

//       final tokenParaDesactivar =
//           authToken ?? _ultimoAuthToken;

//       await _desactivarDispositivoFcm(
//         authToken: tokenParaDesactivar,
//       );

//       if (!mounted) return;

//       context.read<TrackingBloc>().add(
//             const StopTrackingEvent(),
//           );

//       context.read<SocketBloc>().add(
//             const DisconnectSocketEvent(),
//           );

//       await _limpiarFcmLocal();

//       if (!mounted) return;

//       context.read<SessionBloc>().logout();

//       _ultimoAuthToken = null;
//     } finally {
//       _procesandoSesionExpirada = false;
//     }
//   }

//   // ==========================================================
//   // SESIÓN CERRADA
//   // ==========================================================

//   Future<void> _procesarSesionCerrada({
//     required String? tokenAnterior,
//   }) async {
//     if (_procesandoSesionCerrada ||
//         _procesandoSesionExpirada) {
//       return;
//     }

//     _procesandoSesionCerrada = true;

//     try {
//       debugPrint('Usuario deslogueado.');

//       _tokenExpirationTimer?.cancel();
//       _tokenExpirationTimer = null;

//       final tokenParaDesactivar =
//           tokenAnterior ?? _ultimoAuthToken;

//       await _desactivarDispositivoFcm(
//         authToken: tokenParaDesactivar,
//       );

//       if (!mounted) return;

//       context.read<TrackingBloc>().add(
//             const StopTrackingEvent(),
//           );

//       context.read<SocketBloc>().add(
//             const DisconnectSocketEvent(),
//           );

//       await _limpiarFcmLocal();

//       _ultimoAuthToken = null;
//     } finally {
//       _procesandoSesionCerrada = false;
//     }
//   }

//   // ==========================================================
//   // LIMPIAR FCM LOCAL
//   // ==========================================================

//   Future<void> _limpiarFcmLocal() async {
//     try {
//       await _firebaseMessagingService.dispose();

//       _jwtRegistrado = null;

//       debugPrint(
//         'Listeners de FCM limpiados.',
//       );
//     } catch (error, stackTrace) {
//       debugPrint(
//         'Error limpiando FCM: '
//         '$error\n$stackTrace',
//       );
//     }
//   }

//   // ==========================================================
//   // BUILD
//   // ==========================================================

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         // ====================================================
//         // SESSION
//         // ====================================================
//         BlocListener<
//             SessionBloc,
//             SessionState>(
//           listenWhen: (previous, current) {
//             return previous.isAuthenticated !=
//                     current.isAuthenticated ||
//                 previous.user != current.user;
//           },
//           listener: (context, state) async {
//             if (state.isAuthenticated) {
//               await _procesarSesionAutenticada(
//                 state,
//               );

//               return;
//             }

//             /*
//              * No se consulta nuevamente SessionBloc.state
//              * porque ese sería el estado actual sin usuario.
//              */
//             await _procesarSesionCerrada(
//               tokenAnterior: _ultimoAuthToken,
//             );
//           },
//         ),

//         // ====================================================
//         // SOCKET
//         // ====================================================
//         BlocListener<SocketBloc, SocketState>(
//           listenWhen: (previous, current) {
//             return previous.isConnected !=
//                 current.isConnected;
//           },
//           listener: (context, state) {
//             final homeBloc =
//                 context.read<HomeBloc>();

//             if (state.isConnected) {
//               debugPrint(
//                 'Socket conectado → '
//                 'Inicializando Home',
//               );

//               homeBloc.add(
//                 InitSocketListeners(),
//               );

//               homeBloc.add(
//                 LoadPatrullajeActivo(),
//               );

//               return;
//             }

//             debugPrint('Socket desconectado.');
//           },
//         ),
//       ],
//       child: widget.child,
//     );
//   }

//   // ==========================================================
//   // DISPOSE
//   // ==========================================================

//   @override
//   void dispose() {
//     WidgetsBinding.instance.removeObserver(this);

//     _tokenExpirationTimer?.cancel();

//     /*
//      * dispose no puede ser async.
//      */
//     unawaited(
//       _firebaseMessagingService.dispose(),
//     );

//     super.dispose();
//   }
// }
