import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_state.dart';

// Form
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/controller/ocurrencia_form_controller.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/steps/contexto_generalidades_step.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/steps/atencion_ubicacion_step.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/steps/personas_involucradas_step.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/steps/intervencion_step.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/steps/revision_ocurrencia_step.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/widgets/ocurrencia_navigation.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/view/form/widgets/ocurrencia_step_header.dart';

class OcurrenciaFormContent extends StatefulWidget {
  const OcurrenciaFormContent({super.key});

  @override
  State<OcurrenciaFormContent> createState() => _OcurrenciaFormContentState();
}

class _OcurrenciaFormContentState extends State<OcurrenciaFormContent> {
  static const int _totalSteps = 5;

  final List<GlobalKey<FormState>> _formKeys = List.generate(
    _totalSteps,
    (_) => GlobalKey<FormState>(),
  );

  late final OcurrenciaFormController _formController;

  int _currentStep = 0;

  bool get _isLastStep {
    return _currentStep == _totalSteps - 1;
  }

  @override
  void initState() {
    super.initState();

    _formController = OcurrenciaFormController();

    _initializeDateTime();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      _loadInitialData();
    });
  }

  // ==========================================================
  // INICIALIZACIÓN
  // ==========================================================

  void _initializeDateTime() {
    final now = DateTime.now();

    _formController.fechaOcurrenciaController.text = _formatDate(now);

    _formController.horaAlertaController.text = _formatTime(
      TimeOfDay.fromDateTime(now),
    );
  }

  void _loadInitialData() {
    _loadPatrullajeActivo();
    _loadClasificadorArbol();
  }

  // ==========================================================
  // PATRULLAJE ACTIVO
  // ==========================================================

  void _loadPatrullajeActivo() {
    final homeBloc = context.read<HomeBloc>();

    final patrullaje = homeBloc.state.patrullaje;

    if (patrullaje != null) {
      _formController.cargarContextoPatrullaje(patrullaje);

      return;
    }

    homeBloc.add(const LoadPatrullajeActivo());
  }

  // ==========================================================
  // ÁRBOL DE CLASIFICADORES
  // ==========================================================

  void _loadClasificadorArbol() {
    final clasificadoresBloc = context.read<ClasificadoresBloc>();

    final clasificadorState = clasificadoresBloc.state;

    /*
     * Reutiliza el árbol si ya fue cargado y contiene datos.
     */
    if (clasificadorState.arbol != null &&
        clasificadorState.arbol!.isNotEmpty) {
      return;
    }

    /*
     * Evita despachar otra petición si actualmente
     * se está cargando el árbol.
     */
    if (clasificadorState.isLoadingArbol) {
      return;
    }

    clasificadoresBloc.add(GetClasificadorArbol());
  }

  void _reloadClasificadorArbol() {
    final clasificadoresBloc = context.read<ClasificadoresBloc>();

    if (clasificadoresBloc.state.isLoadingArbol) {
      return;
    }

    clasificadoresBloc.add(GetClasificadorArbol());
  }

  // ==========================================================
  // NAVEGACIÓN ENTRE STEPS
  // ==========================================================

  void _nextStep() {
    final currentForm = _formKeys[_currentStep].currentState;

    if (currentForm != null && !currentForm.validate()) {
      return;
    }

    /*
     * La modalidad es obligatoria porque el backend
     * requiere modalidad_id.
     */
    if (_currentStep == 0 && !_formController.tieneModalidadSeleccionada) {
      _showMessage('Selecciona el código clasificador de la ocurrencia.');

      return;
    }

    /*
     * Las personas son obligatorias únicamente cuando
     * la modalidad seleccionada lo requiere.
     */
    final modalidad = _formController.modalidadSeleccionada;

    if (_currentStep == 2 &&
        modalidad?.requiereDatosPersona == true &&
        _formController.personas.isEmpty) {
      _showMessage(
        'El código clasificador seleccionado requiere registrar al menos una persona involucrada.',
      );

      return;
    }

    if (_isLastStep) {
      _submit();
      return;
    }

    setState(() {
      _currentStep++;
    });
  }

  void _previousStep() {
    if (_currentStep == 0) {
      return;
    }

    setState(() {
      _currentStep--;
    });
  }

  void _goToStep(int step) {
    if (step < 0 || step > _currentStep) {
      return;
    }

    setState(() {
      _currentStep = step;
    });
  }

  // ==========================================================
  // CREACIÓN
  // ==========================================================

  void _submit() {
    final ocurrenciaState = context.read<OcurrenciaBloc>().state;

    if (ocurrenciaState.isCreating) {
      return;
    }

    /*
     * Valida todos los formularios y dirige al usuario
     * al primer step que contenga errores.
     */
    for (var index = 0; index < _formKeys.length; index++) {
      final isValid = _formKeys[index].currentState?.validate() ?? true;

      if (!isValid) {
        setState(() {
          _currentStep = index;
        });

        _showMessage('Revisa los campos obligatorios del paso ${index + 1}.');

        return;
      }
    }

    if (!_formController.tieneModalidadSeleccionada) {
      setState(() {
        _currentStep = 0;
      });

      _showMessage('Selecciona el código clasificador de la ocurrencia.');

      return;
    }

    final modalidad = _formController.modalidadSeleccionada!;

    if (modalidad.requiereDatosPersona && _formController.personas.isEmpty) {
      setState(() {
        _currentStep = 2;
      });

      _showMessage(
        'El código clasificador seleccionado requiere registrar al menos una persona involucrada.',
      );

      return;
    }

    final request = _formController.buildRequest();

    context.read<OcurrenciaBloc>().add(CreateOcurrencia(request: request));
  }

  // ==========================================================
  // SELECTOR DE INCIDENCIAS
  // ==========================================================

  Future<void> _seleccionarIncidencia() async {
    final ocurrenciaBloc = context.read<OcurrenciaBloc>();

    final patrullajeId = _formController.patrullajeActivo?.id;

    ocurrenciaBloc.add(
      GetIncidenciasSelector(
        params: IncidenciasSelectorQueryParams(
          page: 1,
          limit: 20,
          patrullajeId: patrullajeId,
        ),
        refresh: true,
      ),
    );

    final incidencia = await showModalBottomSheet<IncidenciaSelectorData>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (_) {
        return BlocProvider.value(
          value: ocurrenciaBloc,
          child: const _IncidenciasSelectorSheet(),
        );
      },
    );

    if (!mounted || incidencia == null) {
      return;
    }

    ocurrenciaBloc.add(SelectIncidenciaOcurrencia(incidencia: incidencia));

    _formController.seleccionarIncidencia(incidencia);
  }

  void _clearSelectedIncidencia() {
    context.read<OcurrenciaBloc>().add(
      const ClearSelectedIncidenciaOcurrencia(),
    );

    _formController.limpiarIncidenciaSeleccionada();
  }

  // ==========================================================
  // LISTENERS
  // ==========================================================

  void _onHomeStateChanged(BuildContext context, HomeState state) {
    _formController.cargarContextoPatrullaje(state.patrullaje);
  }

  void _onClasificadorStateChanged(
    BuildContext context,
    ClasificadoresState state,
  ) {
    final modalidad = _formController.modalidadSeleccionada;

    final arbol = state.arbol;

    if (modalidad == null || arbol == null) {
      return;
    }

    /*
     * Si el árbol se actualizó y la modalidad dejó
     * de existir, se limpia la selección.
     */
    final modalidadActualizada = arbol.findModalidadByCodigo(modalidad.codigo);

    if (modalidadActualizada == null) {
      _formController.limpiarClasificador();
      return;
    }

    /*
     * También se limpia cuando la modalidad continúa
     * en el árbol, pero ahora está inactiva.
     */
    if (!modalidadActualizada.estado) {
      _formController.limpiarClasificador();
    }
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) {
            return previous.patrullaje?.id != current.patrullaje?.id ||
                previous.patrullaje?.estado != current.patrullaje?.estado;
          },
          listener: _onHomeStateChanged,
        ),

        BlocListener<ClasificadoresBloc, ClasificadoresState>(
          listenWhen: (previous, current) {
            return previous.clasificadorArbolResponse !=
                current.clasificadorArbolResponse;
          },
          listener: _onClasificadorStateChanged,
        ),
      ],
      child: AnimatedBuilder(
        animation: _formController,
        builder: (context, _) {
          final ocurrenciaState = context.watch<OcurrenciaBloc>().state;

          final homeState = context.watch<HomeBloc>().state;

          final clasificadorState = context.watch<ClasificadoresBloc>().state;

          return Column(
            children: [
              OcurrenciaStepHeader(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                onStepPressed: _goToStep,
              ),

              Expanded(
                child: IndexedStack(
                  index: _currentStep,
                  children: [
                    // =========================================
                    // STEP 1
                    // =========================================
                    ContextoGeneralidadesStep(
                      formKey: _formKeys[0],
                      controller: _formController,

                      // Patrullaje
                      patrullajeActivo: _formController.patrullajeActivo,
                      isLoadingPatrullaje: homeState.isLoading,
                      onReloadPatrullaje: _loadPatrullajeActivo,

                      // Incidencia
                      incidenciaSeleccionada:
                          ocurrenciaState.selectedIncidencia ??
                          _formController.incidenciaSeleccionada,
                      isLoadingIncidentes:
                          ocurrenciaState.isLoadingIncidenciasSelector,
                      incidentesError: ocurrenciaState.incidenciasSelectorError,
                      onSeleccionarIncidencia: _seleccionarIncidencia,
                      onLimpiarIncidencia: _clearSelectedIncidencia,

                      // Clasificador
                      clasificadorArbol: clasificadorState.arbol,
                      isLoadingClasificador: clasificadorState.isLoadingArbol,
                      clasificadorError: clasificadorState.arbolError?.message,
                      onReloadClasificador: _reloadClasificadorArbol,
                    ),

                    // =========================================
                    // STEP 2
                    // =========================================
                    AtencionUbicacionStep(
                      formKey: _formKeys[1],
                      controller: _formController,
                    ),

                    // =========================================
                    // STEP 3
                    // =========================================
                    PersonasInvolucradasStep(
                      formKey: _formKeys[2],
                      controller: _formController,
                    ),

                    // =========================================
                    // STEP 4
                    // =========================================
                    IntervencionStep(
                      formKey: _formKeys[3],
                      controller: _formController,
                    ),

                    // =========================================
                    // STEP 5
                    // =========================================
                    RevisionOcurrenciaStep(
                      formKey: _formKeys[4],
                      controller: _formController,
                      onEditStep: _goToStep,
                    ),
                  ],
                ),
              ),

              BlocBuilder<OcurrenciaBloc, OcurrenciaState>(
                buildWhen: (previous, current) {
                  return previous.createResponse != current.createResponse;
                },
                builder: (context, state) {
                  return OcurrenciaNavigation(
                    currentStep: _currentStep,
                    totalSteps: _totalSteps,
                    isLoading: state.isCreating,
                    onPrevious: _previousStep,
                    onNext: _nextStep,
                    completedSteps: List.generate(
                      _currentStep,
                      (index) => index,
                    ),
                    onSubmit: _submit,
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  String _formatDate(DateTime value) {
    final year = value.year.toString().padLeft(4, '0');

    final month = value.month.toString().padLeft(2, '0');

    final day = value.day.toString().padLeft(2, '0');

    return '$year-$month-$day';
  }

  String _formatTime(TimeOfDay value) {
    final hour = value.hour.toString().padLeft(2, '0');

    final minute = value.minute.toString().padLeft(2, '0');

    return '$hour:$minute:00';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }
}

class _IncidenciasSelectorSheet extends StatelessWidget {
  const _IncidenciasSelectorSheet();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return DraggableScrollableSheet(
      initialChildSize: 0.82,
      minChildSize: 0.55,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Material(
          color: colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
          clipBehavior: Clip.antiAlias,
          child: Column(
            children: [
              const SizedBox(height: 10),

              Container(
                width: 42,
                height: 4,
                decoration: BoxDecoration(
                  color: colorScheme.outlineVariant,
                  borderRadius: BorderRadius.circular(99),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 12, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Seleccionar incidencia',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            'Solo se muestran incidencias disponibles.',
                            style: Theme.of(context).textTheme.bodySmall
                                ?.copyWith(color: colorScheme.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: const Icon(Icons.close_rounded),
                    ),
                  ],
                ),
              ),

              const Divider(height: 1),

              Expanded(
                child: BlocBuilder<OcurrenciaBloc, OcurrenciaState>(
                  builder: (context, state) {
                    if (state.showIncidenciasSelectorLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (state.showIncidenciasSelectorError) {
                      return _SelectorError(
                        message:
                            state.incidenciasSelectorError ??
                            'No se pudieron cargar las incidencias.',
                        onRetry: () {
                          final params =
                              state.incidenciasSelectorParams ??
                              const IncidenciasSelectorQueryParams(
                                page: 1,
                                limit: 20,
                              );

                          context.read<OcurrenciaBloc>().add(
                            GetIncidenciasSelector(
                              params: params.copyWith(page: 1),
                              refresh: true,
                            ),
                          );
                        },
                      );
                    }

                    if (state.incidenciasSelector.isEmpty) {
                      return const _SelectorEmpty();
                    }

                    return ListView.separated(
                      controller: scrollController,
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                      itemCount: state.incidenciasSelector.length + 1,
                      separatorBuilder: (_, __) => const SizedBox(height: 10),
                      itemBuilder: (context, index) {
                        if (index < state.incidenciasSelector.length) {
                          final incidencia = state.incidenciasSelector[index];

                          return _IncidenciaOptionCard(
                            incidencia: incidencia,
                            selected:
                                state.selectedIncidencia?.id == incidencia.id,
                            onTap: () {
                              Navigator.of(context).pop(incidencia);
                            },
                          );
                        }

                        if (state.isLoadingMoreIncidenciasSelector) {
                          return const Padding(
                            padding: EdgeInsets.all(16),
                            child: Center(child: CircularProgressIndicator()),
                          );
                        }

                        if (!state.incidenciasSelectorHasMore) {
                          return Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(
                              'No hay más incidencias disponibles.',
                              textAlign: TextAlign.center,
                              style: Theme.of(context).textTheme.bodySmall
                                  ?.copyWith(
                                    color: colorScheme.onSurfaceVariant,
                                  ),
                            ),
                          );
                        }

                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: OutlinedButton.icon(
                            onPressed: () {
                              context.read<OcurrenciaBloc>().add(
                                const LoadMoreIncidenciasSelector(),
                              );
                            },
                            icon: const Icon(Icons.expand_more_rounded),
                            label: const Text('Cargar más'),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _IncidenciaOptionCard extends StatelessWidget {
  final IncidenciaSelectorData incidencia;
  final bool selected;
  final VoidCallback onTap;

  const _IncidenciaOptionCard({
    required this.incidencia,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Material(
      color: selected
          ? colorScheme.primaryContainer
          : colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: selected
                  ? colorScheme.primary
                  : colorScheme.outlineVariant,
              width: selected ? 1.5 : 1,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  _getIncidenciaIcon(incidencia.tipo),
                  color: colorScheme.primary,
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
                    const SizedBox(height: 5),
                    Text(
                      incidencia.descripcion,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatFechaHora(incidencia.fechaHora),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              Icon(
                selected
                    ? Icons.check_circle_rounded
                    : Icons.chevron_right_rounded,
                color: selected
                    ? colorScheme.primary
                    : colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SelectorEmpty extends StatelessWidget {
  const _SelectorEmpty();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.assignment_turned_in_outlined,
              size: 58,
              color: colorScheme.primary,
            ),
            const SizedBox(height: 16),
            Text(
              'No hay incidencias disponibles',
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Las incidencias asociadas previamente a una ocurrencia ya no aparecen en este selector.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SelectorError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _SelectorError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.cloud_off_outlined, size: 52, color: colorScheme.error),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center),
            const SizedBox(height: 16),
            FilledButton.tonalIcon(
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
