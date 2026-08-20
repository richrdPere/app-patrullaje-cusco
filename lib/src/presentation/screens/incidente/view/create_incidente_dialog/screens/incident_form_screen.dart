import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:path/path.dart' as path;

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/create_incidente_dialog/widgets/incidente_form_section_card.dart';

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
        return previous.createResponse != current.createResponse ||
            previous.mediaError != current.mediaError;
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
                _buildPatrullajeCard(patrullaje),

                const SizedBox(height: 20),

                IncidentFormSectionCard(
                  icon: Icons.category_outlined,
                  title: 'Tipo de incidente',
                  subtitle:
                      'Selecciona la categoría que mejor describa el hecho.',
                  child: _buildTipoIncidenteSelector(
                    disabled: state.isCreating,
                  ),
                ),

                const SizedBox(height: 18),

                IncidentFormSectionCard(
                  icon: Icons.description_outlined,
                  title: 'Descripción',
                  subtitle: 'Describe de manera clara lo sucedido.',
                  child: _buildDescripcionField(disabled: state.isCreating),
                ),

                const SizedBox(height: 18),

                IncidentFormSectionCard(
                  icon: Icons.location_on_outlined,
                  title: 'Ubicación',
                  subtitle: 'La ubicación se obtiene automáticamente.',
                  child: _buildUbicacionCard(state),
                ),

                const SizedBox(height: 18),

                IncidentFormSectionCard(
                  icon: Icons.perm_media_outlined,
                  title: 'Evidencias',
                  subtitle: 'Adjunta imágenes, videos o grabaciones de audio.',
                  child: _buildEvidenciasCard(context, state),
                ),

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
    if (state.mediaError != null && state.mediaError!.trim().isNotEmpty) {
      _showMessage(context, state.mediaError!, isError: true);

      context.read<IncidenteBloc>().add(const LimpiarErrorIncidenteEvent());

      return;
    }

    final response = state.createResponse;

    if (response is Success<ApiResponse<RegisterIncidenciaData>>) {
      final registerData = response.data.data;

      final incidenciaId = registerData?.incidencia.id;

      _showMessage(
        context,
        incidenciaId != null
            ? 'Incidencia N.° $incidenciaId registrada correctamente.'
            : 'Incidencia registrada correctamente.',
        isSuccess: true,
      );

      _limpiarFormularioLocal();

      context.read<IncidenteBloc>().add(const LimpiarArchivosLocalesEvent());

      context.read<IncidenteBloc>().add(const LimpiarAccionIncidenteEvent());

      return;
    }

    if (response is ErrorData<ApiResponse<RegisterIncidenciaData>>) {
      _showMessage(context, response.message, isError: true);

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
  // EVIDENCIAS CARD
  // ======================================================

  Widget _buildArchivoLocalItem({
    required BuildContext context,
    required IncidenteState state,
    required File archivo,
    required int index,
  }) {
    final extension = path
        .extension(archivo.path)
        .replaceFirst('.', '')
        .toLowerCase();

    final nombre = path.basename(archivo.path);

    final esImagen = {'jpg', 'jpeg', 'png', 'heic', 'heif'}.contains(extension);

    final esVideo = {'mp4', 'mov'}.contains(extension);

    final esAudio = {'m4a', 'aac', 'mp3', 'wav'}.contains(extension);

    final color = esImagen
        ? Colors.green
        : esVideo
        ? Colors.deepPurple
        : esAudio
        ? Colors.orange.shade800
        : Colors.blueGrey;

    final icon = esImagen
        ? Icons.image_outlined
        : esVideo
        ? Icons.videocam_outlined
        : esAudio
        ? Icons.audio_file_outlined
        : Icons.insert_drive_file_outlined;

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.07),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.20)),
        ),
        child: Row(
          children: [
            if (esImagen && {'jpg', 'jpeg', 'png'}.contains(extension))
              ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Image.file(
                  archivo,
                  width: 46,
                  height: 46,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return _FileIcon(icon: icon, color: color);
                  },
                ),
              )
            else
              _FileIcon(icon: icon, color: color),

            const SizedBox(width: 10),

            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    nombre,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 3),

                  Text(
                    _getArchivoTypeLabel(extension),
                    style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),

            IconButton(
              tooltip: 'Eliminar evidencia',
              onPressed: state.isCreating
                  ? null
                  : () {
                      context.read<IncidenteBloc>().add(
                        EliminarArchivoLocalEvent(index),
                      );
                    },
              icon: const Icon(Icons.close_rounded),
            ),
          ],
        ),
      ),
    );
  }

  String _getArchivoTypeLabel(String extension) {
    if ({'jpg', 'jpeg', 'png', 'heic', 'heif'}.contains(extension)) {
      return 'Imagen · ${extension.toUpperCase()}';
    }

    if ({'mp4', 'mov'}.contains(extension)) {
      return 'Video · ${extension.toUpperCase()}';
    }

    if ({'m4a', 'aac', 'mp3', 'wav'}.contains(extension)) {
      return 'Audio · ${extension.toUpperCase()}';
    }

    return extension.isEmpty ? 'Archivo' : extension.toUpperCase();
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

    final disabled = state.isCreating || state.loadingMedia;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: _cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: const Color.fromARGB(
                    255,
                    12,
                    38,
                    145,
                  ).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.collections_outlined,
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
                          ? 'Seleccionar evidencias'
                          : '$cantidad evidencia${cantidad == 1 ? '' : 's'} seleccionada${cantidad == 1 ? '' : 's'}',
                      style: const TextStyle(fontWeight: FontWeight.w700),
                    ),

                    const SizedBox(height: 3),

                    Text(
                      completo
                          ? 'Se alcanzó el máximo permitido.'
                          : 'Puedes adjuntar hasta $maxArchivos archivos.',
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

              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: completo
                      ? Colors.orange.withValues(alpha: 0.12)
                      : const Color.fromARGB(
                          255,
                          12,
                          38,
                          145,
                        ).withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(99),
                ),
                child: Text(
                  '$cantidad/$maxArchivos',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: completo
                        ? Colors.orange.shade800
                        : const Color.fromARGB(255, 12, 38, 145),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          const Divider(height: 1),

          const SizedBox(height: 14),

          // ===============================================
          // SELECTORES
          // ===============================================
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              _EvidenceActionButton(
                icon: Icons.camera_alt_outlined,
                label: 'Cámara',
                color: Colors.blue,
                enabled: !disabled && !completo,
                onPressed: () {
                  context.read<IncidenteBloc>().add(const TomarFotoEvent());
                },
              ),

              _EvidenceActionButton(
                icon: Icons.photo_library_outlined,
                label: 'Imagen',
                color: Colors.green,
                enabled: !disabled && !completo,
                onPressed: () {
                  context.read<IncidenteBloc>().add(
                    const SeleccionarImagenEvent(),
                  );
                },
              ),

              _EvidenceActionButton(
                icon: Icons.video_library_outlined,
                label: 'Video',
                color: Colors.deepPurple,
                enabled: !disabled && !completo,
                onPressed: () {
                  context.read<IncidenteBloc>().add(
                    const SeleccionarVideoEvent(),
                  );
                },
              ),

              _EvidenceActionButton(
                icon: state.recordingAudio
                    ? Icons.stop_circle_outlined
                    : Icons.mic_none_rounded,
                label: state.recordingAudio ? 'Detener' : 'Audio',
                color: state.recordingAudio
                    ? Colors.red
                    : Colors.orange.shade800,
                enabled: state.recordingAudio || (!disabled && !completo),
                onPressed: () {
                  if (state.recordingAudio) {
                    context.read<IncidenteBloc>().add(
                      const DetenerGrabacionAudioEvent(),
                    );
                  } else {
                    context.read<IncidenteBloc>().add(
                      const IniciarGrabacionAudioEvent(),
                    );
                  }
                },
              ),
            ],
          ),

          if (state.recordingAudio) ...[
            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.red.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.red.withValues(alpha: 0.25)),
              ),
              child: const Row(
                children: [
                  _RecordingIndicator(),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'Grabando audio...',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          if (state.loadingMedia) ...[
            const SizedBox(height: 12),

            const LinearProgressIndicator(),

            const SizedBox(height: 6),

            const Text(
              'Procesando evidencia...',
              style: TextStyle(fontSize: 12),
            ),
          ],

          if (state.archivosLocales.isNotEmpty) ...[
            const SizedBox(height: 16),

            Text(
              'Archivos seleccionados',
              style: Theme.of(
                context,
              ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
            ),

            const SizedBox(height: 10),

            ...state.archivosLocales.asMap().entries.map(
              (entry) => _buildArchivoLocalItem(
                context: context,
                state: state,
                archivo: entry.value,
                index: entry.key,
              ),
            ),
          ],
        ],
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

  void _showMessage(
    BuildContext context,
    String message, {
    bool isError = false,
    bool isSuccess = false,
  }) {
    final colors = Theme.of(context).colorScheme;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? colors.error
              : isSuccess
              ? Colors.green.shade700
              : colors.inverseSurface,
          behavior: SnackBarBehavior.floating,
        ),
      );
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

class _EvidenceActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final bool enabled;
  final VoidCallback onPressed;

  const _EvidenceActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton.icon(
      onPressed: enabled ? onPressed : null,
      icon: Icon(icon, size: 19),
      label: Text(label),
      style: OutlinedButton.styleFrom(
        foregroundColor: color,
        side: BorderSide(
          color: enabled
              ? color.withValues(alpha: 0.45)
              : Theme.of(context).disabledColor.withValues(alpha: 0.25),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}

class _FileIcon extends StatelessWidget {
  final IconData icon;
  final Color color;

  const _FileIcon({required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 46,
      height: 46,
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(9),
      ),
      child: Icon(icon, color: color),
    );
  }
}

class _RecordingIndicator extends StatefulWidget {
  const _RecordingIndicator();

  @override
  State<_RecordingIndicator> createState() => _RecordingIndicatorState();
}

class _RecordingIndicatorState extends State<_RecordingIndicator>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 750),
      lowerBound: 0.35,
      upperBound: 1,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _controller,
      child: Container(
        width: 11,
        height: 11,
        decoration: const BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}
