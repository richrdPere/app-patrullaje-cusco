import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';

// Form
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/models/ocurrencia_incidente_select.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/widgets/clasificador-selector/clasificador_ocurrencia_selector.dart';

class ContextoGeneralidadesStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final OcurrenciaFormController controller;

  final PatrullajeData? patrullajeActivo;
  final bool isLoadingPatrullaje;
  final VoidCallback onReloadPatrullaje;

  final IncidenciaSelectorData? incidenciaSeleccionada;

  final bool isLoadingIncidentes;
  final String? incidentesError;

  final VoidCallback onSeleccionarIncidencia;
  final VoidCallback onLimpiarIncidencia;

  // Clasificadores
  final ClasificadorArbolData? clasificadorArbol;
  final bool isLoadingClasificador;
  final String? clasificadorError;
  final VoidCallback onReloadClasificador;

  const ContextoGeneralidadesStep({
    super.key,
    required this.formKey,
    required this.controller,
    required this.patrullajeActivo,
    required this.isLoadingPatrullaje,
    required this.onReloadPatrullaje,
    required this.incidenciaSeleccionada,
    required this.isLoadingIncidentes,
    required this.incidentesError,
    required this.onSeleccionarIncidencia,
    required this.onLimpiarIncidencia,

    // Clasificadores
    required this.clasificadorArbol,
    required this.isLoadingClasificador,
    required this.clasificadorError,
    required this.onReloadClasificador,
  });

  @override
  Widget build(BuildContext context) {
    return Form(
      key: formKey,
      child: ListView(
        key: const PageStorageKey('ocurrencia_contexto_step'),
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
        children: [
          const _StepIntroduction(),
          const SizedBox(height: 20),

          // Modo de registro
          _SectionCard(
            title: 'Forma de registro',
            icon: Icons.edit_note_rounded,
            child: _ModoRegistroSelector(
              value: controller.modoRegistro,
              onChanged: controller.cambiarModo,
            ),
          ),

          const SizedBox(height: 16),

          // Incidencia relacionada
          if (controller.modoRegistro == ModoRegistroOcurrencia.incidencia)
            _SectionCard(
              title: 'Incidencia relacionada',
              icon: Icons.report_outlined,
              child: _IncidenciaSeleccionadaField(
                incidencia: incidenciaSeleccionada,
                isLoading: isLoadingIncidentes,
                errorMessage: incidentesError,
                onSeleccionar: onSeleccionarIncidencia,
                onLimpiar: onLimpiarIncidencia,
              ),
            )
          else
            const _RegistroManualCard(),

          const SizedBox(height: 16),

          // Contexto automático
          // _SectionCard(
          //   title: 'Contexto del sistema',
          //   icon: Icons.hub_outlined,
          //   child: _ContextoSistema(controller: controller),
          // ),
          const SizedBox(height: 16),

          // Clasificación
          const SizedBox(height: 16),

          _SectionCard(
            title: 'Código clasificador',
            icon: Icons.account_tree_outlined,
            child: ClasificadorOcurrenciaSelector(
              arbol: clasificadorArbol,
              controller: controller,
              isLoading: isLoadingClasificador,
              errorMessage: clasificadorError,
              onReload: onReloadClasificador,
            ),
          ),

          // _SectionCard(
          //   title: 'Clasificación',
          //   icon: Icons.account_tree_outlined,
          //   child: TextFormField(
          //     controller: controller.codigoController,
          //     keyboardType: TextInputType.number,
          //     maxLength: 6,
          //     decoration: const InputDecoration(
          //       labelText: 'Código de ocurrencia *',
          //       hintText: 'Ejemplo: 030103',
          //       helperText: 'Código del clasificador estandarizado.',
          //       prefixIcon: Icon(Icons.tag_rounded),
          //       border: OutlineInputBorder(),
          //     ),
          //     validator: (value) {
          //       final code = value?.trim() ?? '';

          //       if (code.isEmpty) {
          //         return 'Selecciona o ingresa el código de ocurrencia.';
          //       }

          //       if (!RegExp(r'^\d{6}$').hasMatch(code)) {
          //         return 'El código debe tener 6 dígitos.';
          //       }

          //       return null;
          //     },
          //   ),
          // ),
          const SizedBox(height: 16),

          // _PatrullajeContextCard(
          //   patrullaje: patrullajeActivo,
          //   isLoading: isLoadingPatrullaje,
          //   onReload: onReloadPatrullaje,
          // ),
          // const SizedBox(height: 16),

          // Generalidades
          _SectionCard(
            title: 'Generalidades',
            icon: Icons.assignment_outlined,
            child: _GeneralidadesFields(controller: controller),
          ),

          const SizedBox(height: 16),

          // Vehículo
          if (controller.isMotorized)
            _SectionCard(
              title: 'Vehículo empleado',
              icon: Icons.directions_car_outlined,
              child: _VehiculoFields(controller: controller),
            ),

          const SizedBox(height: 16),

          const _InformacionCard(),
        ],
      ),
    );
  }
}

