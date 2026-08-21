import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

import 'historial_detalle_content.dart';

class HistorialDetallePage extends StatefulWidget {
  final int historialId;

  const HistorialDetallePage({super.key, required this.historialId});

  @override
  State<HistorialDetallePage> createState() => _HistorialDetallePageState();
}

class _HistorialDetallePageState extends State<HistorialDetallePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _loadDetalle();
    });
  }

  @override
  void didUpdateWidget(covariant HistorialDetallePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.historialId != widget.historialId) {
      context.read<HistorialPatrullajeBloc>().add(
        const ClearHistorialSelectedEvent(),
      );

      _loadDetalle();
    }
  }

  void _loadDetalle() {
    if (widget.historialId <= 0) {
      return;
    }

    context.read<HistorialPatrullajeBloc>().add(
      LoadHistorialDetalleEvent(historialId: widget.historialId),
    );
  }

  Future<void> _onRefresh() async {
    _loadDetalle();

    await context.read<HistorialPatrullajeBloc>().stream.firstWhere(
      (state) => state.detailStatus != HistorialDetailStatus.loading,
    );
  }

  void _closePage() {
    if (context.canPop()) {
      context.pop();
      return;
    }

    context.go('/home');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,

        leading: IconButton(
          tooltip: 'Cerrar',
          onPressed: _closePage,
          icon: const Icon(Icons.close_rounded),
        ),

        title: const Text('Detalle del historial'),

        elevation: 0,

        actions: [
          BlocSelector<HistorialPatrullajeBloc, HistorialPatrullajeState, bool>(
            selector: (state) {
              return state.detailStatus == HistorialDetailStatus.loading;
            },
            builder: (context, isLoading) {
              if (isLoading) {
                return const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 18),
                  child: Center(
                    child: SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                  ),
                );
              }

              return IconButton(
                tooltip: 'Actualizar detalle',
                onPressed: _loadDetalle,
                icon: const Icon(Icons.refresh_rounded),
              );
            },
          ),
        ],
      ),

      body: HistorialDetalleContent(
        onRefresh: _onRefresh,
        onRetry: _loadDetalle,
      ),
    );
  }
}
