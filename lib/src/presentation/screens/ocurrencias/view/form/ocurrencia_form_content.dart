import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  final _formKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  late final OcurrenciaFormController _formController;

  int _currentStep = 0;

  bool get _isLastStep {
    return _currentStep == _totalSteps - 1;
  }

  @override
  void initState() {
    super.initState();

    _formController = OcurrenciaFormController();

    final now = DateTime.now();

    _formController.fechaOcurrenciaController.text = _formatDate(now);

    _formController.horaAlertaController.text = _formatTime(
      TimeOfDay.fromDateTime(now),
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final homeBloc = context.read<HomeBloc>();
      final patrullaje = homeBloc.state.patrullaje;

      if (patrullaje != null) {
        _formController.cargarContextoPatrullaje(patrullaje);
      } else {
        homeBloc.add(const LoadPatrullajeActivo());
      }
    });
  }

  @override
  void dispose() {
    _formController.dispose();
    super.dispose();
  }

  void _nextStep() {
    final form = _formKeys[_currentStep].currentState;

    if (form != null && !form.validate()) {
      return;
    }

    if (_currentStep == 2 && _formController.personas.isEmpty) {
      _showMessage('Registra al menos una persona involucrada.');

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
    if (_currentStep == 0) return;

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

  void _submit() {
    final ocurrenciaState = context.read<OcurrenciaBloc>().state;

    if (ocurrenciaState.isCreating) {
      return;
    }

    for (final formKey in _formKeys) {
      if (formKey.currentState?.validate() == false) {
        _showMessage('Revisa los campos obligatorios.');

        return;
      }
    }

    final request = _formController.buildRequest();

    context.read<OcurrenciaBloc>().add(CreateOcurrencia(request: request));
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (previous, current) {
        return previous.patrullaje?.id != current.patrullaje?.id ||
            previous.patrullaje?.estado != current.patrullaje?.estado;
      },
      listener: (context, state) {
        _formController.cargarContextoPatrullaje(state.patrullaje);
      },
      child: AnimatedBuilder(
        animation: _formController,
        builder: (context, _) {
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
                    // STEP 1
                    ContextoGeneralidadesStep(
                      formKey: _formKeys[0],
                      controller: _formController,
                      patrullajeActivo: _formController.patrullajeActivo,
                      isLoadingPatrullaje: context
                          .watch<HomeBloc>()
                          .state
                          .isLoading,
                      onReloadPatrullaje: () {
                        context.read<HomeBloc>().add(
                          const LoadPatrullajeActivo(),
                        );
                      },
                      onReloadIncidentes: _seleccionarIncidencia,
                    ),

                    // STEP 2
                    AtencionUbicacionStep(
                      formKey: _formKeys[1],
                      controller: _formController,
                    ),

                    // STEP 3
                    PersonasInvolucradasStep(
                      formKey: _formKeys[2],
                      controller: _formController,
                    ),

                    // STEP 4
                    IntervencionStep(
                      formKey: _formKeys[3],
                      controller: _formController,
                    ),

                    // STEP 5
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

  Future<void> _seleccionarIncidencia() async {
    /*
     * Aquí se abrirá el selector conectado al BLoC
     * de incidencias.
     */
  }

  String _formatDate(DateTime value) {
    return '${value.year.toString().padLeft(4, '0')}-'
        '${value.month.toString().padLeft(2, '0')}-'
        '${value.day.toString().padLeft(2, '0')}';
  }

  String _formatTime(TimeOfDay value) {
    return '${value.hour.toString().padLeft(2, '0')}:'
        '${value.minute.toString().padLeft(2, '0')}';
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(behavior: SnackBarBehavior.floating, content: Text(message)),
      );
  }
}
