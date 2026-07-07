import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

import 'historial_patrullaje_content.dart';

class HistorialPatrullajePage extends StatelessWidget {
  const HistorialPatrullajePage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      listener: (context, state) {
        if (state.error != null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
          );
        }
      },

      child: const HistorialPatrullajeContent(),
    );
  }
}
