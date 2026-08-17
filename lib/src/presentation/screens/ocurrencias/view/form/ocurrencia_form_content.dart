import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';

// BloC
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_state.dart';

class OcurrenciaFormContent extends StatefulWidget {
  const OcurrenciaFormContent({super.key});

  @override
  State<OcurrenciaFormContent> createState() => _OcurrenciaFormContentState();
}

class _OcurrenciaFormContentState extends State<OcurrenciaFormContent> {
  static const int _totalSteps = 5;

  final _stepKeys = List.generate(_totalSteps, (_) => GlobalKey<FormState>());

  int _currentStep = 0;

  // ==========================================================
  // IDENTIFICACIÓN Y CONTEXTO
  // ==========================================================
  late final TextEditingController _uuidController;
  final _codigoController = TextEditingController();
  final _incidenciaIdController = TextEditingController();
  final _patrullajeIdController = TextEditingController();
  final _zonaIdController = TextEditingController();
  final _unidadIdController = TextEditingController();
  final _origenOtroController = TextEditingController();
  final _placaVehiculoController = TextEditingController();
  final _tipoVehiculoOtroController = TextEditingController();

  String _origen = 'PATRULLAJE';
  String _modalidadPatrullaje = 'MUNICIPAL';
  String _tipoPatrullaje = 'A_PIE';
  String _turno = 'MAÑANA';
  String? _tipoVehiculo;

  // ==========================================================
  // FECHA, HORAS Y UBICACIÓN
  // ==========================================================
  final _fechaController = TextEditingController();
  final _horaAlertaController = TextEditingController();
  final _horaLlegadaController = TextEditingController();
  final _horaRepliegueController = TextEditingController();

  final _direccionController = TextEditingController();
  final _referenciaController = TextEditingController();
  final _manzanaController = TextEditingController();
  final _loteController = TextEditingController();
  final _nombreZonaController = TextEditingController();
  final _sectorController = TextEditingController();
  final _ubigeoController = TextEditingController();
  final _latitudController = TextEditingController();
  final _longitudController = TextEditingController();
  final _datosImportantesController = TextEditingController();

  String _resultado = 'NO_CONSUMADO';
  String _relacionVictimaVictimario = 'NO_APLICA';
  String _tipoLugar = 'VIA_PUBLICA';
  String? _tipoVia;
  String? _tipoZona;

  // ==========================================================
  // LISTAS DINÁMICAS
  // ==========================================================
  final List<CreateOcurrenciaPersonaRequest> _personas = [];
  final List<CreateOcurrenciaConsecuenciaRequest> _consecuencias = [];
  final List<CreateOcurrenciaMedioEmpleadoRequest> _mediosEmpleados = [];
  final List<CreateOcurrenciaEfectivoPnpRequest> _efectivosPnp = [];

  @override
  void initState() {
    super.initState();

    _uuidController = TextEditingController(text: const Uuid().v4());

    final now = DateTime.now();
    _fechaController.text = _formatDateRequest(now);
    _horaAlertaController.text = _formatTimeRequest(
      TimeOfDay.fromDateTime(now),
    );
  }

  @override
  void dispose() {
    _uuidController.dispose();
    _codigoController.dispose();
    _incidenciaIdController.dispose();
    _patrullajeIdController.dispose();
    _zonaIdController.dispose();
    _unidadIdController.dispose();
    _origenOtroController.dispose();
    _placaVehiculoController.dispose();
    _tipoVehiculoOtroController.dispose();

    _fechaController.dispose();
    _horaAlertaController.dispose();
    _horaLlegadaController.dispose();
    _horaRepliegueController.dispose();

    _direccionController.dispose();
    _referenciaController.dispose();
    _manzanaController.dispose();
    _loteController.dispose();
    _nombreZonaController.dispose();
    _sectorController.dispose();
    _ubigeoController.dispose();
    _latitudController.dispose();
    _longitudController.dispose();
    _datosImportantesController.dispose();

    super.dispose();
  }

  bool get _isLastStep => _currentStep == _totalSteps - 1;

  bool get _isMotorized {
    return _tipoPatrullaje == 'MOTORIZADO';
  }

