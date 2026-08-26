import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// State
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

class AlertaActivaContent extends StatelessWidget {
  final AlertaState state;

  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;
  final ValueChanged<int> onOpenDetail;
  final ValueChanged<int> onCancel;

  const AlertaActivaContent({
    super.key,
    required this.state,
    required this.onRefresh,
    required this.onRetry,
    required this.onOpenDetail,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Volver',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.goNamed('home');
            }
          },
          icon: const Icon(Icons.arrow_back_rounded),
        ),
        title: const Text('Alerta activa'),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: state.isAlertaActivaLoading ? null : onRetry,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.isAlertaActivaLoading && state.alertaActiva == null) {
      return const _LoadingView();
    }

    if (state.alertaActivaStatus == AlertaActivaStatus.error &&
        state.alertaActiva == null) {
      return _ErrorView(
        message:
            state.alertaActivaErrorMessage ??
            'No se pudo obtener la alerta activa.',
        onRetry: onRetry,
      );
    }

    final alerta = state.alertaActiva;

    if (alerta == null ||
        state.alertaActivaStatus == AlertaActivaStatus.empty) {
      return _EmptyView(onRefresh: onRefresh);
    }

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
        children: [
          _AlertaActivaHeader(alerta: alerta),
          const SizedBox(height: 14),
          _DescripcionCard(descripcion: alerta.descripcion),
          if (alerta.zona != null) ...[
            const SizedBox(height: 14),
            _ZonaCard(zona: alerta.zona!),
          ],
          if (alerta.patrullaje != null) ...[
            const SizedBox(height: 14),
            _PatrullajeCard(patrullaje: alerta.patrullaje!),
          ],
          if (alerta.tieneUbicacion) ...[
            const SizedBox(height: 14),
            _UbicacionCard(
              latitud: alerta.latitud!,
              longitud: alerta.longitud!,
            ),
          ],
          const SizedBox(height: 22),
          FilledButton.icon(
            onPressed: state.isActionLoading
                ? null
                : () {
                    onOpenDetail(alerta.id);
                  },
            icon: const Icon(Icons.visibility_outlined),
            label: const Text('Ver detalle completo'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: state.isActionLoading
                ? null
                : () {
                    onCancel(alerta.id);
                  },
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            icon: const Icon(Icons.cancel_schedule_send_outlined),
            label: const Text('Cancelar alerta'),
          ),
          if (state.isCancelandoAlerta) ...[
            const SizedBox(height: 18),
            const Center(child: CircularProgressIndicator()),
          ],
        ],
      ),
    );
  }
}

// ==========================================================================
// CABECERA
// ==========================================================================

class _AlertaActivaHeader extends StatelessWidget {
  final AlertaActivaData alerta;

  const _AlertaActivaHeader({required this.alerta});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final prioridadColor = _getPrioridadColor(alerta.prioridad);

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            prioridadColor.withValues(alpha: 0.16),
            colorScheme.surfaceContainerLow,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: prioridadColor.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: prioridadColor.withValues(alpha: 0.16),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  _getTipoIcon(alerta.tipo),
                  color: prioridadColor,
                  size: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alerta.titulo,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        _StatusChip(
                          label: _formatText(alerta.tipo),
                          icon: _getTipoIcon(alerta.tipo),
                          color: colorScheme.primary,
                        ),
                        _StatusChip(
                          label: _formatText(alerta.prioridad),
                          icon: Icons.priority_high_rounded,
                          color: prioridadColor,
                        ),
                        _StatusChip(
                          label: 'Activa',
                          icon: Icons.notifications_active_rounded,
                          color: Colors.red.shade700,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 14),
          _InfoRow(
            icon: Icons.schedule_rounded,
            label: 'Activada',
            value: _formatDateTime(alerta.createdAt),
          ),
          const SizedBox(height: 10),
          _InfoRow(
            icon: Icons.person_outline_rounded,
            label: 'Emisor',
            value: alerta.emisor?.username ?? 'No disponible',
          ),
          if (alerta.esCritica) ...[
            const SizedBox(height: 10),
            const _InfoRow(
              icon: Icons.wifi_tethering_rounded,
              label: 'Transmisión',
              value: 'Emitida en tiempo real',
              valueColor: Colors.green,
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================================================
// DESCRIPCIÓN
// ==========================================================================

class _DescripcionCard extends StatelessWidget {
  final String descripcion;

  const _DescripcionCard({required this.descripcion});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Descripción',
      icon: Icons.description_outlined,
      child: Text(
        descripcion.isNotEmpty
            ? descripcion
            : 'No existe una descripción disponible.',
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(height: 1.45),
      ),
    );
  }
}

// ==========================================================================
// ZONA
// ==========================================================================

class _ZonaCard extends StatelessWidget {
  final AlertaZonaData zona;

