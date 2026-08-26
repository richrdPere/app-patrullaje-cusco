import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';

// Controller
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';

class IntervencionStep extends StatelessWidget {
  final GlobalKey<FormState> formKey;
  final OcurrenciaFormController controller;

  const IntervencionStep({
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
                icon: Icons.health_and_safety_outlined,
                title: 'Intervención',
                description:
                    'Registra las consecuencias, los medios empleados '
                    'durante el hecho y la participación de efectivos PNP.',
              ),
              const SizedBox(height: 16),

              _InterventionSummary(controller: controller),

              const SizedBox(height: 16),

              // ==================================================
              // CONSECUENCIAS
              // ==================================================
              _SectionCard(
                title: 'Consecuencias',
                subtitle: controller.consecuencias.isEmpty
                    ? 'No se registraron consecuencias.'
                    : '${controller.consecuencias.length} consecuencia(s).',
                icon: Icons.warning_amber_rounded,
                action: IconButton.filledTonal(
                  tooltip: 'Agregar consecuencia',
                  onPressed: () => _openConsecuenciaForm(context),
                  icon: const Icon(Icons.add_rounded),
                ),
                child: controller.consecuencias.isEmpty
                    ? _EmptySection(
                        icon: Icons.shield_outlined,
                        title: 'Sin consecuencias registradas',
                        description:
                            'Puedes continuar sin registrar consecuencias.',
                        buttonLabel: 'Agregar consecuencia',
                        onPressed: () => _openConsecuenciaForm(context),
                      )
                    : Column(
                        children: [
                          for (
                            var index = 0;
                            index < controller.consecuencias.length;
                            index++
                          ) ...[
                            _InterventionItemCard(
                              icon: _consequenceIcon(
                                controller.consecuencias[index].tipo,
                              ),
                              color: _consequenceColor(
                                controller.consecuencias[index].tipo,
                              ),
                              title: _humanize(
                                controller.consecuencias[index].tipo,
                              ),
                              description:
                                  controller.consecuencias[index].descripcion,
                              onEdit: () => _openConsecuenciaForm(
                                context,
                                index: index,
                                initialValue: controller.consecuencias[index],
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                title: 'Eliminar consecuencia',
                                message: '¿Deseas eliminar esta consecuencia?',
                                onConfirm: () {
                                  controller.eliminarConsecuencia(index);
                                },
                              ),
                            ),
                            if (index < controller.consecuencias.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // MEDIOS EMPLEADOS
              // ==================================================
              _SectionCard(
                title: 'Medios empleados',
                subtitle: controller.mediosEmpleados.isEmpty
                    ? 'No se registraron medios empleados.'
                    : '${controller.mediosEmpleados.length} medio(s).',
                icon: Icons.handyman_outlined,
                action: IconButton.filledTonal(
                  tooltip: 'Agregar medio',
                  onPressed: () => _openMedioForm(context),
                  icon: const Icon(Icons.add_rounded),
                ),
                child: controller.mediosEmpleados.isEmpty
                    ? _EmptySection(
                        icon: Icons.pan_tool_alt_outlined,
                        title: 'Sin medios empleados',
                        description:
                            'Registra armas, vehículos, objetos u otros '
                            'medios relacionados con el hecho.',
                        buttonLabel: 'Agregar medio',
                        onPressed: () => _openMedioForm(context),
                      )
                    : Column(
                        children: [
                          for (
                            var index = 0;
                            index < controller.mediosEmpleados.length;
                            index++
                          ) ...[
                            _InterventionItemCard(
                              icon: _medioIcon(
                                controller.mediosEmpleados[index].tipo,
                              ),
                              color: Colors.deepOrange,
                              title: _humanize(
                                controller.mediosEmpleados[index].tipo,
                              ),
                              description:
                                  controller.mediosEmpleados[index].descripcion,
                              onEdit: () => _openMedioForm(
                                context,
                                index: index,
                                initialValue: controller.mediosEmpleados[index],
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                title: 'Eliminar medio',
                                message:
                                    '¿Deseas eliminar este medio empleado?',
                                onConfirm: () {
                                  controller.eliminarMedioEmpleado(index);
                                },
                              ),
                            ),
                            if (index < controller.mediosEmpleados.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              // ==================================================
              // EFECTIVOS PNP
              // ==================================================
              _SectionCard(
                title: 'Participación de la PNP',
                subtitle: controller.efectivosPnp.isEmpty
                    ? 'No se registraron efectivos PNP.'
                    : '${controller.efectivosPnp.length} efectivo(s).',
                icon: Icons.local_police_outlined,
                action: IconButton.filledTonal(
                  tooltip: 'Agregar efectivo PNP',
                  onPressed: () => _openEfectivoForm(context),
                  icon: const Icon(Icons.add_rounded),
                ),
                child: controller.efectivosPnp.isEmpty
                    ? _EmptySection(
                        icon: Icons.local_police_outlined,
                        title: 'Sin efectivos PNP',
                        description:
                            'Agrega los efectivos policiales que participaron '
                            'en la intervención.',
                        buttonLabel: 'Agregar efectivo',
                        onPressed: () => _openEfectivoForm(context),
                      )
                    : Column(
                        children: [
                          for (
                            var index = 0;
                            index < controller.efectivosPnp.length;
                            index++
                          ) ...[
                            _EfectivoPnpCard(
                              efectivo: controller.efectivosPnp[index],
                              onEdit: () => _openEfectivoForm(
                                context,
                                index: index,
                                initialValue: controller.efectivosPnp[index],
                              ),
                              onDelete: () => _confirmDelete(
                                context,
                                title: 'Eliminar efectivo PNP',
                                message:
                                    '¿Deseas eliminar este efectivo del registro?',
                                onConfirm: () {
                                  controller.eliminarEfectivoPnp(index);
                                },
                              ),
                            ),
                            if (index < controller.efectivosPnp.length - 1)
                              const SizedBox(height: 10),
                          ],
                        ],
                      ),
              ),

              const SizedBox(height: 16),

              const _InformationBox(
                message:
                    'Estos registros son opcionales. Agrega únicamente '
                    'información verificada durante la atención de la '
                    'ocurrencia.',
              ),
            ],
          ),
        );
      },
    );
  }

  // ==========================================================
  // CONSECUENCIA
  // ==========================================================

  Future<void> _openConsecuenciaForm(
    BuildContext context, {
    int? index,
    CreateOcurrenciaConsecuenciaRequest? initialValue,
  }) async {
    final result =
        await showModalBottomSheet<CreateOcurrenciaConsecuenciaRequest>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _SimpleInterventionForm(
            title: initialValue == null
                ? 'Nueva consecuencia'
                : 'Editar consecuencia',
            fieldLabel: 'Tipo de consecuencia',
            options: _consequenceOptions,
            initialType: initialValue?.tipo,
            initialDescription: initialValue?.descripcion,
            descriptionLabel: 'Descripción',
            descriptionHint: 'Describe los daños o consecuencias producidas',
            onBuild: (type, description) {
              return CreateOcurrenciaConsecuenciaRequest(
                tipo: type,
                descripcion: description,
              );
            },
          ),
        );

    if (result == null) return;

    if (index == null) {
      controller.agregarConsecuencia(result);
    } else {
      controller.actualizarConsecuencia(index, result);
    }
  }

  // ==========================================================
  // MEDIO EMPLEADO
  // ==========================================================

  Future<void> _openMedioForm(
    BuildContext context, {
    int? index,
    CreateOcurrenciaMedioEmpleadoRequest? initialValue,
  }) async {
    final result =
        await showModalBottomSheet<CreateOcurrenciaMedioEmpleadoRequest>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _SimpleInterventionForm(
            title: initialValue == null
                ? 'Nuevo medio empleado'
                : 'Editar medio empleado',
            fieldLabel: 'Tipo de medio',
            options: _medioOptions,
            initialType: initialValue?.tipo,
            initialDescription: initialValue?.descripcion,
            descriptionLabel: 'Descripción del medio',
            descriptionHint:
                'Características, cantidad, marca u otra información',
            onBuild: (type, description) {
              return CreateOcurrenciaMedioEmpleadoRequest(
                tipo: type,
                descripcion: description,
              );
            },
          ),
        );

    if (result == null) return;

    if (index == null) {
      controller.agregarMedioEmpleado(result);
    } else {
      controller.actualizarMedioEmpleado(index, result);
    }
  }

  // ==========================================================
  // EFECTIVO PNP
  // ==========================================================

  Future<void> _openEfectivoForm(
    BuildContext context, {
    int? index,
    CreateOcurrenciaEfectivoPnpRequest? initialValue,
  }) async {
    final result =
        await showModalBottomSheet<CreateOcurrenciaEfectivoPnpRequest>(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          backgroundColor: Colors.transparent,
          builder: (_) => _EfectivoPnpForm(initialValue: initialValue),
        );

    if (result == null) return;

    if (index == null) {
      controller.agregarEfectivoPnp(result);
    } else {
      controller.actualizarEfectivoPnp(index, result);
    }
  }

  // ==========================================================
  // CONFIRMAR ELIMINACIÓN
  // ==========================================================

  Future<void> _confirmDelete(
    BuildContext context, {
    required String title,
    required String message,
    required VoidCallback onConfirm,
  }) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(Icons.delete_outline_rounded),
          title: Text(title),
          content: Text(message),
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
      onConfirm();
    }
  }
}

// ============================================================
// OPCIONES
// ============================================================

const _consequenceOptions = [
  _Option(value: 'MATERIALES', label: 'Materiales'),
  _Option(value: 'PERSONALES', label: 'Personales'),
  _Option(value: 'PSICOLOGICAS', label: 'Psicologicas'),
  _Option(value: 'MUERTE', label: 'Muerte'),
  _Option(value: 'DESORDEN', label: 'Desorden'),
  _Option(value: 'OCUPACION_INDEBIDA_ESPACIOS_PUBLICOS', label: 'Ocupación indebida'),
  _Option(value: 'PAZ_Y_ORDEN', label: 'Paz y orden'),
  _Option(value: 'ACCIONES_DISUASIVAS_PREVENTIVAS', label: 'Acciones diasivas'),
  _Option(value: 'OTRO', label: 'Otro'),
];

const _medioOptions = [
  _Option(value: 'ARMA_DE_FUEGO', label: 'Arma de fuego'),
  _Option(value: 'ARMA_BLANCA', label: 'Arma blanca'),
  _Option(value: 'AGRESION', label: 'Agresión'),
  _Option(value: 'AMENAZA', label: 'Amenaza'),
  _Option(value: 'FUERZA', label: 'Fuerza'),
  _Option(value: 'FUERZA_FISICA', label: 'Fuerza física'),
  _Option(value: 'ENGANO', label: 'Engaño'),
  _Option(value: 'HABILIDAD', label: 'Habilidad'),
  _Option(value: 'OTRO', label: 'Otro medio'),
];

const _participationOptions = [
  _Option(value: 'APOYO', label: 'Apoyo'),
  _Option(value: 'PATRULLAJE_INTEGRADO', label: 'Patrullaje Integrado'),
  _Option(value: 'INTERVENCION', label: 'Intervención'),
  _Option(value: 'TRASLADO', label: 'Traslado'),
  _Option(value: 'OTRO', label: 'Otra participación'),
];

// ============================================================
// FORMULARIO SIMPLE
// ============================================================

class _SimpleInterventionForm<T> extends StatefulWidget {
  final String title;
  final String fieldLabel;
  final String descriptionLabel;
  final String descriptionHint;
  final List<_Option> options;

