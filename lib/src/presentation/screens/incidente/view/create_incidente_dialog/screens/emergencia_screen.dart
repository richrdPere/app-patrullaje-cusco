import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';

// Home
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';

// Ubicación
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

// Alertas
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_state.dart';

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

      final incidenteBloc = context.read<IncidenteBloc>();

      final incidenteState = incidenteBloc.state;

      if (!incidenteState.tieneUbicacion && !incidenteState.loadingLocation) {
        incidenteBloc.add(const ObtenerUbicacionEvent());
      }

      context.read<AlertaBloc>().add(const GetAlertaActivaEvent());
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

    return BlocConsumer<AlertaBloc, AlertaState>(
      listenWhen: (previous, current) {
        final esAccionActivar =
            current.actionType == AlertaActionType.activarAlerta;

        final cambioEstado = previous.actionStatus != current.actionStatus;

        return esAccionActivar && cambioEstado;
      },
      listener: _onAlertaStateChanged,
      builder: (context, alertaState) {
        return BlocBuilder<IncidenteBloc, IncidenteState>(
          builder: (context, ubicacionState) {
            final enviando = alertaState.isActivandoAlerta;

            final tieneAlertaActiva = alertaState.tieneAlertaActiva;

            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 36),
              children: [
                _buildWarningCard(),

                const SizedBox(height: 20),

                _buildPatrullajeCard(patrullaje),

                const SizedBox(height: 16),

                _buildLocationCard(ubicacionState),

                const SizedBox(height: 24),

                _buildMotivoSection(
                  disabled: enviando || _isHolding || tieneAlertaActiva,
                ),

                const SizedBox(height: 32),

                _buildSosSection(
                  context: context,
                  ubicacionState: ubicacionState,
                  alertaState: alertaState,
                  patrullaje: patrullaje,
                ),

                const SizedBox(height: 26),

                _buildInstructions(),

                if (_emergenciaEnviada || tieneAlertaActiva) ...[
                  const SizedBox(height: 20),
                  _buildSuccessCard(alertaState.alertaActiva),
                ],
              ],
            );
          },
        );
      },
    );
  }

  // ======================================================
  // LISTENER
  // ======================================================
  void _onAlertaStateChanged(BuildContext context, AlertaState state) {
    if (state.actionStatus == AlertaActionStatus.loading) {
      return;
    }

    if (state.actionStatus == AlertaActionStatus.success) {
      setState(() {
        _emergenciaEnviada = true;
        _isHolding = false;
      });

      _holdTimer?.cancel();
      _progressController.reset();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.actionMessage ?? 'La alerta fue activada correctamente.',
            ),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 4),
          ),
        );

      /*
     * El BLoC ya ejecuta GetAlertaActivaEvent después
     * de activar correctamente la alerta.
     */
      context.read<AlertaBloc>().add(const ClearAlertaActionResponseEvent());

      return;
    }

    if (state.actionStatus == AlertaActionStatus.error) {
      setState(() {
        _isHolding = false;
      });

      _holdTimer?.cancel();
      _progressController.reset();

      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.actionMessage ?? 'No se pudo activar la alerta.',
            ),
            backgroundColor: Colors.red,
          ),
        );

      context.read<AlertaBloc>().add(const ClearAlertaActionResponseEvent());
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
    required IncidenteState ubicacionState,
    required AlertaState alertaState,
    required PatrullajeData? patrullaje,
  }) {
    final enviando = alertaState.isActivandoAlerta;

    final consultandoAlertaActiva =
        alertaState.alertaActivaStatus == AlertaActivaStatus.loading;

    final tieneAlertaActiva = alertaState.tieneAlertaActiva;

    final enabled =
        !enviando &&
        !consultandoAlertaActiva &&
        !tieneAlertaActiva &&
        !ubicacionState.loadingLocation &&
        ubicacionState.tieneUbicacion &&
        patrullaje?.id != null;

    return Column(
      children: [
        Text(
          enviando
              ? 'Enviando alerta de emergencia...'
              : tieneAlertaActiva
              ? 'Ya tienes una alerta activa'
              : consultandoAlertaActiva
              ? 'Verificando alerta activa...'
              : 'Mantén presionado durante 2 segundos',
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: enviando
                ? Colors.orange
                : tieneAlertaActiva
                ? Colors.red
                : Colors.grey.shade700,
          ),
        ),

        const SizedBox(height: 18),

        GestureDetector(
          onTapDown: enabled
              ? (_) {
                  _iniciarPresion(
                    context: context,
                    ubicacionState: ubicacionState,
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
                      child: enviando || consultandoAlertaActiva
                          ? const Center(
                              child: CircularProgressIndicator(
                                color: Colors.white,
                              ),
                            )
                          : Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  tieneAlertaActiva
                                      ? Icons.notifications_active_rounded
                                      : Icons.sos_rounded,
                                  color: Colors.white,
                                  size: 62,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  tieneAlertaActiva
                                      ? 'ALERTA ACTIVA'
                                      : 'EMERGENCIA',
                                  style: const TextStyle(
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

        if (!enabled && !enviando)
          Text(
            _getDisabledMessage(
              ubicacionState: ubicacionState,
              alertaState: alertaState,
              patrullaje: patrullaje,
            ),
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
    required IncidenteState ubicacionState,
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
      if (!mounted || !_isHolding) {
        return;
      }

      setState(() {
        _isHolding = false;
      });

      _progressController.reset();

      _confirmarEmergencia(
        context: context,
        ubicacionState: ubicacionState,
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
    required IncidenteState ubicacionState,
    required PatrullajeData patrullaje,
  }) async {
    /*
   * Este texto será enviado como titulo al backend.
   */
    final motivo = _getMotivoLabel(_motivoSeleccionado);

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
            'Motivo: $motivo',
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

    _enviarEmergencia(
      context: context,
      ubicacionState: ubicacionState,
      patrullaje: patrullaje,
    );
  }

  // ======================================================
  // ENVÍO
  // ======================================================

  void _enviarEmergencia({
    required BuildContext context,
    required IncidenteState ubicacionState,
    required PatrullajeData patrullaje,
  }) {
    if (!ubicacionState.tieneUbicacion ||
        ubicacionState.latitud == null ||
        ubicacionState.longitud == null) {
      _showMessage(context, 'No se pudo obtener la ubicación.');

      return;
    }

    /*
   * El motivo seleccionado se utiliza como título.
   *
   * Ejemplos:
   * - APOYO INMEDIATO
   * - AGRESIÓN O VIOLENCIA
   * - PERSONA ARMADA
   * - ACCIDENTE
   * - INCENDIO
   * - OTRA EMERGENCIA
   */
    final titulo = _getMotivoLabel(_motivoSeleccionado).toUpperCase();

    final request = ActivarAlertaRequest(
      patrullajeId: patrullaje.id,
      titulo: titulo,
      tipo: 'PANICO',
      latitud: ubicacionState.latitud!,
      longitud: ubicacionState.longitud!,
    );

    context.read<AlertaBloc>().add(ActivarAlertaEvent(request: request));
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

  Widget _buildSuccessCard(AlertaActivaData? alertaActiva) {
    final titulo = alertaActiva?.titulo.trim();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.green.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline, color: Colors.green, size: 30),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Alerta de emergencia activa',
                  style: TextStyle(fontWeight: FontWeight.w700),
                ),
                if (titulo != null && titulo.isNotEmpty) ...[
                  const SizedBox(height: 4),
                  Text(
                    titulo,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ],
                const SizedBox(height: 4),
                const Text(
                  'Mantente atento a las indicaciones '
                  'de la central de serenazgo.',
                ),
              ],
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
    required IncidenteState ubicacionState,
    required AlertaState alertaState,
    required PatrullajeData? patrullaje,
  }) {
    if (alertaState.alertaActivaStatus == AlertaActivaStatus.loading) {
      return 'Se está verificando si existe una alerta activa.';
    }

    if (alertaState.tieneAlertaActiva) {
      return 'Ya existe una alerta de emergencia activa.';
    }

    if (ubicacionState.loadingLocation) {
      return 'Se está obteniendo la ubicación.';
    }

    if (!ubicacionState.tieneUbicacion) {
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
