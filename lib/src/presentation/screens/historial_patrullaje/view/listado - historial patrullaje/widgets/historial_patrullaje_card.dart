import 'package:flutter/material.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

class HistorialPatrullajeCard extends StatelessWidget {
  final HistorialPatrullajeData historial;
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

    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: colorScheme.surface,

      borderRadius: BorderRadius.circular(18),

      child: InkWell(
        onTap: onTap,

        borderRadius: BorderRadius.circular(18),

        child: Container(
          padding: const EdgeInsets.all(16),

          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),

            border: Border.all(
              color: colorScheme.outlineVariant.withOpacity(0.55),
            ),

            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(
                  Theme.of(context).brightness == Brightness.dark
                      ? 0.12
                      : 0.035,
                ),

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

              Divider(
                height: 1,
                color: colorScheme.outlineVariant.withOpacity(0.6),
              ),

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

  // ========================================================
  // ENCABEZADO
  // ========================================================
  Widget _buildHeader(
    BuildContext context,
    _ChipStyle tipoStyle,
    _ChipStyle prioridadStyle,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Expanded(
          child: Wrap(
            spacing: 8,

            runSpacing: 8,

            children: [
              _StatusChip(
                label: _getTipoLabel(historial.tipo),

                icon: tipoStyle.icon,

                foregroundColor: tipoStyle.foregroundColor,

                backgroundColor: tipoStyle.backgroundColor,
              ),

              _StatusChip(
                label: _getPrioridadLabel(historial.prioridad),

                icon: prioridadStyle.icon,

                foregroundColor: prioridadStyle.foregroundColor,

                backgroundColor: prioridadStyle.backgroundColor,
              ),
            ],
          ),
        ),

        if (onTap != null) ...[
          const SizedBox(width: 8),

          Icon(
            Icons.chevron_right_rounded,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ],
      ],
    );
  }

  // ========================================================
  // TÍTULO
  // ========================================================
  Widget _buildTitle(BuildContext context) {
    return Text(
      historial.titulo.trim().isNotEmpty
          ? historial.titulo.trim()
          : 'Sin título',

      style: Theme.of(context).textTheme.titleMedium?.copyWith(
        fontWeight: FontWeight.w700,

        color: Theme.of(context).colorScheme.onSurface,
      ),
    );
  }

