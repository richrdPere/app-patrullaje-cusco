import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';

// Controller
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';

class PersonasInvolucradasStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final OcurrenciaFormController controller;

  const PersonasInvolucradasStep({
    super.key,
    required this.formKey,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (context, _) {
        return Form(
          key: formKey,
          child: ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
            children: [
              const _StepIntroduction(
                icon: Icons.groups_2_outlined,
                title: 'Personas involucradas',
                description:
                    'Registra víctimas, presuntos responsables, testigos '
                    'u otras personas relacionadas con la ocurrencia.',
              ),
              const SizedBox(height: 16),

              _PeopleSummary(personas: controller.personas),

              const SizedBox(height: 16),

              _SectionCard(
                title: 'Listado de personas',
                subtitle: controller.personas.isEmpty
                    ? 'No se registraron personas involucradas.'
                    : '${controller.personas.length} persona(s) registrada(s).',
                icon: Icons.people_alt_outlined,
                trailing: FilledButton.icon(
                  onPressed: () => _openPersonForm(context),
                  icon: const Icon(Icons.person_add_alt_1_rounded),
                  label: const Text('Agregar'),
                ),
                child: controller.personas.isEmpty
                    ? _EmptyPeople(onAdd: () => _openPersonForm(context))
                    : Column(
                        children: [
                          for (
                            var index = 0;
                            index < controller.personas.length;
                            index++
                          ) ...[
                            _PersonCard(
                              index: index,
                              total: controller.personas.length,
                              persona: controller.personas[index],
                              onEdit: () => _openPersonForm(
                                context,
                                index: index,
                                initialValue: controller.personas[index],
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                index,
                                controller.personas[index],
                              ),
                              onMoveUp: index > 0
                                  ? () => controller.moverPersonaArriba(index)
                                  : null,
                              onMoveDown: index < controller.personas.length - 1
                                  ? () => controller.moverPersonaAbajo(index)
                                  : null,
                            ),
                            if (index < controller.personas.length - 1)
                              const SizedBox(height: 12),
                          ],
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              const _InformationBox(
                icon: Icons.privacy_tip_outlined,
                message:
                    'El registro de personas es opcional. Si una persona '
                    'no desea brindar sus datos o no puede ser identificada, '
                    'puede registrar solamente sus características físicas.',
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // ABRIR FORMULARIO
  // ==========================================================

  Future<void> _openPersonForm(
    BuildContext context, {
    int? index,
    CreateOcurrenciaPersonaRequest? initialValue,
  }) async {
    final persona = await showModalBottomSheet<CreateOcurrenciaPersonaRequest>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return _PersonFormSheet(
          initialValue: initialValue,
          nextOrder: index == null ? controller.personas.length + 1 : index + 1,
        );
      },
    );

    if (persona == null) {
      return;
    }

    if (index == null) {
      controller.agregarPersona(persona);
    } else {
      controller.actualizarPersona(index, persona);
    }
  }

  // ==========================================================
  // ELIMINAR
  // ==========================================================

  Future<void> _confirmDelete(
    BuildContext context,
    int index,
    CreateOcurrenciaPersonaRequest persona,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.person_remove_outlined),
          title: const Text('Eliminar persona'),
          content: Text(
            persona.nombresApellidos?.trim().isNotEmpty == true
                ? '¿Deseas eliminar a '
                      '"${persona.nombresApellidos!.trim()}"?'
                : '¿Deseas eliminar esta persona del registro?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext, false),
              child: const Text('CANCELAR'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(dialogContext, true),
              child: const Text('ELIMINAR'),
            ),
          ],
        );
      },
    );

    if (confirmed == true) {
      controller.eliminarPersona(index);
    }
  }
}

// ============================================================
// FORMULARIO DE PERSONA
// ============================================================

class _PersonFormSheet extends StatefulWidget {
  final int nextOrder;
  final CreateOcurrenciaPersonaRequest? initialValue;

  const _PersonFormSheet({required this.nextOrder, this.initialValue});

  @override
  State<_PersonFormSheet> createState() => _PersonFormSheetState();
}

class _PersonFormSheetState extends State<_PersonFormSheet> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _documentoController;
  late final TextEditingController _nombresController;
  late final TextEditingController _edadController;
  late final TextEditingController _placaController;
  late final TextEditingController _caracteristicasController;
  late final TextEditingController _observacionController;

  String? _tipoPersona;
  String? _genero;
  String _fuenteDatos = 'DIRECTA';

  bool _identificado = true;
  bool _edadEsAproximada = false;
  bool _esComunidad = false;

  static const List<_Option> _tiposPersona = [
    _Option(
      value: 'VICTIMA',
      label: 'Víctima',
      icon: Icons.person_outline_rounded,
    ),
    _Option(
      value: 'AUTOR',
      label: 'Autor',
      icon: Icons.visibility_outlined,
    ),
    _Option(
      value: 'AGRESOR',
      label: 'Agresor',
      icon: Icons.person_off_outlined,
    ),
    _Option(
      value: 'CONDUCTOR',
      label: 'Conductor',
      icon: Icons.record_voice_over_outlined,
    ),
    _Option(
      value: 'BENEFICIARIO',
      label: 'Beneficiario',
      icon: Icons.pan_tool_alt_outlined,
    ),
    // _Option(
    //   value: 'OTRO',
    //   label: 'Otra persona',
    //   icon: Icons.more_horiz_rounded,
    // ),
  ];

  static const List<_Option> _generos = [
    _Option(value: 'MASCULINO', label: 'Masculino'),
    _Option(value: 'FEMENINO', label: 'Femenino'),
    _Option(value: 'NO_DETERMINADO', label: 'No determinado'),
  ];

  static const List<_Option> _fuentesDatos = [
    _Option(value: 'DIRECTA', label: 'Información directa'),
    _Option(value: 'REFERENCIAL', label: 'Referencial'),
    _Option(value: 'CONSULTA_SUNARP', label: 'Consulta sunarp'),
    _Option(value: 'COMUNIDAD', label: 'Comunidad'),
  ];

  @override
  void initState() {
    super.initState();

    final persona = widget.initialValue;

    _tipoPersona = persona?.tipoPersona;
    _genero = persona?.genero;
    _fuenteDatos = persona?.fuenteDatos ?? 'DIRECTA';
    _identificado = persona?.identificado ?? true;
    _edadEsAproximada = persona?.edadEsAproximada ?? false;
    _esComunidad = persona?.esComunidad ?? false;

    _documentoController = TextEditingController(
      text: persona?.documentoIdentidad ?? '',
    );

    _nombresController = TextEditingController(
      text: persona?.nombresApellidos ?? '',
    );

    _edadController = TextEditingController(
      text: persona?.edad?.toString() ?? '',
    );

    _placaController = TextEditingController(text: persona?.placa ?? '');

    _caracteristicasController = TextEditingController(
      text: persona?.caracteristicasFisicas ?? '',
    );

    _observacionController = TextEditingController(
      text: persona?.observacion ?? '',
    );
  }

  @override
  void dispose() {
    _documentoController.dispose();
    _nombresController.dispose();
    _edadController.dispose();
    _placaController.dispose();
    _caracteristicasController.dispose();
    _observacionController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.sizeOf(context).height * 0.94,
      ),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          _SheetHeader(
            isEditing: widget.initialValue != null,
            onClose: () => Navigator.pop(context),
          ),
          const Divider(height: 1),
          Expanded(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
                children: [
                  DropdownButtonFormField<String>(
                    initialValue: _tipoPersona,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de persona *',
                      prefixIcon: Icon(Icons.account_circle_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _tiposPersona.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.value,
                        child: Row(
                          children: [
                            Icon(item.icon, size: 20),
                            const SizedBox(width: 10),
                            Expanded(child: Text(item.label)),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _tipoPersona = value);
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccione el tipo de persona.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  SwitchListTile.adaptive(
                    value: _identificado,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('Persona identificada'),
                    subtitle: Text(
                      _identificado
                          ? 'Se conocen sus datos personales.'
                          : 'No se conocen o no brindó sus datos.',
                    ),
                    secondary: Icon(
                      _identificado
                          ? Icons.badge_outlined
                          : Icons.person_search_outlined,
                    ),
                    onChanged: (value) {
                      setState(() {
                        _identificado = value;

                        if (!value) {
                          _documentoController.clear();
                          _nombresController.clear();
                        }
                      });
                    },
                  ),

                  const SizedBox(height: 14),

                  if (_identificado) ...[
                    TextFormField(
                      controller: _documentoController,
                      keyboardType: TextInputType.number,
                      maxLength: 12,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'Documento de identidad',
                        hintText: 'DNI, CE u otro documento',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        final document = value?.trim() ?? '';

                        if (document.isNotEmpty && document.length < 8) {
                          return 'Ingrese al menos 8 dígitos.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nombresController,
                      textCapitalization: TextCapitalization.words,
                      maxLength: 150,
                      decoration: const InputDecoration(
                        labelText: 'Nombres y apellidos *',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                        counterText: '',
                      ),
                      validator: (value) {
                        if (_identificado &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Ingrese los nombres y apellidos.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                  ],

                  DropdownButtonFormField<String>(
                    initialValue: _genero,
                    decoration: const InputDecoration(
                      labelText: 'Género',
                      prefixIcon: Icon(Icons.wc_rounded),
                      border: OutlineInputBorder(),
                    ),
                    items: _generos.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.value,
                        child: Text(item.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() => _genero = value);
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _edadController,
                    keyboardType: TextInputType.number,
                    maxLength: 3,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Edad',
                      prefixIcon: Icon(Icons.cake_outlined),
                      suffixText: 'años',
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                    validator: (value) {
                      final rawAge = value?.trim() ?? '';

                      if (rawAge.isEmpty) {
                        return null;
                      }

                      final age = int.tryParse(rawAge);

                      if (age == null || age < 0 || age > 120) {
                        return 'Ingrese una edad válida.';
                      }

                      return null;
                    },
                  ),

                  CheckboxListTile(
                    value: _edadEsAproximada,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('La edad es aproximada'),
                    controlAffinity: ListTileControlAffinity.leading,
                    onChanged: (value) {
                      setState(() {
                        _edadEsAproximada = value ?? false;
                      });
                    },
                  ),

                  const SizedBox(height: 8),

                  TextFormField(
                    controller: _placaController,
                    textCapitalization: TextCapitalization.characters,
                    maxLength: 12,
                    decoration: const InputDecoration(
                      labelText: 'Placa relacionada',
                      hintText: 'Vehículo asociado a la persona',
                      prefixIcon: Icon(Icons.directions_car_outlined),
                      border: OutlineInputBorder(),
                      counterText: '',
                    ),
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _caracteristicasController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 3,
                    maxLines: 5,
                    maxLength: 500,
                    decoration: InputDecoration(
                      labelText: _identificado
                          ? 'Características físicas'
                          : 'Características físicas *',
                      hintText:
                          'Vestimenta, estatura aproximada, contextura, '
                          'rasgos distintivos...',
                      prefixIcon: const Icon(Icons.accessibility_new_rounded),
                      alignLabelWithHint: true,
                      border: const OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (!_identificado &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Describa a la persona no identificada.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 4),

                  SwitchListTile.adaptive(
                    value: _esComunidad,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 4),
                    title: const Text('Representa a una comunidad o colectivo'),
                    subtitle: const Text(
                      'Active esta opción cuando el registro no '
                      'corresponda a una persona individual.',
                    ),
                    secondary: const Icon(Icons.groups_outlined),
                    onChanged: (value) {
                      setState(() => _esComunidad = value);
                    },
                  ),

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _fuenteDatos,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Fuente de los datos *',
                      prefixIcon: Icon(Icons.source_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _fuentesDatos.map((item) {
                      return DropdownMenuItem<String>(
                        value: item.value,
                        child: Text(item.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      if (value != null) {
                        setState(() => _fuenteDatos = value);
                      }
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccione la fuente de los datos.';
                      }

                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _observacionController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Observación',
                      hintText: 'Información adicional sobre la persona',
                      prefixIcon: Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 24),

                  FilledButton.icon(
                    onPressed: _save,
                    icon: Icon(
                      widget.initialValue == null
                          ? Icons.person_add_alt_1_rounded
                          : Icons.save_outlined,
                    ),
                    label: Text(
                      widget.initialValue == null
                          ? 'AGREGAR PERSONA'
                          : 'GUARDAR CAMBIOS',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    final persona = CreateOcurrenciaPersonaRequest(
      orden: widget.nextOrder,
      tipoPersona: _tipoPersona!,
      identificado: _identificado,
      documentoIdentidad: _identificado
          ? _nullableText(_documentoController.text)
          : null,
      nombresApellidos: _identificado
          ? _nullableText(_nombresController.text)
          : null,
      genero: _genero,
      edad: int.tryParse(_edadController.text.trim()),
      edadEsAproximada: _edadEsAproximada,
      placa: _nullableText(_placaController.text),
      caracteristicasFisicas: _nullableText(_caracteristicasController.text),
      esComunidad: _esComunidad,
      fuenteDatos: _fuenteDatos,
      observacion: _nullableText(_observacionController.text),
    );

    Navigator.pop(context, persona);
  }

  String? _nullableText(String? value) {
    final normalized = value?.trim();

    if (normalized == null || normalized.isEmpty) {
      return null;
    }

    return normalized;
  }
}

// ============================================================
// PERSON CARD
// ============================================================

class _PersonCard extends StatelessWidget {
  final int index;
  final int total;
  final CreateOcurrenciaPersonaRequest persona;
  final VoidCallback onEdit;
  final VoidCallback onDelete;
  final VoidCallback? onMoveUp;
  final VoidCallback? onMoveDown;

  const _PersonCard({
    required this.index,
    required this.total,
    required this.persona,
    required this.onEdit,
    required this.onDelete,
    this.onMoveUp,
    this.onMoveDown,
  });

  @override
  Widget build(BuildContext context) {
    final configuration = _personTypeConfiguration(persona.tipoPersona);

    final colorScheme = Theme.of(context).colorScheme;

    final displayName = persona.nombresApellidos?.trim().isNotEmpty == true
        ? persona.nombresApellidos!.trim()
        : persona.identificado
        ? 'Persona identificada'
        : 'Persona no identificada';

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: configuration.color.withAlpha(80)),
      ),
      child: Column(
        children: [
          ListTile(
            leading: CircleAvatar(
              backgroundColor: configuration.color.withAlpha(30),
              foregroundColor: configuration.color,
              child: Icon(configuration.icon),
            ),
            title: Text(
              displayName,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
            subtitle: Text(
              '${configuration.label} · '
              '${persona.identificado ? 'Identificada' : 'No identificada'}',
            ),
            trailing: PopupMenuButton<_PersonAction>(
              tooltip: 'Opciones',
              onSelected: (action) {
                switch (action) {
                  case _PersonAction.edit:
                    onEdit();
                    break;
                  case _PersonAction.moveUp:
                    onMoveUp?.call();
                    break;
                  case _PersonAction.moveDown:
                    onMoveDown?.call();
                    break;
                  case _PersonAction.delete:
                    onDelete();
                    break;
                }
              },
              itemBuilder: (_) {
                return [
                  const PopupMenuItem(
                    value: _PersonAction.edit,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(Icons.edit_outlined),
                      title: Text('Editar'),
                    ),
                  ),
                  if (onMoveUp != null)
                    const PopupMenuItem(
                      value: _PersonAction.moveUp,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.arrow_upward_rounded),
                        title: Text('Mover arriba'),
                      ),
                    ),
                  if (onMoveDown != null)
                    const PopupMenuItem(
                      value: _PersonAction.moveDown,
                      child: ListTile(
                        dense: true,
                        contentPadding: EdgeInsets.zero,
                        leading: Icon(Icons.arrow_downward_rounded),
                        title: Text('Mover abajo'),
                      ),
                    ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: _PersonAction.delete,
                    child: ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        Icons.delete_outline_rounded,
                        color: Colors.red,
                      ),
                      title: Text(
                        'Eliminar',
                        style: TextStyle(color: Colors.red),
                      ),
                    ),
                  ),
                ];
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                _InfoChip(
                  icon: Icons.format_list_numbered_rounded,
                  label: 'Orden ${index + 1} de $total',
                ),
                if (persona.documentoIdentidad != null)
                  _InfoChip(
                    icon: Icons.badge_outlined,
                    label: persona.documentoIdentidad!,
                  ),
                if (persona.edad != null)
                  _InfoChip(
                    icon: Icons.cake_outlined,
                    label:
                        '${persona.edad} años'
                        '${persona.edadEsAproximada ? ' aprox.' : ''}',
                  ),
                if (persona.genero != null)
                  _InfoChip(
                    icon: Icons.wc_rounded,
                    label: _humanize(persona.genero!),
                  ),
                if (persona.esComunidad)
                  const _InfoChip(
                    icon: Icons.groups_outlined,
                    label: 'Comunidad',
                  ),
                if (persona.placa != null)
                  _InfoChip(
                    icon: Icons.directions_car_outlined,
                    label: persona.placa!,
                  ),
              ],
            ),
          ),
          if (persona.caracteristicasFisicas?.trim().isNotEmpty == true)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              decoration: BoxDecoration(
                color: colorScheme.surfaceContainerHighest,
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.circular(14),
                ),
              ),
              child: Text(
                persona.caracteristicasFisicas!.trim(),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// RESUMEN
// ============================================================

class _PeopleSummary extends StatelessWidget {
  final List<CreateOcurrenciaPersonaRequest> personas;

  const _PeopleSummary({required this.personas});

  @override
  Widget build(BuildContext context) {
    final victims = personas
        .where((item) => item.tipoPersona == 'VICTIMA')
        .length;

    final allegedOffenders = personas
        .where((item) => item.tipoPersona == 'PRESUNTO_VICTIMARIO')
        .length;

    final witnesses = personas
        .where((item) => item.tipoPersona == 'TESTIGO')
        .length;

    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            icon: Icons.groups_outlined,
            label: 'Total',
            value: personas.length,
            color: Colors.blue,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryItem(
            icon: Icons.person_outline_rounded,
            label: 'Víctimas',
            value: victims,
            color: Colors.orange,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryItem(
            icon: Icons.person_off_outlined,
            label: 'Presuntos',
            value: allegedOffenders,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: _SummaryItem(
            icon: Icons.visibility_outlined,
            label: 'Testigos',
            value: witnesses,
            color: Colors.green,
          ),
        ),
      ],
    );
  }
}

class _SummaryItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final Color color;

  const _SummaryItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 21),
          const SizedBox(height: 5),
          Text(
            value.toString(),
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w800),
          ),
          Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: Theme.of(context).textTheme.labelSmall,
          ),
        ],
      ),
    );
  }
}

// ============================================================
// EMPTY
// ============================================================

class _EmptyPeople extends StatelessWidget {
  final VoidCallback onAdd;

  const _EmptyPeople({required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 18),
      child: Column(
        children: [
          Icon(
            Icons.people_outline_rounded,
            size: 52,
            color: Theme.of(context).colorScheme.outline,
          ),
          const SizedBox(height: 12),
          Text(
            'Sin personas registradas',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 4),
          const Text(
            'Puedes continuar sin registrar personas o agregar una.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 14),
          OutlinedButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add_rounded),
            label: const Text('Agregar persona'),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SHEET HEADER
// ============================================================

class _SheetHeader extends StatelessWidget {
  final bool isEditing;
  final VoidCallback onClose;

  const _SheetHeader({required this.isEditing, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 10, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              isEditing
                  ? 'Editar persona involucrada'
                  : 'Nueva persona involucrada',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
          IconButton(
            tooltip: 'Cerrar',
            onPressed: onClose,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// SECTION CARD
// ============================================================

class _SectionCard extends StatelessWidget {
  final String title;
  final String? subtitle;
  final IconData icon;
  final Widget child;
  final Widget? trailing;

  const _SectionCard({
    required this.title,
    required this.icon,
    required this.child,
    this.subtitle,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      if (subtitle != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          subtitle!,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ],
                  ),
                ),
                if (trailing != null) ...[const SizedBox(width: 8), trailing!],
              ],
            ),
            const SizedBox(height: 16),
            child,
          ],
        ),
      ),
    );
  }
}

// ============================================================
// INTRODUCCIÓN E INFORMACIÓN
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
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.primaryContainer.withAlpha(120),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: colorScheme.primary,
            foregroundColor: colorScheme.onPrimary,
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
  final IconData icon;
  final String message;

  const _InformationBox({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withAlpha(100),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.secondary),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }
}

// ============================================================
// HELPERS VISUALES
// ============================================================

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;

  const _InfoChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 16),
      label: Text(label),
      visualDensity: VisualDensity.compact,
    );
  }
}

