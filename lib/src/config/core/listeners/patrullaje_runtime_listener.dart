import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';

class PatrullajeRuntimeListener extends StatefulWidget {
  final Widget child;

  const PatrullajeRuntimeListener({super.key, required this.child});

  @override
  State<PatrullajeRuntimeListener> createState() =>
      _PatrullajeRuntimeListenerState();
}

class _PatrullajeRuntimeListenerState extends State<PatrullajeRuntimeListener> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final sessionState = context.read<SessionBloc>().state;

      if (!sessionState.isAuthenticated) {
        _stopRuntime();
        return;
      }

      final homeState = context.read<HomeBloc>().state;

      _reconcilePatrullaje(homeState);

      /*
     * Sincronización inicial porque BlocListener
     * solamente escucha cambios posteriores.
     */
      final trackingState = context.read<TrackingBloc>().state;

      final lastLocation = trackingState.lastLocation;

      if (trackingState.isTracking && lastLocation != null) {
        context.read<MapaBloc>().add(
          UpdateTrackingLocationEvent(location: lastLocation),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        // ==================================================
        // SESIÓN
        // ==================================================
        BlocListener<SessionBloc, SessionState>(
          listenWhen: (previous, current) {
            return previous.isAuthenticated != current.isAuthenticated;
          },
          listener: _listenSession,
        ),

        // ==================================================
        // PATRULLAJE ACTIVO
        // ==================================================
        BlocListener<HomeBloc, HomeState>(
          listenWhen: (previous, current) {
            return previous.isLoading != current.isLoading ||
                previous.status != current.status ||
                previous.patrullaje?.id != current.patrullaje?.id;
          },
          listener: (context, state) {
            _reconcilePatrullaje(state);
          },
        ),

        // ==================================================
        // CONEXIÓN SOCKET
        // ==================================================
        BlocListener<SocketBloc, SocketState>(
          listenWhen: (previous, current) {
            /*
           * Se ejecuta cuando el socket pasa de cualquier
           * estado a conectado.
           */
            return !previous.isConnected && current.isConnected;
          },
          listener: _listenSocketConnected,
        ),

        // ==================================================
        // TTACKING ACTIVO
        // ==================================================
        BlocListener<TrackingBloc, TrackingState>(
          listenWhen: (previous, current) {
            return current.isTracking &&
                current.lastLocation != null &&
                previous.lastLocation != current.lastLocation;
          },
          listener: _listenTrackingLocation,
        ),
      ],
      child: widget.child,
    );
  }

  // ======================================================
  // SESIÓN
  // ======================================================

  void _listenSession(BuildContext context, SessionState state) {
    if (state.isAuthenticated) {
      /*
       * Recupera del backend el patrullaje actual.
       * Si está EN_CURSO, el listener de HomeBloc
       * reiniciará automáticamente el tracking.
       */
      context.read<HomeBloc>().add(LoadPatrullajeActivo());

      return;
    }

    _stopRuntime();
  }

  // ======================================================
  // SOCKET CONECTADO O RECONECTADO
  // ======================================================

  void _listenSocketConnected(BuildContext context, SocketState socketState) {
    if (!socketState.isConnected) {
      return;
    }

    debugPrint(
      '🟢 PatrullajeRuntimeListener detectó '
      'Socket.IO conectado.',
    );

    /*
   * Revalida el patrullaje actual.
   *
   * Si el tracking todavía no había comenzado,
   * se iniciará. Si ya estaba funcionando para
   * el mismo patrullaje, _startTracking no lo duplica.
   */
    final homeState = context.read<HomeBloc>().state;

    _reconcilePatrullaje(homeState);

    /*
   * Solicita sincronizar las ubicaciones guardadas
   * en sp_ubicaciones_pendientes.
   *
   * Este evento debe añadirse a TrackingBloc.
   */
    context.read<TrackingBloc>().add(const SyncPendingTrackingLocationsEvent());
  }
  // ======================================================
  // COORDINAR PATRULLAJE
  // ======================================================

  void _reconcilePatrullaje(HomeState state) {
    if (!mounted || state.isLoading) {
      return;
    }

    final patrullaje = state.patrullaje;

    switch (state.status) {
      case PatrullajeStatus.enCurso:
        if (patrullaje == null) return;

        _drawAssignedZone(patrullaje.zona.coordenadas);

        _startTracking(patrullajeId: patrullaje.id);

        break;

      case PatrullajeStatus.asignado:
        if (patrullaje == null) return;

        /*
         * Un patrullaje asignado muestra su zona,
         * pero aún no transmite ubicaciones.
         */
        _stopTracking();

        _drawAssignedZone(patrullaje.zona.coordenadas);

        break;

      case PatrullajeStatus.finalizado:
      case PatrullajeStatus.sinAsignacion:
        _stopRuntime();

        break;

      /*
       * Un error temporal al consultar el backend no debe
       * detener un tracking que ya estaba funcionando.
       */
      case PatrullajeStatus.aceptando:
      case PatrullajeStatus.error:
        break;
    }
  }

  // ======================================================
  // INICIAR TRACKING
  // ======================================================
  void _startTracking({required int patrullajeId}) {
    final trackingBloc = context.read<TrackingBloc>();
    final trackingState = trackingBloc.state;

    final isTrackingCurrentPatrol =
        trackingState.isTracking && trackingState.patrullajeId == patrullajeId;

    if (isTrackingCurrentPatrol) {
      return;
    }

    trackingBloc.add(StartTrackingEvent(patrullajeId));
  }

  // ======================================================
  // SINCRONIZAR TRACKING CON MAPA
  // ======================================================

  void _listenTrackingLocation(
    BuildContext context,
    TrackingState trackingState,
  ) {
    final location = trackingState.lastLocation;

    if (!trackingState.isTracking || location == null) {
      return;
    }

    debugPrint("========================================");
    debugPrint("LOCATION: $location");
    debugPrint("========================================");
    context.read<MapaBloc>().add(
      UpdateTrackingLocationEvent(location: location),
    );
  }
  // ======================================================
  // DETENER TRACKING
  // ======================================================

  void _stopTracking() {
    final trackingBloc = context.read<TrackingBloc>();
    final trackingState = trackingBloc.state;

    if (!trackingState.isTracking && !trackingState.isLoading) {
      return;
    }

    trackingBloc.add(const StopTrackingEvent());
  }

  // ======================================================
  // DIBUJAR ZONA
  // ======================================================

  void _drawAssignedZone(List<Coordenada> coordenadas) {
    final mapaBloc = context.read<MapaBloc>();

    if (coordenadas.length < 3) {
      mapaBloc.add(const ClearAssignedZoneEvent());

      return;
    }

    mapaBloc.add(DrawAssignedZoneEvent(coordenadas: coordenadas));
  }

  // ======================================================
  // DETENER EJECUCIÓN OPERATIVA
  // ======================================================

  void _stopRuntime() {
    _stopTracking();

    context.read<MapaBloc>()
      ..add(const ClearAssignedZoneEvent())
      ..add(const ClearTemporaryMapDataEvent())
      ..add(const SetAutoCenterEvent(enabled: false));
  }
}
