import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';

class AuthListener extends StatelessWidget {
  final Widget child;

  const AuthListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoginBloc, LoginState>(
      listenWhen: (prev, curr) =>
          prev.response.runtimeType != curr.response.runtimeType ||
          prev.isLoggedOut != curr.isLoggedOut,
      listener: (context, state) {
        final socketBloc = context.read<SocketBloc>();

        // =========================
        // LOGIN
        // =========================
        if (state.response is Success<AuthResponse> && !state.isLoggedOut) {
          print("Usuario autenticado");

          socketBloc.add(ConnectSocketEvent());
        }

        // =========================
        // LOGOUT
        // =========================
        if (state.isLoggedOut) {
          print("Usuario deslogueado");

          socketBloc.add(DisconnectSocketEvent());
        }
      },
      child: child,
    );
  }
}
