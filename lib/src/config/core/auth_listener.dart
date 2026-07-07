import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';

class AuthListener extends StatelessWidget {
  final Widget child;

  const AuthListener({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // =========================
        // SESSION LISTENER
        // =========================
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) =>
              previous.isAuthenticated != current.isAuthenticated,

          listener: (context, state) {
            final socketBloc = context.read<SocketBloc>();
            final trackingBloc = context.read<TrackingBloc>();
            // final homeBloc = context.read<HomeBloc>();

            if (state.isAuthenticated) {
              debugPrint("🟢 Usuario autenticado");

              socketBloc.add(ConnectSocketEvent());

              return;
            }

            debugPrint("🔴 Usuario deslogueado");

            // Detener tracking
            trackingBloc.add(StopTrackingEvent());

            // Desconectar socket
            socketBloc.add(DisconnectSocketEvent());

            // Limpiar estado del Home (si implementas este evento)
            // homeBloc.add(ClearHomeState());
          },
        ),

        // =========================
        // SOCKET LISTENER
        // =========================
        BlocListener<SocketBloc, SocketState>(
          listenWhen: (previous, current) =>
              previous.isConnected != current.isConnected,

          listener: (context, state) {
            final homeBloc = context.read<HomeBloc>();

            if (state.isConnected) {
              print("🟢 Socket conectado → Inicializando Home");

              homeBloc.add(InitSocketListeners());

              homeBloc.add(LoadPatrullajeActivo());
            } else {
              print("🔴 Socket desconectado");
            }
          },
        ),
      ],

      child: child,
    );
  }
}
// class AuthListener extends StatelessWidget {
//   final Widget child;

//   const AuthListener({super.key, required this.child});

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         // =========================
//         // SESSION  LISTENER
//         // =========================
//         BlocListener<LoginBloc, LoginState>(
//           listenWhen: (prev, curr) =>
//               prev.response.runtimeType != curr.response.runtimeType ||
//               prev.isLoggedOut != curr.isLoggedOut,
//           listener: (context, state) {
//             final socketBloc = context.read<SocketBloc>();

//             /// LOGIN EXITOSO
//             if (state.response is Success<AuthResponse> && !state.isLoggedOut) {
//               final auth = (state.response as Success<AuthResponse>).data;

//               // Guardar sesión
//               context.read<SessionBloc>().updateSession(auth);

//               // Conectar socket
//               socketBloc.add(ConnectSocketEvent());

//               return;
//             }

//             // LOGOUT
//             if (state.isLoggedOut) {
//               // print("Usuario deslogueado");

//               // detener tracking
//               context.read<TrackingBloc>().add(StopTrackingEvent());

//               // desconectar socket
//               socketBloc.add(DisconnectSocketEvent());

//               // cerrar sesion
//               context.read<SessionBloc>().logout();
//             }
//           },
//         ),

//         // =========================
//         // SOCKET LISTENER (CLAVE)
//         // =========================
//         BlocListener<SocketBloc, SocketState>(
//           listenWhen: (prev, curr) => prev.isConnected != curr.isConnected,
//           listener: (context, socketState) {
//             final homeBloc = context.read<HomeBloc>();

//             if (socketState.isConnected) {
//               print("🟢 Socket conectado → inicializando Home");

//               // Inicializar listeners sockets
//               homeBloc.add(InitSocketListeners());

//               // Recuperar patrullaje activo
//               homeBloc.add(LoadPatrullajeActivo());
//             } else {
//               print("🔴 Socket desconectado");

//               // opcional: limpiar estado
//               // homeBloc.add(ClearHomeState());
//             }
//           },
//         ),
//       ],
//       child: child,
//     );
//   }
// }
