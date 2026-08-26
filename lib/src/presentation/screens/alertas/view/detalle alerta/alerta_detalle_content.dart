import 'package:flutter/material.dart';
import 'package:intl/intl.dart';


// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// State
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

class AlertaDetalleContent extends StatelessWidget {
  final AlertaState state;
  final MisAlertasData? alertaInicial;

  final VoidCallback onRetry;
  final VoidCallback onAceptar;
  final VoidCallback onRechazar;
  final VoidCallback onMarcarAtendida;
  final VoidCallback onCancelar;

  const AlertaDetalleContent({
    super.key,
    required this.state,
    this.alertaInicial,
    required this.onRetry,
    required this.onAceptar,
    required this.onRechazar,
    required this.onMarcarAtendida,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Detalle de alerta')),
      body: SafeArea(child: _buildBody(context)),
    );
  }

  Widget _buildBody(BuildContext context) {
    if (state.detalleStatus == AlertaDetalleStatus.loading &&
        state.alertaDetalle == null) {
      return _DetalleLoadingView(alertaInicial: alertaInicial);
    }

    if (state.detalleStatus == AlertaDetalleStatus.error &&
        state.alertaDetalle == null) {
      return _DetalleErrorView(
        message:
            state.detalleErrorMessage ??
            'No se pudo obtener el detalle de la alerta.',
        onRetry: onRetry,
      );
    }

    final detalle = state.alertaDetalle;

    if (detalle == null) {
      return _DetalleErrorView(
        message: 'No existe información disponible para esta alerta.',
        onRetry: onRetry,
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        onRetry();
      },
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 120),
        children: [
          _AlertaHeaderCard(detalle: detalle),
          const SizedBox(height: 12),
          _DescripcionCard(descripcion: detalle.descripcion),
          const SizedBox(height: 12),
          _EstadoUsuarioCard(recepcion: detalle.recepcionUsuario),
          if (detalle.zona != null) ...[
            const SizedBox(height: 12),
            _ZonaCard(zona: detalle.zona!),
          ],
          if (detalle.patrullaje != null) ...[
            const SizedBox(height: 12),
            _PatrullajeCard(patrullaje: detalle.patrullaje!),
          ],
          if (detalle.tieneUbicacion) ...[
            const SizedBox(height: 12),
            _UbicacionCard(
              latitud: detalle.latitud!,
              longitud: detalle.longitud!,
            ),
          ],
          const SizedBox(height: 12),
          _EmisorCard(emisor: detalle.emisor),
          const SizedBox(height: 20),
          _AccionesSection(
            state: state,
            detalle: detalle,
            onAceptar: onAceptar,
            onRechazar: onRechazar,
            onMarcarAtendida: onMarcarAtendida,
            onCancelar: onCancelar,
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// CABECERA
// ==========================================================================

class _AlertaHeaderCard extends StatelessWidget {
  final AlertaDetalleData detalle;

  const _AlertaHeaderCard({required this.detalle});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final prioridadColor = _getPrioridadColor(detalle.prioridad);

    return Card(
      elevation: 0,
      color: prioridadColor.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: prioridadColor.withValues(alpha: 0.30)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 54,
                  height: 54,
                  decoration: BoxDecoration(
                    color: prioridadColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getTipoIcon(detalle.tipo),
                    color: prioridadColor,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        detalle.titulo,
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
                            label: _formatText(detalle.tipo),
                            icon: _getTipoIcon(detalle.tipo),
                            color: colorScheme.primary,
                          ),
                          _StatusChip(
                            label: _formatText(detalle.prioridad),
                            icon: Icons.priority_high_rounded,
                            color: prioridadColor,
                          ),
                          _StatusChip(
                            label: _formatText(detalle.estado),
                            icon: _getAlertaEstadoIcon(detalle.estado),
                            color: _getAlertaEstadoColor(detalle.estado),
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
              label: 'Creada',
              value: _formatDateTime(detalle.createdAt),
            ),
            if (detalle.fechaExpiracion != null) ...[
              const SizedBox(height: 10),
              _InfoRow(
                icon: Icons.timer_off_outlined,
                label: 'Expira',
                value: _formatDateTime(detalle.fechaExpiracion),
              ),
            ],
          ],
        ),
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
// ESTADO DEL USUARIO
// ==========================================================================

class _EstadoUsuarioCard extends StatelessWidget {
  final AlertaUsuarioEstadoData? recepcion;

  const _EstadoUsuarioCard({required this.recepcion});

  @override
  Widget build(BuildContext context) {
    if (recepcion == null) {
      return const _SectionCard(
        title: 'Estado de recepción',
        icon: Icons.mark_email_unread_outlined,
        child: Text('No existe información de recepción para este usuario.'),
      );
    }

    return _SectionCard(
      title: 'Estado de recepción',
      icon: Icons.mark_email_read_outlined,
      child: Column(
        children: [
          _InfoRow(
            icon: _getRecepcionEstadoIcon(recepcion!.estado),
            label: 'Estado',
            value: _formatText(recepcion!.estado),
            valueColor: _getRecepcionEstadoColor(recepcion!.estado),
          ),
          if (recepcion!.fechaRecibida != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.notifications_active_outlined,
              label: 'Recibida',
              value: _formatDateTime(recepcion!.fechaRecibida),
            ),
          ],
          if (recepcion!.fechaLeida != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.mark_email_read_outlined,
              label: 'Leída',
              value: _formatDateTime(recepcion!.fechaLeida),
            ),
          ],
          if (recepcion!.fechaRespuesta != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.question_answer_outlined,
              label: 'Respondida',
              value: _formatDateTime(recepcion!.fechaRespuesta),
            ),
          ],
          if (recepcion!.fechaAtendida != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.task_alt_rounded,
              label: 'Atendida',
              value: _formatDateTime(recepcion!.fechaAtendida),
            ),
          ],
          if (recepcion!.observacion != null) ...[
            const SizedBox(height: 14),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Observación',
                style: Theme.of(
                  context,
                ).textTheme.labelLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 5),
            Align(
              alignment: Alignment.centerLeft,
              child: Text(recepcion!.observacion!),
            ),
          ],
        ],
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
            label: 'Patrullaje',
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
          if (patrullaje.descripcion != null) ...[
            const SizedBox(height: 12),
            _InfoRow(
              icon: Icons.notes_rounded,
              label: 'Descripción',
              value: patrullaje.descripcion!,
            ),
          ],
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
      title: 'Ubicación',
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
// EMISOR
// ==========================================================================

class _EmisorCard extends StatelessWidget {
  final AlertaEmisorData? emisor;

  const _EmisorCard({required this.emisor});

  @override
  Widget build(BuildContext context) {
    if (emisor == null) {
      return const _SectionCard(
        title: 'Emisor',
        icon: Icons.person_outline_rounded,
        child: Text('No existe información del emisor.'),
      );
    }

    return _SectionCard(
      title: 'Emisor',
      icon: Icons.person_outline_rounded,
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.badge_outlined,
            label: 'Usuario',
            value: emisor!.username,
          ),
          const SizedBox(height: 12),
          _InfoRow(
            icon: Icons.email_outlined,
            label: 'Correo',
            value: emisor!.correo,
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// ACCIONES
// ==========================================================================

class _AccionesSection extends StatelessWidget {
  final AlertaState state;
  final AlertaDetalleData detalle;

  final VoidCallback onAceptar;
  final VoidCallback onRechazar;
  final VoidCallback onMarcarAtendida;
  final VoidCallback onCancelar;

  const _AccionesSection({
    required this.state,
    required this.detalle,
    required this.onAceptar,
    required this.onRechazar,
    required this.onMarcarAtendida,
    required this.onCancelar,
  });

  @override
  Widget build(BuildContext context) {
    final recepcion = detalle.recepcionUsuario;

    final estadoRecepcion = recepcion?.estado.toUpperCase();

    final puedeResponder =
        detalle.permisos.puedeResponder &&
        detalle.resumenEstado.estaActiva &&
        estadoRecepcion != 'ACEPTADA' &&
        estadoRecepcion != 'RECHAZADA' &&
        estadoRecepcion != 'ATENDIDA';

    final puedeMarcarAtendida =
        detalle.resumenEstado.estaActiva && estadoRecepcion == 'ACEPTADA';

    final puedeCancelar =
        detalle.permisos.puedeCancelar && detalle.resumenEstado.estaActiva;

    if (!puedeResponder && !puedeMarcarAtendida && !puedeCancelar) {
      return const SizedBox.shrink();
    }

    final isLoading = state.isActionLoading;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Acciones disponibles',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (puedeResponder) ...[
          FilledButton.icon(
            onPressed: isLoading ? null : onAceptar,
            icon: const Icon(Icons.check_circle_outline_rounded),
            label: const Text('Aceptar alerta'),
          ),
          const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onRechazar,
            icon: const Icon(Icons.cancel_outlined),
            label: const Text('Rechazar alerta'),
          ),
        ],
        if (puedeMarcarAtendida) ...[
          if (puedeResponder) const SizedBox(height: 10),
          FilledButton.icon(
            onPressed: isLoading ? null : onMarcarAtendida,
            icon: const Icon(Icons.task_alt_rounded),
            label: const Text('Marcar como atendida'),
          ),
        ],
        if (puedeCancelar) ...[
          if (puedeResponder || puedeMarcarAtendida) const SizedBox(height: 10),
          OutlinedButton.icon(
            onPressed: isLoading ? null : onCancelar,
            style: OutlinedButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
              side: BorderSide(color: Theme.of(context).colorScheme.error),
            ),
            icon: const Icon(Icons.cancel_schedule_send_outlined),
            label: const Text('Cancelar alerta'),
          ),
        ],
        if (isLoading) ...[
          const SizedBox(height: 14),
          const Center(child: CircularProgressIndicator()),
        ],
      ],
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

    return Card(
      elevation: 0,
      color: colorScheme.surfaceContainerLow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: colorScheme.outlineVariant.withValues(alpha: 0.55),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
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
          width: 88,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor,
            ),
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
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================================
// LOADING Y ERROR
// ==========================================================================

class _DetalleLoadingView extends StatelessWidget {
  final MisAlertasData? alertaInicial;

  const _DetalleLoadingView({this.alertaInicial});

  @override
  Widget build(BuildContext context) {
    final alerta = alertaInicial?.alerta;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 18),
            Text(
              alerta?.titulo.isNotEmpty == true
                  ? alerta!.titulo
                  : 'Cargando detalle de alerta...',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ],
        ),
      ),
    );
  }
}

