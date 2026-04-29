import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';
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

    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   context.read<HomeBloc>().add(LoadPatrullajeActivo());
    // });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<HomeBloc, HomeState>(
      listenWhen: (prev, curr) => prev.status != curr.status,
      listener: _handlePatrullajeListener,

      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          // LOADING
          if (homeState.isLoading) return _buildLoading();

          // ERROR
          if (homeState.status == PatrullajeStatus.error) {
            return _buildError(homeState.error ?? 'Error desconocido');
          }

          // DATA
          // final patrullaje = homeState.patrullaje;

          return BlocBuilder<TrackingBloc, TrackingState>(
            builder: (context, trackingState) {
              return Scaffold(
                appBar: CustomAppBar(),
                body: _buildBody(context, homeState, trackingState),
              );
            },
          );
        },
      ),
    );
  }

  void _handlePatrullajeListener(BuildContext context, HomeState state) {
    final patrullaje = state.patrullaje;

    switch (state.status) {
      case PatrullajeStatus.asignado:
        if (patrullaje != null) {
          context.read<MapaBloc>().add(
            DrawZonaEvent(patrullaje.zona.coordenadas),
          );
        }
        break;

      case PatrullajeStatus.enCurso:
        context.read<TrackingBloc>().add(StartPatrullajeEvent(patrullaje!.id));
        break;

      case PatrullajeStatus.finalizado:
        context.read<TrackingBloc>().add(EndPatrullajeEvent(patrullaje!.id));
        break;

      default:
        break;
    }
  }

  Widget _buildBody(
    BuildContext context,
    HomeState homeState,
    TrackingState trackingState,
  ) {
    // final patrullaje = homeState.patrullaje;

    if (homeState.status == PatrullajeStatus.sinAsignacion) {
      return _buildEmptyState();
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          _buildHeader(homeState, trackingState),
          const SizedBox(height: 20),
          _buildMainButton(context, homeState, trackingState),
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

  Widget _buildEmptyState() {
    return Scaffold(
      // appBar: CustomAppBar(),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.directions_walk, size: 80, color: Colors.grey),
            SizedBox(height: 20),
            Text(
              'Sin patrullaje asignado',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Text(
              'Espera una asignación desde la central',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(HomeState homeState, TrackingState trackingState) {
    final patrullaje = homeState.patrullaje;

    String getStatusText(PatrullajeStatus status) {
      switch (status) {
        case PatrullajeStatus.asignado:
          return '🟡 Asignado';
        case PatrullajeStatus.aceptando:
          return '🟠 Aceptando...';
        case PatrullajeStatus.enCurso:
          return '🟢 En patrullaje';
        case PatrullajeStatus.finalizado:
          return '🔴 Finalizado';
        default:
          return '⚪ Sin asignación';
      }
    }

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
                const Text('Patrullaje', style: TextStyle(color: Colors.white)),
                Text(
                  'Zona: ${patrullaje.zona.nombre}',
                  style: const TextStyle(color: Colors.white),
                ),
                Text(
                  getStatusText(homeState.status),
                  style: const TextStyle(color: Colors.white),
                ),
              ],
            ),
    );
  }

  Widget _buildMainButton(
    BuildContext context,
    HomeState homeState,
    TrackingState trackingState,
  ) {
    final patrullaje = homeState.patrullaje;

    if (patrullaje == null) return const SizedBox();

    final homeBloc = context.read<HomeBloc>();
    final trackingBloc = context.read<TrackingBloc>();

    switch (homeState.status) {
      case PatrullajeStatus.asignado:
        return ElevatedButton.icon(
          onPressed: () {
            homeBloc.add(AceptarPatrullaje(patrullaje.id));
          },
          icon: const Icon(Icons.check),
          label: const Text('Aceptar Patrullaje'),
        );

      case PatrullajeStatus.enCurso:
        return ElevatedButton.icon(
          onPressed: () {
            //  trackingBloc.add(EndPatrullajeEvent(patrullaje.id));
            homeBloc.add(PatrullajeFinalizadoRecibido(patrullaje.id));
          },
          icon: const Icon(Icons.stop),
          label: const Text('Finalizar Patrullaje'),
        );

      case PatrullajeStatus.aceptando:
        return const CircularProgressIndicator();

      default:
        return const SizedBox();
    }
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