  // ==========================================================
  // NAVEGACIÓN
  // ==========================================================
  void _nextStep() {
    final form = _stepKeys[_currentStep].currentState;

    if (form != null && !form.validate()) {
      return;
    }

    if (_currentStep == 2 && _personas.isEmpty) {
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
    if (step < 0 || step >= _totalSteps) return;

    // Solo permite regresar libremente.
    if (step <= _currentStep) {
      setState(() {
        _currentStep = step;
      });
    }
  }

  // ==========================================================
  // REGISTRAR
  // ==========================================================

  void _submit() {
    final isLoading = context.read<OcurrenciaBloc>().state.isCreating;

    if (isLoading) return;

    for (final formKey in _stepKeys) {
      if (formKey.currentState?.validate() == false) {
        _showMessage('Revisa los campos obligatorios del formulario.');
        return;
      }
    }

    final request = CreateOcurrenciaRequest(
      uuidCliente: _uuidController.text.trim(),
      codigoOcurrencia: _codigoController.text.trim(),
      incidenciaId: _parseInt(_incidenciaIdController.text),
      patrullajeId: _parseInt(_patrullajeIdController.text),
      zonaId: _parseInt(_zonaIdController.text),
      unidadId: _parseInt(_unidadIdController.text),
      origen: _origen,
      origenOtro: _origen == 'OTRO'
          ? _nullIfEmpty(_origenOtroController.text)
          : null,
      modalidadPatrullaje: _modalidadPatrullaje,
      tipoPatrullaje: _tipoPatrullaje,
      turno: _turno,
      placaVehiculo: _isMotorized
          ? _nullIfEmpty(_placaVehiculoController.text)
          : null,
      tipoVehiculo: _isMotorized ? _tipoVehiculo : null,
      tipoVehiculoOtro: _isMotorized && _tipoVehiculo == 'OTRO'
          ? _nullIfEmpty(_tipoVehiculoOtroController.text)
          : null,
      fechaOcurrencia: _fechaController.text.trim(),
      horaAlerta: _nullIfEmpty(_horaAlertaController.text),
      horaLlegada: _nullIfEmpty(_horaLlegadaController.text),
      horaRepliegue: _nullIfEmpty(_horaRepliegueController.text),
      resultado: _resultado,
      relacionVictimaVictimario: _relacionVictimaVictimario,
      tipoLugar: _tipoLugar,
      tipoVia: _tipoVia,
      direccion: _nullIfEmpty(_direccionController.text),
      referencia: _nullIfEmpty(_referenciaController.text),
      manzana: _nullIfEmpty(_manzanaController.text),
      lote: _nullIfEmpty(_loteController.text),
      tipoZona: _tipoZona,
      nombreZona: _nullIfEmpty(_nombreZonaController.text),
      sectorPatrullaje: _nullIfEmpty(_sectorController.text),
      ubigeo: _nullIfEmpty(_ubigeoController.text),
      latitud: double.tryParse(_latitudController.text.trim()),
      longitud: double.tryParse(_longitudController.text.trim()),
      datosImportantes: _nullIfEmpty(_datosImportantesController.text),
      personas: List.unmodifiable(_personas),
      consecuencias: List.unmodifiable(_consecuencias),
      mediosEmpleados: List.unmodifiable(_mediosEmpleados),
      efectivosPnp: List.unmodifiable(_efectivosPnp),
    );

    context.read<OcurrenciaBloc>().add(CreateOcurrencia(request: request));
  }

  // ==========================================================
  // BUILD
  // ==========================================================
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _OcurrenciaStepHeader(
          currentStep: _currentStep,
          totalSteps: _totalSteps,
          onStepPressed: _goToStep,
        ),
        Expanded(
          child: IndexedStack(
            index: _currentStep,
            children: [
              _buildContextStep(),
              _buildLocationStep(),
              _buildPersonsStep(),
              _buildResourcesStep(),
              _buildReviewStep(),
            ],
          ),
        ),
        _buildNavigation(),
      ],
    );
  }

  Widget _buildNavigation() {
    return BlocBuilder<OcurrenciaBloc, OcurrenciaState>(
      buildWhen: (previous, current) {
        return previous.createResponse != current.createResponse;
      },
      builder: (context, state) {
        final isCreating = state.isCreating;

        return Material(
          elevation: 10,
          color: Theme.of(context).colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
              child: Row(
                children: [
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: isCreating ? null : _previousStep,
                        icon: const Icon(Icons.arrow_back_rounded),
                        label: const Text('Anterior'),
                      ),
                    ),
                  if (_currentStep > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: FilledButton.icon(
                      onPressed: isCreating ? null : _nextStep,
                      icon: isCreating
                          ? const SizedBox(
                              width: 19,
                              height: 19,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : Icon(
                              _isLastStep
                                  ? Icons.save_outlined
                                  : Icons.arrow_forward_rounded,
                            ),
                      label: Text(
                        isCreating
                            ? 'Guardando...'
                            : _isLastStep
                            ? 'Guardar borrador'
                            : 'Continuar',
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // ==========================================================
  // PASO 1: CONTEXTO
  // ==========================================================
  Widget _buildContextStep() {
    return Form(
      key: _stepKeys[0],
      child: _StepScrollView(
        title: 'Clasificación y contexto',
        description:
            'Identifica el tipo de ocurrencia y el contexto operativo.',
        children: [
          TextFormField(
            controller: _codigoController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            decoration: const InputDecoration(
              labelText: 'Código de ocurrencia *',
              hintText: 'Ejemplo: 030103',
              prefixIcon: Icon(Icons.category_outlined),
              border: OutlineInputBorder(),
            ),
            validator: (value) {
              final code = value?.trim() ?? '';

              if (code.isEmpty) {
                return 'Ingresa el código de ocurrencia.';
              }

              if (!RegExp(r'^\d{6}$').hasMatch(code)) {
                return 'El código debe tener 6 dígitos.';
              }

              return null;
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _uuidController,
            readOnly: true,
            decoration: const InputDecoration(
              labelText: 'UUID de sincronización',
              prefixIcon: Icon(Icons.fingerprint_rounded),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          _twoColumns(
            TextFormField(
              controller: _incidenciaIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID incidencia',
                prefixIcon: Icon(Icons.report_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: _patrullajeIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID patrullaje',
                prefixIcon: Icon(Icons.route_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _twoColumns(
            TextFormField(
              controller: _zonaIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID zona',
                prefixIcon: Icon(Icons.map_outlined),
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: _unidadIdController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'ID unidad',
                prefixIcon: Icon(Icons.directions_car_outlined),
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _origen,
            decoration: const InputDecoration(
              labelText: 'Origen *',
              prefixIcon: Icon(Icons.source_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'PATRULLAJE', child: Text('Patrullaje')),
              DropdownMenuItem(value: 'INCIDENCIA', child: Text('Incidencia')),
              DropdownMenuItem(value: 'CENTRAL', child: Text('Central')),
              DropdownMenuItem(value: 'CIUDADANO', child: Text('Ciudadano')),
              DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _origen = value;
              });
            },
          ),
          if (_origen == 'OTRO') ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _origenOtroController,
              decoration: const InputDecoration(
                labelText: 'Especifique el origen *',
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_origen == 'OTRO' &&
                    (value == null || value.trim().isEmpty)) {
                  return 'Especifica el origen.';
                }

                return null;
              },
            ),
          ],
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _modalidadPatrullaje,
            decoration: const InputDecoration(
              labelText: 'Modalidad de patrullaje *',
              prefixIcon: Icon(Icons.groups_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'MUNICIPAL', child: Text('Municipal')),
              DropdownMenuItem(value: 'INTEGRADO', child: Text('Integrado')),
              DropdownMenuItem(value: 'MIXTO', child: Text('Mixto')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _modalidadPatrullaje = value;
              });
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _tipoPatrullaje,
            decoration: const InputDecoration(
              labelText: 'Tipo de patrullaje *',
              prefixIcon: Icon(Icons.directions_walk_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'A_PIE', child: Text('A pie')),
              DropdownMenuItem(value: 'MOTORIZADO', child: Text('Motorizado')),
              DropdownMenuItem(value: 'BICICLETA', child: Text('Bicicleta')),
              DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _tipoPatrullaje = value;
              });
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _turno,
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
              if (value == null) return;

              setState(() {
                _turno = value;
              });
            },
          ),
          if (_isMotorized) ...[
            const SizedBox(height: 14),
            TextFormField(
              controller: _placaVehiculoController,
              textCapitalization: TextCapitalization.characters,
              decoration: const InputDecoration(
                labelText: 'Placa del vehículo *',
                hintText: 'EUA-123',
                prefixIcon: Icon(Icons.pin_outlined),
                border: OutlineInputBorder(),
              ),
              validator: (value) {
                if (_isMotorized && (value == null || value.trim().isEmpty)) {
                  return 'Ingresa la placa.';
                }

                return null;
              },
            ),
            const SizedBox(height: 14),
            DropdownButtonFormField<String>(
              initialValue: _tipoVehiculo,
              decoration: const InputDecoration(
                labelText: 'Tipo de vehículo *',
                prefixIcon: Icon(Icons.local_police_outlined),
                border: OutlineInputBorder(),
              ),
              items: const [
                DropdownMenuItem(
                  value: 'CAMIONETA_DOBLE_CABINA',
                  child: Text('Camioneta de doble cabina'),
                ),
                DropdownMenuItem(value: 'AUTOMOVIL', child: Text('Automóvil')),
                DropdownMenuItem(
                  value: 'MOTOCICLETA',
                  child: Text('Motocicleta'),
                ),
                DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
              ],
              validator: (value) {
                if (_isMotorized && value == null) {
                  return 'Selecciona el tipo de vehículo.';
                }

                return null;
              },
              onChanged: (value) {
                setState(() {
                  _tipoVehiculo = value;
                });
              },
            ),
            if (_tipoVehiculo == 'OTRO') ...[
              const SizedBox(height: 14),
              TextFormField(
                controller: _tipoVehiculoOtroController,
                decoration: const InputDecoration(
                  labelText: 'Especifique el vehículo *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (_tipoVehiculo == 'OTRO' &&
                      (value == null || value.trim().isEmpty)) {
                    return 'Especifica el vehículo.';
                  }

                  return null;
                },
              ),
            ],
          ],
        ],
      ),
    );
  }

  // ==========================================================
  // PASO 2: UBICACIÓN Y ATENCIÓN
  // ==========================================================
  Widget _buildLocationStep() {
    return Form(
      key: _stepKeys[1],
      child: _StepScrollView(
        title: 'Atención y ubicación',
        description: 'Registra cuándo ocurrió el hecho y dónde fue atendido.',
        children: [
          TextFormField(
            controller: _fechaController,
            readOnly: true,
            onTap: () => _selectDate(_fechaController),
            decoration: const InputDecoration(
              labelText: 'Fecha de ocurrencia *',
              prefixIcon: Icon(Icons.calendar_today_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 14),
          _twoColumns(
            _TimeField(
              controller: _horaAlertaController,
              label: 'Hora de alerta',
            ),
            _TimeField(
              controller: _horaLlegadaController,
              label: 'Hora de llegada',
            ),
          ),
          const SizedBox(height: 14),
          _TimeField(
            controller: _horaRepliegueController,
            label: 'Hora de repliegue',
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _resultado,
            decoration: const InputDecoration(
              labelText: 'Resultado *',
              prefixIcon: Icon(Icons.fact_check_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'CONSUMADO', child: Text('Consumado')),
              DropdownMenuItem(
                value: 'NO_CONSUMADO',
                child: Text('No consumado'),
              ),
              DropdownMenuItem(value: 'TENTATIVA', child: Text('Tentativa')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _resultado = value;
              });
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _relacionVictimaVictimario,
            decoration: const InputDecoration(
              labelText: 'Relación víctima-victimario',
              prefixIcon: Icon(Icons.people_outline),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'NO_APLICA', child: Text('No aplica')),
              DropdownMenuItem(value: 'CONOCIDO', child: Text('Conocido')),
              DropdownMenuItem(
                value: 'DESCONOCIDO',
                child: Text('Desconocido'),
              ),
              DropdownMenuItem(value: 'FAMILIAR', child: Text('Familiar')),
              DropdownMenuItem(value: 'PAREJA', child: Text('Pareja')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _relacionVictimaVictimario = value;
              });
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _tipoLugar,
            decoration: const InputDecoration(
              labelText: 'Tipo de lugar *',
              prefixIcon: Icon(Icons.place_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'VIA_PUBLICA',
                child: Text('Vía pública'),
              ),
              DropdownMenuItem(value: 'DOMICILIO', child: Text('Domicilio')),
              DropdownMenuItem(
                value: 'LOCAL_COMERCIAL',
                child: Text('Local comercial'),
              ),
              DropdownMenuItem(
                value: 'ESPACIO_PUBLICO',
                child: Text('Espacio público'),
              ),
              DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                _tipoLugar = value;
              });
            },
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _tipoVia,
            decoration: const InputDecoration(
              labelText: 'Tipo de vía',
              prefixIcon: Icon(Icons.add_road_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(value: 'AVENIDA', child: Text('Avenida')),
              DropdownMenuItem(value: 'CALLE', child: Text('Calle')),
              DropdownMenuItem(value: 'JIRON', child: Text('Jirón')),
              DropdownMenuItem(value: 'PASAJE', child: Text('Pasaje')),
              DropdownMenuItem(value: 'CARRETERA', child: Text('Carretera')),
            ],
            onChanged: (value) {
              setState(() {
                _tipoVia = value;
              });
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _direccionController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: 'Dirección *',
              prefixIcon: Icon(Icons.location_on_outlined),
              border: OutlineInputBorder(),
            ),
            validator: _requiredValidator,
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _referenciaController,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Referencia',
              prefixIcon: Icon(Icons.near_me_outlined),
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          _twoColumns(
            TextFormField(
              controller: _manzanaController,
              decoration: const InputDecoration(
                labelText: 'Manzana',
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: _loteController,
              decoration: const InputDecoration(
                labelText: 'Lote',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          DropdownButtonFormField<String>(
            initialValue: _tipoZona,
            decoration: const InputDecoration(
              labelText: 'Tipo de zona',
              prefixIcon: Icon(Icons.map_outlined),
              border: OutlineInputBorder(),
            ),
            items: const [
              DropdownMenuItem(
                value: 'URBANIZACION',
                child: Text('Urbanización'),
              ),
              DropdownMenuItem(value: 'ASOCIACION', child: Text('Asociación')),
              DropdownMenuItem(value: 'BARRIO', child: Text('Barrio')),
              DropdownMenuItem(value: 'COMUNIDAD', child: Text('Comunidad')),
              DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
            ],
            onChanged: (value) {
              setState(() {
                _tipoZona = value;
              });
            },
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _nombreZonaController,
            decoration: const InputDecoration(
              labelText: 'Nombre de zona',
              border: OutlineInputBorder(),
            ),
          ),
          const SizedBox(height: 14),
          _twoColumns(
            TextFormField(
              controller: _sectorController,
              decoration: const InputDecoration(
                labelText: 'Sector',
                border: OutlineInputBorder(),
              ),
            ),
            TextFormField(
              controller: _ubigeoController,
              keyboardType: TextInputType.number,
              maxLength: 6,
              decoration: const InputDecoration(
                labelText: 'Ubigeo',
                counterText: '',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(height: 14),
          _twoColumns(
            TextFormField(
              controller: _latitudController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Latitud *',
                hintText: '-13.53195',
                border: OutlineInputBorder(),
              ),
              validator: _coordinateValidator,
            ),
            TextFormField(
              controller: _longitudController,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
                signed: true,
              ),
              decoration: const InputDecoration(
                labelText: 'Longitud *',
                hintText: '-71.96746',
                border: OutlineInputBorder(),
              ),
              validator: _coordinateValidator,
            ),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _datosImportantesController,
            minLines: 4,
            maxLines: 7,
            textCapitalization: TextCapitalization.sentences,
            decoration: const InputDecoration(
              labelText: 'Datos importantes',
              alignLabelWithHint: true,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // PASO 3: PERSONAS
  // ==========================================================
  Widget _buildPersonsStep() {
    return Form(
      key: _stepKeys[2],
      child: _StepScrollView(
        title: 'Personas involucradas',
        description:
            'Registra víctimas, autores, conductores u otras personas.',
        children: [
          FilledButton.tonalIcon(
            onPressed: _addPersona,
            icon: const Icon(Icons.person_add_outlined),
            label: const Text('Agregar persona'),
          ),
          const SizedBox(height: 14),
          if (_personas.isEmpty)
            const _EmptySection(
              icon: Icons.groups_outlined,
              message: 'Todavía no registraste personas involucradas.',
            )
          else
            ..._personas.asMap().entries.map(
              (entry) => _RemovableItemCard(
                title:
                    '${entry.value.tipoPersona} · ${entry.value.nombresApellidos ?? "No identificado"}',
                subtitle: entry.value.documentoIdentidad ?? 'Sin documento',
                icon: Icons.person_outline,
                onDelete: () {
                  setState(() {
                    _personas.removeAt(entry.key);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // PASO 4: RECURSOS
  // ==========================================================
  Widget _buildResourcesStep() {
    return Form(
      key: _stepKeys[3],
      child: _StepScrollView(
        title: 'Resultados e intervención',
        description:
            'Registra consecuencias, medios empleados y participación PNP.',
        children: [
          _SectionHeader(title: 'Consecuencias', onAdd: _addConsecuencia),
          if (_consecuencias.isEmpty)
            const _EmptySection(
              icon: Icons.warning_amber_outlined,
              message: 'No hay consecuencias registradas.',
            )
          else
            ..._consecuencias.asMap().entries.map(
              (entry) => _RemovableItemCard(
                title: entry.value.tipo,
                subtitle: entry.value.descripcion ?? '',
                icon: Icons.warning_amber_outlined,
                onDelete: () {
                  setState(() {
                    _consecuencias.removeAt(entry.key);
                  });
                },
              ),
            ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Medios empleados', onAdd: _addMedio),
          if (_mediosEmpleados.isEmpty)
            const _EmptySection(
              icon: Icons.build_outlined,
              message: 'No hay medios empleados registrados.',
            )
          else
            ..._mediosEmpleados.asMap().entries.map(
              (entry) => _RemovableItemCard(
                title: entry.value.tipo,
                subtitle: entry.value.descripcion ?? '',
                icon: Icons.build_outlined,
                onDelete: () {
                  setState(() {
                    _mediosEmpleados.removeAt(entry.key);
                  });
                },
              ),
            ),
          const SizedBox(height: 20),
          _SectionHeader(title: 'Efectivos PNP', onAdd: _addEfectivoPnp),
          if (_efectivosPnp.isEmpty)
            const _EmptySection(
              icon: Icons.local_police_outlined,
              message: 'No hay efectivos PNP registrados.',
            )
          else
            ..._efectivosPnp.asMap().entries.map(
              (entry) => _RemovableItemCard(
                title: 'Policía ID: ${entry.value.policiaId ?? "Manual"}',
                subtitle: entry.value.tipoParticipacion,
                icon: Icons.local_police_outlined,
                onDelete: () {
                  setState(() {
                    _efectivosPnp.removeAt(entry.key);
                  });
                },
              ),
            ),
        ],
      ),
    );
  }

  // ==========================================================
  // PASO 5: REVISIÓN
  // ==========================================================
  Widget _buildReviewStep() {
    return Form(
      key: _stepKeys[4],
      child: _StepScrollView(
        title: 'Revisión',
        description: 'Verifica la información antes de guardar la ocurrencia.',
        children: [
          _ReviewSection(
            title: 'Clasificación',
            step: 0,
            onEdit: _goToStep,
            rows: {
              'Código': _codigoController.text,
              'Origen': _formatEnum(_origen),
              'Modalidad': _formatEnum(_modalidadPatrullaje),
              'Patrullaje': _formatEnum(_tipoPatrullaje),
              'Turno': _formatEnum(_turno),
            },
          ),
          const SizedBox(height: 14),
          _ReviewSection(
            title: 'Atención y ubicación',
            step: 1,
            onEdit: _goToStep,
            rows: {
              'Fecha': _fechaController.text,
              'Hora de alerta': _horaAlertaController.text,
              'Resultado': _formatEnum(_resultado),
              'Dirección': _direccionController.text,
              'Coordenadas':
                  '${_latitudController.text}, ${_longitudController.text}',
            },
          ),
          const SizedBox(height: 14),
          _ReviewSection(
            title: 'Personas',
            step: 2,
            onEdit: _goToStep,
            rows: {'Registradas': '${_personas.length}'},
          ),
          const SizedBox(height: 14),
          _ReviewSection(
            title: 'Intervención',
            step: 3,
            onEdit: _goToStep,
            rows: {
              'Consecuencias': '${_consecuencias.length}',
              'Medios empleados': '${_mediosEmpleados.length}',
              'Efectivos PNP': '${_efectivosPnp.length}',
            },
          ),
          const SizedBox(height: 18),
          Card(
            elevation: 0,
            color: Theme.of(context).colorScheme.primaryContainer,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Theme.of(context).colorScheme.onPrimaryContainer,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'La ocurrencia será guardada inicialmente '
                      'con estado BORRADOR. Posteriormente podrá '
                      'ser revisada y enviada para validación.',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.onPrimaryContainer,
                      ),
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

  // ==========================================================
  // DIÁLOGOS DINÁMICOS
  // ==========================================================
  Future<void> _addPersona() async {
    final result = await showDialog<CreateOcurrenciaPersonaRequest>(
      context: context,
      builder: (_) => _PersonaDialog(orden: _personas.length + 1),
    );

    if (result == null) return;

    setState(() {
      _personas.add(result);
    });
  }

  Future<void> _addConsecuencia() async {
    final result = await _showTypeDescriptionDialog(
      title: 'Agregar consecuencia',
      types: const ['PERSONALES', 'MATERIALES', 'AMBIENTALES', 'OTRO'],
    );

    if (result == null) return;

    setState(() {
      _consecuencias.add(
        CreateOcurrenciaConsecuenciaRequest(
          tipo: result.$1,
          descripcion: result.$2,
        ),
      );
    });
  }

  Future<void> _addMedio() async {
    final result = await _showTypeDescriptionDialog(
      title: 'Agregar medio empleado',
      types: const ['VEHICULO', 'ARMA', 'HERRAMIENTA', 'EQUIPO', 'OTRO'],
    );

    if (result == null) return;

    setState(() {
      _mediosEmpleados.add(
        CreateOcurrenciaMedioEmpleadoRequest(
          tipo: result.$1,
          descripcion: result.$2,
        ),
      );
    });
  }

  Future<void> _addEfectivoPnp() async {
    final result = await showDialog<CreateOcurrenciaEfectivoPnpRequest>(
      context: context,
      builder: (_) => const _EfectivoPnpDialog(),
    );

    if (result == null) return;

    setState(() {
      _efectivosPnp.add(result);
    });
  }

  Future<(String, String?)?> _showTypeDescriptionDialog({
    required String title,
    required List<String> types,
  }) async {
    return showDialog<(String, String?)>(
      context: context,
      builder: (_) => _TypeDescriptionDialog(title: title, types: types),
    );
  }

  // ==========================================================
  // HELPERS
  // ==========================================================
  Widget _twoColumns(Widget first, Widget second) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth < 520) {
          return Column(children: [first, const SizedBox(height: 14), second]);
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: first),
            const SizedBox(width: 14),
            Expanded(child: second),
          ],
        );
      },
    );
  }

  Future<void> _selectDate(TextEditingController controller) async {
    final initialDate = DateTime.tryParse(controller.text) ?? DateTime.now();

    final selected = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );

    if (selected != null) {
      controller.text = _formatDateRequest(selected);
    }
  }

  String? _requiredValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Este campo es obligatorio.';
    }

    return null;
  }

  String? _coordinateValidator(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Campo obligatorio.';
    }

    if (double.tryParse(value.trim()) == null) {
      return 'Coordenada inválida.';
    }

    return null;
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }
}

class _OcurrenciaStepHeader extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final ValueChanged<int> onStepPressed;

  const _OcurrenciaStepHeader({
    required this.currentStep,
    required this.totalSteps,
    required this.onStepPressed,
  });

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Material(
      color: colors.surface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 14),
        child: Column(
          children: [
            Row(
              children: List.generate(totalSteps, (index) {
                final selected = index == currentStep;
                final completed = index < currentStep;

                return Expanded(
                  child: InkWell(
                    onTap: index <= currentStep
                        ? () => onStepPressed(index)
                        : null,
                    child: Container(
                      height: 6,
                      margin: EdgeInsets.only(
                        right: index < totalSteps - 1 ? 6 : 0,
                      ),
                      decoration: BoxDecoration(
                        color: selected || completed
                            ? colors.primary
                            : colors.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Text(
                  'Paso ${currentStep + 1} de $totalSteps',
                  style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    color: colors.primary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const Spacer(),
                Text(
                  '${((currentStep + 1) / totalSteps * 100).round()}%',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _StepScrollView extends StatelessWidget {
  final String title;
  final String description;
  final List<Widget> children;

  const _StepScrollView({
    required this.title,
    required this.description,
    required this.children,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(18, 20, 18, 110),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 760),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                description,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 22),
              ...children,
            ],
          ),
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback onAdd;

  const _SectionHeader({required this.title, required this.onAdd});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
        ),
        IconButton.filledTonal(
          onPressed: onAdd,
          icon: const Icon(Icons.add_rounded),
        ),
      ],
    );
  }
}

class _EmptySection extends StatelessWidget {
  final IconData icon;
  final String message;

  const _EmptySection({required this.icon, required this.message});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          Icon(icon, size: 42),
          const SizedBox(height: 10),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    );
  }
}

class _RemovableItemCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback onDelete;

  const _RemovableItemCard({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: ListTile(
        leading: CircleAvatar(child: Icon(icon)),
        title: Text(title),
        subtitle: subtitle.isEmpty ? null : Text(subtitle),
        trailing: IconButton(
          tooltip: 'Eliminar',
          onPressed: onDelete,
          icon: Icon(
            Icons.delete_outline,
            color: Theme.of(context).colorScheme.error,
          ),
        ),
      ),
    );
  }
}

class _ReviewSection extends StatelessWidget {
  final String title;
  final int step;
  final Map<String, String> rows;
  final ValueChanged<int> onEdit;

  const _ReviewSection({
    required this.title,
    required this.step,
    required this.rows,
    required this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                TextButton.icon(
                  onPressed: () => onEdit(step),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Editar'),
                ),
              ],
            ),
            const Divider(),
            ...rows.entries.map(
              (entry) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 120,
                      child: Text(
                        entry.key,
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    Expanded(
                      child: Text(
                        entry.value.trim().isEmpty
                            ? 'No registrado'
                            : entry.value,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _TimeField extends StatelessWidget {
  final TextEditingController controller;
  final String label;

  const _TimeField({required this.controller, required this.label});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      readOnly: true,
      onTap: () async {
        final selected = await showTimePicker(
          context: context,
          initialTime: TimeOfDay.now(),
        );

        if (selected != null) {
          controller.text = _formatTimeRequest(selected);
        }
      },
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: const Icon(Icons.schedule_outlined),
        suffixIcon: controller.text.isNotEmpty
            ? IconButton(
                onPressed: controller.clear,
                icon: const Icon(Icons.close_rounded),
              )
            : null,
        border: const OutlineInputBorder(),
      ),
    );
  }
}

class _PersonaDialog extends StatefulWidget {
  final int orden;

  const _PersonaDialog({required this.orden});

  @override
  State<_PersonaDialog> createState() => _PersonaDialogState();
}

class _PersonaDialogState extends State<_PersonaDialog> {
  final _formKey = GlobalKey<FormState>();

  final _documentoController = TextEditingController();
  final _nombreController = TextEditingController();
  final _edadController = TextEditingController();
  final _placaController = TextEditingController();
  final _caracteristicasController = TextEditingController();
  final _observacionController = TextEditingController();

  String _tipoPersona = 'VICTIMA';
  String? _genero;
  bool _identificado = true;
  bool _edadAproximada = false;
  bool _esComunidad = false;

  @override
  void dispose() {
    _documentoController.dispose();
    _nombreController.dispose();
    _edadController.dispose();
    _placaController.dispose();
    _caracteristicasController.dispose();
    _observacionController.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;

    Navigator.of(context).pop(
      CreateOcurrenciaPersonaRequest(
        orden: widget.orden,
        tipoPersona: _tipoPersona,
        identificado: _identificado,
        documentoIdentidad: _nullIfEmpty(_documentoController.text),
        nombresApellidos: _nullIfEmpty(_nombreController.text),
        genero: _genero,
        edad: int.tryParse(_edadController.text),
        edadEsAproximada: _edadAproximada,
        placa: _nullIfEmpty(_placaController.text),
        caracteristicasFisicas: _nullIfEmpty(_caracteristicasController.text),
        esComunidad: _esComunidad,
        fuenteDatos: 'DIRECTA',
        observacion: _nullIfEmpty(_observacionController.text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar persona'),
      content: SizedBox(
        width: 520,
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            child: Column(
              children: [
                DropdownButtonFormField<String>(
                  initialValue: _tipoPersona,
                  decoration: const InputDecoration(
                    labelText: 'Tipo de persona',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(value: 'VICTIMA', child: Text('Víctima')),
                    DropdownMenuItem(value: 'AUTOR', child: Text('Autor')),
                    DropdownMenuItem(
                      value: 'CONDUCTOR',
                      child: Text('Conductor'),
                    ),
                    DropdownMenuItem(value: 'TESTIGO', child: Text('Testigo')),
                    DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
                  ],
                  onChanged: (value) {
                    if (value != null) {
                      setState(() {
                        _tipoPersona = value;
                      });
                    }
                  },
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Persona identificada'),
                  value: _identificado,
                  onChanged: (value) {
                    setState(() {
                      _identificado = value;
                    });
                  },
                ),
                if (_identificado) ...[
                  TextFormField(
                    controller: _documentoController,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(
                      labelText: 'Documento de identidad',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nombreController,
                    textCapitalization: TextCapitalization.words,
                    decoration: const InputDecoration(
                      labelText: 'Nombres y apellidos *',
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (_identificado &&
                          (value == null || value.trim().isEmpty)) {
                        return 'Ingresa los nombres.';
                      }

                      return null;
                    },
                  ),
                ],
                const SizedBox(height: 12),
                DropdownButtonFormField<String>(
                  initialValue: _genero,
                  decoration: const InputDecoration(
                    labelText: 'Género',
                    border: OutlineInputBorder(),
                  ),
                  items: const [
                    DropdownMenuItem(
                      value: 'MASCULINO',
                      child: Text('Masculino'),
                    ),
                    DropdownMenuItem(
                      value: 'FEMENINO',
                      child: Text('Femenino'),
                    ),
                    DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _genero = value;
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _edadController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Edad',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Edad aproximada'),
                  value: _edadAproximada,
                  onChanged: (value) {
                    setState(() {
                      _edadAproximada = value;
                    });
                  },
                ),
                TextFormField(
                  controller: _placaController,
                  textCapitalization: TextCapitalization.characters,
                  decoration: const InputDecoration(
                    labelText: 'Placa relacionada',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _caracteristicasController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Características físicas',
                    border: OutlineInputBorder(),
                  ),
                ),
                SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Representa una comunidad'),
                  value: _esComunidad,
                  onChanged: (value) {
                    setState(() {
                      _esComunidad = value;
                    });
                  },
                ),
                TextFormField(
                  controller: _observacionController,
                  minLines: 2,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Observación',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        FilledButton(onPressed: _save, child: const Text('Agregar')),
      ],
    );
  }
}

class _TypeDescriptionDialog extends StatefulWidget {
  final String title;
  final List<String> types;

  const _TypeDescriptionDialog({required this.title, required this.types});

  @override
  State<_TypeDescriptionDialog> createState() => _TypeDescriptionDialogState();
}

class _TypeDescriptionDialogState extends State<_TypeDescriptionDialog> {
  final _descriptionController = TextEditingController();
  late String _type;

  @override
  void initState() {
    super.initState();
    _type = widget.types.first;
  }

  @override
  void dispose() {
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DropdownButtonFormField<String>(
              initialValue: _type,
              decoration: const InputDecoration(
                labelText: 'Tipo',
                border: OutlineInputBorder(),
              ),
              items: widget.types
                  .map(
                    (type) => DropdownMenuItem(
                      value: type,
                      child: Text(_formatEnum(type)),
                    ),
                  )
                  .toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    _type = value;
                  });
                }
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descriptionController,
              minLines: 3,
              maxLines: 5,
              decoration: const InputDecoration(
                labelText: 'Descripción',
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            Navigator.of(
              context,
            ).pop((_type, _nullIfEmpty(_descriptionController.text)));
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

class _EfectivoPnpDialog extends StatefulWidget {
  const _EfectivoPnpDialog();

  @override
  State<_EfectivoPnpDialog> createState() => _EfectivoPnpDialogState();
}

class _EfectivoPnpDialogState extends State<_EfectivoPnpDialog> {
  final _formKey = GlobalKey<FormState>();
  final _policiaIdController = TextEditingController();

  String _participacion = 'PATRULLAJE_INTEGRADO';

  @override
  void dispose() {
    _policiaIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Agregar efectivo PNP'),
      content: SizedBox(
        width: 440,
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _policiaIdController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'ID del policía *',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  final id = int.tryParse(value ?? '');

                  if (id == null || id <= 0) {
                    return 'Ingresa un ID válido.';
                  }

                  return null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: _participacion,
                decoration: const InputDecoration(
                  labelText: 'Tipo de participación',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'PATRULLAJE_INTEGRADO',
                    child: Text('Patrullaje integrado'),
                  ),
                  DropdownMenuItem(value: 'APOYO', child: Text('Apoyo')),
                  DropdownMenuItem(
                    value: 'INTERVENCION',
                    child: Text('Intervención'),
                  ),
                  DropdownMenuItem(value: 'OTRO', child: Text('Otro')),
                ],
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _participacion = value;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(context).pop,
          child: const Text('Cancelar'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;

            Navigator.of(context).pop(
              CreateOcurrenciaEfectivoPnpRequest(
                policiaId: int.parse(_policiaIdController.text),
                tipoParticipacion: _participacion,
              ),
            );
          },
          child: const Text('Agregar'),
        ),
      ],
    );
  }
}

int? _parseInt(String value) {
  final result = int.tryParse(value.trim());

  if (result == null || result <= 0) return null;

  return result;
}

String? _nullIfEmpty(String? value) {
  final normalized = value?.trim();

  if (normalized == null || normalized.isEmpty) {
    return null;
  }

  return normalized;
}

String _formatDateRequest(DateTime date) {
  final month = date.month.toString().padLeft(2, '0');
  final day = date.day.toString().padLeft(2, '0');

  return '${date.year}-$month-$day';
}

String _formatTimeRequest(TimeOfDay time) {
  final hour = time.hour.toString().padLeft(2, '0');
  final minute = time.minute.toString().padLeft(2, '0');

  return '$hour:$minute:00';
}

String _formatEnum(String value) {
  return value
      .toLowerCase()
      .split('_')
      .where((word) => word.isNotEmpty)
      .map((word) => '${word[0].toUpperCase()}${word.substring(1)}')
      .join(' ');
}