// ==========================================================================
// INTRODUCCIÓN
// ==========================================================================

class _StepIntroduction extends StatelessWidget {
  const _StepIntroduction();

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Contexto y generalidades',
          style: Theme.of(
            context,
          ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 6),
        Text(
          'Selecciona una incidencia reciente o registra '
          'manualmente una nueva ocurrencia.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ==========================================================================
// MODO DE REGISTRO
// ==========================================================================

class _ModoRegistroSelector extends StatelessWidget {
  final ModoRegistroOcurrencia value;

  final ValueChanged<ModoRegistroOcurrencia> onChanged;

  const _ModoRegistroSelector({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxWidth < 520;

        final incidenciaCard = _ModoRegistroCard(
          title: 'Desde incidencia',
          description: 'Relaciona la ocurrencia con una incidencia reciente.',
          icon: Icons.report_problem_outlined,
          selected: value == ModoRegistroOcurrencia.incidencia,
          onTap: () {
            onChanged(ModoRegistroOcurrencia.incidencia);
          },
        );

        final manualCard = _ModoRegistroCard(
          title: 'Registro manual',
          description: 'Registra una ocurrencia sin incidencia previa.',
          icon: Icons.edit_document,
          selected: value == ModoRegistroOcurrencia.manual,
          onTap: () {
            onChanged(ModoRegistroOcurrencia.manual);
          },
        );

        if (compact) {
          return Column(
            children: [incidenciaCard, const SizedBox(height: 10), manualCard],
          );
        }

        return Row(
          children: [
            Expanded(child: incidenciaCard),
            const SizedBox(width: 12),
            Expanded(child: manualCard),
          ],
        );
      },
    );
  }
}

class _ModoRegistroCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  const _ModoRegistroCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              width: selected ? 2 : 1,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    color: selected
                        ? colorScheme.primary
                        : colorScheme.onSurfaceVariant,
                  ),
                  const Spacer(),
                  if (selected)
                    Icon(
                      Icons.check_circle_rounded,
                      color: colorScheme.primary,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const SizedBox(height: 4),
              Text(description, style: Theme.of(context).textTheme.bodySmall),
            ],
          ),
        ),
      ),
    );
  }
}

// ==========================================================================
// SELECCIÓN DE INCIDENCIA
// ==========================================================================
class _IncidenciaSeleccionadaField extends StatelessWidget {
  final IncidenciaSelectorData? incidencia;

  final bool isLoading;
  final String? errorMessage;

  final VoidCallback onSeleccionar;
  final VoidCallback onLimpiar;

  const _IncidenciaSeleccionadaField({
    required this.incidencia,
    required this.isLoading,
    required this.errorMessage,
    required this.onSeleccionar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    if (incidencia != null) {
      return _IncidenciaSeleccionadaCard(
        incidencia: incidencia!,
        onCambiar: onSeleccionar,
        onLimpiar: onLimpiar,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Selecciona una incidencia registrada previamente para relacionarla con esta ocurrencia.',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),

        if (errorMessage != null) ...[
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.error_outline,
                  color: colorScheme.onErrorContainer,
                  size: 20,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    errorMessage!,
                    style: TextStyle(color: colorScheme.onErrorContainer),
                  ),
                ),
              ],
            ),
          ),
        ],

        const SizedBox(height: 14),

        SizedBox(
          width: double.infinity,
          child: FilledButton.icon(
            onPressed: isLoading ? null : onSeleccionar,
            icon: isLoading
                ? SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: colorScheme.onPrimary,
                    ),
                  )
                : const Icon(Icons.search_rounded),
            label: Text(
              isLoading ? 'Cargando incidencias...' : 'Seleccionar incidencia',
            ),
          ),
        ),
      ],
    );
  }
}

