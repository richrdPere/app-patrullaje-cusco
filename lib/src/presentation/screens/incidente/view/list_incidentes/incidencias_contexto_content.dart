import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/list_incidentes/widgets/Incidencia_contexto_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/list_incidentes/widgets/loading_contexto.dart';

class IncidenciasContextoContent extends StatelessWidget {
  final int patrullajeId;
  final int zonaId;
  final VoidCallback onRefresh;
  final ValueChanged<IncidenteModel> onIncidenciaTap;

  const IncidenciasContextoContent({
    super.key,
    required this.patrullajeId,
    required this.zonaId,
    required this.onRefresh,
    required this.onIncidenciaTap,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<IncidenteBloc, IncidenteState>(
      buildWhen: (previous, current) =>
          previous.contextoResponse != current.contextoResponse ||
          previous.incidenciasContexto != current.incidenciasContexto ||
          previous.contextoPatrullajeId != current.contextoPatrullajeId ||
          previous.contextoZonaId != current.contextoZonaId,
      builder: (context, state) {
        final response = state.contextoResponse;
        final incidencias = state.incidenciasContexto;

        final contextoValido = patrullajeId > 0 && zonaId > 0;

        if (!contextoValido) {
          return const SinPatrullajeActivo();
        }

        if (response is Loading<List<IncidenteModel>> && incidencias.isEmpty) {
          return const LoadingContexto();
        }

        if (response is ErrorData<List<IncidenteModel>> &&
            incidencias.isEmpty) {
          return ErrorContexto(message: response.message, onRetry: onRefresh);
        }

        if (incidencias.isEmpty) {
          return EmptyContexto(onRefresh: onRefresh);
        }

        return _IncidenciasContextoList(
          incidencias: incidencias,
          isRefreshing: response is Loading<List<IncidenteModel>>,
          onRefresh: onRefresh,
          onIncidenciaTap: onIncidenciaTap,
        );
      },
    );
  }
}




class _IncidenciasContextoList extends StatelessWidget {
  final List<IncidenteModel> incidencias;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final ValueChanged<IncidenteModel> onIncidenciaTap;

  const _IncidenciasContextoList({
    required this.incidencias,
    required this.isRefreshing,
    required this.onRefresh,
    required this.onIncidenciaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildHeader(context),

        if (isRefreshing) const LinearProgressIndicator(minHeight: 2),

        Expanded(
          child: RefreshIndicator(
            onRefresh: () async {
              onRefresh();
            },
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
              physics: const AlwaysScrollableScrollPhysics(),
              itemCount: incidencias.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final incidencia = incidencias[index];

                return IncidenciaContextoCard(
                  incidencia: incidencia,
                  onTap: () => onIncidenciaTap(incidencia),
                );
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 4),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // const Text(
                //   'Incidencias de la zona',
                //   style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                // ),
                // const SizedBox(height: 3),
                Text(
                  '${incidencias.length} incidencia'
                  '${incidencias.length == 1 ? '' : 's'} encontrada'
                  '${incidencias.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          // IconButton(
          //   onPressed: onRefresh,
          //   tooltip: 'Actualizar incidencias',
          //   icon: const Icon(Icons.refresh),
          // ),
        ],
      ),
    );
  }
}
