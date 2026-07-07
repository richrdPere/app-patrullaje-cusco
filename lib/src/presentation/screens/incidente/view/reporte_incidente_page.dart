// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:go_router/go_router.dart';

// // Models
// // import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';

// // Bloc
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/enums/incidente_tab_enum.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/screens/emergencia_screen.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/screens/evidencia_screen.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/screens/historial_incidentes_screen.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/screens/incident_form_screen.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/screens/video_screen.dart';

// // Widgets
// // import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/media_preview_widget.dart';

// class ReporteIncidentePage extends StatefulWidget {
//   const ReporteIncidentePage({super.key});

//   @override
//   State<ReporteIncidentePage> createState() => _ReporteIncidentePageState();
// }

// class _ReporteIncidentePageState extends State<ReporteIncidentePage> {
//   // String? tipoSeleccionado;

//   // final TextEditingController descripcionCtrl = TextEditingController();

//   // final List<String> tipos = [
//   //   'ROBO',
//   //   'ACCIDENTE',
//   //   'SOSPECHOSO',
//   //   'VIOLENCIA',
//   //   'INCENDIO',
//   //   'OTRO',
//   // ];

//   @override
//   void initState() {
//     super.initState();

//     // OBTENER UBICACIÓN AUTOMÁTICAMENTE
//     // WidgetsBinding.instance.addPostFrameCallback((_) {
//     //   context.read<IncidenteBloc>().add(ObtenerUbicacionEvent());
//     // });
//   }

//   @override
//   void dispose() {
//     // descripcionCtrl.dispose();
//     super.dispose();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       // resizeToAvoidBottomInset: true,
//       appBar: AppBar(title: const Text('Reportar Incidencia')),
//       body: BlocConsumer<IncidenteBloc, IncidenteState>(
//         listener: _listener,

//         builder: (context, state) {
//           return Column(
//             children: [
//               Expanded(child: _buildCurrentTab(state)),

//               _buildBottomTabs(context, state),
//             ],
//           );
//         },
//       ),
//     );
//   }

//   void _listener(BuildContext context, IncidenteState state) {
//     // ERROR
//     if (state.error != null) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text(state.error!), backgroundColor: Colors.red),
//       );

//       context.read<IncidenteBloc>().add(LimpiarErrorEvent());
//     }

//     // SUCCESS INCIDENTE
//     if (state.success) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Text('Incidencia reportada correctamente'),
//           backgroundColor: Colors.green,
//         ),
//       );

//       context.read<IncidenteBloc>().add(ResetIncidenteEvent());

//       context.go('/home');
//     }
//   }

//   // =========================================================
//   // BUILD CURRENT TAB
//   // =========================================================
//   Widget _buildCurrentTab(IncidenteState state) {
//     switch (state.currentTab) {
//       case IncidenteTabEnum.incidente:
//         return const IncidenteFormScreen();

//       case IncidenteTabEnum.video:
//         return const VideoScreen();

//       case IncidenteTabEnum.evidencia:
//         return const EvidenciaScreen();

//       case IncidenteTabEnum.emergencia:
//         return const EmergenciaScreen();

//       case IncidenteTabEnum.historial:
//         return const HistorialIncidentesScreen();
//     }
//   }

//   // =========================================================
//   // BARRA INFERIOR
//   // =========================================================
//   Widget _buildBottomTabs(BuildContext context, IncidenteState state) {
//     return Container(
//       padding: const EdgeInsets.all(12),

//       decoration: BoxDecoration(
//         color: Colors.white,
//         boxShadow: [BoxShadow(blurRadius: 10, color: Colors.black12)],
//       ),

//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceAround,

//         children: [
//           _tabButton(
//             context,
//             icon: Icons.report,
//             label: 'Incidente',
//             selected: state.currentTab == IncidenteTabEnum.incidente,

//             tab: IncidenteTabEnum.incidente,
//           ),

//           _tabButton(
//             context,
//             icon: Icons.camera_alt,
//             label: 'Evidencia',
//             selected: state.currentTab == IncidenteTabEnum.evidencia,

//             tab: IncidenteTabEnum.evidencia,
//           ),

//           _tabButton(
//             context,
//             icon: Icons.emergency,
//             label: 'SOS',
//             selected: state.currentTab == IncidenteTabEnum.emergencia,

//             tab: IncidenteTabEnum.emergencia,
//           ),

//           _tabButton(
//             context,
//             icon: Icons.history,
//             label: 'Historial',
//             selected: state.currentTab == IncidenteTabEnum.historial,

//             tab: IncidenteTabEnum.historial,
//           ),
//         ],
//       ),
//     );
//   }

//   // =========================================================
//   // BOTON TAB
//   // =========================================================
//   Widget _tabButton(
//     BuildContext context, {
//     required IconData icon,
//     required String label,
//     required bool selected,
//     required IncidenteTabEnum tab,
//   }) {
//     return InkWell(
//       onTap: () {
//         context.read<IncidenteBloc>().add(CambiarTabEvent(tab));
//       },

//       child: AnimatedContainer(
//         duration: const Duration(milliseconds: 250),

//         padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),

//         decoration: BoxDecoration(
//           color: selected ? Colors.blue.shade100 : Colors.transparent,

//           borderRadius: BorderRadius.circular(20),
//         ),

//         child: Column(
//           mainAxisSize: MainAxisSize.min,

//           children: [
//             Icon(icon, color: selected ? Colors.blue : Colors.grey),

//             const SizedBox(height: 4),

//             Text(
//               label,

//               style: TextStyle(
//                 fontSize: 11,
//                 color: selected ? Colors.blue : Colors.grey,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
