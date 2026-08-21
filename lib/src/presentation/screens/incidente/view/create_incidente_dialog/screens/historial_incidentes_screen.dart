// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';

// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';

// import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_state.dart';

// class HistorialIncidentesScreen extends StatefulWidget {
//   const HistorialIncidentesScreen({super.key});

//   @override
//   State<HistorialIncidentesScreen> createState() =>
//       _HistorialIncidentesScreenState();
// }

// class _HistorialIncidentesScreenState extends State<HistorialIncidentesScreen> {
//   bool _esperandoDetalle = false;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       _cargarHistorial();
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     final patrullaje = context.watch<HomeBloc>().state.patrullaje;

//     final patrullajeId = patrullaje?.id;

//     return MultiBlocListener(
//       listeners: [
//         BlocListener<HistorialPatrullajeBloc, HistorialPatrullajeState>(
//           listenWhen: (previous, current) {
//             return previous.actionStatus != current.actionStatus;
//           },
//           listener: _onActionStateChanged,
//         ),

//         BlocListener<HistorialPatrullajeBloc, HistorialPatrullajeState>(
//           listenWhen: (previous, current) {
//             return previous.detailStatus != current.detailStatus ||
//                 previous.historialSelected != current.historialSelected;
//           },
//           listener: _onDetailStateChanged,
//         ),
//       ],
//       child: BlocBuilder<HistorialPatrullajeBloc, HistorialPatrullajeState>(
//         builder: (context, state) {
//           if (patrullajeId == null) {
//             return _buildNoPatrullaje();
//           }

//           return RefreshIndicator(
//             onRefresh: () {
//               return _refreshHistorial(patrullajeId);
//             },
//             child: _buildContent(
//               context: context,
//               state: state,
//               patrullajeId: patrullajeId,
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ======================================================
//   // CONTENIDO SEGÚN ESTADO
//   // ======================================================

//   Widget _buildContent({
//     required BuildContext context,
//     required HistorialPatrullajeState state,
//     required int patrullajeId,
//   }) {
//     switch (state.listStatus) {
//       case HistorialListStatus.initial:
//       case HistorialListStatus.loading:
//         return _buildLoading();

//       case HistorialListStatus.empty:
//         return _buildEmpty(patrullajeId);

//       case HistorialListStatus.error:
//         return _buildError(
//           patrullajeId: patrullajeId,
//           message:
//               state.errorMessage ??
//               'No se pudo obtener el historial del patrullaje.',
//           detail: state.errorDetail,
//         );

//       case HistorialListStatus.success:
//         return _buildHistorialList(state: state, patrullajeId: patrullajeId);
//     }
//   }

//   // ======================================================
//   // LISTADO
//   // ======================================================

//   Widget _buildHistorialList({
//     required HistorialPatrullajeState state,
//     required int patrullajeId,
//   }) {
//     final historial = state.historial;

//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//       children: [
//         _buildHeader(cantidad: historial.length, patrullajeId: patrullajeId),

//         const SizedBox(height: 18),

//         ...historial.map(
//           (registro) => Padding(
//             padding: const EdgeInsets.only(bottom: 12),
//             child: _HistorialCard(
//               registro: registro,
//               onTap: () {
//                 _abrirDetalle(registro);
//               },
//               onArchive: registro.id == null
//                   ? null
//                   : () {
//                       _confirmarArchivar(historialId: registro.id!);
//                     },
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ======================================================
//   // HEADER
//   // ======================================================

