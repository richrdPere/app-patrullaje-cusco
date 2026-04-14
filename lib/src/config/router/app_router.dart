// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/incident_data_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/chat/chat_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/view/login_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/view/register_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/home_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa/mapa_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa_incident/mapa_incident_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/view/profile_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/view/profile_update_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/usuarios/usuarios_page.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/loading_page.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/home',
  debugLogDiagnostics: true,
  routes: [
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginPage(),
    ),
    GoRoute(
      path: '/register',
      name: 'register',
      builder: (context, state) => const RegisterPage(),
    ),
    GoRoute(
      path: '/home',
      name: HomePage.name,
      builder: (context, state) => const HomePage(),
    ),
    GoRoute(
      path: '/usuarios',
      name: 'usuarios',
      builder: (context, state) => const UsuariosPage(),
    ),
    GoRoute(
      path: '/chat',
      name: 'chat',
      builder: (context, state) => const ChatPage(),
    ),
    GoRoute(
      path: '/loading',
      name: 'loading',
      builder: (context, state) => const LoadingPage(),
    ),
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (context, state) => const ProfilePage(),
      routes: [
        GoRoute(
          path: 'update',
          name: 'profile-update',
          builder: (context, state) {
            final user = state.extra as Usuario; // CAST
            return ProfileUpdatePage(user: user);
          },
        ),
      ],
    ),
    GoRoute(
      path: '/mapa',
      name: 'mapa',
      builder: (context, state) => const MapaPage(),
      routes: [
        GoRoute(
          path: 'incident',
          name: 'incident',
          builder: (context, state) {
            final incident = state.extra as IncidentData;
            return MapaIncidentPage(incident: incident);
          },
        ),
      ],
    ),
  ],
);
