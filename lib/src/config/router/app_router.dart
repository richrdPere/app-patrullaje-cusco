import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/config/core/main_shell.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/incident_data_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';

// Screens
import 'package:sis_patrullaje_cusco/src/presentation/screens/screens.dart';

String? authRedirect(BuildContext context, GoRouterState state) {
  final session = context.read<SessionBloc>().state;
  final loggedIn = session.isAuthenticated;
  final location = state.matchedLocation;

  // Rutas públicas
  const publicRoutes = {'/splash', '/login', '/register', '/loading'};

  // =========================
  // USUARIO NO AUTENTICADO
  // =========================
  if (!loggedIn) {
    // Puede permanecer en Splash o Login
    if (publicRoutes.contains(location)) {
      return null;
    }

    // Cualquier otra ruta → Login
    return '/login';
  }

  // =========================
  // USUARIO AUTENTICADO
  // =========================
  if (loggedIn) {
    // Si intenta entrar nuevamente a Splash o Login
    if (location == '/splash' ||
        location == '/login' ||
        location == '/register') {
      return '/home';
    }
    // Puede navegar libremente
    return null;
  }

  return null;
}

// ===================================
// RUTAS
// ===================================
final GoRouter appRouter = GoRouter(
  // initialLocation: '/login',
  initialLocation: '/splash',
  debugLogDiagnostics: true,
  redirect: authRedirect,
  routes: [
    // =====================================================
    // AUTH
    // =====================================================
    GoRoute(
      path: '/splash',
      name: 'splash',
      builder: (_, __) => const SplashPage(),
    ),
    GoRoute(
      path: '/login',
      name: "login",
      builder: (_, __) => const LoginPage(),
    ),

    GoRoute(
      path: '/register',
      name: "register",
      builder: (_, __) => const RegisterPage(),
    ),

    GoRoute(
      path: '/loading',
      name: "loading",
      builder: (_, __) => const LoadingPage(),
    ),

    GoRoute(
      path: '/logout',
      name: "logout",
      builder: (_, __) => const LogoutLoadingPage(),
    ),

    // =====================================================
    // APLICACIÓN PRINCIPAL
    // =====================================================
    ShellRoute(
      builder: (context, state, child) {
        return MainShell(child: child);
      },

      routes: [
        // ==================================================
        // 1. HOME - PATRULLAJE
        // ==================================================
        GoRoute(
          path: '/home',
          name: "home",
          builder: (_, __) => const HomePage(),
        ),

        // ==================================================
        // 2. MAPA
        // ==================================================
        GoRoute(
          path: '/mapa',
          name: "mapa",
          builder: (_, __) => const MapaPage(),

          routes: [
            GoRoute(
              path: 'incident',
              name: "mapa_incident",

              builder: (context, state) {
                final incident = state.extra as IncidentData;

                return MapaIncidentPage(incident: incident);
              },
            ),
          ],
        ),

        // =====================================================
        // 3. OCURRENCIAS
        // =====================================================
        GoRoute(
          path: '/ocurrencias',
          name: 'ocurrencias',
          builder: (_, __) => const OcurrenciasPage(),
          routes: [
            // *********************************************************
            // Crear ocurrencia
            // URL: /ocurrencias/crear
            // *********************************************************
            GoRoute(
              path: 'crear',
              name: 'ocurrencia_crear',
              pageBuilder: (context, state) {
                return MaterialPage<void>(
                  key: state.pageKey,
                  fullscreenDialog: true,
                  child: const OcurrenciaFormPage(),
                );
              },
            ),

            // *********************************************************
            // Detalle de ocurrencia
            // URL: /ocurrencias/26
            // *********************************************************
            GoRoute(
              path: ':idOcurrencia',
              name: 'ocurrencia_detalle',
              pageBuilder: (context, state) {
                final int? ocurrenciaId = int.tryParse(
                  state.pathParameters['idOcurrencia'] ?? '',
                );

                return MaterialPage(
                  key: state.pageKey,
                  fullscreenDialog: true,
                  child: ocurrenciaId == null
                      ? const Scaffold(
                          body: Center(child: Text('Categoría inválida.')),
                        )
                      : OcurrenciaDetallePage(ocurrenciaId: ocurrenciaId),
                );
              },
            ),
          ],
        ),

        // 4. USUARIOS
        GoRoute(
          path: '/usuarios',
          name: 'usuarios',
          builder: (_, __) => const UsuariosPage(),
        ),

        // 5. ALERTAS
        GoRoute(
          path: '/alertas',
          name: 'alertas',
          builder: (_, __) => const AlertaPage(),
        ),
      ],
    ),

    // HISTORIAL
    GoRoute(
      name: 'historial_patrullaje',
      path: '/historial-patrullaje/:patrullajeId',
      builder: (context, state) {
        final patrullajeId = int.tryParse(
          state.pathParameters['patrullajeId'] ?? '',
        );

        if (patrullajeId == null || patrullajeId <= 0) {
          return const Scaffold(
            body: Center(child: Text('No se encontró un patrullaje válido.')),
          );
        }

        return HistorialPatrullajePage(patrullajeId: patrullajeId);
      },
    ),

    // =====================================================
    // MIS PATRULLAJES
    // =====================================================
    GoRoute(
      path: '/mis-patrullajes',
      name: 'mis_patrullajes',
      builder: (_, __) => const MisPatrullajesPage(),
      routes: [
        GoRoute(
          path: '/mis-patrullajes/:patrullajeId',
          name: 'patrullaje_detalle',
          pageBuilder: (context, state) {
            final patrullajeId = int.tryParse(
              state.pathParameters['patrullajeId'] ?? '',
            );

            final extra = state.extra;

            return MaterialPage<void>(
              key: state.pageKey,
              fullscreenDialog: true,
              child:
                  patrullajeId != null &&
                      patrullajeId > 0 &&
                      extra is PatrullajeListadoData
                  ? PatrullajeDetallePage(patrullaje: extra)
                  : const Scaffold(
                      body: SafeArea(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No se encontró información válida del patrullaje.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ],
    ),

    // =====================================================
    // MIS INCIDENTES
    // =====================================================
    GoRoute(
      path: '/mis-incidencias',
      name: 'mis_incidencias',
      builder: (_, __) => const MisIncidenciasPage(),
      routes: [
        GoRoute(
          path: ':incidenciaId',
          name: 'incidencia_detalle',
          pageBuilder: (context, state) {
            final incidenciaId = int.tryParse(
              state.pathParameters['incidenciaId'] ?? '',
            );

            return MaterialPage<void>(
              fullscreenDialog: true,
              child: incidenciaId != null && incidenciaId > 0
                  ? IncidenciaDetallePage(incidenciaId: incidenciaId)
                  : const Scaffold(
                      body: SafeArea(
                        child: Center(
                          child: Padding(
                            padding: EdgeInsets.all(24),
                            child: Text(
                              'No se encontró información válida de la incidencia.',
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      ),
                    ),
            );
          },
        ),
      ],
    ),

    // CHAT
    GoRoute(path: '/chat', name: 'chat', builder: (_, __) => const ChatPage()),

    // PERFIL
    GoRoute(
      path: '/profile',
      name: 'profile',
      builder: (_, __) => const ProfilePage(),

      routes: [
        GoRoute(
          path: 'update',
          name: 'profile_update',
          builder: (context, state) {
            final user = state.extra as Usuario;

            return ProfileUpdatePage(user: user);
          },
        ),
      ],
    ),

    // =====================================================
    // CLASIFICADORES
    // =====================================================
    GoRoute(
      path: '/clasificadores',
      name: 'clasificadores',

      pageBuilder: (context, state) {
        return MaterialPage<void>(
          key: state.pageKey,
          fullscreenDialog: true,
          child: const ClasificadoresPage(),
        );
      },
    ),
  ],
);