  const _ZonaCard({required this.zona});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Zona',
      icon: Icons.location_city_outlined,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.place_outlined,
            label: 'Nombre',
            value: zona.nombre,
          ),
          if (zona.riesgo != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.warning_amber_rounded,
              label: 'Riesgo',
              value: _formatText(zona.riesgo!),
            ),
          ],
          if (zona.descripcion != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'Descripción',
              value: zona.descripcion!,
            ),
          ],
        ],
      ),
    );
  }
}

// ==========================================================================
// PATRULLAJE
// ==========================================================================

class _PatrullajeCard extends StatelessWidget {
  final AlertaPatrullajeData patrullaje;

  const _PatrullajeCard({required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Patrullaje relacionado',
      icon: Icons.local_police_outlined,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.tag_rounded,
            label: 'Número',
            value: '#${patrullaje.id}',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.calendar_today_outlined,
            label: 'Fecha',
            value: patrullaje.fecha,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.schedule_outlined,
            label: 'Horario',
            value: '${patrullaje.horaInicio} - ${patrullaje.horaFin}',
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.info_outline_rounded,
            label: 'Estado',
            value: _formatText(patrullaje.estado),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// UBICACIÓN
// ==========================================================================

class _UbicacionCard extends StatelessWidget {
  final double latitud;
  final double longitud;

  const _UbicacionCard({required this.latitud, required this.longitud});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      title: 'Ubicación registrada',
      icon: Icons.location_on_outlined,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.south_rounded,
            label: 'Latitud',
            value: latitud.toStringAsFixed(6),
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.east_rounded,
            label: 'Longitud',
            value: longitud.toStringAsFixed(6),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// COMPONENTES COMUNES
// ==========================================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Widget child;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: colorScheme.primary),
              const SizedBox(width: 9),
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 19, color: colorScheme.onSurfaceVariant),
        const SizedBox(width: 10),
        SizedBox(
          width: 90,
          child: Text(
            label,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ),
      ],
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final Color color;

  const _StatusChip({
    required this.label,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(color: color, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// ESTADOS DE PANTALLA
// ==========================================================================

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(child: CircularProgressIndicator());
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline_rounded,
              size: 68,
              color: colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'No se pudo cargar la alerta',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 20),
            FilledButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Reintentar'),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyView extends StatelessWidget {
  final Future<void> Function() onRefresh;

  const _EmptyView({required this.onRefresh});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: onRefresh,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(24),
        children: [
          SizedBox(height: MediaQuery.sizeOf(context).height * 0.17),
          Icon(
            Icons.notifications_none_rounded,
            size: 82,
            color: colorScheme.onSurfaceVariant.withValues(alpha: 0.60),
          ),
          const SizedBox(height: 18),
          Text(
            'No tienes una alerta activa',
            textAlign: TextAlign.center,
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'Cuando actives el botón de emergencia, '
            'la alerta aparecerá en esta sección.',
            textAlign: TextAlign.center,
            style: TextStyle(color: colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// HELPERS
// ==========================================================================

String _formatText(String value) {
  final normalized = value.trim().replaceAll('_', ' ').toLowerCase();

  if (normalized.isEmpty) {
    return 'No disponible';
  }

  return normalized
      .split(' ')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}

String _formatDateTime(DateTime? date) {
  if (date == null) {
    return 'No disponible';
  }

  return DateFormat('dd/MM/yyyy · HH:mm', 'es_PE').format(date.toLocal());
}

Color _getPrioridadColor(String prioridad) {
  switch (prioridad.trim().toUpperCase()) {
    case 'CRITICA':
      return Colors.red.shade700;
    case 'ALTA':
      return Colors.orange.shade700;
    case 'MEDIA':
      return Colors.amber.shade800;
    case 'BAJA':
      return Colors.green.shade700;
    default:
      return Colors.blueGrey;
  }
}

IconData _getTipoIcon(String tipo) {
  switch (tipo.trim().toUpperCase()) {
    case 'PANICO':
    case 'SOS':
      return Icons.sos_rounded;
    case 'EMERGENCIA':
      return Icons.emergency_rounded;
    case 'INCIDENCIA':
      return Icons.report_problem_outlined;
    case 'INFORMATIVA':
      return Icons.info_outline_rounded;
    default:
      return Icons.notifications_active_outlined;
  }
}
