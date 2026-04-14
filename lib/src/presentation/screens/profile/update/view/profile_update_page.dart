import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/view/profile_update_content.dart';

class ProfileUpdatePage extends StatefulWidget {
  final Usuario? user;

  const ProfileUpdatePage({super.key, required this.user});

  @override
  State<ProfileUpdatePage> createState() => _ProfileUpdatePageState();
}

class _ProfileUpdatePageState extends State<ProfileUpdatePage> {
  @override
  void initState() {
    // PRIMER EVENTO EN DISPARARSE - UNA SOLA VEZ

    super.initState();
    context.read<UpdateProfileBloc>().add(
      ProfileUpdateInitEvent(user: widget.user),
    );

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   context.read<UpdateProfileBloc>().add(
    //     ProfileUpdateInitEvent(user: widget.user),
    //   );
    // });
  }

  @override
  Widget build(BuildContext context) {
    // SEGUNDO - CTRL + S
    return Scaffold(
      body: BlocBuilder<UpdateProfileBloc, UpdateProfileState>(
        builder: (context, state) {
          return ProfileUpdateContent(state, user: widget.user!);
        },
      ),
    );
  }
}
