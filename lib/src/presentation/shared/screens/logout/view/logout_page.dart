import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/logout/bloc/logout_event.dart';

import '../bloc/logout_bloc.dart';
import '../bloc/logout_state.dart';

class LogoutLoadingPage extends StatefulWidget {
  const LogoutLoadingPage({super.key});

  @override
  State<LogoutLoadingPage> createState() => _LogoutLoadingPageState();
}

class _LogoutLoadingPageState extends State<LogoutLoadingPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LogoutBloc>().add(LogoutRequested());
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // LOGOUT
        BlocListener<LogoutBloc, LogoutState>(
          listener: (context, state) {
            if (state is LogoutSuccess) {
              context.read<SessionBloc>().logout();
            }

            if (state is LogoutFailure) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text(state.message)));
            }
          },
        ),

        // SESSION
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) =>
              previous.isAuthenticated != current.isAuthenticated,

          listener: (context, state) {
            if (!state.isAuthenticated) {
              context.goNamed('login');
            }
          },
        ),
      ],

      child: const _LogoutView(),
    );
  }
}

class _LogoutView extends StatelessWidget {
  const _LogoutView();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,

            children: [
              Image.asset('assets/img/tag-logo.png', width: 150, height: 150),

              const SizedBox(height: 35),

              const Text(
                "Cerrando sesión",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.5,
                ),
              ),

              const SizedBox(height: 15),

              Text(
                "Finalizando conexión con el servidor",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
              ),

              const SizedBox(height: 40),

              const SizedBox(
                width: 35,
                height: 35,
                child: CircularProgressIndicator(strokeWidth: 3),
              ),

              const SizedBox(height: 25),

              Text(
                "Espere un momento...",
                style: TextStyle(color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.only(bottom: 25),
        child: Text(
          "Sistema Inteligente de Patrullaje",
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.grey.shade500),
        ),
      ),
    );
  }
}