class _DetalleErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _DetalleErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
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
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colorScheme.onSurfaceVariant),
            ),
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

IconData _getAlertaEstadoIcon(String estado) {
  switch (estado.trim().toUpperCase()) {
    case 'PENDIENTE':
      return Icons.schedule_rounded;

    case 'EN_ATENCION':
      return Icons.pending_actions_rounded;

    case 'ATENDIDA':
      return Icons.task_alt_rounded;

    case 'CANCELADA':
      return Icons.cancel_outlined;

    case 'FINALIZADA':
      return Icons.check_circle_outline_rounded;

    default:
      return Icons.info_outline_rounded;
  }
}

Color _getAlertaEstadoColor(String estado) {
  switch (estado.trim().toUpperCase()) {
    case 'PENDIENTE':
      return Colors.orange.shade700;

    case 'EN_ATENCION':
      return Colors.blue.shade700;

    case 'ATENDIDA':
      return Colors.green.shade700;

    case 'CANCELADA':
      return Colors.red.shade700;

    case 'FINALIZADA':
      return Colors.blueGrey.shade700;

    default:
      return Colors.blueGrey;
  }
}

IconData _getRecepcionEstadoIcon(String estado) {
  switch (estado.trim().toUpperCase()) {
    case 'PENDIENTE':
      return Icons.schedule_rounded;

    case 'RECIBIDA':
      return Icons.notifications_active_outlined;

    case 'LEIDA':
      return Icons.mark_email_read_outlined;

    case 'ACEPTADA':
      return Icons.check_circle_outline_rounded;

    case 'RECHAZADA':
      return Icons.cancel_outlined;

    case 'ATENDIDA':
      return Icons.task_alt_rounded;

    default:
      return Icons.info_outline_rounded;
  }
}

Color _getRecepcionEstadoColor(String estado) {
  switch (estado.trim().toUpperCase()) {
    case 'PENDIENTE':
      return Colors.orange.shade700;

    case 'RECIBIDA':
      return Colors.blue.shade700;

    case 'LEIDA':
      return Colors.blueGrey.shade600;

    case 'ACEPTADA':
      return Colors.green.shade700;

    case 'RECHAZADA':
      return Colors.red.shade700;

    case 'ATENDIDA':
      return Colors.teal.shade700;

    default:
      return Colors.blueGrey;
  }
}
