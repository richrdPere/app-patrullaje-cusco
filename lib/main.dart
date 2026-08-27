import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'package:sis_patrullaje_cusco/blocProviders.dart';
import 'package:sis_patrullaje_cusco/injection.dart';

// Firebase
import 'package:sis_patrullaje_cusco/firebase_options.dart';

// Core
import 'package:sis_patrullaje_cusco/src/config/core/listeners/auth_listener.dart';
import 'package:sis_patrullaje_cusco/src/config/core/listeners/patrullaje_runtime_listener.dart';

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
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  
}

/// ================================================================
/// MAIN
/// ================================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es_PE', null);

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

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
        child: NotificationListener(
          child: PatrullajeRuntimeListener(
            child: MaterialApp.router(
              builder: FToastBuilder(),
              routerConfig: appRouter,
              debugShowCheckedModeBanner: false,
              title: 'Sistema Patrullaje',
              theme: AppTheme(selectedColor: 0).getTheme(),
            ),
          ),
        ),
      ),
    );
  }
}
