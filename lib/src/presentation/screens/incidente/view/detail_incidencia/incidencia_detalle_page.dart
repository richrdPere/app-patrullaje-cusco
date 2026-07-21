import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

import 'incidencia_detalle_content.dart';

class IncidenciaDetallePage extends StatefulWidget {
  final int incidenciaId;

  const IncidenciaDetallePage({super.key, required this.incidenciaId});

  @override
  State<IncidenciaDetallePage> createState() => _IncidenciaDetallePageState();
}

class _IncidenciaDetallePageState extends State<IncidenciaDetallePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _obtenerDetalle();
    });
  }

  @override
  void didUpdateWidget(covariant IncidenciaDetallePage oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.incidenciaId != widget.incidenciaId) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _obtenerDetalle();
      });
    }
  }

  void _obtenerDetalle() {
    if (widget.incidenciaId <= 0) return;

    context.read<IncidenteBloc>().add(
      ObtenerIncidenciaPorIdEvent(widget.incidenciaId),
    );
  }

  @override
  void dispose() {
    /*
     * No uses context.read dentro de dispose si te genera:
     * "Looking up a deactivated widget's ancestor is unsafe".
     *
     * En ese caso, guarda el BLoC en didChangeDependencies.
     */
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),
      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        surfaceTintColor: Colors.white,
        elevation: 0,
        titleSpacing: 0,
        title: const Text(
          'Detalle de incidencia',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _obtenerDetalle,
            tooltip: 'Actualizar',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),
      body: SafeArea(
        top: false,
        child: BlocListener<IncidenteBloc, IncidenteState>(
          listenWhen: (previous, current) =>
              previous.detalleResponse != current.detalleResponse,
          listener: (context, state) {
            final response = state.detalleResponse;

            if (response is ErrorData<IncidenteModel>) {
              ScaffoldMessenger.of(context)
                ..hideCurrentSnackBar()
                ..showSnackBar(
                  SnackBar(
                    content: Text(response.message),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
            }
          },
          child: IncidenciaDetalleContent(
            incidenciaId: widget.incidenciaId,
            onRefresh: _obtenerDetalle,
          ),
        ),
      ),
    );
  }
}
