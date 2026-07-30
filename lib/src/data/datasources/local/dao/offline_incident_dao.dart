// import 'package:drift/drift.dart';

// import '../database/offline_database.dart';
// import '../database/tables/offline_incident_file_table.dart';
// import '../database/tables/offline_incident_table.dart';
// import '../models/local_sync_status.dart';
// import '../models/offline_incident_input.dart';
// import '../models/offline_incident_with_files.dart';

// part 'offline_incident_dao.g.dart';

// @DriftAccessor(tables: [OfflineIncidents, OfflineIncidentFiles])
// class OfflineIncidentDao extends DatabaseAccessor<OfflineDatabase>
//     with _$OfflineIncidentDaoMixin {
//   OfflineIncidentDao(super.db);

//   // ======================================================
//   // REGISTRAR INCIDENCIA COMPLETA
//   // ======================================================

//   Future<int> insertIncident(OfflineIncidentInput input) {
//     return transaction(() async {
//       final existing = await getIncidentByClientId(input.clientId);

//       if (existing != null) {
//         return existing.id;
//       }

//       final incidentId = await into(offlineIncidents).insert(
//         OfflineIncidentsCompanion.insert(
//           clientId: input.clientId,
//           usuarioId: input.usuarioId,
//           patrullajeId: Value(input.patrullajeId),
//           zonaId: Value(input.zonaId),
//           tipo: input.tipo,
//           descripcion: input.descripcion,
//           latitud: input.latitud,
//           longitud: input.longitud,
//           fechaHora: input.fechaHora,
//         ),
//       );

//       for (final file in input.archivos) {
//         await into(offlineIncidentFiles).insert(
//           OfflineIncidentFilesCompanion.insert(
//             offlineIncidentId: incidentId,
//             clientId: file.clientId,
//             localPath: file.localPath,
//             fileName: file.fileName,
//             mimeType: file.mimeType,
//             categoria: file.categoria,
//             sizeBytes: Value(file.sizeBytes),
//           ),
//           mode: InsertMode.insertOrIgnore,
//         );
//       }

//       return incidentId;
//     });
//   }

//   // ======================================================
//   // OBTENER INCIDENCIA
//   // ======================================================

//   Future<OfflineIncidentData?> getIncidentById(int id) {
//     return (select(
//       offlineIncidents,
//     )..where((table) => table.id.equals(id))).getSingleOrNull();
//   }

//   Future<OfflineIncidentData?> getIncidentByClientId(String clientId) {
//     return (select(
//       offlineIncidents,
//     )..where((table) => table.clientId.equals(clientId))).getSingleOrNull();
//   }

//   Future<List<OfflineIncidentFileData>> getIncidentFiles(
//     int offlineIncidentId,
//   ) {
//     return (select(offlineIncidentFiles)
//           ..where((table) => table.offlineIncidentId.equals(offlineIncidentId))
//           ..orderBy([(table) => OrderingTerm.asc(table.createdAt)]))
//         .get();
//   }

//   Future<OfflineIncidentWithFiles?> getIncidentWithFiles(int id) async {
//     final incident = await getIncidentById(id);

//     if (incident == null) return null;

//     final files = await getIncidentFiles(id);

//     return OfflineIncidentWithFiles(incident: incident, files: files);
//   }

//   // ======================================================
//   // OBTENER PENDIENTES
//   // ======================================================

//   Future<List<OfflineIncidentData>> getPendingIncidents({
//     int limit = 20,
//     int? usuarioId,
//   }) {
//     final query = select(offlineIncidents);

//     query.where((table) {
//       Expression<bool> condition =
//           table.syncStatus.equals(LocalSyncStatus.pending.value) |
//           table.syncStatus.equals(LocalSyncStatus.failed.value);

//       if (usuarioId != null) {
//         condition = condition & table.usuarioId.equals(usuarioId);
//       }

//       return condition;
//     });

//     query
//       ..orderBy([(table) => OrderingTerm.asc(table.fechaHora)])
//       ..limit(limit);

//     return query.get();
//   }

//   Future<List<OfflineIncidentWithFiles>> getPendingIncidentsWithFiles({
//     int limit = 20,
//     int? usuarioId,
//   }) async {
//     final incidents = await getPendingIncidents(
//       limit: limit,
//       usuarioId: usuarioId,
//     );

//     final result = <OfflineIncidentWithFiles>[];

//     for (final incident in incidents) {
//       final files = await getIncidentFiles(incident.id);

//       result.add(OfflineIncidentWithFiles(incident: incident, files: files));
//     }

//     return result;
//   }

//   Stream<List<OfflineIncidentData>> watchPendingIncidents({int? usuarioId}) {
//     final query = select(offlineIncidents);

//     query.where((table) {
//       Expression<bool> condition =
//           table.syncStatus.equals(LocalSyncStatus.pending.value) |
//           table.syncStatus.equals(LocalSyncStatus.failed.value);

//       if (usuarioId != null) {
//         condition = condition & table.usuarioId.equals(usuarioId);
//       }

//       return condition;
//     });

//     query.orderBy([(table) => OrderingTerm.asc(table.fechaHora)]);

//     return query.watch();
//   }

//   // ======================================================
//   // ESTADOS DE INCIDENCIA
//   // ======================================================

//   Future<int> markIncidentAsSyncing(int id) {
//     return (update(
//       offlineIncidents,
//     )..where((table) => table.id.equals(id))).write(
//       OfflineIncidentsCompanion(
//         syncStatus: Value(LocalSyncStatus.syncing.value),
//         lastError: const Value(null),
//         updatedAt: Value(DateTime.now()),
//       ),
//     );
//   }

