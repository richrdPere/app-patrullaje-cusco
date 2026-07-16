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

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';

class IncidenteFormScreen extends StatefulWidget {
  const IncidenteFormScreen({super.key});

  @override
  State<IncidenteFormScreen> createState() => _IncidenteFormScreenState();
}

class _IncidenteFormScreenState extends State<IncidenteFormScreen> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _descripcionController = TextEditingController();

  TipoIncidente? _tipoSeleccionado;

  static const int maxArchivos = 5;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final state = context.read<IncidenteBloc>().state;

      if (!state.tieneUbicacion && !state.loadingLocation) {
        context.read<IncidenteBloc>().add(const ObtenerUbicacionEvent());
      }
    });
  }

  @override
  void dispose() {
    _descripcionController.dispose();
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
        return Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // CARD
                _buildPatrullajeCard(patrullaje),

                const SizedBox(height: 20),

                // SELECCION DE INCIDENTE
                _buildSectionTitle(
                  icon: Icons.category_outlined,
                  title: 'Tipo de incidente',
                  subtitle:
                      'Selecciona la categoría que mejor describa el hecho.',
                ),

                const SizedBox(height: 12),

                _buildTipoIncidenteSelector(disabled: state.isCreating),

                const SizedBox(height: 24),

                // DESCRIPCION DE INCIDENTE
                _buildSectionTitle(
                  icon: Icons.description_outlined,
                  title: 'Descripción',
                  subtitle: 'Describe de manera clara lo sucedido.',
                ),

                const SizedBox(height: 12),

                _buildDescripcionField(disabled: state.isCreating),

                const SizedBox(height: 24),

                // UBICACION
                _buildSectionTitle(
                  icon: Icons.location_on_outlined,
                  title: 'Ubicación',
                  subtitle: 'La ubicación se obtiene automáticamente.',
                ),

                const SizedBox(height: 12),

                _buildUbicacionCard(state),

                const SizedBox(height: 24),

                // EVIDENCIA
                _buildSectionTitle(
                  icon: Icons.perm_media_outlined,
                  title: 'Evidencias',
                  subtitle: 'Adjunta fotografías o videos relacionados.',
                ),

                const SizedBox(height: 12),

                _buildEvidenciasCard(context, state),

                const SizedBox(height: 28),

                _buildSubmitButton(
                  context: context,
                  state: state,
                  patrullaje: patrullaje,
                ),
              ],
            ),
          ),
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
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          const SnackBar(
            content: Text('Incidencia registrada correctamente.'),
            backgroundColor: Colors.green,
          ),
        );

      _limpiarFormularioLocal();

      context.read<IncidenteBloc>().add(const LimpiarAccionIncidenteEvent());

      context.read<IncidenteBloc>().add(
        const CambiarTabIncidenteEvent(IncidenteTabEnum.historial),
      );

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

  void _limpiarFormularioLocal() {
    _descripcionController.clear();

    setState(() {
      _tipoSeleccionado = null;
    });
  }

  // ======================================================
  // PATRULLAJE ACTIVO
  // ======================================================
  Widget _buildPatrullajeCard(PatrullajeData? patrullaje) {
    final tienePatrullaje = patrullaje != null;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: tienePatrullaje
            ? Colors.blue.withValues(alpha: 0.07)
            : Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: tienePatrullaje
              ? Colors.blue.withValues(alpha: 0.25)
              : Colors.orange.withValues(alpha: 0.30),
        ),
      ),
      child: Row(
        children: [
          CircleAvatar(
            backgroundColor: tienePatrullaje
                ? Colors.blue.withValues(alpha: 0.12)
                : Colors.orange.withValues(alpha: 0.15),
            child: Icon(
              tienePatrullaje
                  ? Icons.shield_outlined
                  : Icons.warning_amber_rounded,
              color: tienePatrullaje ? Colors.blue : Colors.orange,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tienePatrullaje
                      ? 'Patrullaje activo'
                      : 'Sin patrullaje activo',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  tienePatrullaje
                      ? _obtenerDescripcionPatrullaje(patrullaje)
                      : 'Debes tener un patrullaje activo para registrar una incidencia.',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _obtenerDescripcionPatrullaje(PatrullajeData patrullaje) {
    final id = patrullaje.id;

    return 'Patrullaje N.° $id';
  }

  // ======================================================
  // TÍTULO DE SECCIÓN
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
  // TIPO DE INCIDENTE
  // ======================================================
  Widget _buildTipoIncidenteSelector({required bool disabled}) {
    return Wrap(
      spacing: 8,
      runSpacing: 10,
      children: TipoIncidente.values.map((tipo) {
        final selected = _tipoSeleccionado == tipo;

        return ChoiceChip(
          selected: selected,
          label: Text(_getTipoTitle(tipo)),
          avatar: Icon(
            _getTipoIcon(tipo),
            size: 18,
            color: selected ? Colors.white : Colors.black54,
          ),
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
          onSelected: disabled
              ? null
              : (value) {
                  setState(() {
                    _tipoSeleccionado = value ? tipo : null;
                  });
                },
        );
      }).toList(),
    );
  }

  // ======================================================
  // DESCRIPCIÓN
  // ======================================================
  Widget _buildDescripcionField({required bool disabled}) {
    return TextFormField(
      controller: _descripcionController,
      enabled: !disabled,
      minLines: 4,
      maxLines: 6,
      maxLength: 500,
      textCapitalization: TextCapitalization.sentences,
      decoration: InputDecoration(
        hintText:
            'Ejemplo: Se observó a una persona intentando forzar la puerta de un establecimiento...',
        alignLabelWithHint: true,
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
      ),
      validator: (value) {
        final descripcion = value?.trim() ?? '';

        if (descripcion.isEmpty) {
          return 'Ingrese una descripción del incidente.';
        }

        if (descripcion.length < 10) {
          return 'La descripción debe tener al menos 10 caracteres.';
        }

        return null;
      },
    );
  }

  // ======================================================
  // UBICACIÓN
  // ======================================================
  Widget _buildUbicacionCard(IncidenteState state) {
    if (state.loadingLocation) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: const Row(
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Obteniendo ubicación actual...'),
          ],
        ),
      );
    }

    final tieneUbicacion = state.tieneUbicacion;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: _cardDecoration(),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            backgroundColor: tieneUbicacion
                ? Colors.green.withValues(alpha: 0.12)
                : Colors.red.withValues(alpha: 0.10),
            child: Icon(
              tieneUbicacion ? Icons.location_on : Icons.location_off_outlined,
              color: tieneUbicacion ? Colors.green : Colors.red,
            ),
          ),

          const SizedBox(width: 12),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  tieneUbicacion
                      ? 'Ubicación obtenida'
                      : 'Ubicación no disponible',
                  style: const TextStyle(fontWeight: FontWeight.w700),
                ),

                const SizedBox(height: 4),

                if (state.direccion != null &&
                    state.direccion!.trim().isNotEmpty)
                  Text(
                    state.direccion!,
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  )
                else if (tieneUbicacion)
                  Text(
                    'Latitud: ${state.latitud!.toStringAsFixed(6)}\n'
                    'Longitud: ${state.longitud!.toStringAsFixed(6)}',
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  )
                else
                  Text(
                    'Presiona reintentar para obtener la ubicación.',
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
  // EVIDENCIAS
  // ======================================================

  Widget _buildEvidenciasCard(BuildContext context, IncidenteState state) {
    final cantidad = state.archivosLocales.length;
    final completo = cantidad >= maxArchivos;

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: state.isCreating
          ? null
          : () {
              context.read<IncidenteBloc>().add(
                const CambiarTabIncidenteEvent(IncidenteTabEnum.evidencia),
              );
            },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: _cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: const Color.fromARGB(
                255,
                12,
                38,
                145,
              ).withValues(alpha: 0.10),
              child: const Icon(
                Icons.add_photo_alternate_outlined,
                color: Color.fromARGB(255, 12, 38, 145),
              ),
            ),

            const SizedBox(width: 12),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cantidad == 0
                        ? 'Agregar evidencias'
                        : '$cantidad evidencia${cantidad == 1 ? '' : 's'} seleccionada${cantidad == 1 ? '' : 's'}',
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),

                  const SizedBox(height: 4),

                  Text(
                    completo
                        ? 'Se alcanzó el máximo permitido.'
                        : 'Fotografías o videos. Máximo $maxArchivos archivos.',
                    style: TextStyle(
                      fontSize: 12,
                      color: completo
                          ? Colors.orange.shade800
                          : Colors.grey.shade700,
                    ),
                  ),
                ],
              ),
            ),

            Text(
              '$cantidad/$maxArchivos',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: completo
                    ? Colors.orange
                    : const Color.fromARGB(255, 12, 38, 145),
              ),
            ),

            const SizedBox(width: 6),

            const Icon(Icons.chevron_right, color: Colors.black45),
          ],
        ),
      ),
    );
  }

  // ======================================================
  // BOTÓN REGISTRAR
  // ======================================================

  Widget _buildSubmitButton({
    required BuildContext context,
    required IncidenteState state,
    required PatrullajeData? patrullaje,
  }) {
    final disabled =
        state.isCreating || state.loadingLocation || state.loadingMedia;

    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: disabled
            ? null
            : () {
                _submitIncidente(
                  context: context,
                  state: state,
                  patrullaje: patrullaje,
                );
              },
        icon: state.isCreating
            ? const SizedBox(
                width: 21,
                height: 21,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Icon(Icons.send_rounded),
        label: Text(state.isCreating ? 'REGISTRANDO...' : 'REPORTAR INCIDENTE'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color.fromARGB(255, 12, 38, 145),
          foregroundColor: Colors.white,
          disabledBackgroundColor: Colors.grey.shade400,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  // ======================================================
  // ENVIAR INCIDENCIA
  // ======================================================

  void _submitIncidente({
    required BuildContext context,
    required IncidenteState state,
    required PatrullajeData? patrullaje,
  }) {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_tipoSeleccionado == null) {
      _showMessage(context, 'Seleccione un tipo de incidente.');

      return;
    }

    if (!state.tieneUbicacion) {
      _showMessage(context, 'No se pudo obtener la ubicación actual.');

      return;
    }

    if (patrullaje == null || patrullaje.id == null) {
      _showMessage(context, 'No existe un patrullaje activo.');

      return;
    }

    if (state.archivosLocales.length > maxArchivos) {
      _showMessage(context, 'Solo se permiten hasta $maxArchivos evidencias.');

      return;
    }

    /*
     * Si las evidencias son obligatorias, deja esta validación.
     *
     * Si deseas permitir incidencias sin archivos, elimínala.
     */
    if (state.archivosLocales.isEmpty) {
      _showMessage(context, 'Debe adjuntar al menos una evidencia.');

      return;
    }

    final request = RegisterIncidenciaRequest(
      patrullajeId: patrullaje.id,
      tipo: _tipoSeleccionado!.name.toUpperCase(),
      descripcion: _descripcionController.text.trim(),
      latitud: state.latitud!,
      longitud: state.longitud!,
      archivos: state.archivosLocales,
    );

    context.read<IncidenteBloc>().add(CrearIncidenteEvent(request));
  }

  void _showMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  // ======================================================
  // HELPERS VISUALES
  // ======================================================

  BoxDecoration _cardDecoration() {
    return BoxDecoration(
      color: Colors.grey.shade50,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.grey.shade300),
    );
  }

  String _getTipoTitle(TipoIncidente tipo) {
    switch (tipo) {
      case TipoIncidente.robo:
        return 'Robo';

      case TipoIncidente.accidente:
        return 'Accidente';

      case TipoIncidente.incendio:
        return 'Incendio';

      case TipoIncidente.violencia:
        return 'Violencia';

      case TipoIncidente.sospechoso:
        return 'Sospechoso';

      case TipoIncidente.otro:
        return 'Otro';
    }
  }

  IconData _getTipoIcon(TipoIncidente tipo) {
    switch (tipo) {
      case TipoIncidente.robo:
        return Icons.security_outlined;

      case TipoIncidente.accidente:
        return Icons.car_crash_outlined;

      case TipoIncidente.incendio:
        return Icons.local_fire_department_outlined;

      case TipoIncidente.violencia:
        return Icons.warning_amber_rounded;

      case TipoIncidente.sospechoso:
        return Icons.visibility_outlined;

      case TipoIncidente.otro:
        return Icons.more_horiz;
    }
  }
}
