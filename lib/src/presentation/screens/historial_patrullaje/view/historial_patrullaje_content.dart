import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/view/historial_observacion_dialog.dart';

class HistorialPatrullajeContent extends StatelessWidget {
  const HistorialPatrullajeContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Historial del patrullaje')),

      body: BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
        builder: (context, state) {
          if (state.loading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state.historial.isEmpty) {
            return const Center(
              child: Text('No existen registros de historial.'),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: state.historial.length,
            itemBuilder: (_, index) {
              final historial = state.historial[index];

              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  leading: const Icon(Icons.history),
                  title: Text(historial.titulo),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 4),
                      Text(historial.descripcion),
                      const SizedBox(height: 8),
                      Text(
                        historial.tipo,
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),

      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Próximo paso:
          // abrir formulario para registrar observación.
          await showDialog(
            context: context,
            barrierDismissible: false,
            builder: (_) => HistorialObservacionDialog(
              patrullajeId: 1,
              zonaId: 1,
            ),
          );
        },

        child: const Icon(Icons.add),
      ),
    );
  }
}
