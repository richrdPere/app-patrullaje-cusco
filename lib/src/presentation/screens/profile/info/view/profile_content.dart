// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';

class ProfileContent extends StatelessWidget {
  Usuario? user;

  ProfileContent(this.user, {super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return SafeArea(
      child: Stack(
        children: [
          Column(
            children: [
              _headerProfile(context, screenHeight),

              Spacer(),
              _actionProfile('EDITAR PERFIL', Icons.edit, () {
                context.goNamed('profile-update', extra: user);
              }),
              _actionProfile('CERRAR SESION', Icons.settings_power, () {
                // 1. DESCONECTAR SOCKET PRIMERO
                // context.read<SocketBloc>().add(DisconnectSocketEvent());

                // 2. LOGOUT
                context.read<LoginBloc>().add(LogoutEvent());

                // 3. REDIRIGIR
                context.goNamed('login');
              }),

              SizedBox(height: 35),
            ],
          ),

          _cardUserInfo(context),
        ],
      ),
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 20, right: 20, top: 100),
      width: MediaQuery.of(context).size.width,
      height: 250,
      child: Card(
        color: Colors.white,
        surfaceTintColor: Colors.white,
        child: Column(
          children: [
            Container(
              width: 115,
              margin: EdgeInsets.only(top: 15, bottom: 15),
              child: AspectRatio(
                aspectRatio: 1,
                child: ClipOval(
                  child: FadeInImage.assetNetwork(
                    placeholder: 'assets/img/user_image.png',
                    image:
                        'https://img.freepik.com/free-photo/portrait-white-man-isolated_53876-40306.jpg?semt=ais_incoming&w=740&q=80',
                    fit: BoxFit.cover,
                    fadeInDuration: Duration(seconds: 1),
                  ),
                ),
              ),
            ),

            Text(
              '${user?.nombre} ${user?.apellidos}',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
            Text(
              user?.username ?? '',
              style: TextStyle(color: Colors.grey[700]),
            ),
            Text(
              user?.telefono ?? '',
              style: TextStyle(color: Colors.grey[700]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionProfile(String option, IconData icon, Function() function) {
    return GestureDetector(
      onTap: () {
        function();
      },
      child: Container(
        margin: EdgeInsets.only(left: 35, right: 35, top: 15),
        child: ListTile(
          title: Text(option, style: TextStyle(fontWeight: FontWeight.bold)),
          leading: Container(
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topRight,
                end: Alignment.bottomLeft,
                colors: [
                  Color.fromARGB(255, 12, 38, 145),
                  Color.fromARGB(255, 34, 156, 249),
                ],
              ),

              borderRadius: BorderRadius.all(Radius.circular(50)),
            ),
            child: Icon(icon, color: Colors.white),
          ),
        ),
      ),
    );
  }

  Widget _headerProfile(BuildContext context, double screenHeight) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 40),
      // height: MediaQuery.of(context).size.height * 0.35,
      height: screenHeight * 0.30,
      // width: MediaQuery.of(context).size.width,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
          colors: [
            Color.fromARGB(255, 12, 38, 145),
            Color.fromARGB(255, 34, 156, 249),
          ],
        ),
      ),
      child: Stack(
        children: [
          // BOTÓN BACK (IOS STYLE)
          Positioned(
            top: -10,
            left: 10,
            child: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 22,
              ),
              onPressed: () {
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.go('/home');
                }
              },
            ),
          ),

          // 🧾 TÍTULO
          const Align(
            alignment: Alignment.topCenter,
            child: Text(
              'PERFIL DE USUARIO',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
