import 'package:flutter/material.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';

class HistorialObservacionDialog extends StatefulWidget {
  final int patrullajeId;
  final int zonaId;

  const HistorialObservacionDialog({
    super.key,
    required this.patrullajeId,
    required this.zonaId,
  });

  @override
  State<HistorialObservacionDialog> createState() =>
      _HistorialObservacionDialogState();
}

class _HistorialObservacionDialogState
    extends State<HistorialObservacionDialog> {
  final _formKey = GlobalKey<FormState>();

  final tituloController = TextEditingController();
  final descripcionController = TextEditingController();
  String tipo = "OBSERVACION";
  String prioridad = "MEDIA";
  bool visible = true;

  @override
  Widget build(BuildContext context) {
    return Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          title: const Text("Nueva observación"),

          leading: IconButton(
            onPressed: () {
              Navigator.pop(context);
            },

            icon: const Icon(Icons.close),
          ),
        ),

        body: SafeArea(
          child: Form(
            key: _formKey,

            child: ListView(
              padding: const EdgeInsets.all(20),

              children: [
                DropdownButtonFormField<String>(
                  value: tipo,

                  decoration: const InputDecoration(labelText: "Tipo"),

                  items: const [
                    DropdownMenuItem(
                      value: "OBSERVACION",
                      child: Text("Observación"),
                    ),

                    DropdownMenuItem(value: "NOVEDAD", child: Text("Novedad")),

                    DropdownMenuItem(
                      value: "RECOMENDACION",
                      child: Text("Recomendación"),
                    ),

                    DropdownMenuItem(
                      value: "PUNTO_CRITICO",
                      child: Text("Punto crítico"),
                    ),
                  ],

                  onChanged: (value) {
                    tipo = value!;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: tituloController,

                  decoration: const InputDecoration(labelText: "Título"),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Ingrese un título";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                TextFormField(
                  controller: descripcionController,

                  maxLines: 6,

                  decoration: const InputDecoration(
                    labelText: "Descripción",
                    alignLabelWithHint: true,
                  ),

                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return "Ingrese una descripción";
                    }

                    return null;
                  },
                ),

                const SizedBox(height: 20),

                DropdownButtonFormField<String>(
                  value: prioridad,

                  decoration: const InputDecoration(labelText: "Prioridad"),

                  items: const [
                    DropdownMenuItem(value: "BAJA", child: Text("Baja")),

                    DropdownMenuItem(value: "MEDIA", child: Text("Media")),

                    DropdownMenuItem(value: "ALTA", child: Text("Alta")),

                    DropdownMenuItem(value: "CRITICA", child: Text("Crítica")),
                  ],

                  onChanged: (value) {
                    prioridad = value!;
                  },
                ),

                const SizedBox(height: 20),

                SwitchListTile(
                  value: visible,

                  title: const Text("Visible para el siguiente turno"),

                  onChanged: (value) {
                    setState(() {
                      visible = value;
                    });
                  },
                ),

                const SizedBox(height: 40),

                FilledButton.icon(
                  onPressed: () async {
                    if (!_formKey.currentState!.validate()) {
                      return;
                    }

                    // TODO:
                    // Obtener la ubicación GPS actual si deseas registrar
                    // la posición de la observación.

                    // final historial = HistorialPatrullajeModel(
                    //   // patrullajeId: widget.patrullajeId,
                    //   tipo: tipo,
                    //   titulo: tituloController.text.trim(),
                    //   descripcion: descripcionController.text.trim(),
                    //   prioridad: prioridad,
                    //   latitud: null,
                    //   longitud: null,
                    //   visibleParaSiguienteTurno: visible,
                    //   fechaHora: DateTime.now(),
                    //   // estado: "ACTIVO",
                    // );

                    // context.read<HistorialPatrullajeBloc>().add(
                    //   RegisterHistorialEvent(historial),
                    // );

                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.save),
                  label: const Text("Registrar observación"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