class _IncidenciaSeleccionadaCard extends StatelessWidget {
  final IncidenciaSelectorData incidencia;
  final VoidCallback onCambiar;
  final VoidCallback onLimpiar;

  const _IncidenciaSeleccionadaCard({
    required this.incidencia,
    required this.onCambiar,
    required this.onLimpiar,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colorScheme.primary.withValues(alpha: 0.35)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primary,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIncidenciaIcon(incidencia.tipo),
                  color: colorScheme.onPrimary,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            _formatTipoIncidencia(incidencia.tipo),
                            style: theme.textTheme.titleSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        _IncidenciaEstadoBadge(estado: incidencia.estado),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Incidencia #${incidencia.id}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            incidencia.descripcion,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.bodyMedium,
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _IncidenciaInfoChip(
                icon: Icons.schedule_outlined,
                label: _formatFechaHora(incidencia.fechaHora),
              ),
              _IncidenciaInfoChip(
                icon: Icons.image_outlined,
                label: '${incidencia.totalEvidencias} evidencias',
              ),
              if (incidencia.patrullajeId != null)
                _IncidenciaInfoChip(
                  icon: Icons.route_outlined,
                  label: 'Patrullaje ${incidencia.patrullajeId}',
                ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: onCambiar,
                  icon: const Icon(Icons.swap_horiz_rounded),
                  label: const Text('Cambiar'),
                ),
              ),
              const SizedBox(width: 10),
              IconButton.outlined(
                onPressed: onLimpiar,
                tooltip: 'Quitar incidencia',
                icon: const Icon(Icons.close_rounded),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

IconData _getIncidenciaIcon(String tipo) {
  switch (tipo) {
    case 'ROBO':
      return Icons.local_police_outlined;

    case 'ACCIDENTE':
      return Icons.car_crash_outlined;

    case 'INCENDIO':
      return Icons.local_fire_department_outlined;

    case 'VIOLENCIA':
      return Icons.warning_amber_rounded;

    case 'SOSPECHOSO':
      return Icons.visibility_outlined;

    default:
      return Icons.report_outlined;
  }
}

String _formatTipoIncidencia(String tipo) {
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
      return 'Actividad sospechosa';

    default:
      return 'Otro';
  }
}

String _formatFechaHora(DateTime date) {
  final local = date.toLocal();

  String twoDigits(int value) {
    return value.toString().padLeft(2, '0');
  }

  return '${twoDigits(local.day)}/'
      '${twoDigits(local.month)}/'
      '${local.year} · '
      '${twoDigits(local.hour)}:'
      '${twoDigits(local.minute)}';
}

class _IncidenciaEstadoBadge extends StatelessWidget {
  final String estado;

  const _IncidenciaEstadoBadge({required this.estado});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final Color background;
    final Color foreground;
    final String label;

    switch (estado) {
      case 'REPORTADO':
        background = colorScheme.errorContainer;
        foreground = colorScheme.onErrorContainer;
        label = 'Reportado';
        break;

      case 'EN_PROCESO':
        background = colorScheme.tertiaryContainer;
        foreground = colorScheme.onTertiaryContainer;
        label = 'En proceso';
        break;

      case 'ATENDIDO':
        background = colorScheme.primaryContainer;
        foreground = colorScheme.onPrimaryContainer;
        label = 'Atendido';
        break;

      case 'CERRADO':
        background = colorScheme.secondaryContainer;
        foreground = colorScheme.onSecondaryContainer;
        label = 'Cerrado';
        break;

      default:
        background = colorScheme.surfaceContainerHighest;
        foreground = colorScheme.onSurfaceVariant;
        label = estado;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(99),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
          color: foreground,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}

// class _IncidenciaOptionCard extends StatelessWidget {
//   final IncidenciaSelectorData incidencia;
//   final bool selected;
//   final VoidCallback onTap;

//   const _IncidenciaOptionCard({
//     required this.incidencia,
//     required this.selected,
//     required this.onTap,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final theme = Theme.of(context);
//     final colorScheme = theme.colorScheme;

//     return Material(
//       color: selected
//           ? colorScheme.primaryContainer
//           : colorScheme.surfaceContainerLow,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.all(14),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(
//               color: selected
//                   ? colorScheme.primary
//                   : colorScheme.outlineVariant,
//               width: selected ? 1.5 : 1,
//             ),
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Container(
//                 width: 42,
//                 height: 42,
//                 decoration: BoxDecoration(
//                   color: colorScheme.primaryContainer,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Icon(
//                   _getIncidenciaIcon(incidencia.tipo),
//                   color: colorScheme.primary,
//                 ),
//               ),
//               const SizedBox(width: 12),
//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             _formatTipoIncidencia(incidencia.tipo),
//                             style: theme.textTheme.titleSmall?.copyWith(
//                               fontWeight: FontWeight.bold,
//                             ),
//                           ),
//                         ),
//                         _IncidenciaEstadoBadge(estado: incidencia.estado),
//                       ],
//                     ),
//                     const SizedBox(height: 5),
//                     Text(
//                       incidencia.descripcion,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                     ),
//                     const SizedBox(height: 8),
//                     Text(
//                       _formatFechaHora(incidencia.fechaHora),
//                       style: theme.textTheme.bodySmall?.copyWith(
//                         color: colorScheme.onSurfaceVariant,
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               const SizedBox(width: 6),
//               Icon(
//                 selected
//                     ? Icons.check_circle_rounded
//                     : Icons.chevron_right_rounded,
//                 color: selected
//                     ? colorScheme.primary
//                     : colorScheme.onSurfaceVariant,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

class _IncidenciaInfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _IncidenciaInfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: colorScheme.primary),
          const SizedBox(width: 5),
          Text(label, style: Theme.of(context).textTheme.labelSmall),
        ],
      ),
    );
  }
}
// ==========================================================================
// REGISTRO MANUAL
// ==========================================================================

