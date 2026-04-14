// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/boton_azul.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_input.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/labels.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/logo.dart';

class LoginContent extends StatelessWidget {
  // Instancias
  // LoginBloc? bloc;
  // LoginState state;

  const LoginContent({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        physics: BouncingScrollPhysics(),
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Logo(titulo: 'Login'),
              _Form(),
              Labels(
                ruta: 'register',
                titulo: '¿No tienes cuenta?',
                subTitulo: 'Crea una ahora!',
              ),
              Text(
                'Terminos y condiciones de uso',
                style: TextStyle(fontWeight: FontWeight.w200),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  // LoginBloc? bloc;
  // LoginState state;

  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    final bloc = context.read<LoginBloc>();

    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Correo
            CustomInput(
              icon: Icons.mail_outline,
              placeholder: 'Correo',
              textController: emailCtrl,
              keyboardType: TextInputType.emailAddress,
              isPassword: false,
              onChanged: (value) {
                bloc.add(UsernameChanged(username: BlocFormItem(value: value)));
              },
            ),

            // Password
            CustomInput(
              icon: Icons.lock_outline,
              placeholder: 'Contraseña',
              textController: passCtrl,
              keyboardType: TextInputType.emailAddress,
              isPassword: true,
              onChanged: (value) {
                bloc.add(PasswordChanged(password: BlocFormItem(value: value)));
              },
            ),

            // Button,
            BotonAzul(
              text: 'Ingrese',
              onPressed: () {
            
                if (_formKey.currentState!.validate()) {
                  bloc.add(LoginSubmit());
                  // context.go('/dashboard/home');
                } else {
                  Fluttertoast.showToast(
                    msg: 'El formulario no es valido',
                    toastLength: Toast.LENGTH_SHORT,
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
