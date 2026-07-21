import 'package:flutter/material.dart';

class EstadoIncidenciaChip extends StatelessWidget {
  final String estado;

  const EstadoIncidenciaChip({super.key, required this.estado});

  @override
  Widget build(BuildContext context) {
    final config = _getConfig();

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: config.color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        config.label,
        style: TextStyle(
          fontSize: 10.5,
          fontWeight: FontWeight.w700,
          color: config.color,
        ),
      ),
    );
  }

  _EstadoConfig _getConfig() {
    switch (estado) {
      case 'REPORTADO':
        return const _EstadoConfig(label: 'Reportado', color: Colors.red);

      case 'EN_PROCESO':
        return const _EstadoConfig(label: 'En proceso', color: Colors.orange);

      case 'ATENDIDO':
        return const _EstadoConfig(label: 'Atendido', color: Colors.green);

      case 'CERRADO':
        return const _EstadoConfig(label: 'Cerrado', color: Colors.blueGrey);

      default:
        return _EstadoConfig(label: estado, color: Colors.grey);
    }
  }
}

class InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const InfoItem({super.key, required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 14, color: Colors.grey.shade500),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(fontSize: 11.5, color: Colors.grey.shade600),
        ),
      ],
    );
  }
}

class IncidenciaTipoConfig {
  final IconData icon;
  final Color color;

  const IncidenciaTipoConfig({required this.icon, required this.color});
}

class _EstadoConfig {
  final String label;
  final Color color;

  const _EstadoConfig({required this.label, required this.color});
}