class _Option {
  final String value;
  final String label;
  final IconData? icon;

  const _Option({required this.value, required this.label, this.icon});
}

enum _PersonAction { edit, moveUp, moveDown, delete }

class _PersonTypeConfiguration {
  final String label;
  final IconData icon;
  final Color color;

  const _PersonTypeConfiguration({
    required this.label,
    required this.icon,
    required this.color,
  });
}

_PersonTypeConfiguration _personTypeConfiguration(String type) {
  switch (type) {
    case 'VICTIMA':
      return const _PersonTypeConfiguration(
        label: 'Víctima',
        icon: Icons.person_outline_rounded,
        color: Colors.orange,
      );

    case 'PRESUNTO_VICTIMARIO':
      return const _PersonTypeConfiguration(
        label: 'Presunto victimario',
        icon: Icons.person_off_outlined,
        color: Colors.red,
      );

    case 'TESTIGO':
      return const _PersonTypeConfiguration(
        label: 'Testigo',
        icon: Icons.visibility_outlined,
        color: Colors.green,
      );

    case 'DENUNCIANTE':
      return const _PersonTypeConfiguration(
        label: 'Denunciante',
        icon: Icons.record_voice_over_outlined,
        color: Colors.blue,
      );

    case 'INTERVENIDO':
      return const _PersonTypeConfiguration(
        label: 'Intervenido',
        icon: Icons.pan_tool_alt_outlined,
        color: Colors.deepPurple,
      );

    default:
      return const _PersonTypeConfiguration(
        label: 'Otra persona',
        icon: Icons.more_horiz_rounded,
        color: Colors.grey,
      );
  }
}

String _humanize(String value) {
  if (value.trim().isEmpty) {
    return '';
  }

  return value
      .trim()
      .toLowerCase()
      .split('_')
      .map(
        (word) =>
            word.isEmpty ? '' : '${word[0].toUpperCase()}${word.substring(1)}',
      )
      .join(' ');
}
