import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

import 'incidencias_contexto_content.dart';

class IncidenciasContextoPage extends StatefulWidget {
  final int patrullajeId;
  final int zonaId;

  const IncidenciasContextoPage({
    super.key,
    required this.patrullajeId,
    required this.zonaId,
  });

  @override
  State<IncidenciasContextoPage> createState() =>
      _IncidenciasContextoPageState();
}

class _IncidenciasContextoPageState extends State<IncidenciasContextoPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _obtenerIncidencias();
    });
  }

  @override
  void didUpdateWidget(covariant IncidenciasContextoPage oldWidget) {
    super.didUpdateWidget(oldWidget);

    final cambioPatrullaje = oldWidget.patrullajeId != widget.patrullajeId;

    final cambioZona = oldWidget.zonaId != widget.zonaId;

    if (cambioPatrullaje || cambioZona) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;

        _obtenerIncidencias();
      });
    }
  }

  void _obtenerIncidencias() {
    if (widget.patrullajeId <= 0 || widget.zonaId <= 0) {
      return;
    }

    context.read<IncidenteBloc>().add(
      ObtenerIncidenciasContextoEvent(
        patrullajeId: widget.patrullajeId,
        zonaId: widget.zonaId,
      ),
    );
  }

  void _refrescar() {
    _obtenerIncidencias();
  }

  void _seleccionarIncidencia(IncidenteModel incidencia) {
    final incidenciaId = incidencia.id;

    if (incidenciaId == null || incidenciaId <= 0) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text(
              'No se pudo obtener el identificador de la incidencia.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );

      return;
    }

    context.pushNamed(
      'incidencia_detalle',
      pathParameters: {'incidenciaId': incidenciaId.toString()},
    );

    // context.read<IncidenteBloc>().add(
    //   ObtenerIncidenciaPorIdEvent(incidenciaId),
    // );

    /*
     * Aquí puedes navegar al detalle cuando tengas la ruta:
     *
     * context.pushNamed(
     *   'incidencia_detalle',
     *   pathParameters: {
     *     'incidenciaId': incidenciaId.toString(),
     *   },
     * );
     */
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F6F8),

      appBar: AppBar(
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 0,
        surfaceTintColor: Colors.white,
        centerTitle: false,
        titleSpacing: 0,
        title: const Text(
          'Incidencias',
          style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
        ),
        actions: [
          IconButton(
            onPressed: _refrescar,
            tooltip: 'Actualizar incidencias',
            icon: const Icon(Icons.refresh_rounded),
          ),
          const SizedBox(width: 4),
        ],
      ),

      body: SafeArea(
        top: false,
        child: BlocListener<IncidenteBloc, IncidenteState>(
          listenWhen: (previous, current) =>
              previous.contextoResponse != current.contextoResponse,
          listener: (context, state) {
            final response = state.contextoResponse;

            if (response is ErrorData<List<IncidenteModel>>) {
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
          child: IncidenciasContextoContent(
            patrullajeId: widget.patrullajeId,
            zonaId: widget.zonaId,
            onRefresh: _refrescar,
            onIncidenciaTap: _seleccionarIncidencia,
          ),
        ),
      ),
    );
  }
}
