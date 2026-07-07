import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/loading/bloc/loading_event.dart';

import '../bloc/loading_bloc.dart';
import '../bloc/loading_state.dart';

class LoadingPage extends StatefulWidget {
  const LoadingPage({super.key});

  @override
  State<LoadingPage> createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  void initState() {
    super.initState();
    context.read<LoadingBloc>().add(const LoadingStarted());
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<LoadingBloc, LoadingState>(
      listener: (context, state) {
        if (state is LoadingSuccess) {
          context.goNamed("home");
        }

        if (state is LoadingFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));

          context.goNamed("login");
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,

        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),

              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,

                children: [
                  /// Logo
                  Image.asset(
                    "assets/img/tag-logo.png",
                    width: 130,
                    height: 130,
                  ),

                  const SizedBox(height: 35),

                  const CircularProgressIndicator(),

                  const SizedBox(height: 25),

                  const Text(
                    "Preparando tu información...",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 10),

                  Text(
                    "Estamos cargando la configuración de tu cuenta.",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
