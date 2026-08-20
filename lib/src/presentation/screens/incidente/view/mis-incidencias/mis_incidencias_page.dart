import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

import 'mis_incidencias_content.dart';

class MisIncidenciasPage extends StatefulWidget {
  const MisIncidenciasPage({super.key});

  @override
  State<MisIncidenciasPage> createState() => _MisIncidenciasPageState();
}

class _MisIncidenciasPageState extends State<MisIncidenciasPage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      _loadIncidencias();
    });
  }

  // ======================================================
  // PRIMERA CARGA
  // ======================================================

  void _loadIncidencias({bool refresh = false}) {
    context.read<IncidenteBloc>().add(
      ObtenerMisIncidenciasEvent(
        params: const MisIncidenciasQueryParams(
          page: 1,
          limit: 10,
          mode: MisIncidenciasMode.app,
          incluirArchivos: false,
        ),
        refresh: refresh,
      ),
    );
  }

  // ======================================================
  // ABRIR DETALLE
  // ======================================================
  void _openIncidencia(IncidenciaListadoData incidencia) {
    if (incidencia.id <= 0) {
      _showMessage('No se pudo identificar la incidencia.', isError: true);

      return;
    }

    context.pushNamed(
      'incidencia_detalle',
      pathParameters: {'incidenciaId': incidencia.id.toString()},
    );
  }

  // ======================================================
  // MENSAJES
  // ======================================================

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) {
      return;
    }

    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? colors.error : colors.primary,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  // ======================================================
  // LISTENER
  // ======================================================

  void _handleState(BuildContext context, IncidenteState state) {
    final response = state.misIncidenciasResponse;

    if (response is ErrorData<ApiResponse<MisIncidenciasPaginated>>) {
      _showMessage(response.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,

      appBar: AppBar(
        title: Text(
          'Incidencias',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.w700,
            fontSize: 26,
          ),
        ),
        centerTitle: true,
        // actions: [
        //   BlocSelector<IncidenteBloc, IncidenteState, bool>(
        //     selector: (state) =>
        //         state.isLoadingMisIncidencias ||
        //         state.isLoadingMoreMisIncidencias,
        //     builder: (context, isLoading) {
        //       return IconButton(
        //         tooltip: 'Actualizar incidencias',
        //         onPressed: isLoading
        //             ? null
        //             : () {
        //                 _loadIncidencias(refresh: true);
        //               },
        //         icon: isLoading
        //             ? const SizedBox(
        //                 width: 20,
        //                 height: 20,
        //                 child: CircularProgressIndicator(strokeWidth: 2),
        //               )
        //             : const Icon(Icons.refresh_rounded),
        //       );
        //     },
        //   ),

        //   const SizedBox(width: 4),
        // ],
      ),

      body: SafeArea(
        top: false,
        child: BlocListener<IncidenteBloc, IncidenteState>(
          listenWhen: (previous, current) =>
              previous.misIncidenciasResponse != current.misIncidenciasResponse,
          listener: _handleState,
          child: BlocBuilder<IncidenteBloc, IncidenteState>(
            buildWhen: (previous, current) {
              return previous.misIncidenciasResponse !=
                      current.misIncidenciasResponse ||
                  previous.misIncidencias != current.misIncidencias ||
                  previous.misIncidenciasParams !=
                      current.misIncidenciasParams ||
                  previous.misIncidenciasPage != current.misIncidenciasPage ||
                  previous.misIncidenciasTotalItems !=
                      current.misIncidenciasTotalItems ||
                  previous.isLoadingMoreMisIncidencias !=
                      current.isLoadingMoreMisIncidencias;
            },
            builder: (context, state) {
              return MisIncidenciasContent(
                state: state,
                onIncidenciaTap: _openIncidencia,
              );
            },
          ),
        ),
      ),
    );
  }
}