//   Widget _buildHeader({required int cantidad, required int patrullajeId}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.blue.withValues(alpha: 0.07),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.blue.withValues(alpha: 0.22)),
//       ),
//       child: Row(
//         children: [
//           CircleAvatar(
//             backgroundColor: Colors.blue.withValues(alpha: 0.14),
//             child: const Icon(Icons.history_rounded, color: Colors.blue),
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 const Text(
//                   'Historial operativo',
//                   style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   'Patrullaje N.° $patrullajeId',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//                 ),
//               ],
//             ),
//           ),

//           Container(
//             padding: const EdgeInsets.symmetric(horizontal: 11, vertical: 6),
//             decoration: BoxDecoration(
//               color: const Color.fromARGB(255, 12, 38, 145),
//               borderRadius: BorderRadius.circular(20),
//             ),
//             child: Text(
//               '$cantidad',
//               style: const TextStyle(
//                 color: Colors.white,
//                 fontWeight: FontWeight.w700,
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ======================================================
//   // CARGA
//   // ======================================================

//   Widget _buildLoading() {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
//       children: const [
//         SizedBox(height: 120),

//         Center(child: CircularProgressIndicator()),

//         SizedBox(height: 16),

//         Center(
//           child: Text(
//             'Cargando historial...',
//             style: TextStyle(color: Colors.black54),
//           ),
//         ),
//       ],
//     );
//   }

//   // ======================================================
//   // VACÍO
//   // ======================================================

//   Widget _buildEmpty(int patrullajeId) {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
//       children: [
//         Icon(Icons.note_alt_outlined, size: 72, color: Colors.grey.shade400),

//         const SizedBox(height: 18),

//         const Text(
//           'No existen registros',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
//         ),

//         const SizedBox(height: 8),

//         Text(
//           'Todavía no se registraron observaciones, novedades '
//           'o recomendaciones en este patrullaje.',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//         ),

//         const SizedBox(height: 24),

//         OutlinedButton.icon(
//           onPressed: () {
//             _cargarHistorial(patrullajeId: patrullajeId, refresh: true);
//           },
//           icon: const Icon(Icons.refresh),
//           label: const Text('Actualizar'),
//         ),
//       ],
//     );
//   }

//   // ======================================================
//   // ERROR
//   // ======================================================

//   Widget _buildError({
//     required int patrullajeId,
//     required String message,
//     String? detail,
//   }) {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(24, 70, 24, 32),
//       children: [
//         const Icon(Icons.error_outline, size: 70, color: Colors.red),

//         const SizedBox(height: 18),

//         const Text(
//           'No se pudo cargar el historial',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
//         ),

//         const SizedBox(height: 8),

//         Text(
//           message,
//           textAlign: TextAlign.center,
//           style: TextStyle(color: Colors.grey.shade700),
//         ),

//         if (detail != null && detail.trim().isNotEmpty) ...[
//           const SizedBox(height: 8),

//           Text(
//             detail,
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//           ),
//         ],

//         const SizedBox(height: 24),

//         ElevatedButton.icon(
//           onPressed: () {
//             _cargarHistorial(patrullajeId: patrullajeId, refresh: true);
//           },
//           icon: const Icon(Icons.refresh),
//           label: const Text('REINTENTAR'),
//         ),
//       ],
//     );
//   }

//   // ======================================================
//   // SIN PATRULLAJE
//   // ======================================================

//   Widget _buildNoPatrullaje() {
//     return ListView(
//       physics: const AlwaysScrollableScrollPhysics(),
//       padding: const EdgeInsets.fromLTRB(24, 80, 24, 32),
//       children: [
//         Icon(Icons.shield_outlined, size: 72, color: Colors.orange.shade400),

//         const SizedBox(height: 18),

//         const Text(
//           'Sin patrullaje activo',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 19, fontWeight: FontWeight.w700),
//         ),

//         const SizedBox(height: 8),

//         Text(
//           'Debes tener un patrullaje asignado o en curso para '
//           'consultar sus observaciones y novedades.',
//           textAlign: TextAlign.center,
//           style: TextStyle(fontSize: 13, color: Colors.grey.shade600),
//         ),
//       ],
//     );
//   }

//   // ======================================================
//   // CARGAR Y REFRESCAR
//   // ======================================================

//   void _cargarHistorial({int? patrullajeId, bool refresh = false}) {
//     final id = patrullajeId ?? context.read<HomeBloc>().state.patrullaje?.id;

//     if (id == null) return;

//     context.read<HistorialPatrullajeBloc>().add(
//       LoadHistorialPatrullajeEvent(patrullajeId: id, refresh: refresh),
//     );
//   }

//   Future<void> _refreshHistorial(int patrullajeId) async {
//     final bloc = context.read<HistorialPatrullajeBloc>();

//     bloc.add(
//       LoadHistorialPatrullajeEvent(patrullajeId: patrullajeId, refresh: true),
//     );

//     await bloc.stream.firstWhere(
//       (state) => state.listStatus != HistorialListStatus.loading,
//     );
//   }

//   // ======================================================
//   // DETALLE
//   // ======================================================

//   void _abrirDetalle(HistorialPatrullajeModel registro) {
//     final historialId = registro.id;

//     if (historialId == null) {
//       _mostrarDetalleDialog(registro);
//       return;
//     }

//     setState(() {
//       _esperandoDetalle = true;
//     });

//     context.read<HistorialPatrullajeBloc>().add(
//       LoadHistorialDetalleEvent(historialId: historialId),
//     );
//   }

//   void _onDetailStateChanged(
//     BuildContext context,
//     HistorialPatrullajeState state,
//   ) {
//     if (!_esperandoDetalle) return;

//     if (state.detailStatus == HistorialDetailStatus.success &&
//         state.historialSelected != null) {
//       setState(() {
//         _esperandoDetalle = false;
//       });

//       _mostrarDetalleDialog(state.historialSelected!);

//       return;
//     }

//     if (state.detailStatus == HistorialDetailStatus.error) {
//       setState(() {
//         _esperandoDetalle = false;
//       });

//       _showMessage(
//         state.errorMessage ?? 'No se pudo obtener el detalle.',
//         error: true,
//       );
//     }
//   }

//   Future<void> _mostrarDetalleDialog(HistorialPatrullajeModel registro) async {
//     await showModalBottomSheet<void>(
//       context: context,
//       isScrollControlled: true,
//       showDragHandle: true,
//       builder: (bottomSheetContext) {
//         return DraggableScrollableSheet(
//           expand: false,
//           initialChildSize: 0.68,
//           minChildSize: 0.45,
//           maxChildSize: 0.92,
//           builder: (context, scrollController) {
//             return ListView(
//               controller: scrollController,
//               padding: const EdgeInsets.fromLTRB(20, 4, 20, 32),
//               children: [
//                 Row(
//                   children: [
//                     _TipoHistorialIcon(tipo: registro.tipo, size: 48),

//                     const SizedBox(width: 12),

//                     Expanded(
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           Text(
//                             _formatTipo(registro.tipo),
//                             style: const TextStyle(
//                               fontSize: 12,
//                               color: Colors.black54,
//                               fontWeight: FontWeight.w600,
//                             ),
//                           ),

//                           const SizedBox(height: 3),

//                           Text(
//                             registro.titulo,
//                             style: const TextStyle(
//                               fontSize: 19,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),

//                 const SizedBox(height: 22),

//                 _DetailRow(
//                   icon: Icons.description_outlined,
//                   label: 'Descripción',
//                   value: registro.descripcion,
//                 ),

//                 const SizedBox(height: 16),

//                 _DetailRow(
//                   icon: Icons.flag_outlined,
//                   label: 'Prioridad',
//                   value: _formatPrioridad(registro.prioridad),
//                 ),

//                 const SizedBox(height: 16),

//                 _DetailRow(
//                   icon: Icons.schedule,
//                   label: 'Fecha y hora',
//                   value: _formatDateTime(registro.fechaHora),
//                 ),

//                 const SizedBox(height: 16),

//                 _DetailRow(
//                   icon: Icons.change_circle_outlined,
//                   label: 'Siguiente turno',
//                   value: registro.visibleParaSiguienteTurno
//                       ? 'Visible para el siguiente turno'
//                       : 'Solo visible en el turno actual',
//                 ),

//                 if (registro.latitud != null && registro.longitud != null) ...[
//                   const SizedBox(height: 16),

//                   _DetailRow(
//                     icon: Icons.location_on_outlined,
//                     label: 'Ubicación',
//                     value: '${registro.latitud}, ${registro.longitud}',
//                   ),
//                 ],

//                 // if (registro.estado != null) ...[
//                 //   const SizedBox(height: 16),

//                 //   _DetailRow(
//                 //     icon: Icons.info_outline,
//                 //     label: 'Estado',
//                 //     value: registro.estado!,
//                 //   ),
//                 // ],
//               ],
//             );
//           },
//         );
//       },
//     );

//     if (!mounted) return;

//     context.read<HistorialPatrullajeBloc>().add(
//       const ClearHistorialSelectedEvent(),
//     );
//   }

//   // ======================================================
//   // ARCHIVAR
//   // ======================================================

//   Future<void> _confirmarArchivar({required int historialId}) async {
//     final confirmar = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text('Archivar registro'),
//           content: const Text('¿Deseas archivar este registro del historial?'),
//           actions: [
//             TextButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, false);
//               },
//               child: const Text('Cancelar'),
//             ),

//             FilledButton(
//               onPressed: () {
//                 Navigator.pop(dialogContext, true);
//               },
//               child: const Text('Archivar'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmar != true || !mounted) return;

//     context.read<HistorialPatrullajeBloc>().add(
//       ArchiveHistorialEvent(historialId: historialId),
//     );
//   }

//   void _onActionStateChanged(
//     BuildContext context,
//     HistorialPatrullajeState state,
//   ) {
//     if (state.actionStatus == HistorialActionStatus.success) {
//       _showMessage(state.actionMessage ?? 'Operación realizada correctamente.');

//       final patrullajeId = context.read<HomeBloc>().state.patrullaje?.id;

//       if (patrullajeId != null) {
//         _cargarHistorial(patrullajeId: patrullajeId, refresh: true);
//       }

//       context.read<HistorialPatrullajeBloc>().add(
//         const ClearHistorialActionEvent(),
//       );

//       return;
//     }

//     if (state.actionStatus == HistorialActionStatus.error) {
//       _showMessage(
//         state.errorMessage ??
//             state.actionMessage ??
//             'No se pudo realizar la operación.',
//         error: true,
//       );

//       context.read<HistorialPatrullajeBloc>().add(
//         const ClearHistorialActionEvent(),
//       );
//     }
//   }

//   // ======================================================
//   // HELPERS
//   // ======================================================

//   void _showMessage(String message, {bool error = false}) {
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(
//         SnackBar(
//           content: Text(message),
//           backgroundColor: error ? Colors.red : Colors.green,
//         ),
//       );
//   }
// }

// // ======================================================
// // TARJETA DE HISTORIAL
// // ======================================================

// class _HistorialCard extends StatelessWidget {
//   final HistorialPatrullajeModel registro;
//   final VoidCallback onTap;
//   final VoidCallback? onArchive;

//   const _HistorialCard({
//     required this.registro,
//     required this.onTap,
//     required this.onArchive,
//   });

//   @override
//   Widget build(BuildContext context) {
//     final prioridadColor = _getPrioridadColor(registro.prioridad);

//     return Material(
//       color: Colors.white,
//       borderRadius: BorderRadius.circular(16),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(16),
//         child: Container(
//           padding: const EdgeInsets.all(15),
//           decoration: BoxDecoration(
//             borderRadius: BorderRadius.circular(16),
//             border: Border.all(color: Colors.grey.shade300),
//             boxShadow: [
//               BoxShadow(
//                 color: Colors.black.withValues(alpha: 0.03),
//                 blurRadius: 10,
//                 offset: const Offset(0, 4),
//               ),
//             ],
//           ),
//           child: Row(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _TipoHistorialIcon(tipo: registro.tipo),

//               const SizedBox(width: 12),

//               Expanded(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         Expanded(
//                           child: Text(
//                             registro.titulo,
//                             maxLines: 1,
//                             overflow: TextOverflow.ellipsis,
//                             style: const TextStyle(
//                               fontSize: 15,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),

//                         const SizedBox(width: 8),

//                         Container(
//                           padding: const EdgeInsets.symmetric(
//                             horizontal: 8,
//                             vertical: 4,
//                           ),
//                           decoration: BoxDecoration(
//                             color: prioridadColor.withValues(alpha: 0.10),
//                             borderRadius: BorderRadius.circular(12),
//                           ),
//                           child: Text(
//                             _formatPrioridad(registro.prioridad),
//                             style: TextStyle(
//                               color: prioridadColor,
//                               fontSize: 10,
//                               fontWeight: FontWeight.w700,
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),

//                     const SizedBox(height: 4),

//                     Text(
//                       _formatTipo(registro.tipo),
//                       style: const TextStyle(
//                         fontSize: 11,
//                         color: Color.fromARGB(255, 12, 38, 145),
//                         fontWeight: FontWeight.w600,
//                       ),
//                     ),

//                     const SizedBox(height: 7),

//                     Text(
//                       registro.descripcion,
//                       maxLines: 2,
//                       overflow: TextOverflow.ellipsis,
//                       style: TextStyle(
//                         fontSize: 12,
//                         height: 1.35,
//                         color: Colors.grey.shade700,
//                       ),
//                     ),

//                     const SizedBox(height: 10),

//                     Row(
//                       children: [
//                         Icon(
//                           Icons.schedule,
//                           size: 15,
//                           color: Colors.grey.shade500,
//                         ),

//                         const SizedBox(width: 5),

//                         Expanded(
//                           child: Text(
//                             _formatDateTime(registro.fechaHora),
//                             style: TextStyle(
//                               fontSize: 11,
//                               color: Colors.grey.shade600,
//                             ),
//                           ),
//                         ),

//                         if (registro.visibleParaSiguienteTurno)
//                           Tooltip(
//                             message: 'Visible para el siguiente turno',
//                             child: Icon(
//                               Icons.change_circle_outlined,
//                               size: 18,
//                               color: Colors.green.shade600,
//                             ),
//                           ),

//                         if (onArchive != null) ...[
//                           const SizedBox(width: 6),

//                           IconButton(
//                             tooltip: 'Archivar',
//                             visualDensity: VisualDensity.compact,
//                             onPressed: onArchive,
//                             icon: const Icon(Icons.archive_outlined, size: 20),
//                           ),
//                         ],
//                       ],
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }

// // ======================================================
// // ICONO SEGÚN TIPO
// // ======================================================

// class _TipoHistorialIcon extends StatelessWidget {
//   final String tipo;
//   final double size;

//   const _TipoHistorialIcon({required this.tipo, this.size = 44});

//   @override
//   Widget build(BuildContext context) {
//     final data = _getTipoData(tipo);

//     return Container(
//       width: size,
//       height: size,
//       decoration: BoxDecoration(
//         color: data.color.withValues(alpha: 0.12),
//         shape: BoxShape.circle,
//       ),
//       child: Icon(data.icon, color: data.color, size: size * 0.48),
//     );
//   }
// }

// class _TipoData {
//   final IconData icon;
//   final Color color;

//   const _TipoData({required this.icon, required this.color});
// }

// _TipoData _getTipoData(String tipo) {
//   switch (tipo.toUpperCase()) {
//     case 'NOVEDAD':
//       return const _TipoData(
//         icon: Icons.new_releases_outlined,
//         color: Colors.blue,
//       );

//     case 'ALERTA':
//       return const _TipoData(
//         icon: Icons.warning_amber_rounded,
//         color: Colors.red,
//       );

//     case 'RECOMENDACION':
//       return const _TipoData(
//         icon: Icons.lightbulb_outline,
//         color: Colors.amber,
//       );

//     case 'PUNTO_CRITICO':
//       return const _TipoData(
//         icon: Icons.location_on_outlined,
//         color: Colors.deepOrange,
//       );

//     case 'CAMBIO_TURNO':
//       return const _TipoData(icon: Icons.swap_horiz, color: Colors.purple);

//     case 'OBSERVACION':
//     default:
//       return const _TipoData(
//         icon: Icons.visibility_outlined,
//         color: Colors.green,
//       );
//   }
// }

// // ======================================================
// // FILA DE DETALLE
// // ======================================================

// class _DetailRow extends StatelessWidget {
//   final IconData icon;
//   final String label;
//   final String value;

//   const _DetailRow({
//     required this.icon,
//     required this.label,
//     required this.value,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: const Color.fromARGB(255, 12, 38, 145), size: 21),

//         const SizedBox(width: 12),

//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 label,
//                 style: TextStyle(
//                   fontSize: 11,
//                   color: Colors.grey.shade600,
//                   fontWeight: FontWeight.w600,
//                 ),
//               ),

//               const SizedBox(height: 4),

//               Text(value, style: const TextStyle(fontSize: 14, height: 1.4)),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
// }

// // ======================================================
// // FUNCIONES DE FORMATO
// // ======================================================

// String _formatTipo(String tipo) {
//   switch (tipo.toUpperCase()) {
//     case 'OBSERVACION':
//       return 'Observación';

//     case 'NOVEDAD':
//       return 'Novedad';

//     case 'ALERTA':
//       return 'Alerta';

//     case 'RECOMENDACION':
//       return 'Recomendación';

//     case 'PUNTO_CRITICO':
//       return 'Punto crítico';

//     case 'CAMBIO_TURNO':
//       return 'Cambio de turno';

//     default:
//       return tipo;
//   }
// }

// String _formatPrioridad(String? prioridad) {
//   switch (prioridad?.toUpperCase()) {
//     case 'BAJA':
//       return 'Baja';

//     case 'ALTA':
//       return 'Alta';

//     case 'CRITICA':
//       return 'Crítica';

//     case 'MEDIA':
//     default:
//       return 'Media';
//   }
// }

// Color _getPrioridadColor(String? prioridad) {
//   switch (prioridad?.toUpperCase()) {
//     case 'BAJA':
//       return Colors.green;

//     case 'ALTA':
//       return Colors.orange;

//     case 'CRITICA':
//       return Colors.red;

//     case 'MEDIA':
//     default:
//       return Colors.blue;
//   }
// }

// String _formatDateTime(DateTime? dateTime) {
//   if (dateTime == null) {
//     return 'Fecha no disponible';
//   }

//   String twoDigits(int value) {
//     return value.toString().padLeft(2, '0');
//   }

//   return '${twoDigits(dateTime.day)}/'
//       '${twoDigits(dateTime.month)}/'
//       '${dateTime.year} '
//       '${twoDigits(dateTime.hour)}:'
//       '${twoDigits(dateTime.minute)}';
// }
