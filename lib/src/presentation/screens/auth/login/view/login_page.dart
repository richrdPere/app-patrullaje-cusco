import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
import 'package:sis_patrullaje_cusco/src/data/models/login/auth_response.dart';
// import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/view/login_content.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    // _bloc = BlocProvider.of<LoginBloc>(context);

    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: BlocListener<LoginBloc, LoginState>(
        // SOLO escucha cambios reales
        listenWhen: (prev, curr) => prev.response != curr.response,

        listener: (context, state) {
          final response = state.response;

          if (response is ErrorData) {
            Fluttertoast.showToast(
              msg: response.error,
              toastLength: Toast.LENGTH_LONG,
            );
          } else if (response is Success<AuthResponse>) {
            final auth = response.data;

            // Actualizar el estado global de la sesión
            context.read<SessionBloc>().updateSession(auth);

            Fluttertoast.showToast(
              msg: "Login exitoso",
              toastLength: Toast.LENGTH_LONG,
            );

            // Ir a la pantalla de carga
            context.go('/loading');
          }
        },
        child: BlocBuilder<LoginBloc, LoginState>(
          builder: (context, state) {
            final responseState = state.response;

            if (responseState is Loading) {
              return Stack(
                children: [
                  LoginContent(),
                  Center(child: CircularProgressIndicator()),
                ],
              );
            }
            return LoginContent();
          },
        ),
      ),
    );
  }
}