  final String? initialType;
  final String? initialDescription;

  final T Function(String type, String? description) onBuild;

  const _SimpleInterventionForm({
    required this.title,
    required this.fieldLabel,
    required this.descriptionLabel,
    required this.descriptionHint,
    required this.options,
    required this.onBuild,
    this.initialType,
    this.initialDescription,
  });

  @override
  State<_SimpleInterventionForm<T>> createState() =>
      _SimpleInterventionFormState<T>();
}

class _SimpleInterventionFormState<T>
    extends State<_SimpleInterventionForm<T>> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _descriptionController;

  String? _type;

  @override
  void initState() {
    super.initState();

    _type = widget.initialType;

    _descriptionController = TextEditingController(
      text: widget.initialDescription ?? '',
    );
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 16, 20, 24 + bottomInset),
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _DialogHeader(
                  title: widget.title,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 20),
                DropdownButtonFormField<String>(
                  initialValue: _type,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${widget.fieldLabel} *',
                    prefixIcon: const Icon(Icons.category_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  items: widget.options.map((option) {
                    return DropdownMenuItem<String>(
                      value: option.value,
                      child: Text(option.label),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _type = value);
                  },
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Seleccione una opción.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _descriptionController,
                  minLines: 3,
                  maxLines: 5,
                  maxLength: 500,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    labelText: widget.descriptionLabel,
                    hintText: widget.descriptionHint,
                    alignLabelWithHint: true,
                    prefixIcon: const Icon(Icons.notes_outlined),
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (_type == 'OTRO' &&
                        (value == null || value.trim().isEmpty)) {
                      return 'Especifique la información.';
                    }

                    return null;
                  },
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('GUARDAR'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _save() {
    FocusScope.of(context).unfocus();

    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    Navigator.pop(
      context,
      widget.onBuild(_type!, _nullableText(_descriptionController.text)),
    );
  }
}

// ============================================================
// FORMULARIO EFECTIVO PNP
// ============================================================

class _EfectivoPnpForm extends StatefulWidget {
  final CreateOcurrenciaEfectivoPnpRequest? initialValue;

  const _EfectivoPnpForm({this.initialValue});

  @override
  State<_EfectivoPnpForm> createState() => _EfectivoPnpFormState();
}

class _EfectivoPnpFormState extends State<_EfectivoPnpForm> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _policiaIdController;
  late final TextEditingController _apellidosController;
  late final TextEditingController _nombresController;
  late final TextEditingController _gradoController;
  late final TextEditingController _comisariaController;
  late final TextEditingController _codigoController;
  late final TextEditingController _observacionController;
  late final TextEditingController _participacionOtroController;

  bool _usarCatalogo = false;

  String? _fuenteRegistro;
  String? _tipoParticipacion;

  @override
  void initState() {
    super.initState();

    final efectivo = widget.initialValue;

    _usarCatalogo = efectivo?.policiaId != null;
    _fuenteRegistro =
        efectivo?.fuenteRegistro ?? (_usarCatalogo ? 'CATALOGO' : 'MANUAL');

    _tipoParticipacion = efectivo?.tipoParticipacion;

    _policiaIdController = TextEditingController(
      text: efectivo?.policiaId?.toString() ?? '',
    );

    _apellidosController = TextEditingController(
      text: efectivo?.apellidos ?? '',
    );

    _nombresController = TextEditingController(text: efectivo?.nombres ?? '');

    _gradoController = TextEditingController(text: efectivo?.grado ?? '');

    _comisariaController = TextEditingController(
      text: efectivo?.comisaria ?? '',
    );

    _codigoController = TextEditingController(
      text: efectivo?.codigoInstitucional ?? '',
    );

    _observacionController = TextEditingController(
      text: efectivo?.observacion ?? '',
    );

    _participacionOtroController = TextEditingController(
      text: efectivo?.tipoParticipacionOtro ?? '',
    );
  }

  @override
  void dispose() {
    _policiaIdController.dispose();
    _apellidosController.dispose();
    _nombresController.dispose();
    _gradoController.dispose();
    _comisariaController.dispose();
    _codigoController.dispose();
    _observacionController.dispose();
    _participacionOtroController.dispose();

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
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 14, 10, 14),
            child: _DialogHeader(
              title: widget.initialValue == null
                  ? 'Agregar efectivo PNP'
                  : 'Editar efectivo PNP',
              onClose: () => Navigator.pop(context),
            ),
          ),
          const Divider(height: 1),
          Expanded(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: ListView(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 24 + bottomInset),
                children: [
                  SegmentedButton<bool>(
                    segments: const [
                      ButtonSegment(
                        value: true,
                        icon: Icon(Icons.search_rounded),
                        label: Text('Catálogo'),
                      ),
                      ButtonSegment(
                        value: false,
                        icon: Icon(Icons.edit_outlined),
                        label: Text('Manual'),
                      ),
                    ],
                    selected: {_usarCatalogo},
                    onSelectionChanged: (values) {
                      setState(() {
                        _usarCatalogo = values.first;
                        _fuenteRegistro = _usarCatalogo ? 'CATALOGO' : 'MANUAL';
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  if (_usarCatalogo)
                    TextFormField(
                      controller: _policiaIdController,
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      decoration: const InputDecoration(
                        labelText: 'ID del efectivo PNP *',
                        prefixIcon: Icon(Icons.badge_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (!_usarCatalogo) return null;

                        final id = int.tryParse(value?.trim() ?? '');

                        if (id == null || id <= 0) {
                          return 'Seleccione un efectivo válido.';
                        }

                        return null;
                      },
                    )
                  else ...[
                    TextFormField(
                      controller: _apellidosController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Apellidos *',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (!_usarCatalogo &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Ingrese los apellidos.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _nombresController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Nombres *',
                        prefixIcon: Icon(Icons.person_outline_rounded),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (!_usarCatalogo &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Ingrese los nombres.';
                        }

                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _gradoController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Grado',
                        prefixIcon: Icon(Icons.military_tech_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _comisariaController,
                      textCapitalization: TextCapitalization.words,
                      decoration: const InputDecoration(
                        labelText: 'Comisaría',
                        prefixIcon: Icon(Icons.account_balance_outlined),
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _codigoController,
                      textCapitalization: TextCapitalization.characters,
                      decoration: const InputDecoration(
                        labelText: 'Código institucional',
                        prefixIcon: Icon(Icons.numbers_rounded),
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ],

                  const SizedBox(height: 14),

                  DropdownButtonFormField<String>(
                    initialValue: _tipoParticipacion,
                    isExpanded: true,
                    decoration: const InputDecoration(
                      labelText: 'Tipo de participación *',
                      prefixIcon: Icon(Icons.security_outlined),
                      border: OutlineInputBorder(),
                    ),
                    items: _participationOptions.map((option) {
                      return DropdownMenuItem<String>(
                        value: option.value,
                        child: Text(option.label),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _tipoParticipacion = value;

                        if (value != 'OTRO') {
                          _participacionOtroController.clear();
                        }
                      });
                    },
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Seleccione el tipo de participación.';
                      }

                      return null;
                    },
                  ),

                  if (_tipoParticipacion == 'OTRO') ...[
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _participacionOtroController,
                      textCapitalization: TextCapitalization.sentences,
                      decoration: const InputDecoration(
                        labelText: 'Especifique la participación *',
                        prefixIcon: Icon(Icons.edit_outlined),
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (_tipoParticipacion == 'OTRO' &&
                            (value == null || value.trim().isEmpty)) {
                          return 'Especifique la participación.';
                        }

                        return null;
                      },
                    ),
                  ],

                  const SizedBox(height: 14),

                  TextFormField(
                    controller: _observacionController,
                    textCapitalization: TextCapitalization.sentences,
                    minLines: 2,
                    maxLines: 4,
                    maxLength: 500,
                    decoration: const InputDecoration(
                      labelText: 'Observación',
                      prefixIcon: Icon(Icons.notes_outlined),
                      alignLabelWithHint: true,
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 18),

                  FilledButton.icon(
                    onPressed: _save,
                    icon: const Icon(Icons.save_outlined),
                    label: const Text('GUARDAR EFECTIVO'),
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

    final efectivo = CreateOcurrenciaEfectivoPnpRequest(
      policiaId: _usarCatalogo
          ? int.tryParse(_policiaIdController.text.trim())
          : null,
      apellidos: _usarCatalogo
          ? null
          : _nullableText(_apellidosController.text),
      nombres: _usarCatalogo ? null : _nullableText(_nombresController.text),
      grado: _usarCatalogo ? null : _nullableText(_gradoController.text),
      comisaria: _usarCatalogo
          ? null
          : _nullableText(_comisariaController.text),
      codigoInstitucional: _usarCatalogo
          ? null
          : _nullableText(_codigoController.text),
      fuenteRegistro: _fuenteRegistro,
      observacion: _nullableText(_observacionController.text),
      tipoParticipacion: _tipoParticipacion!,
      tipoParticipacionOtro: _tipoParticipacion == 'OTRO'
          ? _nullableText(_participacionOtroController.text)
          : null,
    );

    Navigator.pop(context, efectivo);
  }
}

// ============================================================
// TARJETA EFECTIVO
// ============================================================

class _EfectivoPnpCard extends StatelessWidget {
  final CreateOcurrenciaEfectivoPnpRequest efectivo;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _EfectivoPnpCard({
    required this.efectivo,
    required this.onEdit,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = [efectivo.grado, efectivo.nombres, efectivo.apellidos]
        .whereType<String>()
        .where((value) {
          return value.trim().isNotEmpty;
        })
        .join(' ');

    return _InterventionItemCard(
      icon: Icons.local_police_outlined,
      color: Colors.blue.shade800,
      title: nombre.isNotEmpty
          ? nombre
          : 'Efectivo PNP #${efectivo.policiaId ?? ''}',
      description: [
        if (efectivo.comisaria != null) 'Comisaría: ${efectivo.comisaria}',
        'Participación: ${_humanize(efectivo.tipoParticipacion)}',
        if (efectivo.observacion != null) efectivo.observacion!,
      ].join('\n'),
      onEdit: onEdit,
      onDelete: onDelete,
    );
  }
}

// ============================================================
// TARJETA GENÉRICA
// ============================================================

class _InterventionItemCard extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String? description;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const _InterventionItemCard({
    required this.icon,
    required this.color,
    required this.title,
    required this.onEdit,
    required this.onDelete,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(70)),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withAlpha(30),
          foregroundColor: color,
          child: Icon(icon),
        ),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: description != null && description!.trim().isNotEmpty
            ? Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  description!,
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
              )
            : null,
        trailing: PopupMenuButton<_ItemAction>(
          onSelected: (action) {
            switch (action) {
              case _ItemAction.edit:
                onEdit();
                break;
              case _ItemAction.delete:
                onDelete();
                break;
            }
          },
          itemBuilder: (_) => const [
            PopupMenuItem(
              value: _ItemAction.edit,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.edit_outlined),
                title: Text('Editar'),
              ),
            ),
            PopupMenuItem(
              value: _ItemAction.delete,
              child: ListTile(
                dense: true,
                contentPadding: EdgeInsets.zero,
                leading: Icon(Icons.delete_outline_rounded, color: Colors.red),
                title: Text('Eliminar', style: TextStyle(color: Colors.red)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RESUMEN
// ============================================================

class _InterventionSummary extends StatelessWidget {
  final OcurrenciaFormController controller;

  const _InterventionSummary({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _SummaryItem(
            icon: Icons.warning_amber_rounded,
            label: 'Consecuencias',
            value: controller.consecuencias.length,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryItem(
            icon: Icons.handyman_outlined,
            label: 'Medios',
            value: controller.mediosEmpleados.length,
            color: Colors.deepOrange,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _SummaryItem(
            icon: Icons.local_police_outlined,
            label: 'Efectivos PNP',
            value: controller.efectivosPnp.length,
            color: Colors.blue,
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 14),
      decoration: BoxDecoration(
        color: color.withAlpha(20),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withAlpha(50)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color),
          const SizedBox(height: 6),
          Text(
            value.toString(),
            style: Theme.of(
              context,
            ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
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
// WIDGETS AUXILIARES
// ============================================================

class _Option {
  final String value;
  final String label;

  const _Option({required this.value, required this.label});
}

enum _ItemAction { edit, delete }

class _DialogHeader extends StatelessWidget {
  final String title;
  final VoidCallback onClose;

  const _DialogHeader({required this.title, required this.onClose});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
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
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Widget child;
  final Widget? action;

  const _SectionCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.child,
    this.action,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
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
                      const SizedBox(height: 2),
                      Text(
                        subtitle,
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                    ],
                  ),
                ),
                if (action != null) action!,
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

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String buttonLabel;
  final VoidCallback onPressed;

  const _EmptySection({
    required this.icon,
    required this.title,
    required this.description,
    required this.buttonLabel,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Center(
        child: Column(
          children: [
            Icon(icon, size: 42, color: Theme.of(context).colorScheme.outline),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            const SizedBox(height: 4),
            Text(description, textAlign: TextAlign.center),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: onPressed,
              icon: const Icon(Icons.add_rounded),
              label: Text(buttonLabel),
            ),
          ],
        ),
      ),
    );
  }
}

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

String? _nullableText(String? value) {
  final normalized = value?.trim();

  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}

String _humanize(String value) {
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

IconData _consequenceIcon(String type) {
  switch (type) {
    case 'LESIONES_LEVES':
    case 'LESIONES_GRAVES':
      return Icons.personal_injury_outlined;

    case 'FALLECIMIENTO':
      return Icons.warning_amber_rounded;

    case 'DAÑO_MATERIAL':
    case 'PERDIDA_PATRIMONIAL':
      return Icons.home_work_outlined;

    case 'DAÑO_AMBIENTAL':
      return Icons.eco_outlined;

    case 'SIN_CONSECUENCIAS':
      return Icons.shield_outlined;

    default:
      return Icons.report_problem_outlined;
  }
}

Color _consequenceColor(String type) {
  switch (type) {
    case 'SIN_CONSECUENCIAS':
      return Colors.green;

    case 'LESIONES_LEVES':
      return Colors.orange;

    case 'LESIONES_GRAVES':
    case 'FALLECIMIENTO':
      return Colors.red;

    default:
      return Colors.deepOrange;
  }
}

IconData _medioIcon(String type) {
  switch (type) {
    case 'ARMA_DE_FUEGO':
      return Icons.gps_fixed_rounded;

    case 'ARMA_BLANCA':
      return Icons.content_cut_rounded;

    case 'VEHICULO':
      return Icons.directions_car_outlined;

    case 'MEDIO_DIGITAL':
      return Icons.phone_android_outlined;

    case 'FUERZA_FISICA':
      return Icons.sports_martial_arts_outlined;

    default:
      return Icons.handyman_outlined;
  }
}