class _RegistroManualCard extends StatelessWidget {
  const _RegistroManualCard();

  @override
  Widget build(BuildContext context) {
    return const _MessageBox(
      icon: Icons.edit_document,
      color: Colors.blue,
      message:
          'La ocurrencia se registrará manualmente. '
          'No quedará vinculada a una incidencia previa, '
          'pero conservará el patrullaje, zona y unidad '
          'del contexto operativo actual.',
    );
  }
}

// ==========================================================================
// CONTEXTO DEL SISTEMA
// ==========================================================================

// class _ContextoSistema extends StatelessWidget {
//   final OcurrenciaFormController controller;

//   const _ContextoSistema({required this.controller});

//   @override
//   Widget build(BuildContext context) {
//     return Column(
//       children: [
//         _ContextRow(
//           icon: Icons.fingerprint_rounded,
//           label: 'UUID',
//           value: controller.uuidController.text,
//         ),
//         const Divider(height: 24),
//         _ContextRow(
//           icon: Icons.route_outlined,
//           label: 'Patrullaje',
//           value: controller.patrullajeId != null
//               ? '#${controller.patrullajeId}'
//               : 'No asociado',
//         ),
//         const Divider(height: 24),
//         _ContextRow(
//           icon: Icons.map_outlined,
//           label: 'Zona',
//           value: controller.zonaId != null
//               ? '#${controller.zonaId}'
//               : 'No asociada',
//         ),
//         const Divider(height: 24),
//         _ContextRow(
//           icon: Icons.directions_car_outlined,
//           label: 'Unidad',
//           value: controller.unidadId != null
//               ? '#${controller.unidadId}'
//               : 'No asociada',
//         ),
//       ],
//     );
//   }
// }

// ==========================================================================
// GENERALIDADES
// ==========================================================================

class _GeneralidadesFields extends StatelessWidget {
  final OcurrenciaFormController controller;

