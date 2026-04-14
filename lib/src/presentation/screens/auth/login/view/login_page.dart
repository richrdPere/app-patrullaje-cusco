import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/view/login_content.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  @override
  void initState() {
    super.initState();

    // Verificar sesión al iniciar
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LoginBloc>().add(InitEvent());
    });
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
          final responseState = state.response;
          if (responseState is Error) {
            Fluttertoast.showToast(
              msg: responseState.error,
              toastLength: Toast.LENGTH_LONG,
            );
          } else if (responseState is Success) {
            // Fluttertoast.showToast(
            //   msg: "Login Exitoso",
            //   toastLength: Toast.LENGTH_LONG,
            // );

            // final authResponse = responseState.data as AuthResponse;

            // context.read<LoginBloc>().add(
            //   SaveUserSession(authResponse: authResponse),
            // );

            // SOLO NAVEGAR (la sesión ya debe guardarse en el Bloc)
            context.go('/home');
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
