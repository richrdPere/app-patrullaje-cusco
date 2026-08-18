import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

// =====================================================
// BLOCS
// =====================================================

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

// =====================================================
// WIDGETS
// =====================================================

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/empy_patrullaje_card.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/home_quick_actions.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/home_stats_section.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/main_patrullaje_button.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/patrullaje_header.dart';

import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_appbar.dart';

class HomeContent extends StatelessWidget {
  final HomeState homeState;
  final TrackingState trackingState;
  final SocketState socketState;

  const HomeContent({
    super.key,
    required this.homeState,
    required this.trackingState,
    required this.socketState,
  });

  @override
  Widget build(BuildContext context) {
    final patrullaje = homeState.patrullaje;

    final patrullajeId = patrullaje?.id;
    final zonaId = patrullaje?.zona.id;

    final isEmpty =
        homeState.status == PatrullajeStatus.sinAsignacion ||
        patrullaje == null;

    final patrullajeEnCurso = homeState.status == PatrullajeStatus.enCurso;

    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: colorScheme.surface,
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          // ===============================================
          // FONDO IRREGULAR
          // ===============================================
          Positioned.fill(
            child: IgnorePointer(
              child: RepaintBoundary(
                child: CustomPaint(
                  painter: _HomeBackgroundPainter(
                    colorScheme: colorScheme,
                    isDark: Theme.of(context).brightness == Brightness.dark,
                  ),
                ),
              ),
            ),
          ),

          // ===============================================
          // CONTENIDO
          // ===============================================
          Positioned.fill(
            child: RefreshIndicator(
              onRefresh: () async {
                final bloc = context.read<HomeBloc>();

                bloc.add(const LoadPatrullajeActivo());

                bloc.add(const RefreshMisPatrullajes());

                await bloc.stream.firstWhere(
                  (state) => !state.isLoading && !state.isLoadingMisPatrullajes,
                );
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // =====================================
                    // TÍTULO
                    // =====================================
                    Text(
                      'Para ti...',
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: colorScheme.onSurface,
                      ),
                    ),

                    const SizedBox(height: 14),

                    if (isEmpty) ...[
                      // ===================================
                      // SIN PATRULLAJE
                      // ===================================
                      const NoPatrullajeAsignadoCard(),

                      const SizedBox(height: 20),
                    ] else ...[
                      // ===================================
                      // PATRULLAJE ASIGNADO
                      // ===================================
                      PatrullajeHeader(homeState: homeState),

                      const SizedBox(height: 20),

                      MainPatrullajeButton(homeState: homeState),

                      if (patrullajeEnCurso) ...[
                        const SizedBox(height: 16),

                        // TrackingStatusCard(
                        //   socketState: socketState,
                        //   trackingState: trackingState,
                        // ),
                      ],

                      const SizedBox(height: 20),
                    ],

                    // =====================================
                    // ESTADÍSTICAS
                    // =====================================
                    const HomeStatsSection(),

                    const SizedBox(height: 28),

                    // =====================================
                    // ACCIONES RÁPIDAS
                    // =====================================
                    HomeQuickActions(
                      patrullajeId: patrullajeId,
                      zonaId: zonaId,
                      patrullajeActivo: patrullajeEnCurso,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ==========================================================
// FONDO IRREGULAR DEL HOME
// ==========================================================

class _HomeBackgroundPainter extends CustomPainter {
  final ColorScheme colorScheme;
  final bool isDark;

  const _HomeBackgroundPainter({
    required this.colorScheme,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    _drawTopShape(canvas, size);
    _drawMiddleShape(canvas, size);
    _drawBottomShape(canvas, size);
    _drawDecorativeCircles(canvas, size);
  }

  // ========================================================
  // FORMA SUPERIOR
  // ========================================================

  void _drawTopShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.primary.withValues(alpha: isDark ? 0.14 : 0.10)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, 0)
      ..lineTo(size.width, 0)
      ..lineTo(size.width, size.height * 0.20)
      ..cubicTo(
        size.width * 0.78,
        size.height * 0.15,
        size.width * 0.62,
        size.height * 0.28,
        size.width * 0.40,
        size.height * 0.21,
      )
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.15,
        size.width * 0.12,
        size.height * 0.25,
        0,
        size.height * 0.19,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  // ========================================================
  // FORMA CENTRAL
  // ========================================================

  void _drawMiddleShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: isDark ? 0.10 : 0.065)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(size.width, size.height * 0.38)
      ..cubicTo(
        size.width * 0.85,
        size.height * 0.32,
        size.width * 0.69,
        size.height * 0.45,
        size.width * 0.58,
        size.height * 0.52,
      )
      ..cubicTo(
        size.width * 0.72,
        size.height * 0.60,
        size.width * 0.90,
        size.height * 0.53,
        size.width,
        size.height * 0.58,
      )
      ..close();

    canvas.drawPath(path, paint);
  }

  // ========================================================
  // FORMA INFERIOR
  // ========================================================

  void _drawBottomShape(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = colorScheme.tertiary.withValues(alpha: isDark ? 0.12 : 0.07)
      ..style = PaintingStyle.fill;

    final path = Path()
      ..moveTo(0, size.height * 0.78)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.72,
        size.width * 0.32,
        size.height * 0.82,
        size.width * 0.46,
        size.height * 0.87,
      )
      ..cubicTo(
        size.width * 0.63,
        size.height * 0.94,
        size.width * 0.82,
        size.height * 0.84,
        size.width,
        size.height * 0.91,
      )
      ..lineTo(size.width, size.height)
      ..lineTo(0, size.height)
      ..close();

    canvas.drawPath(path, paint);
  }

  // ========================================================
  // CÍRCULOS DECORATIVOS
  // ========================================================

  void _drawDecorativeCircles(Canvas canvas, Size size) {
    final primaryPaint = Paint()
      ..color = colorScheme.primary.withValues(alpha: isDark ? 0.08 : 0.055)
      ..style = PaintingStyle.fill;

    final secondaryPaint = Paint()
      ..color = colorScheme.secondary.withValues(alpha: isDark ? 0.09 : 0.05)
      ..style = PaintingStyle.fill;

    canvas.drawCircle(
      Offset(size.width * 0.89, size.height * 0.12),
      46,
      primaryPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.08, size.height * 0.48),
      30,
      secondaryPaint,
    );

    canvas.drawCircle(
      Offset(size.width * 0.82, size.height * 0.72),
      22,
      primaryPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _HomeBackgroundPainter oldDelegate) {
    return oldDelegate.colorScheme != colorScheme ||
        oldDelegate.isDark != isDark;
  }
}
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/enums/patrullaje_enum.dart';

// // =====================================================
// // BLOCS
// // =====================================================
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_state.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_state.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_state.dart';

// // =====================================================
// // WIDGETS
// // =====================================================
// // import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/empty_patrullaje.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/empy_patrullaje_card.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/home_quick_actions.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/home_stats_section.dart';
// // import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/location_card.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/main_patrullaje_button.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/home/widgets/patrullaje_header.dart';
// // import 'package:sis_patrullaje_cusco/src/presentation/screens/home/view/widgets/tracking_status_card.dart';

// import 'package:sis_patrullaje_cusco/src/presentation/shared/widgets/custom_appbar.dart';

// class HomeContent extends StatelessWidget {
//   final HomeState homeState;
//   final TrackingState trackingState;
//   final SocketState socketState;

//   const HomeContent({
//     super.key,
//     required this.homeState,
//     required this.trackingState,
//     required this.socketState,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final patrullaje = homeState.patrullaje;

//     final patrullajeId = patrullaje?.id;
//     final zonaId = patrullaje?.zona.id;

//     final isEmpty =
//         homeState.status == PatrullajeStatus.sinAsignacion ||
//         patrullaje == null;

//     final patrullajeEnCurso = homeState.status == PatrullajeStatus.enCurso;

//     return Scaffold(
//       appBar: const CustomAppBar(),
//       body: RefreshIndicator(
//         onRefresh: () async {
//           context.read<HomeBloc>().add(LoadPatrullajeActivo());
//         },
//         child: SingleChildScrollView(
//           physics: const AlwaysScrollableScrollPhysics(),
//           padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               if (isEmpty) ...[
//                 // ===========================================
//                 // SIN PATRULLAJE
//                 // ===========================================
//                 Text(
//                   'Para ti...',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//                 ),

//                 const SizedBox(height: 14),

//                 const NoPatrullajeAsignadoCard(),

//                 const SizedBox(height: 20),
//               ] else ...[
//                 // ===========================================
//                 // PATRULLAJE ASIGNADO
//                 // ===========================================
//                 Text(
//                   'Para ti...',
//                   style: Theme.of(
//                     context,
//                   ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
//                 ),

//                 // 1. Card de patrullaje
//                 PatrullajeHeader(homeState: homeState),

//                 const SizedBox(height: 20),

//                 // 2. Boton para el patrullaje
//                 MainPatrullajeButton(homeState: homeState),

//                 // ===========================================
//                 // CONEXIÓN Y TRANSMISIÓN
//                 // ===========================================
//                 if (patrullajeEnCurso) ...[
//                   const SizedBox(height: 16),

//                   // TrackingStatusCard(
//                   //   socketState: socketState,
//                   //   trackingState: trackingState,
//                   // ),
//                 ],

//                 const SizedBox(height: 20),
//               ],

//               // LocationCard(
//               //   trackingState: trackingState,
//               // ),

//               // 3. Stats
//               const HomeStatsSection(),

//               const SizedBox(height: 28),

//               HomeQuickActions(
//                 patrullajeId: patrullajeId,
//                 zonaId: zonaId,
//                 patrullajeActivo: patrullajeEnCurso,
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
