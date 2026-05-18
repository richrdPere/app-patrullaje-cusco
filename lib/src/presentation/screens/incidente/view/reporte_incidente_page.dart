import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

// Models
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

// Bloc
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/bloc/incidente_state.dart';

// Widgets
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/media_preview_widget.dart';

class ReporteIncidentePage extends StatefulWidget {
  const ReporteIncidentePage({super.key});

  @override
  State<ReporteIncidentePage> createState() => _ReporteIncidentePageState();
}

class _ReporteIncidentePageState extends State<ReporteIncidentePage> {
  String? tipoSeleccionado;

  final TextEditingController descripcionCtrl = TextEditingController();

  final List<String> tipos = [
    'ROBO',
    'ACCIDENTE',
    'SOSPECHOSO',
    'VIOLENCIA',
    'INCENDIO',
    'OTRO',
  ];

  @override
  void initState() {
    super.initState();

    // OBTENER UBICACIÓN AUTOMÁTICAMENTE
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<IncidenteBloc>().add(ObtenerUbicacionEvent());
    });
  }

  @override
  void dispose() {
    descripcionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(title: const Text('Reportar Incidencia')),
      body: BlocConsumer<IncidenteBloc, IncidenteState>(
        listener: (context, state) {
          // SUCCESS
          if (state.success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Incidencia reportada correctamente'),
              ),
            );

            context.go('/home');
          }

          // ERROR
          if (state.error != null) {
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text(state.error!)));
          }
        },

        builder: (context, state) {
          return Stack(
            children: [
              _buildContent(context, state),

              // LOADING
              if (state.isLoading)
                Container(
                  color: Colors.black.withOpacity(0.4),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          );
        },
      ),
    );
  }

  // =========================================================
  // CONTENT
  // =========================================================
  Widget _buildContent(BuildContext context, IncidenteState state) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),

            keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,

            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  // =====================================================
                  // TIPO
                  // =====================================================
                  const Text(
                    'Tipo de incidencia',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),

                  const SizedBox(height: 12),

                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: tipos.map((tipo) {
                      return ChoiceChip(
                        label: Text(tipo),
                        selected: tipoSeleccionado == tipo,
                        onSelected: (_) {
                          setState(() {
                            tipoSeleccionado = tipo;
                          });
                        },
                      );
                    }).toList(),
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // DESCRIPCIÓN
                  // =====================================================
                  TextField(
                    controller: descripcionCtrl,
                    maxLines: 4,

                    decoration: const InputDecoration(
                      labelText: 'Descripción',
                      hintText: 'Describe lo sucedido...',
                      border: OutlineInputBorder(),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // UBICACIÓN
                  // =====================================================
                  _buildUbicacion(state),

                  const SizedBox(height: 20),

                  // =====================================================
                  // MULTIMEDIA
                  // =====================================================
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,

                    children: [
                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<IncidenteBloc>().add(TomarFotoEvent());
                        },

                        icon: const Icon(Icons.camera_alt),

                        label: const Text('Foto'),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<IncidenteBloc>().add(GrabarVideoEvent());
                        },

                        icon: const Icon(Icons.videocam),

                        label: const Text('Video'),
                      ),

                      ElevatedButton.icon(
                        onPressed: () {
                          context.read<IncidenteBloc>().add(
                            SeleccionarImagenEvent(),
                          );
                        },

                        icon: const Icon(Icons.photo_library),

                        label: const Text('Galería'),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // =====================================================
                  // PREVIEW MEDIA
                  // =====================================================
                  const MediaPreviewWidget(),

                  const SizedBox(height: 30),

                  // =====================================================
                  // BOTÓN ENVIAR
                  // =====================================================
                  SizedBox(
                    width: double.infinity,

                    child: ElevatedButton(
                      onPressed: state.isLoading
                          ? null
                          : () => _enviarIncidencia(context),

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),

                      child: const Text(
                        'ENVIAR REPORTE',

                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // =========================================================
  // CARD UBICACIÓN
  // =========================================================
  Widget _buildUbicacion(IncidenteState state) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.green[50],
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.green.shade300),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.location_on, color: Colors.green),
              SizedBox(width: 8),
              Text(
                'Ubicación actual',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),

          const SizedBox(height: 10),

          if (state.latitud != null) Text('Latitud: ${state.latitud}'),

          if (state.longitud != null) Text('Longitud: ${state.longitud}'),

          if (state.direccion != null)
            Padding(
              padding: const EdgeInsets.only(top: 6),

              child: Text(state.direccion!),
            ),

          if (state.latitud == null) const Text('Obteniendo ubicación...'),
        ],
      ),
    );
  }

  // =========================================================
  // ENVIAR INCIDENTE
  // =========================================================
  Future<void> _enviarIncidencia(BuildContext context) async {
    if (tipoSeleccionado == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Seleccione un tipo')));

      return;
    }

    if (descripcionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese una descripción')));

      return;
    }

    final blocState = context.read<IncidenteBloc>().state;

    // VALIDAR UBICACIÓN
    if (blocState.latitud == null || blocState.longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener ubicación')),
      );

      return;
    }

    try {
      // TODO:
      // OBTENER DE AUTH
      final usuarioId = 1;

      // TODO:
      // OBTENER DE PATRULLAJE ACTIVO
      final patrullajeId = 1;

      // TODO:
      // OBTENER ZONA ACTUAL
      final zonaId = 1;

      final params = IncidenteModel(
        usuarioId: usuarioId,
        patrullajeId: patrullajeId,
        zonaId: zonaId,
        tipo: tipoSeleccionado!,
        descripcion: descripcionCtrl.text.trim(),
        latitud: blocState.latitud!,
        longitud: blocState.longitud!,
        archivos: blocState.archivos,
      );

      print(
        "📂 ARCHIVOS: "
        "${blocState.archivos.length}",
      );

      context.read<IncidenteBloc>().add(CrearIncidenteEvent(params));
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error: $e')));
    }
  }
}
