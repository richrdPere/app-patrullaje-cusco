import 'package:flutter/material.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';

// Controller
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';

class RevisionOcurrenciaStep extends StatefulWidget {
  final GlobalKey<FormState> formKey;
  final OcurrenciaFormController controller;

  /// Recibe el índice del step:
  /// 0: Contexto
  /// 1: Atención y ubicación
  /// 2: Personas
  /// 3: Intervención
  final ValueChanged<int> onEditStep;

  const RevisionOcurrenciaStep({
    super.key,
    required this.formKey,
    required this.controller,
    required this.onEditStep,
  });

  @override
  State<RevisionOcurrenciaStep> createState() => _RevisionOcurrenciaStepState();
}

class _RevisionOcurrenciaStepState extends State<RevisionOcurrenciaStep> {
  bool _confirmacion = false;

  OcurrenciaFormController get controller => widget.controller;

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Form(
          key: widget.formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const _StepIntroduction(
                icon: Icons.fact_check_outlined,
                title: 'Revisión de la ocurrencia',
                description:
                    'Verifica cuidadosamente la información antes de '
                    'registrarla. Puedes volver a cualquier sección para '
                    'realizar cambios.',
              ),
              const SizedBox(height: 16),

              _ValidationSummary(controller: controller),

              const SizedBox(height: 16),

              // ==================================================
              // 1. CONTEXTO Y GENERALIDADES
              // ==================================================
              _ReviewSection(
                number: 1,
                title: 'Contexto y generalidades',
                icon: Icons.assignment_outlined,
                onEdit: () => widget.onEditStep(0),
                children: [
                  _ReviewRow(
                    label: 'Modo de registro',
                    value: controller.modoRegistro.name == 'incidencia'
                        ? 'Desde incidente'
                        : 'Registro manual',
                  ),
                  if (controller.incidenteSeleccionado != null)
                    _ReviewRow(
                      label: 'Incidente seleccionado',
                      value:
                          '#${controller.incidenteSeleccionado!.id} - '
                          '${controller.incidenteSeleccionado!.titulo}',
                    ),
                  _ReviewRow(
                    label: 'Código de ocurrencia',
                    value: controller.codigoController.text,
                    required: true,
                  ),
                  _ReviewRow(
                    label: 'UUID del dispositivo',
                    value: controller.uuidController.text,
                  ),
                  _ReviewRow(
                    label: 'Origen',
                    value: controller.origen == 'OTRO'
                        ? controller.origenOtroController.text
                        : _humanize(controller.origen),
                    required: true,
                  ),
                  _ReviewRow(
                    label: 'Modalidad de patrullaje',
                    value: _humanize(controller.modalidadPatrullaje),
                    required: true,
                  ),
                  _ReviewRow(
                    label: 'Tipo de patrullaje',
                    value: controller.tipoPatrullaje == 'OTRO'
                        ? controller.tipoPatrullajeOtroController.text
                        : _humanize(controller.tipoPatrullaje),
                    required: true,
                  ),
                  _ReviewRow(
                    label: 'Turno',
                    value: _humanize(controller.turno),
                    required: true,
                  ),
                  if (controller.isMotorized) ...[
                    _ReviewRow(
                      label: 'Tipo de vehículo',
                      value: controller.tipoVehiculo == 'OTRO'
                          ? controller.tipoVehiculoOtroController.text
                          : _humanizeNullable(controller.tipoVehiculo),
                    ),
                    _ReviewRow(
                      label: 'Placa del vehículo',
                      value: controller.placaVehiculoController.text,
                    ),
                  ],
                  _SystemRelationChips(controller: controller),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // 2. ATENCIÓN Y UBICACIÓN
              // ==================================================
              _ReviewSection(
                number: 2,
                title: 'Atención y ubicación',
                icon: Icons.location_on_outlined,
                onEdit: () => widget.onEditStep(1),
                children: [
                  _ReviewRow(
                    label: 'Fecha de ocurrencia',
                    value: controller.fechaOcurrenciaController.text,
                    required: true,
                  ),
                  _ReviewRow(
                    label: 'Hora de alerta',
                    value: controller.horaAlertaController.text,
                  ),
                  _ReviewRow(
                    label: 'Hora de llegada',
                    value: controller.horaLlegadaController.text,
                  ),
                  _ReviewRow(
                    label: 'Hora de repliegue',
                    value: controller.horaRepliegueController.text,
                  ),
                  _ReviewRow(
                    label: 'Resultado',
                    value: _humanize(controller.resultado),
                    required: true,
                  ),
                  _ReviewRow(
                    label: 'Relación víctima-victimario',
                    value: _firstNonEmpty([
                      controller.relacionVictimaVictimarioController.text,
                      controller.relacionVictimaVictimario,
                    ]),
                  ),
                  _ReviewRow(
                    label: 'Tipo de lugar',
                    value: controller.tipoLugar == 'OTRO'
                        ? controller.tipoLugarOtroController.text
                        : _humanizeNullable(controller.tipoLugar),
                  ),
                  _ReviewRow(
                    label: 'Tipo de vía',
                    value: _humanizeNullable(controller.tipoVia),
                  ),
                  _ReviewRow(
                    label: 'Dirección',
                    value: controller.direccionController.text,
                  ),
                  _ReviewRow(
                    label: 'Referencia',
                    value: controller.referenciaController.text,
                  ),
                  _ReviewRow(
                    label: 'Manzana / lote',
                    value: _joinValues([
                      controller.manzanaController.text.isNotEmpty
                          ? 'Mz. ${controller.manzanaController.text}'
                          : null,
                      controller.loteController.text.isNotEmpty
                          ? 'Lt. ${controller.loteController.text}'
                          : null,
                    ]),
                  ),
                  _ReviewRow(
                    label: 'Tipo de zona',
                    value: _humanizeNullable(controller.tipoZona),
                  ),
                  _ReviewRow(
                    label: 'Nombre de zona',
                    value: controller.nombreZonaController.text,
                  ),
                  _ReviewRow(
                    label: 'Sector de patrullaje',
                    value: controller.sectorPatrullajeController.text,
                  ),
                  _ReviewRow(
                    label: 'Ubigeo',
                    value: controller.ubigeoController.text,
                  ),
                  _CoordinatesPreview(controller: controller),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // 3. PERSONAS
              // ==================================================
              _ReviewSection(
                number: 3,
                title: 'Personas involucradas',
                icon: Icons.groups_2_outlined,
                onEdit: () => widget.onEditStep(2),
                children: [
                  if (controller.personas.isEmpty)
                    const _EmptyReviewValue(
                      icon: Icons.people_outline_rounded,
                      message: 'No se registraron personas involucradas.',
                    )
                  else
                    ...controller.personas.map(
                      (persona) => _ReviewPersonCard(persona: persona),
                    ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // 4. INTERVENCIÓN
              // ==================================================
              _ReviewSection(
                number: 4,
                title: 'Intervención',
                icon: Icons.health_and_safety_outlined,
                onEdit: () => widget.onEditStep(3),
                children: [
                  _ReviewCollection<CreateOcurrenciaConsecuenciaRequest>(
                    title: 'Consecuencias',
                    icon: Icons.warning_amber_rounded,
                    items: controller.consecuencias,
                    itemBuilder: (item) {
                      return _CompactItem(
                        title: _humanize(item.tipo),
                        subtitle: item.descripcion,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ReviewCollection<CreateOcurrenciaMedioEmpleadoRequest>(
                    title: 'Medios empleados',
                    icon: Icons.handyman_outlined,
                    items: controller.mediosEmpleados,
                    itemBuilder: (item) {
                      return _CompactItem(
                        title: _humanize(item.tipo),
                        subtitle: item.descripcion,
                      );
                    },
                  ),
                  const SizedBox(height: 14),
                  _ReviewCollection<CreateOcurrenciaEfectivoPnpRequest>(
                    title: 'Efectivos PNP',
                    icon: Icons.local_police_outlined,
                    items: controller.efectivosPnp,
                    itemBuilder: (item) {
                      return _CompactItem(
                        title: _efectivoName(item),
                        subtitle:
                            'Participación: '
                            '${_humanize(item.tipoParticipacion)}'
                            '${item.comisaria?.trim().isNotEmpty == true ? '\nComisaría: ${item.comisaria}' : ''}',
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // ==================================================
              // DATOS IMPORTANTES
              // ==================================================
              if (controller.datosImportantesController.text.trim().isNotEmpty)
                _ReviewSection(
                  number: 5,
                  title: 'Datos importantes',
                  icon: Icons.notes_outlined,
                  onEdit: () => widget.onEditStep(1),
                  children: [
                    Text(
                      controller.datosImportantesController.text.trim(),
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),

              const SizedBox(height: 16),

              // ==================================================
              // CONFIRMACIÓN
              // ==================================================
              FormField<bool>(
                initialValue: _confirmacion,
                validator: (value) {
                  if (value != true) {
                    return 'Debes confirmar la información.';
                  }

                  return null;
                },
                builder: (field) {
                  return Container(
                    decoration: BoxDecoration(
                      color: field.hasError
                          ? Theme.of(context).colorScheme.errorContainer
                          : Theme.of(
                              context,
                            ).colorScheme.primaryContainer.withAlpha(90),
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: field.hasError
                            ? Theme.of(context).colorScheme.error
                            : Theme.of(context).colorScheme.outlineVariant,
                      ),
                    ),
                    child: Column(
                      children: [
                        CheckboxListTile(
                          value: _confirmacion,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          controlAffinity: ListTileControlAffinity.leading,
                          title: const Text(
                            'Confirmo que la información registrada '
                            'es correcta',
                            style: TextStyle(fontWeight: FontWeight.w700),
                          ),
                          subtitle: const Text(
                            'La ocurrencia será enviada para su '
                            'registro y posterior generación del reporte.',
                          ),
                          onChanged: (value) {
                            final confirmed = value ?? false;

                            setState(() {
                              _confirmacion = confirmed;
                            });

                            field.didChange(confirmed);
                          },
                        ),
                        if (field.hasError)
                          Padding(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(
                                field.errorText!,
                                style: TextStyle(
                                  color: Theme.of(context).colorScheme.error,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                      ],
                    ),
                  );
                },
              ),

              const SizedBox(height: 12),

              const _InformationBox(
                message:
                    'Al registrar la ocurrencia se enviarán los datos '
                    'mostrados en este resumen. Verifica especialmente '
                    'el código, la fecha, el resultado y la ubicación.',
              ),
            ],
          ),
        );
      },
    );
  }
}

// ============================================================
// RESUMEN DE VALIDACIÓN
// ============================================================

class _ValidationSummary extends StatelessWidget {
  final OcurrenciaFormController controller;

  const _ValidationSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    final pendingFields = <String>[];

    if (controller.codigoController.text.trim().isEmpty) {
      pendingFields.add('Código');
    }

    if (controller.origen.trim().isEmpty) {
      pendingFields.add('Origen');
    }

    if (controller.fechaOcurrenciaController.text.trim().isEmpty) {
      pendingFields.add('Fecha');
    }

    if (controller.resultado.trim().isEmpty) {
      pendingFields.add('Resultado');
    }

    final isComplete = pendingFields.isEmpty;
    final color = isComplete ? Colors.green : Colors.orange;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withAlpha(80)),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: color.withAlpha(35),
            foregroundColor: color,
            child: Icon(
              isComplete
                  ? Icons.check_circle_outline_rounded
                  : Icons.info_outline_rounded,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isComplete
                      ? 'Información principal completa'
                      : 'Existen datos por completar',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  isComplete
                      ? 'La ocurrencia está lista para ser registrada.'
                      : 'Verifica: ${pendingFields.join(', ')}.',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECCIÓN DE REVISIÓN
// ============================================================

class _ReviewSection extends StatelessWidget {
  final int number;
  final String title;
  final IconData icon;
  final VoidCallback onEdit;
  final List<Widget> children;

  const _ReviewSection({
    required this.number,
    required this.title,
    required this.icon,
    required this.onEdit,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: ExpansionTile(
        initiallyExpanded: true,
        leading: CircleAvatar(child: Text(number.toString())),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: const Text('Revisa la información registrada'),
        trailing: IconButton(
          tooltip: 'Editar sección',
          onPressed: onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
        children: [
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children:
                  children
                      .expand((widget) => [widget, const SizedBox(height: 10)])
                      .toList()
                    ..removeLast(),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FILA DE REVISIÓN
// ============================================================

class _ReviewRow extends StatelessWidget {
  final String label;
  final String? value;
  final bool required;

  const _ReviewRow({required this.label, this.value, this.required = false});

  @override
  Widget build(BuildContext context) {
    final normalized = value?.trim() ?? '';
    final hasValue = normalized.isNotEmpty;

    final displayedValue = hasValue
        ? normalized
        : required
        ? 'Pendiente'
        : 'No registrado';

    final valueColor = !hasValue && required
        ? Theme.of(context).colorScheme.error
        : !hasValue
        ? Theme.of(context).colorScheme.outline
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 135,
          child: Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: Theme.of(context).colorScheme.outline,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            displayedValue,
            style: TextStyle(
              color: valueColor,
              fontWeight: hasValue || required
                  ? FontWeight.w600
                  : FontWeight.normal,
              fontStyle: hasValue ? FontStyle.normal : FontStyle.italic,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// RELACIONES DEL SISTEMA
// ============================================================

class _SystemRelationChips extends StatelessWidget {
  final OcurrenciaFormController controller;

  const _SystemRelationChips({required this.controller});

  @override
  Widget build(BuildContext context) {
    final values = <Widget>[
      if (controller.patrullajeId != null)
        _ReviewChip(
          icon: Icons.route_outlined,
          label: 'Patrullaje #${controller.patrullajeId}',
        ),
      if (controller.zonaId != null)
        _ReviewChip(
          icon: Icons.map_outlined,
          label: 'Zona #${controller.zonaId}',
        ),
      if (controller.unidadId != null)
        _ReviewChip(
          icon: Icons.directions_car_outlined,
          label: 'Unidad #${controller.unidadId}',
        ),
      if (controller.incidenteSeleccionado != null)
        _ReviewChip(
          icon: Icons.report_problem_outlined,
          label: 'Incidente #${controller.incidenteSeleccionado!.id}',
        ),
    ];

    if (values.isEmpty) {
      return const _ReviewRow(
        label: 'Relaciones',
        value: 'Sin relaciones del sistema',
      );
    }

    return Wrap(spacing: 8, runSpacing: 8, children: values);
  }
}

class _ReviewChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _ReviewChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 17),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

// ============================================================
// COORDENADAS
// ============================================================

class _CoordinatesPreview extends StatelessWidget {
  final OcurrenciaFormController controller;

  const _CoordinatesPreview({required this.controller});

  @override
  Widget build(BuildContext context) {
    final latitude = controller.latitudController.text.trim();
    final longitude = controller.longitudController.text.trim();

    if (latitude.isEmpty || longitude.isEmpty) {
      return const _ReviewRow(label: 'Coordenadas', value: null);
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondaryContainer.withAlpha(80),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on_rounded,
            color: Theme.of(context).colorScheme.secondary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Latitud: $latitude\nLongitud: $longitude',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// PERSONA
// ============================================================

class _ReviewPersonCard extends StatelessWidget {
  final CreateOcurrenciaPersonaRequest persona;

  const _ReviewPersonCard({required this.persona});

  @override
  Widget build(BuildContext context) {
    final name = persona.nombresApellidos?.trim().isNotEmpty == true
        ? persona.nombresApellidos!.trim()
        : persona.identificado
        ? 'Persona identificada'
        : 'Persona no identificada';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const CircleAvatar(child: Icon(Icons.person_outline_rounded)),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),
                    Text(_humanize(persona.tipoPersona)),
                  ],
                ),
              ),
              Text(
                '#${persona.orden}',
                style: Theme.of(context).textTheme.labelLarge,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _ReviewChip(
                icon: persona.identificado
                    ? Icons.badge_outlined
                    : Icons.person_search_outlined,
                label: persona.identificado
                    ? 'Identificada'
                    : 'No identificada',
              ),
              if (persona.documentoIdentidad != null)
                _ReviewChip(
                  icon: Icons.numbers_rounded,
                  label: persona.documentoIdentidad!,
                ),
              if (persona.edad != null)
                _ReviewChip(
                  icon: Icons.cake_outlined,
                  label:
                      '${persona.edad} años'
                      '${persona.edadEsAproximada ? ' aprox.' : ''}',
                ),
              if (persona.genero != null)
                _ReviewChip(
                  icon: Icons.wc_rounded,
                  label: _humanize(persona.genero!),
                ),
            ],
          ),
          if (persona.caracteristicasFisicas?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              persona.caracteristicasFisicas!.trim(),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ],
      ),
    );
  }
}

// ============================================================
// COLECCIÓN
// ============================================================

class _ReviewCollection<T> extends StatelessWidget {
  final String title;
  final IconData icon;
  final List<T> items;
  final Widget Function(T item) itemBuilder;

  const _ReviewCollection({
    required this.title,
    required this.icon,
    required this.items,
    required this.itemBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '$title (${items.length})',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          if (items.isEmpty)
            Text(
              'No registrado',
              style: TextStyle(
                color: Theme.of(context).colorScheme.outline,
                fontStyle: FontStyle.italic,
              ),
            )
          else
            ...items.map(itemBuilder),
        ],
      ),
    );
  }
}

class _CompactItem extends StatelessWidget {
  final String title;
  final String? subtitle;

  const _CompactItem({required this.title, this.subtitle});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      dense: true,
      contentPadding: EdgeInsets.zero,
      leading: const Icon(Icons.check_circle_outline_rounded, size: 20),
      title: Text(title),
      subtitle: subtitle?.trim().isNotEmpty == true ? Text(subtitle!) : null,
    );
  }
}

// ============================================================
// SIN INFORMACIÓN
// ============================================================

class _EmptyReviewValue extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptyReviewValue({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.outline),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(color: Theme.of(context).colorScheme.outline),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// INTRODUCCIÓN
// ============================================================

class _StepIntroduction extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _StepIntroduction({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colors.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: colors.primary,
            foregroundColor: colors.onPrimary,
            child: Icon(icon),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(description),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _InformationBox extends StatelessWidget {
  final String message;

  const _InformationBox({required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colors.secondaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline_rounded, color: colors.secondary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

String _efectivoName(CreateOcurrenciaEfectivoPnpRequest efectivo) {
  final name = [efectivo.grado, efectivo.nombres, efectivo.apellidos]
      .whereType<String>()
      .where((value) {
        return value.trim().isNotEmpty;
      })
      .join(' ');

  if (name.isNotEmpty) {
    return name;
  }

  if (efectivo.policiaId != null) {
    return 'Efectivo PNP #${efectivo.policiaId}';
  }

  return 'Efectivo PNP';
}

String _humanizeNullable(String? value) {
  if (value == null || value.trim().isEmpty) {
    return '';
  }

  return _humanize(value);
}

String _humanize(String value) {
  final normalized = value.trim();

  if (normalized.isEmpty) return '';

  return normalized
      .toLowerCase()
      .split('_')
      .map(
        (word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}

String _joinValues(List<String?> values) {
  return values
      .whereType<String>()
      .where((value) => value.trim().isNotEmpty)
      .join(' · ');
}

String _firstNonEmpty(List<String?> values) {
  for (final value in values) {
    if (value != null && value.trim().isNotEmpty) {
      return value.trim();
    }
  }

  return '';
}
