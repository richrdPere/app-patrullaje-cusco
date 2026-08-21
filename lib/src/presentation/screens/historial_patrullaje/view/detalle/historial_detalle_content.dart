import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl/intl.dart';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

class HistorialDetalleContent extends StatelessWidget {
  final Future<void> Function() onRefresh;
  final VoidCallback onRetry;

  const HistorialDetalleContent({
    super.key,
    required this.onRefresh,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      buildWhen: (previous, current) {
        return previous.detailStatus != current.detailStatus ||
            previous.historialSelected != current.historialSelected ||
            previous.errorMessage != current.errorMessage;
      },

      builder: (context, state) {
        final status = state.detailStatus;

        final historial = state.historialSelected;

        if (status == HistorialDetailStatus.loading && historial == null) {
          return const Center(child: CircularProgressIndicator());
        }

        if (status == HistorialDetailStatus.error && historial == null) {
          return _ErrorView(
            message:
                state.errorMessage ??
                'No se pudo obtener el detalle del historial.',
            onRetry: onRetry,
          );
        }

        if (historial == null) {
          return _ErrorView(
            message: 'No se encontró información del historial.',
            onRetry: onRetry,
          );
        }

        return Stack(
          children: [
            RefreshIndicator(
              onRefresh: onRefresh,

              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),

                padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),

                children: [
                  _HeaderCard(historial: historial),

                  const SizedBox(height: 16),

                  _DescriptionCard(historial: historial),

                  const SizedBox(height: 16),

                  _OperationalInformationCard(historial: historial),

                  const SizedBox(height: 16),

                  _SerenoCard(sereno: historial.sereno),

                  const SizedBox(height: 16),

                  _ZonaCard(zona: historial.zona),

                  if (historial.tieneUbicacion) ...[
                    const SizedBox(height: 16),

                    _LocationCard(
                      latitud: historial.latitud!,

                      longitud: historial.longitud!,
                    ),
                  ],

                  if (historial.visibleParaSiguienteTurno) ...[
                    const SizedBox(height: 16),

                    const _NextShiftCard(),
                  ],
                ],
              ),
            ),

            if (status == HistorialDetailStatus.loading)
              const Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: LinearProgressIndicator(),
              ),
          ],
        );
      },
    );
  }
}

// ==========================================================
// ENCABEZADO
// ==========================================================
class _HeaderCard extends StatelessWidget {
  final HistorialDetalleData historial;

  const _HeaderCard({required this.historial});