  const _GeneralidadesFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DropdownButtonFormField<String>(
          initialValue: controller.origen,
          decoration: const InputDecoration(
            labelText: 'Origen *',
            prefixIcon: Icon(Icons.source_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(
              value: 'VISUALIZACION_CAMARAS',
              child: Text('Visualización de cámaras'),
            ),
            DropdownMenuItem(
              value: 'REQUERIMIENTO_TELEFONICO',
              child: Text('Requerimiento telefónico'),
            ),
            DropdownMenuItem(value: 'PATRULLAJE', child: Text('Patrullaje')),
            DropdownMenuItem(value: 'OPERATIVO', child: Text('Operativo')),
            DropdownMenuItem(
              value: 'REDES_SOCIALES',
              child: Text('Redes sociales'),
            ),
            DropdownMenuItem(
              value: 'BOTON_PANICO',
              child: Text('Botón de pánico'),
            ),
            DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.setOrigen(value);
            }
          },
        ),
        if (controller.origen == 'OTRO') ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.origenOtroController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Especifique el origen *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (controller.origen == 'OTRO' &&
                  (value == null || value.trim().isEmpty)) {
                return 'Especifica el origen.';
              }

              return null;
            },
          ),
        ],
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: controller.modalidadPatrullaje,
          decoration: const InputDecoration(
            labelText: 'Modalidad de patrullaje *',
            prefixIcon: Icon(Icons.groups_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'MUNICIPAL', child: Text('Municipal')),
            DropdownMenuItem(value: 'INTEGRADO', child: Text('Integrado')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.setModalidadPatrullaje(value);
            }
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: controller.tipoPatrullaje,
          decoration: const InputDecoration(
            labelText: 'Tipo de patrullaje *',
            prefixIcon: Icon(Icons.directions_walk_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'MOTORIZADO', child: Text('Motorizado')),
            DropdownMenuItem(value: 'A_PIE', child: Text('A pie')),
            DropdownMenuItem(value: 'BICICLETA', child: Text('Bicicleta')),
            DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.setTipoPatrullaje(value);
            }
          },
        ),
        if (controller.tipoPatrullaje == 'OTRO') ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.tipoPatrullajeOtroController,
            decoration: const InputDecoration(
              labelText: 'Especifique el patrullaje *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (controller.tipoPatrullaje == 'OTRO' &&
                  (value == null || value.trim().isEmpty)) {
                return 'Especifica el tipo de patrullaje.';
              }

              return null;
            },
          ),
        ],
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: controller.turno,
          decoration: const InputDecoration(
            labelText: 'Turno *',
            prefixIcon: Icon(Icons.schedule_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'MAÑANA', child: Text('Mañana')),
            DropdownMenuItem(value: 'TARDE', child: Text('Tarde')),
            DropdownMenuItem(value: 'NOCHE', child: Text('Noche')),
          ],
          onChanged: (value) {
            if (value != null) {
              controller.setTurno(value);
            }
          },
        ),
      ],
    );
  }
}

// ==========================================================================
// VEHÍCULO
// ==========================================================================
class _VehiculoFields extends StatelessWidget {
  final OcurrenciaFormController controller;

  const _VehiculoFields({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        TextFormField(
          controller: controller.placaVehiculoController,
          textCapitalization: TextCapitalization.characters,
          decoration: const InputDecoration(
            labelText: 'Placa del vehículo *',
            hintText: 'EUA-123',
            prefixIcon: Icon(Icons.pin_outlined),
            border: OutlineInputBorder(),
          ),
          validator: (value) {
            if (controller.isMotorized &&
                (value == null || value.trim().isEmpty)) {
              return 'Ingresa la placa.';
            }

            return null;
          },
        ),
        const SizedBox(height: 14),
        DropdownButtonFormField<String>(
          initialValue: controller.tipoVehiculo,
          decoration: const InputDecoration(
            labelText: 'Tipo de vehículo *',
            prefixIcon: Icon(Icons.local_police_outlined),
            border: OutlineInputBorder(),
          ),
          items: const [
            DropdownMenuItem(value: 'AUTO', child: Text('Auto')),
            DropdownMenuItem(
              value: 'CAMIONETA_DOBLE_CABINA',
              child: Text('Camioneta de doble cabina'),
            ),
            DropdownMenuItem(value: 'MOTO_LINEAL', child: Text('Moto lineal')),
            DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
          ],
          validator: (value) {
            if (controller.isMotorized && value == null) {
              return 'Selecciona el tipo de vehículo.';
            }

            return null;
          },
          onChanged: controller.setTipoVehiculo,
        ),
        if (controller.tipoVehiculo == 'OTRO') ...[
          const SizedBox(height: 14),
          TextFormField(
            controller: controller.tipoVehiculoOtroController,
            decoration: const InputDecoration(
              labelText: 'Especifique el vehículo *',
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              if (controller.tipoVehiculo == 'OTRO' &&
                  (value == null || value.trim().isEmpty)) {
                return 'Especifica el vehículo.';
              }

              return null;
            },
          ),
        ],
      ],
    );
  }
}

