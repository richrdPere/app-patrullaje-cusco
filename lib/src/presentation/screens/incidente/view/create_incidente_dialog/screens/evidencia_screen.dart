// // import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_archivo_model.dart';
// import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
// import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_event.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_state.dart';

// import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/view/create_incidente_dialog/widgets/media_preview_widget.dart';

// class EvidenciaScreen extends StatefulWidget {
//   const EvidenciaScreen({super.key});

//   @override
//   State<EvidenciaScreen> createState() => _EvidenciaScreenState();
// }

// class _EvidenciaScreenState extends State<EvidenciaScreen> {
//   static const int maxArchivos = 5;

//   @override
//   void initState() {
//     super.initState();

//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       if (!mounted) return;

//       final state = context.read<IncidenteBloc>().state;
//       final incidenciaId = state.incidenciaSeleccionada?.id;

//       if (incidenciaId != null &&
//           state.archivosIncidencia.isEmpty &&
//           state.archivosResponse is! Loading) {
//         context.read<IncidenteBloc>().add(
//           ObtenerArchivosIncidenciaEvent(incidenciaId),
//         );
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return MultiBlocListener(
//       listeners: [
//         BlocListener<IncidenteBloc, IncidenteState>(
//           listenWhen: (previous, current) {
//             return previous.archivoActionResponse !=
//                 current.archivoActionResponse;
//           },
//           listener: _onArchivoActionChanged,
//         ),
//         BlocListener<IncidenteBloc, IncidenteState>(
//           listenWhen: (previous, current) {
//             return previous.archivosResponse != current.archivosResponse;
//           },
//           listener: _onArchivosResponseChanged,
//         ),
//       ],
//       child: BlocBuilder<IncidenteBloc, IncidenteState>(
//         buildWhen: (previous, current) {
//           return previous.archivosLocales != current.archivosLocales ||
//               previous.archivosIncidencia != current.archivosIncidencia ||
//               previous.incidenciaSeleccionada !=
//                   current.incidenciaSeleccionada ||
//               previous.archivosResponse != current.archivosResponse ||
//               previous.archivoActionResponse != current.archivoActionResponse ||
//               previous.loadingMedia != current.loadingMedia ||
//               previous.recordingVideo != current.recordingVideo ||
//               previous.recordingAudio != current.recordingAudio;
//         },
//         builder: (context, state) {
//           final incidencia = state.incidenciaSeleccionada;
//           final incidenciaCreada = incidencia?.id != null;

//           return RefreshIndicator(
//             onRefresh: () => _refrescarArchivos(context, incidencia),
//             child: ListView(
//               physics: const AlwaysScrollableScrollPhysics(),
//               padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
//               children: [
//                 _buildInfoCard(incidenciaCreada: incidenciaCreada),

//                 const SizedBox(height: 20),

//                 _buildSectionHeader(
//                   icon: Icons.add_photo_alternate_outlined,
//                   title: incidenciaCreada
//                       ? 'Nuevas evidencias'
//                       : 'Evidencias del reporte',
//                   subtitle: incidenciaCreada
//                       ? 'Selecciona archivos para agregarlos a la incidencia.'
//                       : 'Estos archivos se enviarán al registrar el incidente.',
//                   count: state.archivosLocales.length,
//                 ),

//                 const SizedBox(height: 14),

//                 const MediaPreviewWidget(),

//                 if (incidenciaCreada && state.archivosLocales.isNotEmpty) ...[
//                   const SizedBox(height: 18),

//                   _buildUploadButton(
//                     context: context,
//                     state: state,
//                     incidenciaId: incidencia!.id!,
//                   ),
//                 ],

//                 if (incidenciaCreada) ...[
//                   const SizedBox(height: 28),

//                   _buildSectionHeader(
//                     icon: Icons.cloud_done_outlined,
//                     title: 'Evidencias almacenadas',
//                     subtitle:
//                         'Archivos que ya fueron enviados y asociados a la incidencia.',
//                     count: state.archivosIncidencia.length,
//                   ),

//                   const SizedBox(height: 14),

//                   _buildArchivosRemotos(context, state, incidencia!.id!),
//                 ],

//                 const SizedBox(height: 18),

//                 _buildFormatInfo(),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }

//   // ======================================================
//   // LISTENERS
//   // ======================================================
//   void _onArchivoActionChanged(BuildContext context, IncidenteState state) {
//     final response = state.archivoActionResponse;

//     if (response is Success<bool>) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           const SnackBar(
//             content: Text('Operación realizada correctamente.'),
//             backgroundColor: Colors.green,
//           ),
//         );

//       context.read<IncidenteBloc>().add(const LimpiarAccionIncidenteEvent());

//       return;
//     }

//     if (response is ErrorData<bool>) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content: Text(response.message),
//             backgroundColor: Colors.red,
//           ),
//         );

//       context.read<IncidenteBloc>().add(const LimpiarAccionIncidenteEvent());
//     }
//   }

//   void _onArchivosResponseChanged(BuildContext context, IncidenteState state) {
//     final response = state.archivosResponse;

//     if (response is ErrorData<List<IncidenciaArchivoModel>>) {
//       ScaffoldMessenger.of(context)
//         ..hideCurrentSnackBar()
//         ..showSnackBar(
//           SnackBar(
//             content: Text(response.message),
//             backgroundColor: Colors.red,
//           ),
//         );
//     }
//   }

//   // ======================================================
//   // ACTUALIZAR ARCHIVOS
//   // ======================================================
//   Future<void> _refrescarArchivos(
//     BuildContext context,
//     IncidenteModel? incidencia,
//   ) async {
//     final incidenciaId = incidencia?.id;

//     if (incidenciaId == null) {
//       return;
//     }

//     context.read<IncidenteBloc>().add(
//       ObtenerArchivosIncidenciaEvent(incidenciaId),
//     );

//     await context.read<IncidenteBloc>().stream.firstWhere(
//       (state) => state.archivosResponse is! Loading,
//     );
//   }

//   // ======================================================
//   // INFORMACIÓN PRINCIPAL
//   // ======================================================
//   Widget _buildInfoCard({required bool incidenciaCreada}) {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: incidenciaCreada
//             ? Colors.green.withValues(alpha: 0.07)
//             : Colors.blue.withValues(alpha: 0.07),
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(
//           color: incidenciaCreada
//               ? Colors.green.withValues(alpha: 0.25)
//               : Colors.blue.withValues(alpha: 0.25),
//         ),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           CircleAvatar(
//             backgroundColor: incidenciaCreada
//                 ? Colors.green.withValues(alpha: 0.14)
//                 : Colors.blue.withValues(alpha: 0.14),
//             child: Icon(
//               incidenciaCreada
//                   ? Icons.cloud_done_outlined
//                   : Icons.cloud_upload_outlined,
//               color: incidenciaCreada ? Colors.green : Colors.blue,
//             ),
//           ),

//           const SizedBox(width: 12),

//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   incidenciaCreada
//                       ? 'Incidencia registrada'
//                       : 'Evidencias pendientes',
//                   style: const TextStyle(
//                     fontWeight: FontWeight.w700,
//                     fontSize: 15,
//                   ),
//                 ),

//                 const SizedBox(height: 4),

//                 Text(
//                   incidenciaCreada
//                       ? 'Puedes consultar, agregar o eliminar archivos asociados.'
//                       : 'Los archivos seleccionados se enviarán junto con el reporte.',
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ======================================================
//   // HEADER DE SECCIÓN
//   // ======================================================
//   Widget _buildSectionHeader({
//     required IconData icon,
//     required String title,
//     required String subtitle,
//     required int count,
//   }) {
//     return Row(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Icon(icon, color: const Color.fromARGB(255, 12, 38, 145), size: 23),

//         const SizedBox(width: 10),

//         Expanded(
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               Text(
//                 title,
//                 style: const TextStyle(
//                   fontSize: 16,
//                   fontWeight: FontWeight.w700,
//                 ),
//               ),

//               const SizedBox(height: 2),

//               Text(
//                 subtitle,
//                 style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//               ),
//             ],
//           ),
//         ),

//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
//           decoration: BoxDecoration(
//             color: count >= maxArchivos
//                 ? Colors.orange.withValues(alpha: 0.12)
//                 : Colors.blue.withValues(alpha: 0.10),
//             borderRadius: BorderRadius.circular(20),
//           ),
//           child: Text(
//             '$count/$maxArchivos',
//             style: TextStyle(
//               fontSize: 12,
//               fontWeight: FontWeight.w700,
//               color: count >= maxArchivos
//                   ? Colors.orange.shade800
//                   : const Color.fromARGB(255, 12, 38, 145),
//             ),
//           ),
//         ),
//       ],
//     );
//   }

//   // ======================================================
//   // BOTÓN SUBIR ARCHIVOS
//   // ======================================================
//   Widget _buildUploadButton({
//     required BuildContext context,
//     required IncidenteState state,
//     required int incidenciaId,
//   }) {
//     final processing = state.isProcessingArchivo;

//     return SizedBox(
//       width: double.infinity,
//       height: 50,
//       child: ElevatedButton.icon(
//         onPressed: processing
//             ? null
//             : () {
//                 _agregarArchivos(
//                   context: context,
//                   state: state,
//                   incidenciaId: incidenciaId,
//                 );
//               },
//         icon: processing
//             ? const SizedBox(
//                 width: 19,
//                 height: 19,
//                 child: CircularProgressIndicator(
//                   strokeWidth: 2,
//                   color: Colors.white,
//                 ),
//               )
//             : const Icon(Icons.cloud_upload_outlined),
//         label: Text(
//           processing ? 'SUBIENDO ARCHIVOS...' : 'AGREGAR A LA INCIDENCIA',
//         ),
//         style: ElevatedButton.styleFrom(
//           backgroundColor: const Color.fromARGB(255, 12, 38, 145),
//           foregroundColor: Colors.white,
//           disabledBackgroundColor: Colors.grey.shade400,
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(14),
//           ),
//           textStyle: const TextStyle(fontWeight: FontWeight.w700),
//         ),
//       ),
//     );
//   }

//   void _agregarArchivos({
//     required BuildContext context,
//     required IncidenteState state,
//     required int incidenciaId,
//   }) {
//     final archivosLocales = state.archivosLocales;

//     if (archivosLocales.isEmpty) {
//       _showMessage(context, 'Seleccione al menos un archivo.');

//       return;
//     }

//     final totalFinal = state.archivosIncidencia.length + archivosLocales.length;

//     if (totalFinal > maxArchivos) {
//       _showMessage(
//         context,
//         'La incidencia solo puede tener hasta $maxArchivos archivos.',
//       );

//       return;
//     }

//     context.read<IncidenteBloc>().add(
//       AgregarArchivosIncidenciaEvent(
//         incidenciaId: incidenciaId,
//         archivos: archivosLocales,
//       ),
//     );
//   }

//   // ======================================================
//   // ARCHIVOS REMOTOS
//   // ======================================================
//   Widget _buildArchivosRemotos(
//     BuildContext context,
//     IncidenteState state,
//     int incidenciaId,
//   ) {
//     if (state.isLoadingArchivos) {
//       return const Center(
//         child: Padding(
//           padding: EdgeInsets.symmetric(vertical: 28),
//           child: CircularProgressIndicator(),
//         ),
//       );
//     }

//     if (state.archivosIncidencia.isEmpty) {
//       return _buildEmptyRemoteFiles();
//     }

//     return GridView.builder(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: state.archivosIncidencia.length,
//       gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
//         crossAxisCount: 3,
//         mainAxisSpacing: 10,
//         crossAxisSpacing: 10,
//         childAspectRatio: 1,
//       ),
//       itemBuilder: (context, index) {
//         final archivo = state.archivosIncidencia[index];

//         return _buildArchivoRemotoItem(
//           context: context,
//           archivo: archivo,
//           incidenciaId: incidenciaId,
//           disabled: state.isProcessingArchivo,
//         );
//       },
//     );
//   }

//   Widget _buildEmptyRemoteFiles() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 28),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(16),
//         border: Border.all(color: Colors.grey.shade300),
//       ),
//       child: Column(
//         children: [
//           Icon(Icons.cloud_off_outlined, size: 42, color: Colors.grey.shade500),

//           const SizedBox(height: 10),

//           const Text(
//             'No existen evidencias almacenadas',
//             style: TextStyle(fontWeight: FontWeight.w700),
//           ),

//           const SizedBox(height: 4),

//           Text(
//             'Selecciona nuevos archivos para agregarlos.',
//             textAlign: TextAlign.center,
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildArchivoRemotoItem({
//     required BuildContext context,
//     required IncidenciaArchivoModel archivo,
//     required int incidenciaId,
//     required bool disabled,
//   }) {
//     final tipo = _obtenerTipoArchivoRemoto(archivo);

//     return Stack(
//       fit: StackFit.expand,
//       children: [
//         ClipRRect(
//           borderRadius: BorderRadius.circular(12),
//           child: Container(
//             color: Colors.grey.shade200,
//             child: _buildRemotePreview(archivo, tipo),
//           ),
//         ),

//         Positioned(left: 5, bottom: 5, child: _buildTypeBadge(tipo)),

//         if (archivo.id != null)
//           Positioned(
//             top: 5,
//             right: 5,
//             child: Material(
//               color: Colors.black54,
//               shape: const CircleBorder(),
//               child: InkWell(
//                 customBorder: const CircleBorder(),
//                 onTap: disabled
//                     ? null
//                     : () {
//                         _confirmarEliminarArchivo(
//                           context: context,
//                           incidenciaId: incidenciaId,
//                           archivoId: archivo.id!,
//                         );
//                       },
//                 child: const Padding(
//                   padding: EdgeInsets.all(5),
//                   child: Icon(
//                     Icons.delete_outline,
//                     color: Colors.white,
//                     size: 17,
//                   ),
//                 ),
//               ),
//             ),
//           ),
//       ],
//     );
//   }

//   Widget _buildRemotePreview(
//     IncidenciaArchivoModel archivo,
//     TipoEvidencia tipo,
//   ) {
//     switch (tipo) {
//       case TipoEvidencia.imagen:
//         return Image.network(
//           archivo.urlArchivo,
//           fit: BoxFit.cover,
//           loadingBuilder: (context, child, loadingProgress) {
//             if (loadingProgress == null) {
//               return child;
//             }

//             return const Center(
//               child: CircularProgressIndicator(strokeWidth: 2),
//             );
//           },
//           errorBuilder: (_, __, ___) {
//             return const Center(
//               child: Icon(
//                 Icons.broken_image_outlined,
//                 size: 38,
//                 color: Colors.black45,
//               ),
//             );
//           },
//         );

//       case TipoEvidencia.video:
//         return const Center(
//           child: Icon(
//             Icons.play_circle_fill_rounded,
//             size: 46,
//             color: Colors.black54,
//           ),
//         );

//       case TipoEvidencia.audio:
//         return const Center(
//           child: Icon(
//             Icons.audio_file_outlined,
//             size: 42,
//             color: Colors.black54,
//           ),
//         );

//       case TipoEvidencia.otro:
//         return const Center(
//           child: Icon(
//             Icons.insert_drive_file_outlined,
//             size: 42,
//             color: Colors.black54,
//           ),
//         );
//     }
//   }

//   Widget _buildTypeBadge(TipoEvidencia tipo) {
//     final IconData icon;
//     final String text;

//     switch (tipo) {
//       case TipoEvidencia.imagen:
//         icon = Icons.image_outlined;
//         text = 'Imagen';
//         break;

//       case TipoEvidencia.video:
//         icon = Icons.videocam_outlined;
//         text = 'Video';
//         break;

//       case TipoEvidencia.audio:
//         icon = Icons.mic_none;
//         text = 'Audio';
//         break;

//       case TipoEvidencia.otro:
//         icon = Icons.insert_drive_file_outlined;
//         text = 'Archivo';
//         break;
//     }

//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
//       decoration: BoxDecoration(
//         color: Colors.black54,
//         borderRadius: BorderRadius.circular(6),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(icon, color: Colors.white, size: 11),
//           const SizedBox(width: 3),
//           Text(
//             text,
//             style: const TextStyle(
//               color: Colors.white,
//               fontSize: 9,
//               fontWeight: FontWeight.w600,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Future<void> _confirmarEliminarArchivo({
//     required BuildContext context,
//     required int incidenciaId,
//     required int archivoId,
//   }) async {
//     final confirmar = await showDialog<bool>(
//       context: context,
//       builder: (dialogContext) {
//         return AlertDialog(
//           title: const Text('Eliminar evidencia'),
//           content: const Text(
//             '¿Está seguro de eliminar este archivo? '
//             'Esta acción no se puede deshacer.',
//           ),
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
//               style: FilledButton.styleFrom(backgroundColor: Colors.red),
//               child: const Text('Eliminar'),
//             ),
//           ],
//         );
//       },
//     );

//     if (confirmar != true || !context.mounted) {
//       return;
//     }

//     context.read<IncidenteBloc>().add(
//       EliminarArchivoIncidenciaEvent(
//         incidenciaId: incidenciaId,
//         archivoId: archivoId,
//       ),
//     );
//   }

//   // ======================================================
//   // INFORMACIÓN DE FORMATOS
//   // ======================================================
//   Widget _buildFormatInfo() {
//     return Container(
//       width: double.infinity,
//       padding: const EdgeInsets.all(14),
//       decoration: BoxDecoration(
//         color: Colors.amber.withValues(alpha: 0.08),
//         borderRadius: BorderRadius.circular(14),
//         border: Border.all(color: Colors.amber.withValues(alpha: 0.30)),
//       ),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Icon(Icons.info_outline, color: Colors.amber.shade800, size: 21),

//           const SizedBox(width: 10),

//           Expanded(
//             child: Text(
//               'Formatos permitidos: JPG, JPEG, PNG, HEIC, HEIF, MP4 y MOV. '
//               'Se admite un máximo de $maxArchivos evidencias por incidencia.',
//               style: TextStyle(fontSize: 12, color: Colors.amber.shade900),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   // ======================================================
//   // HELPERS
//   // ======================================================
//   TipoEvidencia _obtenerTipoArchivoRemoto(IncidenciaArchivoModel archivo) {
//     final tipo = archivo.tipoArchivo.toUpperCase();
//     final mime = archivo.mimeType.toLowerCase();

//     if (tipo == 'IMAGEN' || mime.startsWith('image/')) {
//       return TipoEvidencia.imagen;
//     }

//     if (tipo == 'VIDEO' || mime.startsWith('video/')) {
//       return TipoEvidencia.video;
//     }

//     if (tipo == 'AUDIO' || mime.startsWith('audio/')) {
//       return TipoEvidencia.audio;
//     }

//     return TipoEvidencia.otro;
//   }

//   void _showMessage(BuildContext context, String message) {
//     ScaffoldMessenger.of(context)
//       ..hideCurrentSnackBar()
//       ..showSnackBar(SnackBar(content: Text(message)));
//   }
// }

// enum TipoEvidencia { imagen, video, audio, otro }
