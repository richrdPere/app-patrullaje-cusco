import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

// Bloc's
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';

// Widgets
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home_content.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) {
            return previous.status != current.status ||
                previous.patrullaje?.id != current.patrullaje?.id;
          },
          listener: _handlePatrullajeListener,
        ),

        BlocListener<TrackingBloc, TrackingState>(
          listenWhen: (previous, current) {
            return previous.lastLocation != current.lastLocation;
          },
          listener: _handleTrackingListener,
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, homeState) {
          if (homeState.isLoading &&
              homeState.status != PatrullajeStatus.aceptando) {
            return const _HomeLoading();
          }

          if (homeState.status == PatrullajeStatus.error) {
            return _HomeError(
              message: homeState.error ?? 'Ocurrió un error desconocido.',
              onRetry: () {
                context.read<HomeBloc>().add(LoadPatrullajeActivo());
              },
            );
          }

          return BlocBuilder<TrackingBloc, TrackingState>(
            buildWhen: (previous, current) {
              return previous.lastLocation != current.lastLocation;
            },
            builder: (context, trackingState) {
              return HomeContent(
                homeState: homeState,
                trackingState: trackingState,
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
        if (patrullaje == null) return;

        context.read<MapaBloc>().add(
          DrawZonaEvent(patrullaje.zona.coordenadas),
        );
        break;

      case PatrullajeStatus.enCurso:
        if (patrullaje == null) return;

        context.read<TrackingBloc>().add(StartTrackingEvent(patrullaje.id));
        break;

      case PatrullajeStatus.finalizado:
      case PatrullajeStatus.sinAsignacion:
        context.read<TrackingBloc>().add(StopTrackingEvent());
        break;

      case PatrullajeStatus.aceptando:
      case PatrullajeStatus.error:
        break;
    }
  }

  void _handleTrackingListener(BuildContext context, TrackingState state) {
    final location = state.lastLocation;

    if (location == null) return;

    context.read<MapaBloc>().add(
      UpdateTrackingLocationEvent(
        lat: location.latitud,
        lng: location.longitud,
      ),
    );
  }
}

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

class _HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, size: 70, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
              const SizedBox(height: 20),
              ElevatedButton.icon(
                onPressed: onRetry,
                icon: const Icon(Icons.refresh),
                label: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