//   Future<int> markIncidentAsSynced({
//     required int localId,
//     required int serverId,
//   }) {
//     final now = DateTime.now();

//     return (update(
//       offlineIncidents,
//     )..where((table) => table.id.equals(localId))).write(
//       OfflineIncidentsCompanion(
//         serverId: Value(serverId),
//         syncStatus: Value(LocalSyncStatus.synced.value),
//         syncedAt: Value(now),
//         updatedAt: Value(now),
//         lastError: const Value(null),
//       ),
//     );
//   }

//   Future<void> markIncidentAsFailed({
//     required int localId,
//     required String error,
//   }) async {
//     final current = await getIncidentById(localId);

//     if (current == null) return;

//     await (update(
//       offlineIncidents,
//     )..where((table) => table.id.equals(localId))).write(
//       OfflineIncidentsCompanion(
//         syncStatus: Value(LocalSyncStatus.failed.value),
//         retryCount: Value(current.retryCount + 1),
//         lastError: Value(error),
//         updatedAt: Value(DateTime.now()),
//       ),
//     );
//   }

//   Future<int> resetSyncingIncidentsToPending() {
//     return (update(offlineIncidents)..where(
//           (table) => table.syncStatus.equals(LocalSyncStatus.syncing.value),
//         ))
//         .write(
//           OfflineIncidentsCompanion(
//             syncStatus: Value(LocalSyncStatus.pending.value),
//             updatedAt: Value(DateTime.now()),
//           ),
//         );
//   }

//   // ======================================================
//   // ESTADOS DE ARCHIVOS
//   // ======================================================

//   Future<int> markFileAsSyncing(int fileId) {
//     return (update(
//       offlineIncidentFiles,
//     )..where((table) => table.id.equals(fileId))).write(
//       OfflineIncidentFilesCompanion(
//         syncStatus: Value(LocalSyncStatus.syncing.value),
//         lastError: const Value(null),
//         updatedAt: Value(DateTime.now()),
//       ),
//     );
//   }

//   Future<int> markFileAsSynced({
//     required int fileId,
//     required String remoteUrl,
//   }) {
//     final now = DateTime.now();

//     return (update(
//       offlineIncidentFiles,
//     )..where((table) => table.id.equals(fileId))).write(
//       OfflineIncidentFilesCompanion(
//         syncStatus: Value(LocalSyncStatus.synced.value),
//         remoteUrl: Value(remoteUrl),
//         syncedAt: Value(now),
//         updatedAt: Value(now),
//         lastError: const Value(null),
//       ),
//     );
//   }

//   Future<void> markFileAsFailed({
//     required int fileId,
//     required String error,
//   }) async {
//     final current = await (select(
//       offlineIncidentFiles,
//     )..where((table) => table.id.equals(fileId))).getSingleOrNull();

//     if (current == null) return;

//     await (update(
//       offlineIncidentFiles,
//     )..where((table) => table.id.equals(fileId))).write(
//       OfflineIncidentFilesCompanion(
//         syncStatus: Value(LocalSyncStatus.failed.value),
//         retryCount: Value(current.retryCount + 1),
//         lastError: Value(error),
//         updatedAt: Value(DateTime.now()),
//       ),
//     );
//   }

//   // ======================================================
//   // CONTADORES
//   // ======================================================

//   Future<int> countPendingIncidents({int? usuarioId}) async {
//     final countExpression = offlineIncidents.id.count();

//     final query = selectOnly(offlineIncidents)..addColumns([countExpression]);

//     Expression<bool> condition =
//         offlineIncidents.syncStatus.equals(LocalSyncStatus.pending.value) |
//         offlineIncidents.syncStatus.equals(LocalSyncStatus.failed.value);

//     if (usuarioId != null) {
//       condition = condition & offlineIncidents.usuarioId.equals(usuarioId);
//     }

//     query.where(condition);

//     final result = await query.getSingle();

//     return result.read(countExpression) ?? 0;
//   }

//   Future<int> countPendingFiles() async {
//     final countExpression = offlineIncidentFiles.id.count();

//     final query = selectOnly(offlineIncidentFiles)
//       ..addColumns([countExpression])
//       ..where(
//         offlineIncidentFiles.syncStatus.equals(LocalSyncStatus.pending.value) |
//             offlineIncidentFiles.syncStatus.equals(
//               LocalSyncStatus.failed.value,
//             ),
//       );

//     final result = await query.getSingle();

//     return result.read(countExpression) ?? 0;
//   }

//   // ======================================================
//   // ELIMINACIÓN
//   // ======================================================

//   Future<int> deleteIncident(int id) {
//     return (delete(
//       offlineIncidents,
//     )..where((table) => table.id.equals(id))).go();
//   }

//   Future<int> deleteSyncedIncidentsBefore(DateTime date) {
//     return (delete(offlineIncidents)..where(
//           (table) =>
//               table.syncStatus.equals(LocalSyncStatus.synced.value) &
//               table.syncedAt.isNotNull() &
//               table.syncedAt.isSmallerThanValue(date),
//         ))
//         .go();
//   }

//   Future<int> deleteAllByUser(int usuarioId) {
//     return (delete(
//       offlineIncidents,
//     )..where((table) => table.usuarioId.equals(usuarioId))).go();
//   }
// }
