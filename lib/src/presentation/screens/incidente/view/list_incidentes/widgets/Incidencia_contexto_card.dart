import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/list_incidentes/widgets/estado_incidencia_chip.dart';

class IncidenciaContextoCard extends StatelessWidget {
  final IncidenteModel incidencia;
  final VoidCallback onTap;

  const IncidenciaContextoCard({
    super.key,
    required this.incidencia,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tipo = incidencia.tipo.trim().toUpperCase();
    final estado = incidencia.estado?.trim().toUpperCase();

    final configuracion = _getTipoConfig(tipo);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildIcon(configuracion),
              const SizedBox(width: 13),
              Expanded(child: _buildInformation(context, tipo, estado!)),
              const SizedBox(width: 8),
              Icon(Icons.chevron_right, color: Colors.grey.shade500),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildIcon(_IncidenciaTipoConfig configuracion) {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: configuracion.color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Icon(configuracion.icon, color: configuracion.color, size: 25),
    );
  }

  Widget _buildInformation(BuildContext context, String tipo, String estado) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _formatTipo(tipo),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            EstadoIncidenciaChip(estado: estado),
          ],
        ),
        const SizedBox(height: 7),
        Text(
          incidencia.descripcion.trim().isEmpty
              ? 'Sin descripción registrada.'
              : incidencia.descripcion.trim(),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 13.5,
            height: 1.35,
            color: Colors.grey.shade700,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 12,
          runSpacing: 6,
          children: [
            if (incidencia.id != null)
              _InfoItem(icon: Icons.tag, text: 'N.° ${incidencia.id}'),

            if (incidencia.evidencias.isNotEmpty)
              _InfoItem(
                icon: Icons.attach_file,
                text:
                    '${incidencia.evidencias.length} evidencia'
                    '${incidencia.evidencias.length == 1 ? '' : 's'}',
              ),

            /*
             * Cambia fechaHora por el nombre real de la propiedad
             * de fecha de tu IncidenteModel.
             */
            if (incidencia.fechaHora != null)
              _InfoItem(
                icon: Icons.schedule,
                text: _formatFecha(incidencia.fechaHora!),
              ),
          ],
        ),
      ],
    );
  }

  String _formatTipo(String tipo) {
    switch (tipo) {
      case 'ROBO':
        return 'Robo';

      case 'ACCIDENTE':
        return 'Accidente';

      case 'INCENDIO':
        return 'Incendio';

      case 'VIOLENCIA':
        return 'Violencia';

      case 'SOSPECHOSO':
        return 'Persona sospechosa';

      case 'OTRO':
        return 'Otro';

      default:
        return tipo;
    }
  }

  String _formatFecha(DateTime fecha) {
    String twoDigits(int value) => value.toString().padLeft(2, '0');

    final dia = twoDigits(fecha.day);
    final mes = twoDigits(fecha.month);
    final hora = twoDigits(fecha.hour);
    final minuto = twoDigits(fecha.minute);

    return '$dia/$mes/${fecha.year} $hora:$minuto';
  }

  _IncidenciaTipoConfig _getTipoConfig(String tipo) {
    switch (tipo) {
      case 'ROBO':
        return const _IncidenciaTipoConfig(
          icon: Icons.security,
          color: Colors.red,
        );

      case 'ACCIDENTE':
        return const _IncidenciaTipoConfig(
          icon: Icons.car_crash,
          color: Colors.orange,
        );

      case 'INCENDIO':
        return const _IncidenciaTipoConfig(
          icon: Icons.local_fire_department,
          color: Colors.deepOrange,
        );

      case 'VIOLENCIA':
        return const _IncidenciaTipoConfig(
          icon: Icons.warning_amber_rounded,
          color: Colors.purple,
        );

      case 'SOSPECHOSO':
        return const _IncidenciaTipoConfig(
          icon: Icons.visibility,
          color: Colors.amber,
        );

      default:
        return const _IncidenciaTipoConfig(
          icon: Icons.report_problem_outlined,
          color: Colors.blueGrey,
        );
    }
  }
}

class _InfoItem extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoItem({required this.icon, required this.text});

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

class _IncidenciaTipoConfig {
  final IconData icon;
  final Color color;

  const _IncidenciaTipoConfig({required this.icon, required this.color});
}


