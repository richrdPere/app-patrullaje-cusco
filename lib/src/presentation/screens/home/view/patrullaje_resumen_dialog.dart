import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';

class PatrullajeResumenDialog extends StatelessWidget {
  final PatrullajeData patrullaje;

  const PatrullajeResumenDialog({super.key, required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    final resumen = patrullaje.resumen;

    if (resumen == null) {
      return const AlertDialog(
        title: Text('Resumen no disponible'),
        content: Text('No se pudo obtener el resumen del patrullaje.'),
      );
    }

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: EdgeInsets.zero,
      contentPadding: const EdgeInsets.fromLTRB(20, 18, 20, 8),
      actionsPadding: const EdgeInsets.fromLTRB(20, 8, 20, 18),
      title: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.green.shade700,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
        ),
        child: const Column(
          children: [
            Icon(Icons.check_circle_rounded, color: Colors.white, size: 54),
            SizedBox(height: 10),
            Text(
              'Patrullaje finalizado',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 21,
                fontWeight: FontWeight.w700,
              ),
            ),
            SizedBox(height: 4),
            Text(
              'El resumen fue registrado correctamente.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
          ],
        ),
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _ResumenGeneralCard(
              distancia: resumen.distanciaFormateada,
              duracion: resumen.duracionFormateada,
            ),
            const SizedBox(height: 14),
            Row(
              children: [
                Expanded(
                  child: _ResumenItem(
                    icon: Icons.route_rounded,
                    label: 'Puntos GPS',
                    value: resumen.totalPuntosRecorrido.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumenItem(
                    icon: Icons.report_problem_outlined,
                    label: 'Incidencias',
                    value: resumen.totalIncidencias.toString(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _ResumenItem(
                    icon: Icons.description_outlined,
                    label: 'Observaciones',
                    value: resumen.totalObservaciones.toString(),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ResumenItem(
                    icon: Icons.badge_outlined,
                    label: 'Patrullaje',
                    value: '#${patrullaje.id}',
                  ),
                ),
              ],
            ),
            if (resumen.observacionFinal != null &&
                resumen.observacionFinal!.trim().isNotEmpty) ...[
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Row(
                      children: [
                        Icon(Icons.notes_rounded, size: 19),
                        SizedBox(width: 8),
                        Text(
                          'Observación final',
                          style: TextStyle(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      resumen.observacionFinal!,
                      style: TextStyle(
                        color: Colors.grey.shade800,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            if (resumen.fechaInicio != null || resumen.fechaFin != null) ...[
              const SizedBox(height: 16),
              _FechaSection(
                fechaInicio: resumen.fechaInicio,
                fechaFin: resumen.fechaFin,
              ),
            ],
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: () {
              Navigator.pop(context);
            },
            icon: const Icon(Icons.done_rounded),
            label: const Text('Cerrar resumen'),
          ),
        ),
      ],
    );
  }
}

class _ResumenGeneralCard extends StatelessWidget {
  final String distancia;
  final String duracion;

  const _ResumenGeneralCard({required this.distancia, required this.duracion});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.blue.shade100),
      ),
      child: Row(
        children: [
          Expanded(
            child: _GeneralValue(
              icon: Icons.route_rounded,
              label: 'Distancia',
              value: distancia,
            ),
          ),
          Container(width: 1, height: 48, color: Colors.blue.shade100),
          Expanded(
            child: _GeneralValue(
              icon: Icons.schedule_rounded,
              label: 'Duración',
              value: duracion,
            ),
          ),
        ],
      ),
    );
  }
}

class _GeneralValue extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _GeneralValue({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, color: Colors.blue.shade700),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
        ),
      ],
    );
  }
}

class _ResumenItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _ResumenItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(height: 7),
          Text(
            value,
            style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey.shade600, fontSize: 11),
          ),
        ],
      ),
    );
  }
}

class _FechaSection extends StatelessWidget {
  final DateTime? fechaInicio;
  final DateTime? fechaFin;

  const _FechaSection({required this.fechaInicio, required this.fechaFin});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (fechaInicio != null)
          _FechaRow(label: 'Inicio', fecha: fechaInicio!),
        if (fechaInicio != null && fechaFin != null) const Divider(height: 18),
        if (fechaFin != null)
          _FechaRow(label: 'Finalización', fecha: fechaFin!),
      ],
    );
  }
}

class _FechaRow extends StatelessWidget {
  final String label;
  final DateTime fecha;

  const _FechaRow({required this.label, required this.fecha});

  @override
  Widget build(BuildContext context) {
    final fechaLocal = fecha.toLocal();

    final dia = fechaLocal.day.toString().padLeft(2, '0');
    final mes = fechaLocal.month.toString().padLeft(2, '0');
    final anio = fechaLocal.year.toString();

    final hora = fechaLocal.hour.toString().padLeft(2, '0');
    final minuto = fechaLocal.minute.toString().padLeft(2, '0');

    return Row(
      children: [
        Icon(
          Icons.calendar_today_outlined,
          size: 18,
          color: Colors.grey.shade600,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(label, style: TextStyle(color: Colors.grey.shade700)),
        ),
        Text(
          '$dia/$mes/$anio $hora:$minuto',
          style: const TextStyle(fontWeight: FontWeight.w600),
        ),
      ],
    );
  }
}
