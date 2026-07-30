import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:sis_patrullaje_cusco/blocProviders.dart';
import 'package:sis_patrullaje_cusco/injection.dart';

// Firebase
import 'package:sis_patrullaje_cusco/firebase_options.dart';

// Core
import 'package:sis_patrullaje_cusco/src/config/core/auth_listener.dart';

// Routes
import 'package:sis_patrullaje_cusco/src/config/router/app_router.dart';

// Theme
import 'package:sis_patrullaje_cusco/src/config/theme/app_theme.dart';

/// ================================================================
/// HANDLER DE MENSAJES EN SEGUNDO PLANO
/// ================================================================
///
/// Debe estar fuera de cualquier clase.
///
/// Se ejecuta cuando llega una notificación y la aplicación está:
/// - En segundo plano.
/// - Cerrada, dependiendo del tipo de mensaje y del sistema operativo.
///
@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  /*
   * El handler puede ejecutarse en un isolate separado,
   * por eso Firebase debe inicializarse nuevamente aquí.
   */
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  debugPrint('========================================');
  debugPrint('FCM - MENSAJE EN SEGUNDO PLANO');
  debugPrint('Message ID: ${message.messageId}');
  debugPrint('Título: ${message.notification?.title}');
  debugPrint('Mensaje: ${message.notification?.body}');
  debugPrint('Data: ${message.data}');
  debugPrint('========================================');
}

/// ================================================================
/// MAIN
/// ================================================================

Future<void> main() async {
  /*
   * Obligatorio antes de ejecutar código asíncrono
   * o usar plugins antes de runApp().
   */
  WidgetsFlutterBinding.ensureInitialized();

  /*
   * Inicializa Firebase utilizando la configuración
   * generada por FlutterFire CLI.
   */
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  /*
   * Registra el handler de notificaciones recibidas
   * cuando la aplicación está en segundo plano.
   */
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  /*
   * Inicializa tus dependencias con injectable/get_it.
   *
   * Se ejecuta después de Firebase por si posteriormente
   * algún servicio inyectado depende de Firebase.
   */
  await configureDependencies();

  runApp(const MyApp());
}

/// ================================================================
/// APLICACIÓN
/// ================================================================

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: blocProviders,
      child: AuthListener(
        child: MaterialApp.router(
          builder: FToastBuilder(),
          routerConfig: appRouter,
          debugShowCheckedModeBanner: false,
          title: 'Sistema Patrullaje',
          theme: AppTheme(selectedColor: 0).getTheme(),
        ),
      ),
    );
  }
}
