import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';
// import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/defaulds/default_icon_back.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/defaulds/default_text_field.dart';

class ProfileUpdateContent extends StatelessWidget {
  Usuario user;
  UpdateProfileState state;

  ProfileUpdateContent(this.state, {super.key, required this.user});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Column(
          children: [
            _headerProfile(context),

            Spacer(),
            _actionProfile(context, 'ACTUALIZAR USUARIO', Icons.check),

            SizedBox(height: 35),
          ],
        ),

        _cardUserInfo(context),

        DefauldIconBack(margin: EdgeInsets.only(top: 60, left: 30)),
      ],
    );
  }

  Widget _cardUserInfo(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(left: 35, right: 35, top: 150),
      width: MediaQuery.of(context).size.width,
      height: MediaQuery.of(context).size.height * 0.5,
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

            // Nombre
            DefaultTextField(
              label: 'Nombre',
              icon: Icons.person,
              backgroundColor: Colors.grey[200]!,
              margin: EdgeInsetsGeometry.only(left: 30, right: 30, top: 15),
              initialValue: user.nombre,
              onChanged: (String text) {
                print("NAME: $text");
                context.read<UpdateProfileBloc>().add(
                  NameChanged(name: BlocFormItem(value: text)),
                );
              },
              validator: (value) {
                return state.name.error;
              },
            ),

            // Apellidos
            DefaultTextField(
              label: 'Apellidos',
              icon: Icons.person_outline,
              backgroundColor: Colors.grey[200]!,
              margin: EdgeInsetsGeometry.only(left: 30, right: 30, top: 15),
              initialValue: user.apellidos,
              onChanged: (String text) {
                context.read<UpdateProfileBloc>().add(
                  LastNameChanged(lastname: BlocFormItem(value: text)),
                );
              },
              validator: (value) {
                return state.lastname.error;
              },
            ),

            // Telefono
            DefaultTextField(
              label: 'Teléfono',
              icon: Icons.phone,
              backgroundColor: Colors.grey[200]!,
              margin: EdgeInsetsGeometry.only(left: 30, right: 30, top: 15),
              initialValue: user.telefono,
              onChanged: (String text) {
                context.read<UpdateProfileBloc>().add(
                  PhoneNumberChanged(phone: BlocFormItem(value: text)),
                );
              },
              validator: (value) {
                return state.phone.error;
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionProfile(BuildContext context, String option, IconData icon) {
    return GestureDetector(
      onTap: () {
        print("CLICK DETECTADO");
        context.read<UpdateProfileBloc>().add(FormSubmit());
        // print("GESTURE: ${state.formKey!.currentState}");

        // if (state.formKey!.currentState != null) {
        //   if (state.formKey!.currentState!.validate()) {
        //     context.read<UpdateProfileBloc>().add(FormSubmit());
        //   }
        // } else {
        //   context.read<UpdateProfileBloc>().add(FormSubmit());
        // }
      },
      child: Container(
        margin: EdgeInsets.only(left: 35, right: 35, top: 15),
        child: Card(
          child: ListTile(
            // onTap: () {
            //   final bloc = context.read<UpdateProfileBloc>();

            //   if (state.formKey?.currentState?.validate() ?? false) {
            //     bloc.add(FormSubmit());
            //   }
            // },
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
      ),
    );
  }

  Widget _headerProfile(BuildContext context) {
    return Container(
      alignment: Alignment.topCenter,
      padding: EdgeInsets.only(top: 70),
      height: MediaQuery.of(context).size.height * 0.40,
      width: MediaQuery.of(context).size.width,
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

      child: Text(
        'ACTUALIZAR PERFIL',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
