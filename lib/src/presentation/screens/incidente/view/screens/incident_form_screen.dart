import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';
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
  final descripcionCtrl = TextEditingController();
  TipoIncidente? selectedTipo;

  @override
  void initState() {
    super.initState();

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
    final patrullaje = context.watch<HomeBloc>().state.patrullaje;

    return BlocConsumer<IncidenteBloc, IncidenteState>(
      listener: _listener,
      builder: (context, state) {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTipoIncidente(),
              const SizedBox(height: 24),

              _buildDescripcion(),
              const SizedBox(height: 20),

              _buildUbicacion(state),
              const SizedBox(height: 20),

              _buildEvidenciasHeader(),
              const SizedBox(height: 12),

              _buildEvidenciasActions(context),
              const SizedBox(height: 12),

              _buildEvidenciasPreview(context, state),
              const SizedBox(height: 30),

              _buildSubmitButton(context, state, patrullaje),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  // LISTENER
  void _listener(BuildContext context, IncidenteState state) {
    if (state.success) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Incidencia registrada correctamente')),
      );

      Navigator.pop(context);
    }

    if (state.error != null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(state.error!)));
    }
  }

  // TIPO INCIDENTE
  Widget _buildTipoIncidente() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Tipo de incidente',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 12),

        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: TipoIncidente.values.map((tipo) {
            final selected = selectedTipo == tipo;

            return ChoiceChip(
              selected: selected,
              label: Text(_getTitle(tipo)),
              onSelected: (_) {
                setState(() {
                  selectedTipo = tipo;
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  // DESCRIPCION
  Widget _buildDescripcion() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Descripción',
          style: TextStyle(fontWeight: FontWeight.w600),
        ),

        const SizedBox(height: 8),

        TextField(
          controller: descripcionCtrl,
          maxLines: 3,
          maxLength: 300,
          decoration: InputDecoration(
            hintText: 'Describe lo sucedido...',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ],
    );
  }

  // UBICACION
  Widget _buildUbicacion(IncidenteState state) {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.location_on, color: Colors.red),

        title: const Text('Ubicación actual'),

        subtitle: Text(
          state.direccion ??
              '${state.latitud ?? '-'}, ${state.longitud ?? '-'}',
        ),
      ),
    );
  }

  // HEADER EVIDENCIAS
  Widget _buildEvidenciasHeader() {
    return const Text(
      'Evidencias fotográficas',
      style: TextStyle(fontWeight: FontWeight.w600),
    );
  }

  // ACCIONES EVIDENCIAS
  Widget _buildEvidenciasActions(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.camera_alt),
            label: const Text('Tomar foto'),
            onPressed: () {
              context.read<IncidenteBloc>().add(const TomarFotoEvent());
            },
          ),
        ),

        const SizedBox(width: 12),

        Expanded(
          child: ElevatedButton.icon(
            icon: const Icon(Icons.photo_library),
            label: const Text('Galería'),
            onPressed: () {
              context.read<IncidenteBloc>().add(const SeleccionarImagenEvent());
            },
          ),
        ),
      ],
    );
  }

  // PREVIEW EVIDENCIAS
  Widget _buildEvidenciasPreview(BuildContext context, IncidenteState state) {
    if (state.archivos.isEmpty) {
      return const SizedBox();
    }

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: state.archivos.length,
        separatorBuilder: (_, __) => const SizedBox(width: 10),

        itemBuilder: (_, index) {
          final archivo = state.archivos[index];

          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(
                  archivo,
                  width: 110,
                  height: 110,
                  fit: BoxFit.cover,
                ),
              ),

              Positioned(
                top: 4,
                right: 4,
                child: GestureDetector(
                  onTap: () {
                    context.read<IncidenteBloc>().add(
                      EliminarArchivoEvent(index),
                    );
                  },
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Padding(
                      padding: EdgeInsets.all(4),
                      child: Icon(Icons.close, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // BUTTON REGISTRAR
  Widget _buildSubmitButton(
    BuildContext context,
    IncidenteState state,
    PatrullajeModel? patrullaje,
  ) {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        icon: const Icon(Icons.send),

        label: Text(state.isLoading ? 'Enviando...' : 'REPORTAR INCIDENTE'),

        onPressed: state.isLoading
            ? null
            : () => _submitIncidente(context, state, patrullaje),
      ),
    );
  }

  // METODO REGISTRAR INCIDENTE
  void _submitIncidente(
    BuildContext context,
    IncidenteState state,
    PatrullajeModel? patrullaje,
  ) {
    // todas las validaciones

    if (selectedTipo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Seleccione un tipo de incidente')),
      );
      return;
    }

    if (descripcionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Ingrese una descripción')));
      return;
    }

    if (state.latitud == null || state.longitud == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se pudo obtener la ubicación')),
      );
      return;
    }

    if (patrullaje == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No existe un patrullaje activo')),
      );
      return;
    }

    if (state.archivos.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Debe adjuntar al menos una fotografía')),
      );
      return;
    }

    if (state.archivos.length > 5) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Máximo 5 evidencias permitidas')),
      );
      return;
    }

    final incidente = IncidenteModel(
      patrullajeId: patrullaje.id,
      tipo: selectedTipo!.name.toUpperCase(),
      descripcion: descripcionCtrl.text.trim(),
      latitud: state.latitud!,
      longitud: state.longitud!,
      archivos: state.archivos,
    );

    context.read<IncidenteBloc>().add(CrearIncidenteEvent(incidente));
  }

  String _getTitle(TipoIncidente tipo) {
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
}
