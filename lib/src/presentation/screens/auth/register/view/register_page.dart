import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/boton_azul.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_input.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/labels.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/logo.dart';

class RegisterPage extends StatelessWidget {
  const RegisterPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF2F2F2),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: BouncingScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height * 0.9,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Logo(titulo: 'Registro'),
                _Form(),
                Labels(
                  ruta: 'login',
                  titulo: '¿Ya tienes una cuenta?',
                  subTitulo: 'Ingrese ahora!',
                ),
                Text(
                  'Terminos y condiciones de uso',
                  style: TextStyle(fontWeight: FontWeight.w200),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _Form extends StatefulWidget {
  @override
  State<_Form> createState() => _FormState();
}

class _FormState extends State<_Form> {
  final nameCtrl = TextEditingController();
  final emailCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(top: 40),
      padding: EdgeInsets.symmetric(horizontal: 50),
      child: Column(
        children: [
          // Nombre
          CustomInput(
            icon: Icons.perm_identity,
            placeholder: 'Nombres',
            textController: nameCtrl,
            keyboardType: TextInputType.text,
            isPassword: false,
          ),

          // Correo
          CustomInput(
            icon: Icons.mail_outline,
            placeholder: 'Correo',
            textController: emailCtrl,
            keyboardType: TextInputType.emailAddress,
            isPassword: false,
          ),

          // Password
          CustomInput(
            icon: Icons.lock_outline,
            placeholder: 'Contraseña',
            textController: passCtrl,
            keyboardType: TextInputType.emailAddress,
            isPassword: true,
          ),

          // Button,
          BotonAzul(
            text: 'Registre',
            onPressed: () {
              print('email: ${emailCtrl.text}');
              print('password: ${passCtrl.text}');
            },
          ),
        ],
      ),
    );
  }
}
