import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';

class HomeContent extends StatefulWidget {
  const HomeContent({super.key});

  @override
  State<HomeContent> createState() => _HomeContentState();
}

class _HomeContentState extends State<HomeContent> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<HomeBloc>().add(LoadPatrullajeActivo());
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) => prev.patrullaje != curr.patrullaje,
      listener: (context, state) {
        final patrullaje = state.patrullaje;

        if (patrullaje != null) {
        
          context.read<MapaBloc>().add(
            DrawZonaEvent(patrullaje.zona.coordenadas),
          );
        }
      },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          // LOADING
          if (homeState.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          // ERROR
          if (homeState.error != null) {
            return Center(child: Text(homeState.error!));
          }

          // DATA
          final patrullaje = homeState.patrullaje;

          return BlocBuilder<TrackingBloc, TrackingState>(
            builder: (context, trackingState) {
              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // HEADER DINÁMICO
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: patrullaje == null
                          ? const Text(
                              'No tienes patrullaje asignado',
                              style: TextStyle(color: Colors.white),
                            )
                          : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Patrullaje Activo',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                  ),
                                ),
                                const SizedBox(height: 10),

                                Text(
                                  'Zona: ${patrullaje.zona.nombre}',
                                  style: const TextStyle(color: Colors.white),
                                ),

                                Text(
                                  'Riesgo: ${patrullaje.zona.riesgo}',
                                  style: const TextStyle(color: Colors.white),
                                ),

                                Text(
                                  'Horario: ${patrullaje.horaInicio} - ${patrullaje.horaFin}',
                                  style: const TextStyle(color: Colors.white),
                                ),

                                Text(
                                  'Unidad: ${patrullaje.unidad.codigo}',
                                  style: const TextStyle(color: Colors.white),
                                ),

                                const SizedBox(height: 10),

                                //  ESTADO TRACKING
                                Text(
                                  trackingState.isTracking
                                      ? '🟢 En patrullaje'
                                      : '🔴 Sin iniciar',
                                  style: const TextStyle(color: Colors.white),
                                ),
                              ],
                            ),
                    ),

                    const SizedBox(height: 20),

                    // 🔘 BOTÓN PRINCIPAL
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: patrullaje == null
                            ? null
                            : () {
                                // iniciar patrullaje
                                final trackingBloc = context
                                    .read<TrackingBloc>();

                                if (!trackingState.isTracking) {
                                  // INICIAR
                                  trackingBloc.add(
                                    StartPatrullajeEvent(patrullaje.id),
                                  );
                                } else {
                                  // FINALIZAR
                                  trackingBloc.add(
                                    EndPatrullajeEvent(patrullaje.id),
                                  );
                                }
                              },
                        icon: Icon(
                          trackingState.isTracking
                              ? Icons.stop
                              : Icons.play_arrow,
                        ),
                        label: Text(
                          trackingState.isTracking
                              ? 'Finalizar Patrullaje'
                              : 'Iniciar Patrullaje',
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: trackingState.isTracking
                              ? Colors.red
                              : Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // UBICACIÓN EN TIEMPO REAL
                    if (trackingState.lastLocation != null)
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: Text(
                            '📍 ${trackingState.lastLocation!.latitud}, '
                            '${trackingState.lastLocation!.longitud}',
                          ),
                        ),
                      ),

                    const SizedBox(height: 20),

                    // RESUMEN (puedes hacerlo dinámico luego)
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _buildStatCard('Incidencias', '3', Colors.red),
                        _buildStatCard('Alertas', '2', Colors.orange),
                        _buildStatCard('Recorrido', '75%', Colors.green),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ACCIONES RÁPIDAS
                    const Text(
                      'Acciones rápidas',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _quickAction(Icons.report, 'Incidencia'),
                        _quickAction(Icons.warning, 'Alerta'),
                        _quickAction(Icons.location_on, 'Ubicación'),
                      ],
                    ),

                    const SizedBox(height: 20),

                    // ACTIVIDAD RECIENTE
                    const Text(
                      'Actividad reciente',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 10),

                    Container(
                      height: 120,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: Text('Sin actividad reciente'),
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildStatCard(String title, String value, Color color) {
    return Expanded(
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            children: [
              Text(title),
              const SizedBox(height: 5),
              Text(value, style: TextStyle(fontSize: 18, color: color)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _quickAction(IconData icon, String label) {
    return Column(
      children: [
        CircleAvatar(radius: 25, child: Icon(icon)),
        const SizedBox(height: 5),
        Text(label),
      ],
    );
  }
}
