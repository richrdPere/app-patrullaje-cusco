import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';

// Form
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/models/ocurrencia_incidente_select.dart';

class ContextoGeneralidadesStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final OcurrenciaFormController controller;

  final PatrullajeData? patrullajeActivo;
  final bool isLoadingPatrullaje;
  final VoidCallback onReloadPatrullaje;

  final VoidCallback onReloadIncidentes;

  final List<OcurrenciaIncidenteSeleccionado> incidentesRecientes;

  final bool isLoadingIncidentes;
  final String? incidentesError;

  const ContextoGeneralidadesStep({
    super.key,
    required this.formKey,
    required this.controller,
    this.incidentesRecientes = const [],
    this.isLoadingIncidentes = false,
    this.incidentesError,
    required this.onReloadIncidentes,
    this.patrullajeActivo,
    required this.isLoadingPatrullaje,
    required this.onReloadPatrullaje,
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

          // Incidencias recientes
          if (controller.modoRegistro == ModoRegistroOcurrencia.incidencia)
            _SectionCard(
              title: 'Incidencia relacionada',
              icon: Icons.report_outlined,
              child: _IncidenciasRecientesField(
                controller: controller,
                incidentes: incidentesRecientes,
                isLoading: isLoadingIncidentes,
                errorMessage: incidentesError,
                onReload: onReloadIncidentes,
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
          _SectionCard(
            title: 'Clasificación',
            icon: Icons.account_tree_outlined,
            child: TextFormField(
              controller: controller.codigoController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Código de ocurrencia *',
                hintText: 'Ejemplo: 030103',
                helperText: 'Código del clasificador estandarizado.',
                prefixIcon: Icon(Icons.tag_rounded),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                final code = value?.trim() ?? '';

                if (code.isEmpty) {
                  return 'Selecciona o ingresa el código de ocurrencia.';
                }

                if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                  return 'El código debe tener 6 dígitos.';
                }

                return null;
              },
            ),
          ),

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
class _IncidenciasRecientesField extends StatelessWidget {
  final OcurrenciaFormController controller;

  final List<OcurrenciaIncidenteSeleccionado> incidentes;

  final bool isLoading;
  final String? errorMessage;
  final VoidCallback onReload;

  const _IncidenciasRecientesField({
    required this.controller,
    required this.incidentes,
    required this.isLoading,
    required this.errorMessage,
    required this.onReload,
  });

  @override
  Widget build(BuildContext context) {
    return FormField<int>(
      initialValue: controller.incidenteSeleccionado?.id,
      validator: (_) {
        if (controller.modoRegistro == ModoRegistroOcurrencia.incidencia &&
            controller.incidenteSeleccionado == null) {
          return 'Selecciona una incidencia reciente.';
        }

        return null;
      },
      builder: (field) {
        if (isLoading) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 20),
            child: Center(child: CircularProgressIndicator()),
          );
        }

        if (errorMessage != null) {
          return Column(
            children: [
              _MessageBox(
                icon: Icons.error_outline_rounded,
                message: errorMessage!,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Reintentar'),
              ),
              if (field.hasError) ...[
                const SizedBox(height: 8),
                _FieldError(message: field.errorText!),
              ],
            ],
          );
        }

        if (incidentes.isEmpty) {
          return Column(
            children: [
              const _MessageBox(
                icon: Icons.report_off_outlined,
                message:
                    'No se encontraron incidencias recientes. '
                    'Puedes actualizar el listado o utilizar '
                    'el registro manual.',
                color: Colors.orange,
              ),
              const SizedBox(height: 10),
              OutlinedButton.icon(
                onPressed: onReload,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Actualizar'),
              ),
              if (field.hasError) ...[
                const SizedBox(height: 8),
                _FieldError(message: field.errorText!),
              ],
            ],
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ...incidentes.map((incidente) {
              final selected =
                  controller.incidenteSeleccionado?.id == incidente.id;

              return Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: _IncidenciaCard(
                  incidencia: incidente,
                  selected: selected,
                  onTap: () {
                    controller.seleccionarIncidente(incidente);

                    field.didChange(incidente.id);
                  },
                ),
              );
            }),
            if (field.hasError) _FieldError(message: field.errorText!),
          ],
        );
      },
    );
  }
}

class _IncidenciaCard extends StatelessWidget {
  final OcurrenciaIncidenteSeleccionado incidencia;

  final bool selected;
  final VoidCallback onTap;

  const _IncidenciaCard({
    required this.incidencia,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    final fecha = incidencia.fecha != null
        ? DateFormat(
            'dd/MM/yyyy · HH:mm',
            'es_PE',
          ).format(incidencia.fecha!.toLocal())
        : 'Fecha no disponible';

    return Material(
      color: selected
          ? colorScheme.primaryContainer.withValues(alpha: 0.65)
          : colorScheme.surface,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              width: selected ? 2 : 1,
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                backgroundColor: colorScheme.errorContainer,
                child: Icon(
                  Icons.report_problem_outlined,
                  color: colorScheme.onErrorContainer,
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
                            incidencia.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                        if (selected)
                          Icon(
                            Icons.check_circle_rounded,
                            color: colorScheme.primary,
                          ),
                      ],
                    ),
                    if (incidencia.tipo != null) ...[
                      const SizedBox(height: 5),
                      Text(
                        _formatEnum(incidencia.tipo!),
                        style: Theme.of(context).textTheme.labelMedium
                            ?.copyWith(
                              color: colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                      ),
                    ],
                    const SizedBox(height: 7),
                    Row(
                      children: [
                        const Icon(Icons.schedule_rounded, size: 15),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            fecha,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                    if (incidencia.descripcion != null) ...[
                      const SizedBox(height: 7),
                      Text(
                        incidencia.descripcion!,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
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

class _FieldError extends StatelessWidget {
  final String message;

  const _FieldError({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Padding(
        padding: const EdgeInsets.only(left: 12),
        child: Text(
          message,
          style: TextStyle(
            color: Theme.of(context).colorScheme.error,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}

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

String _formatEnum(String value) {
  final normalized = value.replaceAll('_', ' ').toLowerCase();

  return normalized
      .split(' ')
      .map(
        (word) => word.isEmpty
            ? ''
            : '${word[0].toUpperCase()}'
                  '${word.substring(1)}',
      )
      .join(' ');
}

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
