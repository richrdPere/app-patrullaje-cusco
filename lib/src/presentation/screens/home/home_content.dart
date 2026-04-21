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
import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_appbar.dart';

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
      listener: _handlePatrullajeListener,
      // listener: (context, state) {
      //   final patrullaje = state.patrullaje;

      //   if (patrullaje != null) {
      //     // 1. DIBUJAR ZONA
      //     context.read<MapaBloc>().add(
      //       DrawZonaEvent(patrullaje.zona.coordenadas),
      //     );

      //     // 2. INICIAR TRACKING AUTOMÁTICO
      //     context.read<TrackingBloc>().add(StartTrackingEvent());
      //   } else {
      //     // 3. detener tracking si no hay patrullaje
      //     context.read<TrackingBloc>().add(StopTrackingEvent());
      //   }
      // },
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          // LOADING
          if (homeState.isLoading) return _buildLoading();

          // ERROR
          if (homeState.error != null) return _buildError(homeState.error!);

          // DATA
          // final patrullaje = homeState.patrullaje;

          return BlocBuilder<TrackingBloc, TrackingState>(
            builder: (context, trackingState) {
              return Scaffold(
                appBar: CustomAppBar(),
                body: _buildBody(context, homeState, trackingState),
                // body: SingleChildScrollView(
                //   padding: const EdgeInsets.all(16),
                //   child: Column(
                //     crossAxisAlignment: CrossAxisAlignment.start,
                //     children: [
                //       // HEADER DINÁMICO
                //       Container(
                //         width: double.infinity,
                //         padding: const EdgeInsets.all(20),
                //         decoration: BoxDecoration(
                //           color: Colors.blue,
                //           borderRadius: BorderRadius.circular(15),
                //         ),
                //         child: patrullaje == null
                //             ? const Text(
                //                 'No tienes patrullaje asignado',
                //                 style: TextStyle(color: Colors.white),
                //               )
                //             : Column(
                //                 crossAxisAlignment: CrossAxisAlignment.start,
                //                 children: [
                //                   const Text(
                //                     'Patrullaje Activo',
                //                     style: TextStyle(
                //                       color: Colors.white,
                //                       fontSize: 18,
                //                     ),
                //                   ),
                //                   const SizedBox(height: 10),

                //                   Text(
                //                     'Zona: ${patrullaje.zona.nombre}',
                //                     style: const TextStyle(color: Colors.white),
                //                   ),

                //                   Text(
                //                     'Riesgo: ${patrullaje.zona.riesgo}',
                //                     style: const TextStyle(color: Colors.white),
                //                   ),

                //                   Text(
                //                     'Horario: ${patrullaje.horaInicio} - ${patrullaje.horaFin}',
                //                     style: const TextStyle(color: Colors.white),
                //                   ),

                //                   Text(
                //                     'Unidad: ${patrullaje.unidad.codigo}',
                //                     style: const TextStyle(color: Colors.white),
                //                   ),

                //                   const SizedBox(height: 10),

                //                   //  ESTADO TRACKING
                //                   Text(
                //                     trackingState.isTracking
                //                         ? '🟢 En patrullaje'
                //                         : '🔴 Sin iniciar',
                //                     style: const TextStyle(color: Colors.white),
                //                   ),
                //                 ],
                //               ),
                //       ),

                //       const SizedBox(height: 20),

                //       // 🔘 BOTÓN PRINCIPAL
                //       SizedBox(
                //         width: double.infinity,
                //         child: ElevatedButton.icon(
                //           onPressed: patrullaje == null
                //               ? null
                //               : () {
                //                   // iniciar patrullaje
                //                   final trackingBloc = context
                //                       .read<TrackingBloc>();

                //                   // context.read<TrackingBloc>().add(
                //                   //   ConnectSocketIO(),
                //                   // );

                //                   if (!trackingState.isTracking) {
                //                     // INICIAR
                //                     trackingBloc.add(
                //                       StartPatrullajeEvent(patrullaje.id),
                //                     );
                //                   } else {
                //                     // FINALIZAR
                //                     trackingBloc.add(
                //                       EndPatrullajeEvent(patrullaje.id),
                //                     );
                //                   }
                //                 },
                //           icon: Icon(
                //             trackingState.isTracking
                //                 ? Icons.stop
                //                 : Icons.play_arrow,
                //           ),
                //           label: Text(
                //             trackingState.isTracking
                //                 ? 'Finalizar Patrullaje'
                //                 : 'Iniciar Patrullaje',
                //           ),
                //           style: ElevatedButton.styleFrom(
                //             backgroundColor: trackingState.isTracking
                //                 ? Colors.red
                //                 : Colors.green,
                //             padding: const EdgeInsets.symmetric(vertical: 15),
                //           ),
                //         ),
                //       ),

                //       const SizedBox(height: 20),

                //       // UBICACIÓN EN TIEMPO REAL
                //       if (trackingState.lastLocation != null)
                //         Card(
                //           child: Padding(
                //             padding: const EdgeInsets.all(10),
                //             child: Text(
                //               '📍 ${trackingState.lastLocation!.latitud}, '
                //               '${trackingState.lastLocation!.longitud}',
                //             ),
                //           ),
                //         ),

                //       const SizedBox(height: 20),

                //       // RESUMEN (puedes hacerlo dinámico luego)
                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceBetween,
                //         children: [
                //           _buildStatCard('Incidencias', '3', Colors.red),
                //           _buildStatCard('Alertas', '2', Colors.orange),
                //           _buildStatCard('Recorrido', '75%', Colors.green),
                //         ],
                //       ),

                //       const SizedBox(height: 20),

                //       // ACCIONES RÁPIDAS
                //       const Text(
                //         'Acciones rápidas',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),

                //       const SizedBox(height: 10),

                //       Row(
                //         mainAxisAlignment: MainAxisAlignment.spaceAround,
                //         children: [
                //           _quickAction(Icons.report, 'Incidencia'),
                //           _quickAction(Icons.warning, 'Alerta'),
                //           _quickAction(Icons.location_on, 'Ubicación'),
                //         ],
                //       ),

                //       const SizedBox(height: 20),

                //       // ACTIVIDAD RECIENTE
                //       const Text(
                //         'Actividad reciente',
                //         style: TextStyle(
                //           fontSize: 18,
                //           fontWeight: FontWeight.bold,
                //         ),
                //       ),

                //       const SizedBox(height: 10),

                //       Container(
                //         height: 120,
                //         width: double.infinity,
                //         decoration: BoxDecoration(
                //           color: Colors.grey[200],
                //           borderRadius: BorderRadius.circular(10),
                //         ),
                //         child: const Center(
                //           child: Text('Sin actividad reciente'),
                //         ),
                //       ),
                //     ],
                //   ),
                // ),
              );
            },
          );
        },
      ),
    );
  }

  void _handlePatrullajeListener(BuildContext context, HomeState state) {
    final patrullaje = state.patrullaje;

    if (patrullaje != null) {
      // Dibujar zona
      context.read<MapaBloc>().add(DrawZonaEvent(patrullaje.zona.coordenadas));

      // SOLO si está activo
      if (patrullaje.estado == "EN_CURSO") {
        context.read<TrackingBloc>().add(StartTrackingEvent());
      }
    } else {
      context.read<TrackingBloc>().add(StopTrackingEvent());
    }
  }

  Widget _buildBody(
    BuildContext context,
    HomeState homeState,
    TrackingState trackingState,
  ) {
    final patrullaje = homeState.patrullaje;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(patrullaje, trackingState),
          const SizedBox(height: 20),
          _buildMainButton(context, patrullaje, trackingState),
          const SizedBox(height: 20),
          _buildLocationCard(trackingState),
          const SizedBox(height: 20),
          _buildStats(),
          const SizedBox(height: 20),
          // _quickAction(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _quickAction(Icons.report, 'Incidencia'),
              _quickAction(Icons.warning, 'Alerta'),
              _quickAction(Icons.location_on, 'Ubicación'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(patrullaje, TrackingState trackingState) {
    return Container(
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
                  style: TextStyle(color: Colors.white),
                ),
                Text(
                  'Zona: ${patrullaje.zona.nombre}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  trackingState.isTracking
                      ? '🟢 En patrullaje'
                      : '🔴 Sin iniciar',
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    patrullaje,
    TrackingState trackingState,
  ) {
    if (patrullaje == null) return const SizedBox();

    final trackingBloc = context.read<TrackingBloc>();

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () {
          if (!trackingState.isTracking) {
            trackingBloc.add(StartPatrullajeEvent(patrullaje.id));
          } else {
            trackingBloc.add(EndPatrullajeEvent(patrullaje.id));
          }
        },
        icon: Icon(trackingState.isTracking ? Icons.stop : Icons.play_arrow),
        label: Text(
          trackingState.isTracking
              ? 'Finalizar Patrullaje'
              : 'Iniciar Patrullaje',
        ),
      ),
    );
  }

  Widget _buildLocationCard(TrackingState trackingState) {
    if (trackingState.lastLocation == null) return const SizedBox();

    final loc = trackingState.lastLocation!;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Text('📍 ${loc.latitud}, ${loc.longitud}'),
      ),
    );
  }

  Widget _buildLoading() {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }

  Widget _buildError(String error) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            error,
            style: const TextStyle(color: Colors.red, fontSize: 16),
            textAlign: TextAlign.center,
          ),
        ),
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

  Widget _buildStats() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildStatCard('Incidencias', '3', Colors.red),
        _buildStatCard('Alertas', '2', Colors.orange),
        _buildStatCard('Recorrido', '75%', Colors.green),
      ],
    );
  }
}
