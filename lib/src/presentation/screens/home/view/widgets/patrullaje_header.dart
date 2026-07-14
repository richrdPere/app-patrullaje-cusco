import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

class PatrullajeHeader extends StatelessWidget {
  final HomeState homeState;

  const PatrullajeHeader({super.key, required this.homeState});

  @override
  Widget build(BuildContext context) {
    final patrullaje = homeState.patrullaje;

    if (patrullaje == null) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Patrullaje asignado',
            style: TextStyle(
              color: Colors.white,
              fontSize: 19,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),

          Text(
            'Zona: ${patrullaje.zona.nombre}',
            style: const TextStyle(color: Colors.white),
          ),

          if (patrullaje.descripcion.trim().isNotEmpty) ...[
            const SizedBox(height: 5),
            Text(
              'Descripción: ${patrullaje.descripcion}',
              style: const TextStyle(color: Colors.white),
            ),
          ],

          const SizedBox(height: 8),

          Text(
            _getStatusText(homeState.status),
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _getStatusText(PatrullajeStatus status) {
    switch (status) {
      case PatrullajeStatus.asignado:
        return '🟡 Asignado';

      case PatrullajeStatus.aceptando:
        return '🟠 Aceptando...';

      case PatrullajeStatus.enCurso:
        return '🟢 En patrullaje';

      case PatrullajeStatus.finalizado:
        return '🔴 Finalizado';

      case PatrullajeStatus.error:
        return '🔴 Error';

      case PatrullajeStatus.sinAsignacion:
        return '⚪ Sin asignación';
    }
  }
}
