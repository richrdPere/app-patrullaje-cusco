import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

// Enums
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

// Home BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

// Tracking BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

// Mapa BLoC
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
        // ==================================================
        // CAMBIOS DEL PATRULLAJE ACTIVO
        // ==================================================
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) {
            return previous.status != current.status ||
                previous.patrullaje?.id != current.patrullaje?.id;
          },
          listener: _handlePatrullajeListener,
        ),

        // ==================================================
        // CAMBIOS DE UBICACIÓN DEL TRACKING
        // ==================================================
        BlocListener<TrackingBloc, TrackingState>(
          listenWhen: (previous, current) {
            return previous.lastLocation != current.lastLocation;
          },
          listener: _handleTrackingListener,
        ),
      ],
      child: BlocBuilder<HomeBloc, HomeState>(
        buildWhen: (previous, current) {
          return previous.status != current.status ||
              previous.isLoading != current.isLoading ||
              previous.error != current.error ||
              previous.patrullaje != current.patrullaje;
        },
        builder: (context, homeState) {
          // ==================================================
          // CARGANDO PATRULLAJE
          // ==================================================

          if (homeState.isLoading &&
              homeState.status != PatrullajeStatus.aceptando) {
            return const _HomeLoading();
          }

          // ==================================================
          // ERROR AL CARGAR PATRULLAJE
          // ==================================================

          if (homeState.status == PatrullajeStatus.error) {
            return _HomeError(
              message:
                  homeState.error ??
                  'Ocurrió un error al obtener el patrullaje activo.',
              onRetry: () {
                context.read<HomeBloc>().add(LoadPatrullajeActivo());
              },
            );
          }

          // ==================================================
          // CONTENIDO PRINCIPAL
          // ==================================================

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

  // ======================================================
  // LISTENER DEL PATRULLAJE
  // ======================================================

  void _handlePatrullajeListener(BuildContext context, HomeState state) {
    final patrullaje = state.patrullaje;

    switch (state.status) {
      // ==================================================
      // PATRULLAJE ASIGNADO
      // ==================================================

      case PatrullajeStatus.asignado:
        if (patrullaje == null) return;

        /*
         * Dibuja la zona asignada en el mapa.
         *
         * Todavía no inicia el tracking porque el sereno
         * aún no ha comenzado formalmente el patrullaje.
         */
        _drawAssignedZone(context, patrullaje.zona.coordenadas);

        break;

      // ==================================================
      // PATRULLAJE EN CURSO
      // ==================================================

      case PatrullajeStatus.enCurso:
        if (patrullaje == null) return;

        /*
         * La zona también se dibuja en EN_CURSO porque la
         * aplicación podría recuperar un patrullaje que ya
         * estaba iniciado antes de abrir HomePage.
         */
        _drawAssignedZone(context, patrullaje.zona.coordenadas);

        /*
         * Inicia el stream de geolocalización y el envío
         * periódico de la ubicación del sereno.
         */
        context.read<TrackingBloc>().add(StartTrackingEvent(patrullaje.id));

        break;

      // ==================================================
      // PATRULLAJE FINALIZADO
      // ==================================================

      case PatrullajeStatus.finalizado:
        _stopTracking(context);
        _clearPatrullajeMapData(context);
        break;

      // ==================================================
      // SIN PATRULLAJE ASIGNADO
      // ==================================================

      case PatrullajeStatus.sinAsignacion:
        _stopTracking(context);
        _clearPatrullajeMapData(context);
        break;

      // ==================================================
      // ESTADOS SIN ACCIONES ADICIONALES
      // ==================================================

      case PatrullajeStatus.aceptando:
      case PatrullajeStatus.error:
        break;
    }
  }

  // ======================================================
  // LISTENER DEL TRACKING
  // ======================================================
  void _handleTrackingListener(BuildContext context, TrackingState state) {
    final location = state.lastLocation;

    if (location == null) return;

    /*
     * MapaBloc recibe ahora la entidad completa.
     *
     * De esta forma conserva:
     * - latitud;
     * - longitud;
     * - velocidad;
     * - precisión;
     * - fecha y hora;
     * - tipo de ubicación.
     */
    context.read<MapaBloc>().add(
      UpdateTrackingLocationEvent(location: location),
    );
  }

  // ======================================================
  // DIBUJAR ZONA ASIGNADA
  // ======================================================
  void _drawAssignedZone(BuildContext context, List<Coordenada> coordenadas) {
    if (coordenadas.length < 3) {
      context.read<MapaBloc>().add(const ClearAssignedZoneEvent());

      return;
    }

    context.read<MapaBloc>().add(
      DrawAssignedZoneEvent(coordenadas: coordenadas),
    );
  }

  // ======================================================
  // DETENER TRACKING
  // ======================================================

  void _stopTracking(BuildContext context) {
    context.read<TrackingBloc>().add(StopTrackingEvent());
  }

  // ======================================================
  // LIMPIAR DATOS DEL PATRULLAJE EN EL MAPA
  // ======================================================

  void _clearPatrullajeMapData(BuildContext context) {
    final mapaBloc = context.read<MapaBloc>();

    // Elimina el polígono de la zona asignada.
    mapaBloc.add(const ClearAssignedZoneEvent());

    // Elimina rutas, origen, destino y selecciones temporales.
    mapaBloc.add(const ClearTemporaryMapDataEvent());

    // Desactiva el autocentrado al finalizar el patrullaje.
    mapaBloc.add(const SetAutoCenterEvent(enabled: false));
  }
}

// ======================================================
// ESTADO DE CARGA
// ======================================================

class _HomeLoading extends StatelessWidget {
  const _HomeLoading();

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Center(child: CircularProgressIndicator()));
  }
}

// ======================================================
// ESTADO DE ERROR
// ======================================================

class _HomeError extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _HomeError({required this.message, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
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
      ),
    );
  }
}
