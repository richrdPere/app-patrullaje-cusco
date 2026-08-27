import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/domain/entities/location_permission_status.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_state.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/view/mapa/mapa_content.dart';

class MapaPage extends StatefulWidget {
  static const name = 'mapa-screen';

  const MapaPage({super.key});

  @override
  State<MapaPage> createState() => _MapaPageState();
}

class _MapaPageState extends State<MapaPage> {
  // ======================================================
  // CICLO DE VIDA
  // ======================================================

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;

      final mapaBloc = context.read<MapaBloc>();

      /*
     * Evita inicializar nuevamente el mapa cuando el BLoC
     * ya fue cargado desde un BlocProvider superior.
     */
      if (mapaBloc.state.status == MapaStatus.initial) {
        mapaBloc.add(const MapaInitEvent());
      }
    });
  }

  // ======================================================
  // BUILD
  // ======================================================
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MultiBlocListener(
        listeners: [
          // ==================================================
          // ESTADO GENERAL DEL MAPA
          // ==================================================
          BlocListener<MapaBloc, MapaState>(
            listenWhen: (previous, current) {
              return previous.status != current.status ||
                  previous.errorMessage != current.errorMessage;
            },
            listener: _listenMapaStatus,
          ),

          // ==================================================
          // ERRORES DE UBICACIÓN
          // ==================================================
          BlocListener<MapaBloc, MapaState>(
            listenWhen: (previous, current) {
              return previous.locationStatus != current.locationStatus ||
                  previous.locationErrorMessage != current.locationErrorMessage;
            },
            listener: _listenLocationStatus,
          ),

          // ==================================================
          // ERRORES DE GEOCODIFICACIÓN
          // ==================================================
          BlocListener<MapaBloc, MapaState>(
            listenWhen: (previous, current) {
              return previous.geocodingStatus != current.geocodingStatus ||
                  previous.geocodingErrorMessage !=
                      current.geocodingErrorMessage;
            },
            listener: _listenGeocodingStatus,
          ),

          // ==================================================
          // ERRORES DE RUTA
          // ==================================================
          BlocListener<MapaBloc, MapaState>(
            listenWhen: (previous, current) {
              return previous.routeStatus != current.routeStatus ||
                  previous.routeErrorMessage != current.routeErrorMessage;
            },
            listener: _listenRouteStatus,
          ),

          // ==================================================
          // ALERTAS
          // ==================================================
          BlocListener<AlertBloc, AlertState>(listener: _listenAlertStatus),
        ],
        child: BlocBuilder<MapaBloc, MapaState>(
          buildWhen: (previous, current) {
            return previous.status != current.status ||
                previous.currentLocation != current.currentLocation ||
                previous.trackingLocation != current.trackingLocation ||
                previous.cameraPosition != current.cameraPosition ||
                previous.cameraTargetLocation != current.cameraTargetLocation ||
                previous.placemarkData != current.placemarkData ||
                previous.pickUpLocation != current.pickUpLocation ||
                previous.destinationLocation != current.destinationLocation ||
                previous.pickUpDescription != current.pickUpDescription ||
                previous.destinationDescription !=
                    current.destinationDescription ||
                previous.markers != current.markers ||
                previous.polygons != current.polygons ||
                previous.polylines != current.polylines ||
                previous.routeStatus != current.routeStatus ||
                previous.locationStatus != current.locationStatus ||
                previous.geocodingStatus != current.geocodingStatus ||
                previous.isPickingLocation != current.isPickingLocation ||
                previous.isAutoCentering != current.isAutoCentering;
          },
          builder: (context, state) {
            return MapaContent(state: state);
          },
        ),
      ),
    );
  }

  // ======================================================
  // LISTENER: ESTADO GENERAL
  // ======================================================
  void _listenMapaStatus(BuildContext context, MapaState state) {
    if (state.status != MapaStatus.error) return;

    final message = state.errorMessage ?? 'No se pudo inicializar el mapa.';

    /*
     * Si el GPS está desactivado, ofrecemos abrir directamente
     * la configuración de ubicación del dispositivo.
     */
    if (!state.isLocationServiceEnabled) {
      _showLocationServiceDialog(context, message: message);

      return;
    }

    /*
     * Si el permiso está denegado permanentemente, el usuario
     * debe habilitarlo desde la configuración de la aplicación.
     */
    if (state.permissionStatus == LocationPermissionStatus.deniedForever) {
      _showPermissionSettingsDialog(context, message: message);

      return;
    }

    _showSnackBar(context, message: message, isError: true);
  }

  // ======================================================
  // LISTENER: UBICACIÓN
  // ======================================================

  void _listenLocationStatus(BuildContext context, MapaState state) {
    if (state.locationStatus != MapaLocationStatus.error) {
      return;
    }

    final message =
        state.locationErrorMessage ?? 'No se pudo obtener la ubicación actual.';

    _showSnackBar(context, message: message, isError: true);
  }

  // ======================================================
  // LISTENER: GEOCODIFICACIÓN
  // ======================================================

  void _listenGeocodingStatus(BuildContext context, MapaState state) {
    if (state.geocodingStatus == MapaGeocodingStatus.error) {
      final message =
          state.geocodingErrorMessage ??
          'No se pudo obtener la dirección seleccionada.';

      _showSnackBar(context, message: message, isError: true);

      return;
    }

    if (state.geocodingStatus == MapaGeocodingStatus.empty) {
      _showSnackBar(
        context,
        message: 'No se encontró una dirección para la ubicación seleccionada.',
      );
    }
  }

  // ======================================================
  // LISTENER: RUTA
  // ======================================================

  void _listenRouteStatus(BuildContext context, MapaState state) {
    if (state.routeStatus == MapaRouteStatus.error) {
      final message =
          state.routeErrorMessage ??
          'No se pudo calcular la ruta seleccionada.';

      _showSnackBar(context, message: message, isError: true);

      return;
    }

    if (state.routeStatus == MapaRouteStatus.empty) {
      _showSnackBar(
        context,
        message:
            'No se encontró una ruta disponible entre los puntos seleccionados.',
      );
    }
  }

  // ======================================================
  // LISTENER: ALERTAS
  // ======================================================
  void _listenAlertStatus(BuildContext context, AlertState state) {
    if (state.success) {
      _showSnackBar(context, message: 'Alerta enviada correctamente.');
    }

    final error = state.error;

    if (error != null && error.trim().isNotEmpty) {
      _showSnackBar(context, message: error, isError: true);
    }
  }

  // ======================================================
  // DIÁLOGO: GPS DESACTIVADO
  // ======================================================
  Future<void> _showLocationServiceDialog(
    BuildContext context, {
    required String message,
  }) async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Ubicación desactivada'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldOpenSettings != true) return;

    final opened = await context
        .read<MapaBloc>()
        .geolocatorUseCases
        .openLocationSettings
        .run();

    if (!mounted) return;

    if (!opened) {
      _showSnackBar(
        context,
        message: 'No se pudo abrir la configuración de ubicación.',
        isError: true,
      );

      return;
    }
  }

  // ======================================================
  // DIÁLOGO: PERMISO PERMANENTEMENTE DENEGADO
  // ======================================================
  Future<void> _showPermissionSettingsDialog(
    BuildContext context, {
    required String message,
  }) async {
    final shouldOpenSettings = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Permiso de ubicación'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(false);
              },
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.of(dialogContext).pop(true);
              },
              child: const Text('Abrir configuración'),
            ),
          ],
        );
      },
    );

    if (!mounted || shouldOpenSettings != true) return;

    final opened = await context
        .read<MapaBloc>()
        .geolocatorUseCases
        .openAppSettings
        .run();

    if (!mounted) return;

    if (!opened) {
      _showSnackBar(
        context,
        message: 'No se pudo abrir la configuración de la aplicación.',
        isError: true,
      );
    }
  }

  // ======================================================
  // SNACKBAR
  // ======================================================
  void _showSnackBar(
    BuildContext context, {
    required String message,
    bool isError = false,
  }) {
    final messenger = ScaffoldMessenger.of(context);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError
              ? Colors.red.shade700
              : Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }
}
