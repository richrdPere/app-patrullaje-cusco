import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_listado_data.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/operational_summary_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/patrullaje_header_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/mis-patrullaje/detalle/widgets/section_card.dart';

class PatrullajeInformationSection extends StatelessWidget {
  final PatrullajeListadoData patrullaje;

  const PatrullajeInformationSection({super.key, required this.patrullaje});

  @override
  Widget build(BuildContext context) {
    final resumen = patrullaje.resumen;

    return SingleChildScrollView(
      key: const PageStorageKey('patrullaje_information'),
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // =============================================
          // ENCABEZADO
          // =============================================
          PatrullajeHeaderCard(patrullaje: patrullaje),

          const SizedBox(height: 16),

          // =============================================
          // PROGRAMACIÓN
          // =============================================
          SectionCard(
            title: 'Programación',
            icon: Icons.calendar_month_outlined,
            children: [
              DetailRow(
                icon: Icons.event_outlined,
                label: 'Fecha',
                value: DateFormat(
                  'EEEE, dd MMMM yyyy',
                  'es_PE',
                ).format(patrullaje.fecha),
              ),

              DetailRow(
                icon: Icons.schedule_outlined,
                label: 'Horario',
                value:
                    '${_formatTime(patrullaje.horaInicio)} - '
                    '${_formatTime(patrullaje.horaFin)}',
              ),

              DetailRow(
                icon: Icons.tag_rounded,
                label: 'Código',
                value: 'PAT-${patrullaje.id.toString().padLeft(5, '0')}',
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =============================================
          // ZONA
          // =============================================
          SectionCard(
            title: 'Zona asignada',
            icon: Icons.location_on_outlined,
            children: [
              DetailRow(
                icon: Icons.map_outlined,
                label: 'Zona',
                value: patrullaje.zona?.nombre ?? 'No especificada',
              ),

              DetailRow(
                icon: Icons.shield_outlined,
                label: 'Nivel de riesgo',
                value: _formatText(patrullaje.zona?.riesgo),
              ),

              DetailRow(
                icon: Icons.description_outlined,
                label: 'Descripción',
                value: patrullaje.zona?.descripcion ?? 'Sin descripción',
                showDivider: false,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // =============================================
          // UNIDAD
          // =============================================
          SectionCard(
            title: 'Unidad asignada',
            icon: Icons.directions_car_outlined,
            children: [
              if (patrullaje.unidad == null)
                const EmptySectionMessage(
                  message: 'Este patrullaje no tiene una unidad asignada.',
                )
              else ...[
                DetailRow(
                  icon: Icons.qr_code_outlined,
                  label: 'Código',
                  value: patrullaje.unidad!.codigo,
                ),

                DetailRow(
                  icon: Icons.directions_car,
                  label: 'Tipo de unidad',
                  value: _formatText(patrullaje.unidad!.tipo),
                ),

                DetailRow(
                  icon: Icons.pin_outlined,
                  label: 'Placa',
                  value: patrullaje.unidad!.placa ?? 'Sin placa',
                ),

                DetailRow(
                  icon: Icons.info_outline,
                  label: 'Estado',
                  value: _formatText(patrullaje.unidad!.estado),
                  showDivider: false,
                ),
              ],
            ],
          ),

          const SizedBox(height: 16),

          // =============================================
          // PERSONAL
          // =============================================
          SectionCard(
            title: 'Asignación',
            icon: Icons.groups_2_outlined,
            children: [
              if (patrullaje.personal.isEmpty)
                const EmptySectionMessage(
                  message: 'No se encontró información del personal asignado.',
                )
              else
                ...patrullaje.personal.asMap().entries.map((entry) {
                  final index = entry.key;

                  final personal = entry.value;

                  return DetailRow(
                    icon: personal.tipoPersonal == 'POLICIA'
                        ? Icons.local_police_outlined
                        : Icons.security_outlined,
                    label: 'Personal ${index + 1}',
                    value:
                        '${_formatText(personal.tipoPersonal)} · '
                        '${_formatText(personal.estado)}',
                    showDivider: index != patrullaje.personal.length - 1,
                  );
                }),
            ],
          ),

          const SizedBox(height: 16),

          // =============================================
          // RESUMEN
          // =============================================
          OperationalSummaryCard(resumen: resumen),

          if (resumen?.observacionFinal?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 16),

            SectionCard(
              title: 'Observación final',
              icon: Icons.notes_outlined,
              children: [
                Text(
                  resumen!.observacionFinal!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(height: 1.45),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(String value) {
    if (value.length >= 5) {
      return value.substring(0, 5);
    }

    return value;
  }

  String _formatText(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'No especificado';
    }

    return value
        .replaceAll('_', ' ')
        .toLowerCase()
        .split(' ')
        .map(
          (word) => word.isEmpty
              ? word
              : '${word[0].toUpperCase()}'
                    '${word.substring(1)}',
        )
        .join(' ');
  }
}
