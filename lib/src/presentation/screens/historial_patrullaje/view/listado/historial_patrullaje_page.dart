import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Bloc's
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

// Widget
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/listado/historial_patrullaje_content.dart';

class HistorialPatrullajePage extends StatefulWidget {
  final int patrullajeId;

  const HistorialPatrullajePage({super.key, required this.patrullajeId});

  @override
  State<HistorialPatrullajePage> createState() =>
      _HistorialPatrullajePageState();
}

class _HistorialPatrullajePageState extends State<HistorialPatrullajePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadHistorial();
    });
  }

  @override
  void didUpdateWidget(covariant HistorialPatrullajePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.patrullajeId != widget.patrullajeId) {
      _loadHistorial();
    }
  }

  void _loadHistorial({bool refresh = false}) {
    context.read<HistorialPatrullajeBloc>().add(
      LoadHistorialPatrullajeEvent(
        patrullajeId: widget.patrullajeId,
        refresh: refresh,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      listenWhen: (previous, current) {
        return previous.actionStatus != current.actionStatus;
      },
      listener: (context, state) {
        if (state.actionStatus == HistorialActionStatus.success) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.actionMessage ?? 'Operación realizada correctamente.',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.green.shade700,
              ),
            );

          context.read<HistorialPatrullajeBloc>().add(
            const ClearHistorialActionEvent(),
          );
        }

        if (state.actionStatus == HistorialActionStatus.error) {
          ScaffoldMessenger.of(context)
            ..hideCurrentSnackBar()
            ..showSnackBar(
              SnackBar(
                content: Text(
                  state.errorMessage ?? 'No se pudo realizar la operación.',
                ),
                behavior: SnackBarBehavior.floating,
                backgroundColor: Colors.red.shade700,
              ),
            );

          context.read<HistorialPatrullajeBloc>().add(
            const ClearHistorialActionEvent(),
          );
        }
      },
      child: Scaffold(
        backgroundColor: const Color(0xFFF5F7FA),
        appBar: AppBar(
          title: const Text('Historial de patrullaje'),
          centerTitle: false,
          elevation: 0,
          actions: [
            IconButton(
              tooltip: 'Actualizar historial',
              onPressed: () {
                _loadHistorial(refresh: true);
              },
              icon: const Icon(Icons.refresh_rounded),
            ),
          ],
        ),
        body: HistorialPatrullajeContent(patrullajeId: widget.patrullajeId),
      ),
    );
  }
}