  @override
  Widget build(BuildContext context) {
    final typeColor = _typeColor(historial.tipo);

    final priorityColor = _priorityColor(historial.prioridad);

    return Container(
      padding: const EdgeInsets.all(18),

      decoration: BoxDecoration(
        color: typeColor.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(18),

        border: Border.all(color: typeColor.withValues(alpha: 0.28)),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: typeColor.withValues(alpha: 0.15),

                child: Icon(_typeIcon(historial.tipo), color: typeColor),
              ),

              const SizedBox(width: 12),

              Expanded(
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _StatusChip(
                      label: _typeLabel(historial.tipo),

                      color: typeColor,
                    ),

                    _StatusChip(
                      label: _priorityLabel(historial.prioridad),

                      color: priorityColor,
                    ),

                    _StatusChip(
                      label: _statusLabel(historial.estado),

                      color: historial.estado == HistorialEstado.activo
                          ? Colors.green
                          : Colors.grey,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            historial.titulo.trim().isNotEmpty
                ? historial.titulo
                : 'Sin título',

            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
          ),

          const SizedBox(height: 8),

          Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                size: 17,
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),

              const SizedBox(width: 6),

              Expanded(
                child: Text(
                  DateFormat(
                    'dd/MM/yyyy - HH:mm',
                  ).format(historial.fechaHora.toLocal()),

                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// DESCRIPCIÓN
// ==========================================================
class _DescriptionCard extends StatelessWidget {
  final HistorialDetalleData historial;

  const _DescriptionCard({required this.historial});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.description_outlined,

      title: 'Descripción',

      child: Text(
        historial.descripcion.trim().isNotEmpty
            ? historial.descripcion
            : 'No se registró una descripción.',

        style: Theme.of(context).textTheme.bodyMedium?.copyWith(height: 1.5),
      ),
    );
  }
}

// ==========================================================
// INFORMACIÓN OPERATIVA
// ==========================================================
class _OperationalInformationCard extends StatelessWidget {
  final HistorialDetalleData historial;

  const _OperationalInformationCard({required this.historial});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.info_outline_rounded,

      title: 'Información operativa',

      child: Column(
        children: [
          _InformationRow(label: 'Registro', value: 'N.° ${historial.id}'),

          const Divider(),

          _InformationRow(
            label: 'Patrullaje',
            value: 'N.° ${historial.patrullajeId}',
          ),

          const Divider(),

          _InformationRow(label: 'Tipo', value: _typeLabel(historial.tipo)),

          const Divider(),

          _InformationRow(
            label: 'Prioridad',
            value: _priorityLabel(historial.prioridad),
          ),

          const Divider(),

          _InformationRow(
            label: 'Estado',
            value: _statusLabel(historial.estado),
          ),

          const Divider(),

          _InformationRow(
            label: 'Siguiente turno',
            value: historial.visibleParaSiguienteTurno
                ? 'Visible'
                : 'No visible',
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// SERENO
// ==========================================================
class _SerenoCard extends StatelessWidget {
  final HistorialSerenoData? sereno;

  const _SerenoCard({required this.sereno});

  @override
  Widget build(BuildContext context) {
    final nombre = sereno?.nombreCompleto.trim();

    return _SectionCard(
      icon: Icons.person_outline_rounded,

      title: 'Sereno responsable',

      child: Row(
        children: [
          CircleAvatar(child: Text(_initials(nombre))),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  nombre?.isNotEmpty == true ? nombre! : 'Sereno no disponible',

                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                if (sereno != null)
                  Text(
                    'ID de usuario: ${sereno!.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// ZONA
// ==========================================================
class _ZonaCard extends StatelessWidget {
  final HistorialZonaData? zona;

  const _ZonaCard({required this.zona});

  @override
  Widget build(BuildContext context) {
    final risk = zona?.riesgo?.toLowerCase();

    final riskColor = _riskColor(risk);

    return _SectionCard(
      icon: Icons.map_outlined,

      title: 'Zona',

      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  zona?.nombre.isNotEmpty == true
                      ? zona!.nombre
                      : 'Zona no disponible',

                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                if (zona != null)
                  Text(
                    'Zona N.° ${zona!.id}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
              ],
            ),
          ),

          if (risk != null && risk.isNotEmpty)
            _StatusChip(label: 'Riesgo ${_capitalize(risk)}', color: riskColor),
        ],
      ),
    );
  }
}

// ==========================================================
// UBICACIÓN
// ==========================================================
class _LocationCard extends StatelessWidget {
  final double latitud;
  final double longitud;

  const _LocationCard({required this.latitud, required this.longitud});

  @override
  Widget build(BuildContext context) {
    return _SectionCard(
      icon: Icons.location_on_outlined,

      title: 'Ubicación registrada',

      child: Container(
        width: double.infinity,

        padding: const EdgeInsets.all(13),

        decoration: BoxDecoration(
          color: Theme.of(
            context,
          ).colorScheme.primaryContainer.withValues(alpha: 0.45),

          borderRadius: BorderRadius.circular(12),
        ),

        child: Row(
          children: [
            Icon(
              Icons.my_location_rounded,
              color: Theme.of(context).colorScheme.primary,
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  const Text(
                    'Coordenadas',

                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    '${latitud.toStringAsFixed(7)}, '
                    '${longitud.toStringAsFixed(7)}',

                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// SIGUIENTE TURNO
// ==========================================================
class _NextShiftCard extends StatelessWidget {
  const _NextShiftCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(15),

      decoration: BoxDecoration(
        color: Colors.amber.withValues(alpha: 0.09),

        borderRadius: BorderRadius.circular(15),

        border: Border.all(color: Colors.amber.withValues(alpha: 0.35)),
      ),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Icon(Icons.visibility_outlined, color: Colors.amber.shade900),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,

              children: [
                Text(
                  'Visible para el siguiente turno',

                  style: TextStyle(
                    color: Colors.amber.shade900,

                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                const Text(
                  'Esta información estará disponible para el siguiente sereno asignado a la zona.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// COMPONENTES AUXILIARES
// ==========================================================
class _SectionCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final Widget child;

  const _SectionCard({
    required this.icon,
    required this.title,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(16),

      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,

        borderRadius: BorderRadius.circular(16),

        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Icon(
                icon,
                size: 21,
                color: Theme.of(context).colorScheme.primary,
              ),

              const SizedBox(width: 9),

              Text(
                title,

                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
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

class _InformationRow extends StatelessWidget {
  final String label;
  final String value;

  const _InformationRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),

      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Expanded(
            child: Text(
              label,

              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
            ),
          ),

          const SizedBox(width: 12),

          Flexible(
            child: Text(
              value,

              textAlign: TextAlign.end,

              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusChip extends StatelessWidget {
  final String label;
  final Color color;

  const _StatusChip({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),

      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.11),

        borderRadius: BorderRadius.circular(30),
      ),

      child: Text(
        label,

        style: TextStyle(
          color: color,

          fontSize: 11,

          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),

        child: Column(
          mainAxisSize: MainAxisSize.min,

          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 50,
              color: Colors.red,
            ),

            const SizedBox(height: 12),

            Text(message, textAlign: TextAlign.center),

            const SizedBox(height: 16),

            FilledButton.icon(
              onPressed: onRetry,

              icon: const Icon(Icons.refresh_rounded),

              label: const Text('REINTENTAR'),
            ),
          ],
        ),
      ),
    );
  }
}

// ==========================================================
// HELPERS
// ==========================================================
String _typeLabel(HistorialTipo tipo) {
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

IconData _typeIcon(HistorialTipo tipo) {
  switch (tipo) {
    case HistorialTipo.observacion:
      return Icons.visibility_outlined;
    case HistorialTipo.novedad:
      return Icons.new_releases_outlined;
    case HistorialTipo.alerta:
      return Icons.warning_amber_rounded;
    case HistorialTipo.recomendacion:
      return Icons.lightbulb_outline;
    case HistorialTipo.puntoCritico:
      return Icons.location_on_outlined;
    case HistorialTipo.cambioTurno:
      return Icons.swap_horiz_rounded;
  }
}

Color _typeColor(HistorialTipo tipo) {
  switch (tipo) {
    case HistorialTipo.observacion:
      return Colors.indigo;
    case HistorialTipo.novedad:
      return Colors.blue;
    case HistorialTipo.alerta:
      return Colors.red;
    case HistorialTipo.recomendacion:
      return Colors.green;
    case HistorialTipo.puntoCritico:
      return Colors.deepOrange;
    case HistorialTipo.cambioTurno:
      return Colors.purple;
  }
}

String _priorityLabel(HistorialPrioridad prioridad) {
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

Color _priorityColor(HistorialPrioridad prioridad) {
  switch (prioridad) {
    case HistorialPrioridad.baja:
      return Colors.green;
    case HistorialPrioridad.media:
      return Colors.amber.shade800;
    case HistorialPrioridad.alta:
      return Colors.deepOrange;
    case HistorialPrioridad.critica:
      return Colors.red;
  }
}

String _statusLabel(HistorialEstado estado) {
  switch (estado) {
    case HistorialEstado.activo:
      return 'Activo';
    case HistorialEstado.archivado:
      return 'Archivado';
  }
}

Color _riskColor(String? risk) {
  switch (risk) {
    case 'bajo':
      return Colors.green;
    case 'alto':
      return Colors.deepOrange;
    case 'critico':
      return Colors.red;
    case 'medio':
    default:
      return Colors.amber.shade800;
  }
}

String _initials(String? name) {
  if (name == null || name.trim().isEmpty) {
    return 'S';
  }

  final parts = name.trim().split(RegExp(r'\s+'));

  if (parts.length == 1) {
    return parts.first[0].toUpperCase();
  }

  return '${parts.first[0]}${parts.last[0]}'.toUpperCase();
}

String _capitalize(String value) {
  if (value.isEmpty) {
    return value;
  }

  return '${value[0].toUpperCase()}'
      '${value.substring(1).toLowerCase()}';
}
