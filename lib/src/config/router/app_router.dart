// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/config/core/main_shell.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/incident_data_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/view/alertas_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/chat/chat_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/view/login_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/view/register_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/home_content.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/home_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa/mapa_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa_incident/mapa_incident_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/view/profile_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/view/profile_update_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/usuarios/usuarios_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/loading_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  debugLogDiagnostics: true,
  routes: [
    // AUTH
    GoRoute(path: '/login', builder: (_, __) => const LoginPage()),

    GoRoute(path: '/register', builder: (_, __) => const RegisterPage()),

    GoRoute(path: '/loading', builder: (_, __) => const LoadingPage()),

    // APP
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },

      routes: [
        // 1. HOME
        GoRoute(path: '/home', builder: (_, __) => const HomeContent()),

        // 2. MAPA
        GoRoute(
          path: '/mapa',
          builder: (_, __) => const MapaPage(),

          routes: [
            GoRoute(
              path: 'incident',

              builder: (context, state) {
                final incident = state.extra as IncidentData;

                return MapaIncidentPage(incident: incident);
              },
            ),
          ],
        ),

        // 4. USUARIOS
        GoRoute(path: '/usuarios', builder: (_, __) => const UsuariosPage()),

        // 5. ALERTAS
        GoRoute(path: '/alertas', builder: (_, __) => const AlertasPage()),
      ],
    ),

    // CHAT
    GoRoute(path: '/chat', builder: (_, __) => const ChatPage()),

    // PERFIL
    GoRoute(
      path: '/profile',

      builder: (_, __) => const ProfilePage(),

      routes: [
        GoRoute(
          path: 'update',

          builder: (context, state) {
            final user = state.extra as Usuario;

            return ProfileUpdatePage(user: user);
          },
        ),
      ],
    ),
  ],
);