  // ========================================================
  // DESCRIPCIÓN
  // ========================================================
  Widget _buildDescription(BuildContext context) {
    return Text(
      historial.descripcion.trim().isNotEmpty
          ? historial.descripcion.trim()
          : 'Sin descripción registrada.',

      maxLines: 4,

      overflow: TextOverflow.ellipsis,

      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
        color: Theme.of(context).colorScheme.onSurfaceVariant,

        height: 1.45,
      ),
    );
  }

  // ========================================================
  // INFORMACIÓN
  // ========================================================
  Widget _buildInformation(BuildContext context) {
    final nombreSereno = _getNombreSereno();

    final nombreZona = historial.zona?.nombre.trim();

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

        if (historial.tieneUbicacion) ...[
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

  // ========================================================
  // SIGUIENTE TURNO
  // ========================================================
  Widget _buildNextShiftAlert(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final foregroundColor = isDark
        ? Colors.amber.shade200
        : Colors.amber.shade900;

    final backgroundColor = isDark
        ? Colors.amber.shade900.withOpacity(0.20)
        : Colors.amber.shade50;

    final borderColor = isDark
        ? Colors.amber.shade700.withOpacity(0.50)
        : Colors.amber.shade200;

    return Container(
      width: double.infinity,

      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

      decoration: BoxDecoration(
        color: backgroundColor,

        borderRadius: BorderRadius.circular(12),

        border: Border.all(color: borderColor),
      ),

      child: Row(
        children: [
          Icon(Icons.visibility_outlined, size: 20, color: foregroundColor),

          const SizedBox(width: 10),

          Expanded(
            child: Text(
              'Información visible para el siguiente turno.',

              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: foregroundColor,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ========================================================
  // NOMBRE DEL SERENO
  // ========================================================
  String _getNombreSereno() {
    final nombres = historial.sereno?.nombres.trim() ?? '';

    final apellidos = historial.sereno?.apellidos.trim() ?? '';

    final nombreCompleto = [
      nombres,
      apellidos,
    ].where((value) => value.isNotEmpty).join(' ');

    return nombreCompleto.isNotEmpty ? nombreCompleto : 'Sereno no disponible';
  }

  // ========================================================
  // FORMATEAR FECHA
  // ========================================================
  String _formatDateTime(DateTime value) {
    final localDate = value.toLocal();

    final day = localDate.day.toString().padLeft(2, '0');

    final month = localDate.month.toString().padLeft(2, '0');

    final year = localDate.year.toString();

    final hour = localDate.hour.toString().padLeft(2, '0');

    final minute = localDate.minute.toString().padLeft(2, '0');

    return '$day/$month/$year - $hour:$minute';
  }

  // ========================================================
  // LABEL DE TIPO
  // ========================================================
  String _getTipoLabel(HistorialTipo tipo) {
    switch (tipo) {
      case HistorialTipo.observacion:
        return 'Observación';

      case HistorialTipo.novedad:
        return 'Novedad';

      case HistorialTipo.alerta:
        return 'Alerta';

      case HistorialTipo.recomendacion:
        return 'Recomendación';

      case HistorialTipo.puntoCritico:
        return 'Punto crítico';

      case HistorialTipo.cambioTurno:
        return 'Cambio de turno';
    }
  }

  // ========================================================
  // LABEL DE PRIORIDAD
  // ========================================================
  String _getPrioridadLabel(HistorialPrioridad prioridad) {
    switch (prioridad) {
      case HistorialPrioridad.baja:
        return 'Prioridad baja';

      case HistorialPrioridad.media:
        return 'Prioridad media';

      case HistorialPrioridad.alta:
        return 'Prioridad alta';

      case HistorialPrioridad.critica:
        return 'Prioridad crítica';
    }
  }

  // ========================================================
  // ESTILO DEL TIPO
  // ========================================================
  _ChipStyle _getTipoStyle(HistorialTipo tipo) {
    switch (tipo) {
      case HistorialTipo.observacion:
        return _ChipStyle(
          icon: Icons.visibility_outlined,

          foregroundColor: Colors.indigo.shade800,

          backgroundColor: Colors.indigo.shade50,
        );

      case HistorialTipo.novedad:
        return _ChipStyle(
          icon: Icons.campaign_outlined,

          foregroundColor: Colors.blue.shade800,

          backgroundColor: Colors.blue.shade50,
        );

      case HistorialTipo.alerta:
        return _ChipStyle(
          icon: Icons.notification_important_outlined,

          foregroundColor: Colors.red.shade800,

          backgroundColor: Colors.red.shade50,
        );

      case HistorialTipo.recomendacion:
        return _ChipStyle(
          icon: Icons.lightbulb_outline_rounded,

          foregroundColor: Colors.green.shade800,

          backgroundColor: Colors.green.shade50,
        );

      case HistorialTipo.puntoCritico:
        return _ChipStyle(
          icon: Icons.warning_amber_rounded,

          foregroundColor: Colors.deepOrange.shade800,

          backgroundColor: Colors.deepOrange.shade50,
        );

      case HistorialTipo.cambioTurno:
        return _ChipStyle(
          icon: Icons.sync_alt_rounded,

          foregroundColor: Colors.purple.shade800,

          backgroundColor: Colors.purple.shade50,
        );
    }
  }

  // ========================================================
  // ESTILO DE PRIORIDAD
  // ========================================================
  _ChipStyle _getPrioridadStyle(HistorialPrioridad prioridad) {
    switch (prioridad) {
      case HistorialPrioridad.baja:
        return _ChipStyle(
          icon: Icons.arrow_downward_rounded,

          foregroundColor: Colors.green.shade800,

          backgroundColor: Colors.green.shade50,
        );

      case HistorialPrioridad.media:
        return _ChipStyle(
          icon: Icons.remove_rounded,

          foregroundColor: Colors.amber.shade900,

          backgroundColor: Colors.amber.shade50,
        );

      case HistorialPrioridad.alta:
        return _ChipStyle(
          icon: Icons.arrow_upward_rounded,

          foregroundColor: Colors.deepOrange.shade800,

          backgroundColor: Colors.deepOrange.shade50,
        );

      case HistorialPrioridad.critica:
        return _ChipStyle(
          icon: Icons.priority_high_rounded,

          foregroundColor: Colors.red.shade900,

          backgroundColor: Colors.red.shade100,
        );
    }
  }
}

// ==========================================================
// CHIP DE ESTADO
// ==========================================================
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

// ==========================================================
// FILA DE INFORMACIÓN
// ==========================================================
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
    final color = Theme.of(context).colorScheme.onSurfaceVariant;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,

      children: [
        Icon(icon, size: 19, color: color),

        const SizedBox(width: 10),

        Expanded(
          child: RichText(
            text: TextSpan(
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: color, height: 1.35),

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

// ==========================================================
// CONFIGURACIÓN DEL CHIP
// ==========================================================
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
