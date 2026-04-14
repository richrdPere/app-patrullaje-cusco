import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/view/profile_content.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_appbar.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(),
      body: BlocBuilder<ProfileBloc, ProfileState>(
        builder: (context, state) {
          return ProfileContent(state.user);
        },
      ),
    );
  }
}
