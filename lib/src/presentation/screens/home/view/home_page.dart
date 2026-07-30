import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

// Enums
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

// Home BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

// Socket BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';

// Tracking BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

// Mapa BLoC
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';

// Widgets
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home_content.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/patrullaje_resumen_dialog.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;

      final homeState = context.read<HomeBloc>().state;

      await _handlePatrullajeListener(context, homeState);
    });
  }

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

      // ==================================================
      // HOME STATE
      // ==================================================
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
          // TRACKING STATE
          // ==================================================
          return BlocBuilder<TrackingBloc, TrackingState>(
            buildWhen: _buildWhenTracking,
            builder: (context, trackingState) {
              // ==================================================
              // SOCKET STATE
              // ==================================================
              return BlocBuilder<SocketBloc, SocketState>(
                buildWhen: _buildWhenSocket,
                builder: (context, socketState) {
                  return HomeContent(
                    homeState: homeState,
                    trackingState: trackingState,
                    socketState: socketState,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  // ======================================================
  // RECONSTRUIR POR CAMBIOS DE TRACKING
  // ======================================================
  bool _buildWhenTracking(TrackingState previous, TrackingState current) {
    return previous.lastLocation != current.lastLocation ||
        previous.isTracking != current.isTracking ||
        previous.isLoading != current.isLoading ||
        previous.patrullajeId != current.patrullajeId ||
        previous.error != current.error ||
        previous.transmissionStatus != current.transmissionStatus ||
        previous.lastTransmissionAt != current.lastTransmissionAt ||
        previous.transmissionMessage != current.transmissionMessage ||
        previous.consecutiveFailures != current.consecutiveFailures;
  }

  // ======================================================
  // RECONSTRUIR POR CAMBIOS DEL SOCKET
  // ======================================================
  bool _buildWhenSocket(SocketState previous, SocketState current) {
    return previous.status != current.status ||
        previous.message != current.message ||
        previous.error != current.error ||
        previous.lastConnectedAt != current.lastConnectedAt;
  }

  // ======================================================
  // CONTROLAR ESTADO DEL PATRULLAJE
  // ======================================================
  Future<void> _handlePatrullajeListener(
    BuildContext context,
    HomeState state,
  ) async {
    final patrullaje = state.patrullaje;

    switch (state.status) {
      // ==================================================
      // PATRULLAJE ASIGNADO
      // ==================================================
      case PatrullajeStatus.asignado:
        if (patrullaje == null) return;

        _drawAssignedZone(context, patrullaje.zona.coordenadas);

        break;

      // ==================================================
      // PATRULLAJE EN CURSO
      // ==================================================
      case PatrullajeStatus.enCurso:
        if (patrullaje == null) return;

        _drawAssignedZone(context, patrullaje.zona.coordenadas);

        final trackingState = context.read<TrackingBloc>().state;

        final yaEstaRastreandoElPatrullaje =
            trackingState.isTracking &&
            trackingState.patrullajeId == patrullaje.id;

        if (!yaEstaRastreandoElPatrullaje) {
          context.read<TrackingBloc>().add(StartTrackingEvent(patrullaje.id));
        }

        break;

      // ==================================================
      // PATRULLAJE FINALIZADO
      // ==================================================
      case PatrullajeStatus.finalizado:
        _stopTracking(context);
        _clearPatrullajeMapData(context);

        if (patrullaje?.resumen == null) {
          if (!context.mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'El patrullaje finalizó, pero no se recibió el resumen.',
              ),
            ),
          );

          context.read<HomeBloc>().add(LimpiarPatrullajeFinalizado());

          return;
        }

        await _showPatrullajeResumen(context, patrullaje!);

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
  // MOSTRAR RESUMEN DEL PATRULLAJE
  // ======================================================
  Future<void> _showPatrullajeResumen(
    BuildContext context,
    PatrullajeData patrullaje,
  ) async {
    if (!context.mounted) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return PatrullajeResumenDialog(patrullaje: patrullaje);
      },
    );

    if (!context.mounted) return;

    context.read<HomeBloc>().add(LimpiarPatrullajeFinalizado());
  }

  // ======================================================
  // ENVIAR UBICACIÓN AL MAPA
  // ======================================================
  void _handleTrackingListener(BuildContext context, TrackingState state) {
    final location = state.lastLocation;

    if (location == null) return;

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
    final trackingState = context.read<TrackingBloc>().state;

    if (!trackingState.isTracking && !trackingState.isLoading) {
      return;
    }

    context.read<TrackingBloc>().add(StopTrackingEvent());
  }

  // ======================================================
  // LIMPIAR DATOS DEL MAPA
  // ======================================================
  void _clearPatrullajeMapData(BuildContext context) {
    final mapaBloc = context.read<MapaBloc>();

    mapaBloc.add(const ClearAssignedZoneEvent());

    mapaBloc.add(const ClearTemporaryMapDataEvent());

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
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
// import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

// // Enums
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

// // Home BLoC
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';

// // Tracking BLoC
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

// // Mapa BLoC
// import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_event.dart';

// // Widgets
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home_content.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/patrullaje_resumen_dialog.dart';

// class HomePage extends StatefulWidget {
//   const HomePage({super.key});

//   @override
//   State<HomePage> createState() => _HomePageState();
// }

// class _HomePageState extends State<HomePage> {
//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) async {
//       if (!mounted) return;

//       final homeState = context.read<HomeBloc>().state;

//       await _handlePatrullajeListener(context, homeState);
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         // ==================================================
//         // CAMBIOS DEL PATRULLAJE ACTIVO
//         // ==================================================
//         BlocListener<HomeBloc, HomeState>(
//           listenWhen: (previous, current) {
//             return previous.status != current.status ||
//                 previous.patrullaje?.id != current.patrullaje?.id;
//           },
//           listener: _handlePatrullajeListener,
//         ),

//         // ==================================================
//         // CAMBIOS DE UBICACIÓN DEL TRACKING
//         // ==================================================
//         BlocListener<TrackingBloc, TrackingState>(
//           listenWhen: (previous, current) {
//             return previous.lastLocation != current.lastLocation;
//           },
//           listener: _handleTrackingListener,
//         ),
//       ],
//       child: BlocBuilder<HomeBloc, HomeState>(
//         buildWhen: (previous, current) {
//           return previous.status != current.status ||
//               previous.isLoading != current.isLoading ||
//               previous.error != current.error ||
//               previous.patrullaje != current.patrullaje;
//         },
//         builder: (context, homeState) {
//           // ==================================================
//           // CARGANDO PATRULLAJE
//           // ==================================================
//           if (homeState.isLoading &&
//               homeState.status != PatrullajeStatus.aceptando) {
//             return const _HomeLoading();
//           }

//           // ==================================================
//           // ERROR AL CARGAR PATRULLAJE
//           // ==================================================
//           if (homeState.status == PatrullajeStatus.error) {
//             return _HomeError(
//               message:
//                   homeState.error ??
//                   'Ocurrió un error al obtener el patrullaje activo.',
//               onRetry: () {
//                 context.read<HomeBloc>().add(LoadPatrullajeActivo());
//               },
//             );
//           }

//           // ==================================================
//           // CONTENIDO PRINCIPAL
//           // ==================================================
//           return BlocBuilder<TrackingBloc, TrackingState>(
//             buildWhen: (previous, current) {
//               return previous.lastLocation != current.lastLocation ||
//                   previous.isTracking != current.isTracking ||
//                   previous.isLoading != current.isLoading ||
//                   previous.error != current.error;
//             },
//             builder: (context, trackingState) {
//               return HomeContent(
//                 homeState: homeState,
//                 trackingState: trackingState,
//               );
//             },
//           );
//         },
//       ),
//     );
//   }

//   // ======================================================
//   Future<void> _handlePatrullajeListener(
//     BuildContext context,
//     HomeState state,
//   ) async {
//     final patrullaje = state.patrullaje;

//     switch (state.status) {
//       // ==================================================
//       // PATRULLAJE ASIGNADO
//       // ==================================================
//       case PatrullajeStatus.asignado:
//         if (patrullaje == null) return;

//         _drawAssignedZone(context, patrullaje.zona.coordenadas);

//         break;

//       // ==================================================
//       // PATRULLAJE EN CURSO
//       // ==================================================
//       case PatrullajeStatus.enCurso:
//         if (patrullaje == null) return;

//         _drawAssignedZone(context, patrullaje.zona.coordenadas);

//         final trackingState = context.read<TrackingBloc>().state;

//         final yaEstaRastreandoElPatrullaje =
//             trackingState.isTracking &&
//             trackingState.patrullajeId == patrullaje.id;

//         if (!yaEstaRastreandoElPatrullaje) {
//           context.read<TrackingBloc>().add(StartTrackingEvent(patrullaje.id));
//         }

//         break;

//       // ==================================================
//       // PATRULLAJE FINALIZADO
//       // ==================================================
//       case PatrullajeStatus.finalizado:
//         _stopTracking(context);
//         _clearPatrullajeMapData(context);

//         if (patrullaje?.resumen == null) {
//           if (!context.mounted) return;

//           ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//               content: Text(
//                 'El patrullaje finalizó, pero no se recibió el resumen.',
//               ),
//             ),
//           );

//           context.read<HomeBloc>().add(LimpiarPatrullajeFinalizado());

//           return;
//         }

//         await _showPatrullajeResumen(context, patrullaje!);

//         break;

//       // ==================================================
//       // SIN PATRULLAJE ASIGNADO
//       // ==================================================
//       case PatrullajeStatus.sinAsignacion:
//         _stopTracking(context);
//         _clearPatrullajeMapData(context);

//         break;

//       // ==================================================
//       // ESTADOS SIN ACCIONES ADICIONALES
//       // ==================================================
//       case PatrullajeStatus.aceptando:
//       case PatrullajeStatus.error:
//         break;
//     }
//   }

//   // ======================================================
//   Future<void> _showPatrullajeResumen(
//     BuildContext context,
//     PatrullajeData patrullaje,
//   ) async {
//     if (!context.mounted) return;

//     await showDialog<void>(
//       context: context,
//       barrierDismissible: false,
//       builder: (dialogContext) {
//         return PatrullajeResumenDialog(patrullaje: patrullaje);
//       },
//     );

//     if (!context.mounted) return;

//     context.read<HomeBloc>().add(LimpiarPatrullajeFinalizado());
//   }

//   // ======================================================
//   void _handleTrackingListener(BuildContext context, TrackingState state) {
//     final location = state.lastLocation;

//     if (location == null) return;

//     context.read<MapaBloc>().add(
//       UpdateTrackingLocationEvent(location: location),
//     );
//   }

//   // ======================================================
//   void _drawAssignedZone(BuildContext context, List<Coordenada> coordenadas) {
//     if (coordenadas.length < 3) {
//       context.read<MapaBloc>().add(const ClearAssignedZoneEvent());

//       return;
//     }

//     context.read<MapaBloc>().add(
//       DrawAssignedZoneEvent(coordenadas: coordenadas),
//     );
//   }

//   // ======================================================
//   void _stopTracking(BuildContext context) {
//     final trackingState = context.read<TrackingBloc>().state;

//     if (!trackingState.isTracking && !trackingState.isLoading) {
//       return;
//     }

//     context.read<TrackingBloc>().add(StopTrackingEvent());
//   }

//   // ======================================================
//   void _clearPatrullajeMapData(BuildContext context) {
//     final mapaBloc = context.read<MapaBloc>();

//     mapaBloc.add(const ClearAssignedZoneEvent());

//     mapaBloc.add(const ClearTemporaryMapDataEvent());

//     mapaBloc.add(const SetAutoCenterEvent(enabled: false));
//   }
// }

// // ======================================================
// // ESTADO DE CARGA
// // ======================================================
// class _HomeLoading extends StatelessWidget {
//   const _HomeLoading();

//   @override
//   Widget build(BuildContext context) {
//     return const Scaffold(body: Center(child: CircularProgressIndicator()));
//   }
// }

// // ======================================================
// // ESTADO DE ERROR
// // ======================================================
// class _HomeError extends StatelessWidget {
//   final String message;
//   final VoidCallback onRetry;

//   const _HomeError({required this.message, required this.onRetry});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: SafeArea(
//         child: Center(
//           child: Padding(
//             padding: const EdgeInsets.all(24),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 const Icon(Icons.error_outline, size: 70, color: Colors.red),
//                 const SizedBox(height: 16),
//                 Text(
//                   message,
//                   textAlign: TextAlign.center,
//                   style: const TextStyle(color: Colors.red, fontSize: 16),
//                 ),
//                 const SizedBox(height: 20),
//                 ElevatedButton.icon(
//                   onPressed: onRetry,
//                   icon: const Icon(Icons.refresh),
//                   label: const Text('Reintentar'),
//                 ),
//               ],
//             ),
//           ),
//         ),
//       ),
//     );
//   }
// }
