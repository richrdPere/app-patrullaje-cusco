import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/list_incidentes/widgets/Incidencia_contexto_card.dart';

class IncidenciasContextoList extends StatelessWidget {
  final List<IncidenteModel> incidencias;
  final bool isRefreshing;
  final VoidCallback onRefresh;
  final ValueChanged<IncidenteModel> onIncidenciaTap;

  const IncidenciasContextoList({super.key, 
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
                const Text(
                  'Incidencias de la zona',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  '${incidencias.length} incidencia'
                  '${incidencias.length == 1 ? '' : 's'} encontrada'
                  '${incidencias.length == 1 ? '' : 's'}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onRefresh,
            tooltip: 'Actualizar incidencias',
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }
}
