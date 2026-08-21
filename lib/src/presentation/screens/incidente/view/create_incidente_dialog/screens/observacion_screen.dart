import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';

// Models
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/enum/historial_enum.dart';

// Home
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';

// Historial BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

// Incidencia BLoC: reutilizado para ubicación
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

  HistorialTipo _tipoSeleccionado = HistorialTipo.observacion;

  HistorialPrioridad _prioridadSeleccionada = HistorialPrioridad.media;

  static const int _maxImagenes = 5;

  final ImagePicker _imagePicker = ImagePicker();

  final List<XFile> _imagenesSeleccionadas = [];

  bool _visibleSiguienteTurno = true;
  bool _incluirUbicacion = false;

  // ========================================================
  // CICLO DE VIDA
  // ========================================================
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        return;
      }

      /*
       * Evita conservar un resultado antiguo de otra
       * operación del módulo de historial.
       */
      context.read<HistorialPatrullajeBloc>().add(
        const ClearHistorialActionEvent(),
      );

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

  // ========================================================
  // BUILD
  // ========================================================
  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeBloc>().state;

    final patrullaje = homeState.patrullaje;

    return BlocListener<HistorialPatrullajeBloc, HistorialPatrullajeState>(
      listenWhen: (previous, current) {
        final changed = previous.actionStatus != current.actionStatus;

        final isFinalStatus =
            current.actionStatus == HistorialActionStatus.success ||
            current.actionStatus == HistorialActionStatus.error;

        return changed && isFinalStatus;
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

                const SizedBox(height: 24),

                _buildSectionTitle(
                  icon: Icons.photo_camera_outlined,
                  title: 'Evidencias fotográficas',
                  subtitle: 'Puedes adjuntar hasta $_maxImagenes imágenes.',
                ),

                const SizedBox(height: 12),

                _buildImagesSection(),

                const SizedBox(height: 24),

                _buildLocationOption(incidenteState),

                const SizedBox(height: 28),

                BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
                  buildWhen: (previous, current) {
                    return previous.actionStatus != current.actionStatus;
                  },

                  builder: (context, historialState) {
                    return _buildSubmitButton(
                      context: context,

                      historialState: historialState,

                      incidenteState: incidenteState,

                      patrullajeId: patrullaje?.id,
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

  // ========================================================
  // LISTENER DEL HISTORIAL
  // ========================================================
  void _onHistorialStateChanged(
    BuildContext context,
    HistorialPatrullajeState state,
  ) {
    if (state.actionStatus == HistorialActionStatus.success) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.actionMessage ?? 'Observación registrada correctamente.',
            ),
            backgroundColor: Colors.green.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

      _limpiarFormulario();

      context.read<HistorialPatrullajeBloc>().add(
        const ClearHistorialActionEvent(),
      );

      return;
    }

    if (state.actionStatus == HistorialActionStatus.error) {
      ScaffoldMessenger.of(context)
        ..hideCurrentSnackBar()
        ..showSnackBar(
          SnackBar(
            content: Text(
              state.errorMessage ?? 'No se pudo registrar la observación.',
            ),
            backgroundColor: Colors.red.shade700,
            behavior: SnackBarBehavior.floating,
          ),
        );

      context.read<HistorialPatrullajeBloc>().add(
        const ClearHistorialActionEvent(),
      );
    }
  }

  // ========================================================
  // LIMPIAR FORMULARIO
  // ========================================================
  void _limpiarFormulario() {
    _tituloController.clear();
    _descripcionController.clear();

    if (!mounted) {
      return;
    }

    setState(() {
      _tipoSeleccionado = HistorialTipo.observacion;

      _prioridadSeleccionada = HistorialPrioridad.media;

      _visibleSiguienteTurno = true;

      _incluirUbicacion = false;

      _imagenesSeleccionadas.clear();
    });
  }

  // ========================================================
  // INFORMACIÓN
  // ========================================================
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

  // ==========================================================
  // EVIDENCIAS FOTOGRÁFICAS
  // ==========================================================
  Widget _buildImagesSection() {
    return Container(
      width: double.infinity,

      padding: const EdgeInsets.all(14),

      decoration: _cardDecoration(),

      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,

        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  _imagenesSeleccionadas.isEmpty
                      ? 'No hay imágenes seleccionadas.'
                      : '${_imagenesSeleccionadas.length} de $_maxImagenes imágenes seleccionadas.',

                  style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
                ),
              ),

              if (_imagenesSeleccionadas.isNotEmpty)
                TextButton(
                  onPressed: _eliminarTodasLasImagenes,

                  child: const Text('Quitar todas'),
                ),
            ],
          ),

          if (_imagenesSeleccionadas.isNotEmpty) ...[
            const SizedBox(height: 10),

            SizedBox(
              height: 110,

              child: ListView.separated(
                scrollDirection: Axis.horizontal,

                itemCount: _imagenesSeleccionadas.length,

                separatorBuilder: (context, index) {
                  return const SizedBox(width: 10);
                },

                itemBuilder: (context, index) {
                  return _buildImagePreview(
                    image: _imagenesSeleccionadas[index],

                    index: index,
                  );
                },
              ),
            ),

            const SizedBox(height: 14),
          ],

          SizedBox(
            width: double.infinity,

            child: OutlinedButton.icon(
              onPressed: _imagenesSeleccionadas.length >= _maxImagenes
                  ? null
                  : _showImageSourceSelector,

              icon: const Icon(Icons.add_a_photo_outlined),

              label: Text(
                _imagenesSeleccionadas.length >= _maxImagenes
                    ? 'LÍMITE DE IMÁGENES ALCANZADO'
                    : 'AGREGAR IMÁGENES',
              ),

              style: OutlinedButton.styleFrom(
                minimumSize: const Size.fromHeight(46),

                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),

          const SizedBox(height: 8),

          Text(
            'Formatos permitidos: JPG, JPEG, PNG, HEIC y HEIF.',

            style: TextStyle(fontSize: 11, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview({required XFile image, required int index}) {
    return Stack(
      clipBehavior: Clip.none,

      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),

          child: Image.file(
            File(image.path),

            width: 110,

            height: 110,

            fit: BoxFit.cover,

            errorBuilder: (context, error, stackTrace) {
              return Container(
                width: 110,

                height: 110,

                color: Colors.grey.shade200,

                alignment: Alignment.center,

                child: const Icon(
                  Icons.broken_image_outlined,
                  color: Colors.grey,
                ),
              );
            },
          ),
        ),

        Positioned(
          top: 5,

          right: 5,

          child: Material(
            color: Colors.black.withValues(alpha: 0.65),

            shape: const CircleBorder(),

            child: InkWell(
              customBorder: const CircleBorder(),

              onTap: () {
                _eliminarImagen(index);
              },

              child: const Padding(
                padding: EdgeInsets.all(5),

                child: Icon(Icons.close_rounded, size: 17, color: Colors.white),
              ),
            ),
          ),
        ),

        Positioned(
          bottom: 5,

          left: 5,

          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),

            decoration: BoxDecoration(
              color: Colors.black.withValues(alpha: 0.65),

              borderRadius: BorderRadius.circular(20),
            ),

            child: Text(
              '${index + 1}',

              style: const TextStyle(
                color: Colors.white,

                fontSize: 11,

                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _showImageSourceSelector() async {
    if (_imagenesSeleccionadas.length >= _maxImagenes) {
      _showMessage(
        context,
        'Solo puedes adjuntar hasta $_maxImagenes imágenes.',
      );

      return;
    }

    await showModalBottomSheet<void>(
      context: context,

      showDragHandle: true,

      builder: (bottomSheetContext) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),

            child: Column(
              mainAxisSize: MainAxisSize.min,

              children: [
                const ListTile(
                  title: Text(
                    'Agregar evidencia',
                    style: TextStyle(fontWeight: FontWeight.w700),
                  ),

                  subtitle: Text('Selecciona el origen de la imagen.'),
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.camera_alt_outlined),
                  ),

                  title: const Text('Tomar fotografía'),

                  subtitle: const Text('Usar la cámara del dispositivo.'),

                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();

                    _tomarFotografia();
                  },
                ),

                ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.photo_library_outlined),
                  ),

                  title: const Text('Seleccionar de la galería'),

                  subtitle: const Text('Elegir una o varias imágenes.'),

                  onTap: () {
                    Navigator.of(bottomSheetContext).pop();

                    _seleccionarDesdeGaleria();
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _tomarFotografia() async {
    try {
      final image = await _imagePicker.pickImage(
        source: ImageSource.camera,

        imageQuality: 85,

        maxWidth: 1920,

        maxHeight: 1920,
      );

      if (image == null || !mounted) {
        return;
      }

      _agregarImagenes([image]);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(context, 'No se pudo tomar la fotografía.');
    }
  }

  Future<void> _seleccionarDesdeGaleria() async {
    try {
      final images = await _imagePicker.pickMultiImage(
        imageQuality: 85,

        maxWidth: 1920,

        maxHeight: 1920,
      );

      if (images.isEmpty || !mounted) {
        return;
      }

      _agregarImagenes(images);
    } catch (error) {
      if (!mounted) {
        return;
      }

      _showMessage(context, 'No se pudieron seleccionar las imágenes.');
    }
  }

  void _agregarImagenes(List<XFile> nuevasImagenes) {
    final espaciosDisponibles = _maxImagenes - _imagenesSeleccionadas.length;

    if (espaciosDisponibles <= 0) {
      _showMessage(
        context,
        'Ya alcanzaste el límite de $_maxImagenes imágenes.',
      );

      return;
    }

    final rutasExistentes = _imagenesSeleccionadas
        .map((image) => image.path)
        .toSet();

    final imagenesSinDuplicar = nuevasImagenes
        .where((image) => !rutasExistentes.contains(image.path))
        .take(espaciosDisponibles)
        .toList();

    setState(() {
      _imagenesSeleccionadas.addAll(imagenesSinDuplicar);
    });

    if (nuevasImagenes.length > imagenesSinDuplicar.length) {
      _showMessage(
        context,
        'Solo se agregaron las imágenes disponibles hasta completar el límite de $_maxImagenes.',
      );
    }
  }

  void _eliminarImagen(int index) {
    if (index < 0 || index >= _imagenesSeleccionadas.length) {
      return;
    }

    setState(() {
      _imagenesSeleccionadas.removeAt(index);
    });
  }

  void _eliminarTodasLasImagenes() {
    setState(() {
      _imagenesSeleccionadas.clear();
    });
  }

  // ========================================================
  // TÍTULOS
  // ========================================================
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

  // ========================================================
  // TIPO
  // ========================================================
  Widget _buildTipoSelector() {
    return Wrap(
      spacing: 8,

      runSpacing: 10,

      children: HistorialTipo.values.map((tipo) {
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

              if (tipo == HistorialTipo.alerta ||
                  tipo == HistorialTipo.puntoCritico) {
                _prioridadSeleccionada = HistorialPrioridad.alta;
              }

              if (tipo == HistorialTipo.cambioTurno) {
                _visibleSiguienteTurno = true;
              }
            });
          },
        );
      }).toList(),
    );
  }

  // ========================================================
  // TÍTULO
  // ========================================================
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

  // ========================================================
  // DESCRIPCIÓN
  // ========================================================
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

  // ========================================================
  // PRIORIDAD
  // ========================================================
  Widget _buildPrioridadSelector() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,

      child: SegmentedButton<HistorialPrioridad>(
        segments: const [
          ButtonSegment(
            value: HistorialPrioridad.baja,

            label: Text('Baja'),

            icon: Icon(Icons.low_priority),
          ),

          ButtonSegment(
            value: HistorialPrioridad.media,

            label: Text('Media'),

            icon: Icon(Icons.drag_handle),
          ),

          ButtonSegment(
            value: HistorialPrioridad.alta,

            label: Text('Alta'),

            icon: Icon(Icons.priority_high),
          ),

          ButtonSegment(
            value: HistorialPrioridad.critica,

            label: Text('Crítica'),

            icon: Icon(Icons.warning_amber_rounded),
          ),
        ],

        selected: {_prioridadSeleccionada},

        onSelectionChanged: (values) {
          setState(() {
            _prioridadSeleccionada = values.first;
          });
        },
      ),
    );
  }

  // ========================================================
  // UBICACIÓN
  // ========================================================
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

  // ========================================================
  // SIGUIENTE TURNO
  // ========================================================
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

  // ========================================================
  // BOTÓN REGISTRAR
  // ========================================================
  Widget _buildSubmitButton({
    required BuildContext context,
    required HistorialPatrullajeState historialState,
    required IncidenteState incidenteState,
    required int? patrullajeId,
  }) {
    final loading = historialState.isProcessingAction;

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

  // ========================================================
  // REGISTRAR OBSERVACIÓN
  // ========================================================
  void _registrarObservacion({
    required BuildContext context,
    required IncidenteState incidenteState,
    required int? patrullajeId,
  }) {
    FocusScope.of(context).unfocus();

    final formIsValid = _formKey.currentState?.validate() ?? false;

    if (!formIsValid) {
      return;
    }

    if (patrullajeId == null || patrullajeId <= 0) {
      _showMessage(context, 'No existe un patrullaje activo.');

      return;
    }

    if (_incluirUbicacion && !incidenteState.tieneUbicacion) {
      _showMessage(context, 'No se pudo obtener la ubicación.');

      return;
    }

    final request = CreateHistorialRequest(
      patrullajeId: patrullajeId,

      tipo: _tipoSeleccionado,

      titulo: _tituloController.text.trim(),

      descripcion: _descripcionController.text.trim(),

      prioridad: _prioridadSeleccionada,

      latitud: _incluirUbicacion ? incidenteState.latitud : null,

      longitud: _incluirUbicacion ? incidenteState.longitud : null,

      visibleParaSiguienteTurno: _visibleSiguienteTurno,
    );

    final archivos = _imagenesSeleccionadas
        .map((image) => File(image.path))
        .toList();

    if (archivos.isNotEmpty) {
      context.read<HistorialPatrullajeBloc>().add(
        CreateObservacionConArchivosEvent(request: request, archivos: archivos),
      );

      return;
    }

    context.read<HistorialPatrullajeBloc>().add(
      CreateHistorialEvent(request: request),
    );
  }

  // ========================================================
  // HELPERS
  // ========================================================
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
      ..showSnackBar(
        SnackBar(content: Text(message), behavior: SnackBarBehavior.floating),
      );
  }

  String _getTipoLabel(HistorialTipo tipo) {
    switch (tipo) {
      case HistorialTipo.observacion:
        return 'Observación';

      case HistorialTipo.novedad:
        return 'Novedad';

      case HistorialTipo.alerta:
        return 'Alerta';

      case HistorialTipo.recomendacion:
        return 'Recomendación';

      case HistorialTipo.puntoCritico:
        return 'Punto crítico';

      case HistorialTipo.cambioTurno:
        return 'Cambio de turno';
    }
  }

  IconData _getTipoIcon(HistorialTipo tipo) {
    switch (tipo) {
      case HistorialTipo.observacion:
        return Icons.visibility_outlined;

      case HistorialTipo.novedad:
        return Icons.new_releases_outlined;

      case HistorialTipo.alerta:
        return Icons.warning_amber_rounded;

      case HistorialTipo.recomendacion:
        return Icons.lightbulb_outline;

      case HistorialTipo.puntoCritico:
        return Icons.location_on_outlined;

      case HistorialTipo.cambioTurno:
        return Icons.swap_horiz;
    }
  }
}