// ==========================================================================
// WIDGETS COMUNES
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
        border: Border.all(color: colorScheme.outlineVariant),
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

// class _ContextRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _ContextRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       children: [
//         Icon(
//           icon,
//           size: 20,
//           color: Theme.of(context).colorScheme.onSurfaceVariant,
//         ),
//         const SizedBox(width: 10),
//         SizedBox(width: 90, child: Text(label)),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             value,
//             textAlign: TextAlign.end,
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ),
//       ],
//     );
//   }
// }

class _MessageBox extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;

  const _MessageBox({
    required this.icon,
    required this.message,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(13),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color),
          const SizedBox(width: 10),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

// class _FieldError extends StatelessWidget {
//   final String message;

//   const _FieldError({required this.message});

//   @override
//   Widget build(BuildContext context) {
//     return Align(
//       alignment: Alignment.centerLeft,
//       child: Padding(
//         padding: const EdgeInsets.only(left: 12),
//         child: Text(
//           message,
//           style: TextStyle(
//             color: Theme.of(context).colorScheme.error,
//             fontSize: 12,
//           ),
//         ),
//       ),
//     );
//   }
// }

class _InformacionCard extends StatelessWidget {
  const _InformacionCard();

  @override
  Widget build(BuildContext context) {
    return const _MessageBox(
      icon: Icons.info_outline_rounded,
      color: Colors.blue,
      message:
          'El código de ocurrencia debe corresponder '
          'al Clasificador Estandarizado del Servicio '
          'de Serenazgo Municipal.',
    );
  }
}

// String _formatEnum(String value) {
//   final normalized = value.replaceAll('_', ' ').toLowerCase();

//   return normalized
//       .split(' ')
//       .map(
//         (word) => word.isEmpty
//             ? ''
//             : '${word[0].toUpperCase()}'
//                   '${word.substring(1)}',
//       )
//       .join(' ');
// }

// class _PatrullajeContextCard extends StatelessWidget {
//   final PatrullajeData? patrullaje;
//   final bool isLoading;
//   final VoidCallback onReload;

//   const _PatrullajeContextCard({
//     required this.patrullaje,
//     required this.isLoading,
//     required this.onReload,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final colors = Theme.of(context).colorScheme;

//     if (isLoading && patrullaje == null) {
//       return const Card(
//         margin: EdgeInsets.zero,
//         child: Padding(
//           padding: EdgeInsets.all(20),
//           child: Row(
//             children: [
//               SizedBox.square(
//                 dimension: 22,
//                 child: CircularProgressIndicator(strokeWidth: 2.5),
//               ),
//               SizedBox(width: 14),
//               Expanded(child: Text('Obteniendo el patrullaje activo...')),
//             ],
//           ),
//         ),
//       );
//     }

//     if (patrullaje == null) {
//       return Card(
//         margin: EdgeInsets.zero,
//         color: colors.errorContainer.withAlpha(120),
//         child: Padding(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             children: [
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Icon(Icons.route_outlined, color: colors.onErrorContainer),
//                   const SizedBox(width: 12),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Text(
//                           'Sin patrullaje activo',
//                           style: TextStyle(
//                             color: colors.onErrorContainer,
//                             fontWeight: FontWeight.w700,
//                           ),
//                         ),
//                         const SizedBox(height: 4),
//                         Text(
//                           'La ocurrencia se registrará sin '
//                           'patrullaje, zona ni unidad asociada.',
//                           style: TextStyle(color: colors.onErrorContainer),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 12),
//               Align(
//                 alignment: Alignment.centerRight,
//                 child: TextButton.icon(
//                   onPressed: isLoading ? null : onReload,
//                   icon: const Icon(Icons.refresh_rounded),
//                   label: const Text('ACTUALIZAR'),
//                 ),
//               ),
//             ],
//           ),
//         ),
//       );
//     }

//     return Card(
//       margin: EdgeInsets.zero,
//       clipBehavior: Clip.antiAlias,
//       child: Column(
//         children: [
//           Container(
//             width: double.infinity,
//             padding: const EdgeInsets.all(14),
//             color: colors.primaryContainer.withAlpha(110),
//             child: Row(
//               children: [
//                 CircleAvatar(
//                   backgroundColor: colors.primary,
//                   foregroundColor: colors.onPrimary,
//                   child: const Icon(Icons.route_rounded),
//                 ),
//                 const SizedBox(width: 12),
//                 Expanded(
//                   child: Column(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       Text(
//                         'Patrullaje #${patrullaje!.id}',
//                         style: const TextStyle(fontWeight: FontWeight.w800),
//                       ),
//                       const SizedBox(height: 2),
//                       Text(_humanize(patrullaje!.estado)),
//                     ],
//                   ),
//                 ),
//                 IconButton(
//                   tooltip: 'Actualizar patrullaje',
//                   onPressed: isLoading ? null : onReload,
//                   icon: isLoading
//                       ? const SizedBox.square(
//                           dimension: 20,
//                           child: CircularProgressIndicator(strokeWidth: 2),
//                         )
//                       : const Icon(Icons.refresh_rounded),
//                 ),
//               ],
//             ),
//           ),
//           Padding(
//             padding: const EdgeInsets.all(16),
//             child: Column(
//               children: [
//                 _ContextInformationRow(
//                   icon: Icons.map_outlined,
//                   label: 'Zona',
//                   value:
//                       '${patrullaje!.zona.nombre} '
//                       '(ID: ${patrullaje!.zona.id})',
//                 ),
//                 const SizedBox(height: 12),
//                 _ContextInformationRow(
//                   icon: Icons.warning_amber_rounded,
//                   label: 'Riesgo',
//                   value: patrullaje!.zona.riesgo,
//                 ),
//                 const SizedBox(height: 12),
//                 _ContextInformationRow(
//                   icon: Icons.directions_car_outlined,
//                   label: 'Unidad',
//                   value: _unidadDescription(patrullaje!),
//                 ),
//                 const SizedBox(height: 12),
//                 _ContextInformationRow(
//                   icon: Icons.schedule_outlined,
//                   label: 'Horario',
//                   value:
//                       '${patrullaje!.horaInicio} - '
//                       '${patrullaje!.horaFin}',
//                 ),
//                 if (patrullaje!.descripcion.trim().isNotEmpty) ...[
//                   const SizedBox(height: 12),
//                   _ContextInformationRow(
//                     icon: Icons.notes_outlined,
//                     label: 'Descripción',
//                     value: patrullaje!.descripcion,
//                   ),
//                 ],
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   String _unidadDescription(PatrullajeData patrullaje) {
//     final values = [
//       if (patrullaje.unidad.codigo.trim().isNotEmpty)
//         patrullaje.unidad.codigo.trim(),
//       if (patrullaje.unidad.tipo.trim().isNotEmpty)
//         _humanize(patrullaje.unidad.tipo),
//       if (patrullaje.unidad.placa.trim().isNotEmpty)
//         'Placa ${patrullaje.unidad.placa.trim()}',
//     ];

//     if (values.isEmpty) {
//       return 'Unidad #${patrullaje.unidad.id}';
//     }

//     return values.join(' · ');
//   }
// // }

// class _ContextInformationRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _ContextInformationRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, size: 21, color: Theme.of(context).colorScheme.primary),
//         const SizedBox(width: 12),
//         SizedBox(
//           width: 80,
//           child: Text(
//             label,
//             style: Theme.of(context).textTheme.bodySmall?.copyWith(
//               color: Theme.of(context).colorScheme.outline,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ),
//         const SizedBox(width: 8),
//         Expanded(
//           child: Text(
//             value.trim().isEmpty ? 'No registrado' : value,
//             style: const TextStyle(fontWeight: FontWeight.w600),
//           ),
//         ),
//       ],
//     );
//   }
// }

// String _humanize(String value) {
//   if (value.trim().isEmpty) {
//     return 'No registrado';
//   }

//   return value
//       .trim()
//       .toLowerCase()
//       .split('_')
//       .map(
//         (word) => word.isEmpty
//             ? ''
//             : '${word[0].toUpperCase()}'
//                   '${word.substring(1)}',
//       )
//       .join(' ');
// }
