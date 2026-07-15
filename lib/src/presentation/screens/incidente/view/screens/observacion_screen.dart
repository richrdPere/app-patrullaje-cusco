import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_request.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

class ObservacionScreen extends StatefulWidget {
  const ObservacionScreen({super.key});

  @override
  State<ObservacionScreen> createState() => _ObservacionScreenState();
}

class _ObservacionScreenState extends State<ObservacionScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _tituloController = TextEditingController();

  final TextEditingController _descripcionController = TextEditingController();

  TipoHistorialPatrullaje _tipoSeleccionado =
      TipoHistorialPatrullaje.observacion;

  PrioridadHistorial _prioridadSeleccionada = PrioridadHistorial.media;

  bool _visibleSiguienteTurno = true;
  bool _incluirUbicacion = false;

  @override
  void initState() {
    super.initState();

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
    _tituloController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeBloc>().state;
    final patrullaje = homeState.patrullaje;

    return BlocListener<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      listenWhen: (previous, current) {
        return previous.historial != current.historial;
      },
      listener: _onHistorialStateChanged,
      child: BlocBuilder<IncidenteBloc, IncidenteState>(
        buildWhen: (previous, current) {
          return previous.latitud != current.latitud ||
              previous.longitud != current.longitud ||
              previous.direccion != current.direccion ||
              previous.loadingLocation != current.loadingLocation;
        },
        builder: (context, incidenteState) {
          return Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
              children: [
                _buildInfoCard(),

                const SizedBox(height: 22),

                _buildPatrullajeCard(
                  patrullajeId: patrullaje?.id,
                  zonaNombre: patrullaje?.zona.nombre ?? 'Zona asignada',
                ),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.assignment_outlined,
                  title: 'Tipo de registro',
                  subtitle: 'Selecciona la categoría de la anotación.',
                ),

                const SizedBox(height: 12),

                _buildTipoSelector(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.title,
                  title: 'Título',
                  subtitle:
                      'Escribe un título breve para identificar el registro.',
                ),

                const SizedBox(height: 12),

                _buildTituloField(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.description_outlined,
                  title: 'Descripción',
                  subtitle: 'Describe claramente la situación observada.',
                ),

                const SizedBox(height: 12),

                _buildDescripcionField(),

                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.flag_outlined,
                  title: 'Prioridad',
                  subtitle: 'Indica la importancia operativa del registro.',
                ),

                const SizedBox(height: 12),

                _buildPrioridadSelector(),

                const SizedBox(height: 24),

                _buildLocationOption(incidenteState),

                const SizedBox(height: 16),

                _buildNextShiftOption(),

                const SizedBox(height: 28),

                BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
                  buildWhen: (previous, current) {
                    return previous.historial != current.historial;
                  },
                  builder: (context, historialState) {
                    return _buildSubmitButton(
                      context: context,
                      historialState: historialState,
                      incidenteState: incidenteState,
                      patrullajeId: patrullaje?.id,
                      zonaId: patrullaje?.zona.id,
                    );
                  },
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  // ======================================================
  // LISTENER
  // ======================================================
  void _onHistorialStateChanged(
    BuildContext context,
    HistorialPatrullajeState state,
  ) {
    final response = state.historial;

    if (response is Success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Observación registrada correctamente.'),
            backgroundColor: Colors.green,
          ),
        );

      _limpiarFormulario();

      context.read<HistorialPatrullajeBloc>().add(ClearHistorialActionEvent());

      return;
    }

    // if (response is ErrorData) {
    //   ScaffoldMessenger.of(context)
    //     ..hideCurrentSnackBar()
    //     ..showSnackBar(
    //       SnackBar(
    //         content: Text(response.error),
    //         backgroundColor: Colors.red,
    //       ),
    //     );

    //   context.read<HistorialPatrullajeBloc>().add(ClearHistorialActionEvent());
    // }
  }

  void _limpiarFormulario() {
    _tituloController.clear();
    _descripcionController.clear();

    setState(() {
      _tipoSeleccionado = TipoHistorialPatrullaje.observacion;
      _prioridadSeleccionada = PrioridadHistorial.media;
      _visibleSiguienteTurno = true;
      _incluirUbicacion = false;
    });
  }

  // ======================================================
  // INFORMACIÓN
  // ======================================================

  Widget _buildInfoCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: Colors.blue.withValues(alpha: 0.14),
            child: const Icon(Icons.note_alt_outlined, color: Colors.blue),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Registro operativo',
                  style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 4),
                Text(
                  'Registra novedades, observaciones y recomendaciones '
                  'detectadas durante el patrullaje.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPatrullajeCard({
    required int? patrullajeId,
    required String zonaNombre,
  }) {
    final activo = patrullajeId != null;

    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: activo
            ? Colors.green.withValues(alpha: 0.06)
            : Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(
          color: activo
              ? Colors.green.withValues(alpha: 0.25)
              : Colors.orange.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          Icon(
            activo ? Icons.shield_outlined : Icons.warning_amber_rounded,
            color: activo ? Colors.green : Colors.orange,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activo
                      ? 'Patrullaje N.° $patrullajeId'
                      : 'Sin patrullaje activo',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 3),
                Text(
                  activo
                      ? zonaNombre
                      : 'Debes iniciar un patrullaje para registrar observaciones.',
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
  // TÍTULOS
  // ======================================================

  Widget _buildSectionTitle({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 22, color: const Color.fromARGB(255, 12, 38, 145)),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ======================================================
  // TIPO
  // ======================================================

  Widget _buildTipoSelector() {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: TipoHistorialPatrullaje.values.map((tipo) {
        final selected = tipo == _tipoSeleccionado;

        return ChoiceChip(
          selected: selected,
          avatar: Icon(
            _getTipoIcon(tipo),
            size: 17,
            color: selected ? Colors.white : Colors.black54,
          ),
          label: Text(_getTipoLabel(tipo)),
          selectedColor: const Color.fromARGB(255, 12, 38, 145),
          backgroundColor: Colors.grey.shade100,
          side: BorderSide(
            color: selected
                ? const Color.fromARGB(255, 12, 38, 145)
                : Colors.grey.shade300,
          ),
          labelStyle: TextStyle(
            color: selected ? Colors.white : Colors.black87,
            fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
          ),
          onSelected: (_) {
            setState(() {
              _tipoSeleccionado = tipo;

              if (tipo == TipoHistorialPatrullaje.alerta ||
                  tipo == TipoHistorialPatrullaje.puntoCritico) {
                _prioridadSeleccionada = PrioridadHistorial.alta;
              }

              if (tipo == TipoHistorialPatrullaje.cambioTurno) {
                _visibleSiguienteTurno = true;
              }
            });
          },
        );
      }).toList(),
    );
  }

  // ======================================================
  // TÍTULO Y DESCRIPCIÓN
  // ======================================================

  Widget _buildTituloField() {
    return TextFormField(
      controller: _tituloController,
      maxLength: 100,
      textCapitalization: TextCapitalization.sentences,
      decoration: _inputDecoration(
        hintText: 'Ejemplo: Vehículo sospechoso',
        icon: Icons.short_text,
      ),
      validator: (value) {
        final titulo = value?.trim() ?? '';

        if (titulo.isEmpty) {
          return 'Ingrese un título.';
        }

        if (titulo.length < 4) {
          return 'El título debe tener al menos 4 caracteres.';
        }

        return null;
      },
    );
  }

  Widget _buildDescripcionField() {
    return TextFormField(
      controller: _descripcionController,
      minLines: 4,
      maxLines: 7,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      decoration: _inputDecoration(
        hintText:
            'Describe la situación, las personas involucradas, '
            'características o acciones realizadas...',
        icon: Icons.notes,
        alignLabelWithHint: true,
      ),
      validator: (value) {
        final descripcion = value?.trim() ?? '';

        if (descripcion.isEmpty) {
          return 'Ingrese una descripción.';
        }

        if (descripcion.length < 10) {
          return 'La descripción debe tener al menos 10 caracteres.';
        }

        return null;
      },
    );
  }

  InputDecoration _inputDecoration({
    required String hintText,
    required IconData icon,
    bool alignLabelWithHint = false,
  }) {
    return InputDecoration(
      hintText: hintText,
      prefixIcon: Icon(icon),
      alignLabelWithHint: alignLabelWithHint,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color.fromARGB(255, 12, 38, 145),
          width: 1.5,
        ),
      ),
    );
  }

  // ======================================================
  // PRIORIDAD
  // ======================================================

  Widget _buildPrioridadSelector() {
    return SegmentedButton<PrioridadHistorial>(
      segments: const [
        ButtonSegment(
          value: PrioridadHistorial.baja,
          label: Text('Baja'),
          icon: Icon(Icons.low_priority),
        ),
        ButtonSegment(
          value: PrioridadHistorial.media,
          label: Text('Media'),
          icon: Icon(Icons.drag_handle),
        ),
        ButtonSegment(
          value: PrioridadHistorial.alta,
          label: Text('Alta'),
          icon: Icon(Icons.priority_high),
        ),
      ],
      selected: {_prioridadSeleccionada},
      onSelectionChanged: (values) {
        setState(() {
          _prioridadSeleccionada = values.first;
        });
      },
    );
  }

  // ======================================================
  // UBICACIÓN
  // ======================================================

  Widget _buildLocationOption(IncidenteState state) {
    final tieneUbicacion = state.tieneUbicacion;

    return Container(
      decoration: _cardDecoration(),
      child: Column(
        children: [
          SwitchListTile(
            value: _incluirUbicacion,
            onChanged: tieneUbicacion
                ? (value) {
                    setState(() {
                      _incluirUbicacion = value;
                    });
                  }
                : null,
            secondary: Icon(
              tieneUbicacion
                  ? Icons.location_on_outlined
                  : Icons.location_off_outlined,
              color: tieneUbicacion ? Colors.green : Colors.red,
            ),
            title: const Text(
              'Incluir ubicación',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              state.loadingLocation
                  ? 'Obteniendo ubicación...'
                  : tieneUbicacion
                  ? state.direccion ??
                        '${state.latitud!.toStringAsFixed(6)}, '
                            '${state.longitud!.toStringAsFixed(6)}'
                  : 'No se pudo obtener la ubicación.',
            ),
          ),
          if (!tieneUbicacion && !state.loadingLocation)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    context.read<IncidenteBloc>().add(
                      const ObtenerUbicacionEvent(),
                    );
                  },
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reintentar ubicación'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ======================================================
  // SIGUIENTE TURNO
  // ======================================================

  Widget _buildNextShiftOption() {
    return Container(
      decoration: _cardDecoration(),
      child: SwitchListTile(
        value: _visibleSiguienteTurno,
        onChanged: (value) {
          setState(() {
            _visibleSiguienteTurno = value;
          });
        },
        secondary: const Icon(
          Icons.change_circle_outlined,
          color: Color.fromARGB(255, 12, 38, 145),
        ),
        title: const Text(
          'Visible para el siguiente turno',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),
        subtitle: const Text(
          'El siguiente sereno podrá consultar esta anotación.',
        ),
      ),
    );
  }

  // ======================================================
  // BOTÓN REGISTRAR
  // ======================================================

  Widget _buildSubmitButton({
    required BuildContext context,
    required HistorialPatrullajeState historialState,
    required IncidenteState incidenteState,
    required int? patrullajeId,
    required int? zonaId,
  }) {
    final loading = historialState.actionMessage is Loading;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: loading
            ? null
            : () {
                _registrarObservacion(
                  context: context,
                  incidenteState: incidenteState,
                  patrullajeId: patrullajeId,
                  zonaId: zonaId,
                );
              },
        icon: loading
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.save_outlined),
        label: Text(loading ? 'REGISTRANDO...' : 'REGISTRAR OBSERVACIÓN'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 12, 38, 145),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  void _registrarObservacion({
    required BuildContext context,
    required IncidenteState incidenteState,
    required int? patrullajeId,
    required int? zonaId,
  }) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (patrullajeId == null) {
      _showMessage(context, 'No existe un patrullaje activo.');
      return;
    }

    if (zonaId == null) {
      _showMessage(context, 'No se pudo identificar la zona del patrullaje.');
      return;
    }

    if (_incluirUbicacion && !incidenteState.tieneUbicacion) {
      _showMessage(context, 'No se pudo obtener la ubicación.');
      return;
    }

    final request = HistorialPatrullajeRequest(
      patrullajeId: patrullajeId,
      zonaId: zonaId,
      tipo: _tipoSeleccionado.apiValue,
      titulo: _tituloController.text.trim(),
      descripcion: _descripcionController.text.trim(),
      prioridad: _prioridadSeleccionada.apiValue,
      latitud: _incluirUbicacion ? incidenteState.latitud : null,
      longitud: _incluirUbicacion ? incidenteState.longitud : null,
      visibleParaSiguienteTurno: _visibleSiguienteTurno,
      // fecha: DateTime.now(),
    );

    context.read<HistorialPatrullajeBloc>().add(
      RegisterHistorialEvent(request: request),
    );
  }

  // ======================================================
  // HELPERS
  // ======================================================

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

  String _getTipoLabel(TipoHistorialPatrullaje tipo) {
    switch (tipo) {
      case TipoHistorialPatrullaje.observacion:
        return 'Observación';
      case TipoHistorialPatrullaje.novedad:
        return 'Novedad';
      case TipoHistorialPatrullaje.alerta:
        return 'Alerta';
      case TipoHistorialPatrullaje.recomendacion:
        return 'Recomendación';
      case TipoHistorialPatrullaje.puntoCritico:
        return 'Punto crítico';
      case TipoHistorialPatrullaje.cambioTurno:
        return 'Cambio de turno';
    }
  }

  IconData _getTipoIcon(TipoHistorialPatrullaje tipo) {
    switch (tipo) {
      case TipoHistorialPatrullaje.observacion:
        return Icons.visibility_outlined;
      case TipoHistorialPatrullaje.novedad:
        return Icons.new_releases_outlined;
      case TipoHistorialPatrullaje.alerta:
        return Icons.warning_amber_rounded;
      case TipoHistorialPatrullaje.recomendacion:
        return Icons.lightbulb_outline;
      case TipoHistorialPatrullaje.puntoCritico:
        return Icons.location_on_outlined;
      case TipoHistorialPatrullaje.cambioTurno:
        return Icons.swap_horiz;
    }
  }
}

// ======================================================
// ENUMS
// ======================================================

enum TipoHistorialPatrullaje {
  observacion,
  novedad,
  alerta,
  recomendacion,
  puntoCritico,
  cambioTurno,
}

extension TipoHistorialPatrullajeExtension on TipoHistorialPatrullaje {
  String get apiValue {
    switch (this) {
      case TipoHistorialPatrullaje.observacion:
        return 'OBSERVACION';
      case TipoHistorialPatrullaje.novedad:
        return 'NOVEDAD';
      case TipoHistorialPatrullaje.alerta:
        return 'ALERTA';
      case TipoHistorialPatrullaje.recomendacion:
        return 'RECOMENDACION';
      case TipoHistorialPatrullaje.puntoCritico:
        return 'PUNTO_CRITICO';
      case TipoHistorialPatrullaje.cambioTurno:
        return 'CAMBIO_TURNO';
    }
  }
}

enum PrioridadHistorial { baja, media, alta }

extension PrioridadHistorialExtension on PrioridadHistorial {
  String get apiValue {
    switch (this) {
      case PrioridadHistorial.baja:
        return 'BAJA';
      case PrioridadHistorial.media:
        return 'MEDIA';
      case PrioridadHistorial.alta:
        return 'ALTA';
    }
  }
}
