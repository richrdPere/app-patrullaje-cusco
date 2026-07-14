import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';

class HistorialPatrullajeCard extends StatelessWidget {
  final HistorialPatrullajeModel historial;
  final VoidCallback? onTap;

  const HistorialPatrullajeCard({
    super.key,
    required this.historial,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final tipoStyle = _getTipoStyle(historial.tipo);
    final prioridadStyle = _getPrioridadStyle(historial.prioridad);

    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(color: Colors.grey.shade200),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.035),
                blurRadius: 12,
                offset: const Offset(0, 5),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(context, tipoStyle, prioridadStyle),
              const SizedBox(height: 14),
              _buildTitle(context),
              const SizedBox(height: 8),
              _buildDescription(context),
              const SizedBox(height: 16),
              Divider(height: 1, color: Colors.grey.shade200),
              const SizedBox(height: 14),
              _buildInformation(context),
              if (historial.visibleParaSiguienteTurno) ...[
                const SizedBox(height: 14),
                _buildNextShiftAlert(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(
    BuildContext context,
    _ChipStyle tipoStyle,
    _ChipStyle prioridadStyle,
  ) {
    return Row(
      children: [
        Expanded(
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _StatusChip(
                label: _formatLabel(historial.tipo),
                icon: tipoStyle.icon,
                foregroundColor: tipoStyle.foregroundColor,
                backgroundColor: tipoStyle.backgroundColor,
              ),
              _StatusChip(
                label: _formatLabel(historial.prioridad),
                icon: prioridadStyle.icon,
                foregroundColor: prioridadStyle.foregroundColor,
                backgroundColor: prioridadStyle.backgroundColor,
              ),
            ],
          ),
        ),
        if (onTap != null)
          Icon(Icons.chevron_right_rounded, color: Colors.grey.shade500),
      ],
    );
  }

  Widget _buildTitle(BuildContext context) {
    return Text(
      historial.titulo.isNotEmpty ? historial.titulo : 'Sin título',
      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,
        color: const Color(0xFF1F2937),
      ),
    );
  }

  Widget _buildDescription(BuildContext context) {
    return Text(
      historial.descripcion.isNotEmpty
          ? historial.descripcion
          : 'Sin descripción registrada.',
      maxLines: 4,
      overflow: TextOverflow.ellipsis,
      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Colors.grey.shade700,
        height: 1.45,
      ),
    );
  }

  Widget _buildInformation(BuildContext context) {
    final nombreSereno = _getNombreSereno();
    final nombreZona = historial.zona?.nombre;
    final fecha = _formatDateTime(historial.fechaHora);

    return Column(
      children: [
        _InformationRow(
          icon: Icons.person_outline_rounded,
          label: 'Registrado por',
          value: nombreSereno,
        ),
        const SizedBox(height: 10),
        _InformationRow(
          icon: Icons.location_on_outlined,
          label: 'Zona',
          value: nombreZona?.isNotEmpty == true
              ? nombreZona!
              : 'Zona no disponible',
        ),
        const SizedBox(height: 10),
        _InformationRow(
          icon: Icons.schedule_rounded,
          label: 'Fecha y hora',
          value: fecha,
        ),
        if (historial.latitud != null && historial.longitud != null) ...[
          const SizedBox(height: 10),
          _InformationRow(
            icon: Icons.my_location_rounded,
            label: 'Ubicación',
            value:
                '${historial.latitud!.toStringAsFixed(6)}, '
                '${historial.longitud!.toStringAsFixed(6)}',
          ),
        ],
      ],
    );
  }

  Widget _buildNextShiftAlert(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.amber.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.amber.shade200),
      ),
      child: Row(
        children: [
          Icon(
            Icons.visibility_outlined,
            size: 20,
            color: Colors.amber.shade900,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Información visible para el siguiente turno.',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.amber.shade900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getNombreSereno() {
    final nombres = historial.sereno?.nombres.trim() ?? '';
    final apellidos = historial.sereno?.apellidos.trim() ?? '';

    final nombreCompleto = '$nombres $apellidos'.trim();

    return nombreCompleto.isNotEmpty ? nombreCompleto : 'Sereno no disponible';
  }

  String _formatDateTime(DateTime? value) {
    if (value == null) {
      return 'Fecha no disponible';
    }

    final localDate = value.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');
    final month = localDate.month.toString().padLeft(2, '0');
    final year = localDate.year.toString();

    final hour = localDate.hour.toString().padLeft(2, '0');
    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }

  String _formatLabel(String value) {
    if (value.trim().isEmpty) {
      return 'Sin definir';
    }

    return value
        .trim()
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .where((word) => word.isNotEmpty)
        .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
        .join(' ');
  }

  _ChipStyle _getTipoStyle(String tipo) {
    switch (tipo.toUpperCase()) {
      case 'NOVEDAD':
        return _ChipStyle(
          icon: Icons.campaign_outlined,
          foregroundColor: Colors.blue.shade800,
          backgroundColor: Colors.blue.shade50,
        );

      case 'ALERTA':
        return _ChipStyle(
          icon: Icons.notification_important_outlined,
          foregroundColor: Colors.red.shade800,
          backgroundColor: Colors.red.shade50,
        );

      case 'RECOMENDACION':
        return _ChipStyle(
          icon: Icons.lightbulb_outline_rounded,
          foregroundColor: Colors.green.shade800,
          backgroundColor: Colors.green.shade50,
        );

      case 'PUNTO_CRITICO':
        return _ChipStyle(
          icon: Icons.warning_amber_rounded,
          foregroundColor: Colors.deepOrange.shade800,
          backgroundColor: Colors.deepOrange.shade50,
        );

      case 'CAMBIO_TURNO':
        return _ChipStyle(
          icon: Icons.sync_alt_rounded,
          foregroundColor: Colors.purple.shade800,
          backgroundColor: Colors.purple.shade50,
        );

      case 'OBSERVACION':
      default:
        return _ChipStyle(
          icon: Icons.visibility_outlined,
          foregroundColor: Colors.indigo.shade800,
          backgroundColor: Colors.indigo.shade50,
        );
    }
  }

  _ChipStyle _getPrioridadStyle(String prioridad) {
    switch (prioridad.toUpperCase()) {
      case 'CRITICA':
        return _ChipStyle(
          icon: Icons.priority_high_rounded,
          foregroundColor: Colors.red.shade900,
          backgroundColor: Colors.red.shade100,
        );

      case 'ALTA':
        return _ChipStyle(
          icon: Icons.arrow_upward_rounded,
          foregroundColor: Colors.deepOrange.shade800,
          backgroundColor: Colors.deepOrange.shade50,
        );

      case 'BAJA':
        return _ChipStyle(
          icon: Icons.arrow_downward_rounded,
          foregroundColor: Colors.green.shade800,
          backgroundColor: Colors.green.shade50,
        );

      case 'MEDIA':
      default:
        return _ChipStyle(
          icon: Icons.remove_rounded,
          foregroundColor: Colors.amber.shade900,
          backgroundColor: Colors.amber.shade50,
        );
    }
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: foregroundColor),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InformationRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: Colors.grey.shade600),
        const SizedBox(width: 10),
        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey.shade700,
                height: 1.35,
              ),
              children: [
                TextSpan(
                  text: '$label: ',
                  style: const TextStyle(fontWeight: FontWeight.w600),
                ),
                TextSpan(text: value),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _ChipStyle {
  final IconData icon;
  final Color foregroundColor;
  final Color backgroundColor;

  const _ChipStyle({
    required this.icon,
    required this.foregroundColor,
    required this.backgroundColor,
  });
}
