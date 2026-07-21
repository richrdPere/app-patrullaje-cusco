import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/incidencia/register_incidencia_req.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';

import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class EmergenciaScreen extends StatefulWidget {
  const EmergenciaScreen({super.key});

  @override
  State<EmergenciaScreen> createState() => _EmergenciaScreenState();
}

class _EmergenciaScreenState extends State<EmergenciaScreen>
    with SingleTickerProviderStateMixin {
  static const Duration _holdDuration = Duration(seconds: 2);

  Timer? _holdTimer;

  late final AnimationController _progressController;

  bool _isHolding = false;
  bool _emergenciaEnviada = false;

  MotivoEmergencia _motivoSeleccionado = MotivoEmergencia.apoyoInmediato;

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: _holdDuration,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final incidenteState = context.read<IncidenteBloc>().state;

      if (!incidenteState.tieneUbicacion && !incidenteState.loadingLocation) {
        context.read<IncidenteBloc>().add(const ObtenerUbicacionEvent());
      }
    });
  }

  @override
  void dispose() {
    _holdTimer?.cancel();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final patrullaje = context.watch<HomeBloc>().state.patrullaje;

    return BlocConsumer<IncidenteBloc, IncidenteState>(
      listenWhen: (previous, current) {
        return previous.createResponse != current.createResponse;
      },
      listener: _onIncidenteStateChanged,
      builder: (context, state) {
        return ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
          children: [
            _buildWarningCard(),

            const SizedBox(height: 20),

            _buildPatrullajeCard(patrullaje),

            const SizedBox(height: 16),

            _buildLocationCard(state),

            const SizedBox(height: 24),

            _buildMotivoSection(disabled: state.isCreating || _isHolding),

            const SizedBox(height: 32),

            _buildSosSection(
              context: context,
              state: state,
              patrullaje: patrullaje,
            ),

            const SizedBox(height: 26),

            _buildInstructions(),

            if (_emergenciaEnviada) ...[
              const SizedBox(height: 20),
              _buildSuccessCard(),
            ],
          ],
        );
      },
    );
  }

  // ======================================================
  // LISTENER
  // ======================================================

  void _onIncidenteStateChanged(BuildContext context, IncidenteState state) {
    final response = state.createResponse;

    if (response is Success<IncidenteModel>) {
      setState(() {
        _emergenciaEnviada = true;
      });

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('La emergencia fue reportada correctamente.'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 4),
          ),
        );

      context.read<IncidenteBloc>().add(const LimpiarAccionIncidenteEvent());

      return;
    }

    if (response is ErrorData<IncidenteModel>) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );

      context.read<IncidenteBloc>().add(const LimpiarAccionIncidenteEvent());
    }
  }

  // ======================================================
  // ADVERTENCIA
  // ======================================================

  Widget _buildWarningCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.red.withValues(alpha: 0.14),
            child: const Icon(Icons.warning_amber_rounded, color: Colors.red),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Uso exclusivo para emergencias',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.red,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Utiliza esta opción cuando necesites apoyo inmediato '
                  'por riesgo para tu integridad o la de otras personas.',
                  style: TextStyle(
                    fontSize: 12,
                    height: 1.4,
                    color: Colors.grey.shade800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // PATRULLAJE
  // ======================================================

  Widget _buildPatrullajeCard(PatrullajeData? patrullaje) {
    final activo = patrullaje?.id != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: activo
            ? Colors.blue.withValues(alpha: 0.06)
            : Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: activo
              ? Colors.blue.withValues(alpha: 0.24)
              : Colors.orange.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            activo ? Icons.shield_outlined : Icons.warning_amber_rounded,
            color: activo ? Colors.blue : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activo
                      ? 'Patrullaje N.° ${patrullaje!.id}'
                      : 'Sin patrullaje activo',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  activo
                      ? 'La alerta quedará asociada al patrullaje actual.'
                      : 'No se podrá asociar la emergencia a un patrullaje.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // UBICACIÓN
  // ======================================================

  Widget _buildLocationCard(IncidenteState state) {
    if (state.loadingLocation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(15),
        decoration: _cardDecoration(),
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Expanded(child: Text('Obteniendo ubicación actual...')),
          ],
        ),
      );
    }

    final disponible = state.tieneUbicacion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: _cardDecoration(),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: disponible
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.red.withValues(alpha: 0.10),
            child: Icon(
              disponible ? Icons.location_on : Icons.location_off_outlined,
              color: disponible ? Colors.green : Colors.red,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  disponible
                      ? 'Ubicación disponible'
                      : 'Ubicación no disponible',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  disponible
                      ? state.direccion ??
                            '${state.latitud!.toStringAsFixed(6)}, '
                                '${state.longitud!.toStringAsFixed(6)}'
                      : 'Es necesario obtener la ubicación para enviar la emergencia.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualizar ubicación',
            onPressed: state.loadingLocation
                ? null
                : () {
                    context.read<IncidenteBloc>().add(
                      const ObtenerUbicacionEvent(),
                    );
                  },
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // MOTIVO
  // ======================================================

  Widget _buildMotivoSection({required bool disabled}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Row(
          children: [
            Icon(
              Icons.report_problem_outlined,
              color: Color.fromARGB(255, 12, 38, 145),
            ),
            SizedBox(width: 10),
            Text(
              'Motivo de la emergencia',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          'Selecciona la situación que necesita atención inmediata.',
          style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
        ),
        const SizedBox(height: 14),
        Wrap(
          spacing: 8,
          runSpacing: 10,
          children: MotivoEmergencia.values.map((motivo) {
            final selected = motivo == _motivoSeleccionado;

            return ChoiceChip(
              selected: selected,
              avatar: Icon(
                _getMotivoIcon(motivo),
                size: 18,
                color: selected ? Colors.white : Colors.black54,
              ),
              label: Text(_getMotivoLabel(motivo)),
              selectedColor: Colors.red,
              backgroundColor: Colors.grey.shade100,
              side: BorderSide(
                color: selected ? Colors.red : Colors.grey.shade300,
              ),
              labelStyle: TextStyle(
                color: selected ? Colors.white : Colors.black87,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
              ),
              onSelected: disabled
                  ? null
                  : (_) {
                      setState(() {
                        _motivoSeleccionado = motivo;
                        _emergenciaEnviada = false;
                      });
                    },
            );
          }).toList(),
        ),
      ],
    );
  }

  // ======================================================
  // BOTÓN SOS
  // ======================================================

  Widget _buildSosSection({
    required BuildContext context,
    required IncidenteState state,
    required PatrullajeData? patrullaje,
  }) {
    final enabled =
        !state.isCreating &&
        !state.loadingLocation &&
        state.tieneUbicacion &&
        patrullaje?.id != null;

    return Column(
      children: [
        Text(
          state.isCreating
              ? 'Enviando emergencia...'
              : 'Mantén presionado durante 2 segundos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: state.isCreating ? Colors.orange : Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 18),

        GestureDetector(
          onTapDown: enabled
              ? (_) {
                  _iniciarPresion(
                    context: context,
                    state: state,
                    patrullaje: patrullaje!,
                  );
                }
              : null,
          onTapUp: enabled
              ? (_) {
                  _cancelarPresion();
                }
              : null,
          onTapCancel: enabled ? _cancelarPresion : null,
          child: AnimatedBuilder(
            animation: _progressController,
            builder: (context, child) {
              return SizedBox(
                width: 190,
                height: 190,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 190,
                      height: 190,
                      child: CircularProgressIndicator(
                        value: _progressController.value,
                        strokeWidth: 9,
                        backgroundColor: Colors.red.withValues(alpha: 0.12),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.red,
                        ),
                      ),
                    ),

                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: _isHolding ? 155 : 165,
                      height: _isHolding ? 155 : 165,
                      decoration: BoxDecoration(
                        color: enabled ? Colors.red : Colors.grey.shade400,
                        shape: BoxShape.circle,
                        boxShadow: enabled
                            ? [
                                BoxShadow(
                                  color: Colors.red.withValues(alpha: 0.35),
                                  blurRadius: _isHolding ? 28 : 18,
                                  spreadRadius: _isHolding ? 7 : 3,
                                ),
                              ]
                            : [],
                      ),
                      child: state.isCreating
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : const Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.sos_rounded,
                                  color: Colors.white,
                                  size: 62,
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'EMERGENCIA',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        const SizedBox(height: 16),

        if (!enabled && !state.isCreating)
          Text(
            _getDisabledMessage(state: state, patrullaje: patrullaje),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
      ],
    );
  }

  void _iniciarPresion({
    required BuildContext context,
    required IncidenteState state,
    required PatrullajeData patrullaje,
  }) {
    if (_isHolding) return;

    setState(() {
      _isHolding = true;
      _emergenciaEnviada = false;
    });

    _progressController.forward(from: 0);

    _holdTimer?.cancel();

    _holdTimer = Timer(_holdDuration, () {
      if (!mounted || !_isHolding) return;

      setState(() {
        _isHolding = false;
      });

      _progressController.reset();

      _confirmarEmergencia(
        context: context,
        state: state,
        patrullaje: patrullaje,
      );
    });
  }

  void _cancelarPresion() {
    _holdTimer?.cancel();

    if (!_isHolding) return;

    setState(() {
      _isHolding = false;
    });

    _progressController.animateBack(
      0,
      duration: const Duration(milliseconds: 180),
    );
  }

  // ======================================================
  // CONFIRMACIÓN
  // ======================================================

  Future<void> _confirmarEmergencia({
    required BuildContext context,
    required IncidenteState state,
    required PatrullajeData patrullaje,
  }) async {
    final confirmar = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          icon: const Icon(
            Icons.warning_amber_rounded,
            color: Colors.red,
            size: 46,
          ),
          title: const Text(
            'Confirmar emergencia',
            textAlign: TextAlign.center,
          ),
          content: Text(
            'Se enviará una solicitud de apoyo inmediato.\n\n'
            'Motivo: ${_getMotivoLabel(_motivoSeleccionado)}',
            textAlign: TextAlign.center,
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton.icon(
              style: FilledButton.styleFrom(backgroundColor: Colors.red),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              icon: const Icon(Icons.sos),
              label: const Text('ENVIAR SOS'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    _enviarEmergencia(context: context, state: state, patrullaje: patrullaje);
  }

  // ======================================================
  // ENVÍO
  // ======================================================

  void _enviarEmergencia({
    required BuildContext context,
    required IncidenteState state,
    required PatrullajeData patrullaje,
  }) {
    if (!state.tieneUbicacion) {
      _showMessage(context, 'No se pudo obtener la ubicación.');
      return;
    }

    final descripcion =
        'EMERGENCIA SOS - ${_getMotivoLabel(_motivoSeleccionado)}. '
        'El sereno solicita apoyo inmediato desde el patrullaje '
        'N.° ${patrullaje.id}.';

    final request = RegisterIncidenciaRequest(
      patrullajeId: patrullaje.id,
      tipo: 'OTRO',
      descripcion: descripcion,
      latitud: state.latitud!,
      longitud: state.longitud!,
      archivos: const [],
    );

    context.read<IncidenteBloc>().add(CrearIncidenteEvent(request));
  }

  // ======================================================
  // INSTRUCCIONES
  // ======================================================

  Widget _buildInstructions() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '¿Qué ocurrirá al enviar la emergencia?',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          SizedBox(height: 10),
          _InstructionRow(
            number: '1',
            text: 'Se registrará la ubicación y el patrullaje actual.',
          ),
          SizedBox(height: 8),
          _InstructionRow(
            number: '2',
            text: 'La emergencia quedará registrada en el sistema.',
          ),
          SizedBox(height: 8),
          _InstructionRow(
            number: '3',
            text: 'Debes mantener comunicación con la base de serenazgo.',
          ),
        ],
      ),
    );
  }

  Widget _buildSuccessCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.28)),
      ),
      child: const Row(
        children: [
          Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'La solicitud fue registrada. Mantente atento a las '
              'indicaciones de la central.',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================

  String _getDisabledMessage({
    required IncidenteState state,
    required PatrullajeData? patrullaje,
  }) {
    if (state.loadingLocation) {
      return 'Se está obteniendo la ubicación.';
    }

    if (!state.tieneUbicacion) {
      return 'No se puede enviar el SOS sin una ubicación válida.';
    }

    if (patrullaje?.id == null) {
      return 'Debes tener un patrullaje activo.';
    }

    return 'El envío de emergencia no está disponible.';
  }

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(15),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  String _getMotivoLabel(MotivoEmergencia motivo) {
    switch (motivo) {
      case MotivoEmergencia.apoyoInmediato:
        return 'Apoyo inmediato';

      case MotivoEmergencia.agresion:
        return 'Agresión o violencia';

      case MotivoEmergencia.personaArmada:
        return 'Persona armada';

      case MotivoEmergencia.accidente:
        return 'Accidente';

      case MotivoEmergencia.incendio:
        return 'Incendio';

      case MotivoEmergencia.otro:
        return 'Otra emergencia';
    }
  }

  IconData _getMotivoIcon(MotivoEmergencia motivo) {
    switch (motivo) {
      case MotivoEmergencia.apoyoInmediato:
        return Icons.security;

      case MotivoEmergencia.agresion:
        return Icons.warning_amber_rounded;

      case MotivoEmergencia.personaArmada:
        return Icons.report_problem_outlined;

      case MotivoEmergencia.accidente:
        return Icons.car_crash_outlined;

      case MotivoEmergencia.incendio:
        return Icons.local_fire_department_outlined;

      case MotivoEmergencia.otro:
        return Icons.sos;
    }
  }
}

// ======================================================
// INSTRUCCIÓN
// ======================================================

class _InstructionRow extends StatelessWidget {
  final String number;
  final String text;

  const _InstructionRow({required this.number, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 23,
          height: 23,
          alignment: Alignment.center,
          decoration: const BoxDecoration(
            color: Color.fromARGB(255, 12, 38, 145),
            shape: BoxShape.circle,
          ),
          child: Text(
            number,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(text, style: const TextStyle(fontSize: 12, height: 1.4)),
        ),
      ],
    );
  }
}

// ======================================================
// ENUM
// ======================================================

enum MotivoEmergencia {
  apoyoInmediato,
  agresion,
  personaArmada,
  accidente,
  incendio,
  otro,
}
