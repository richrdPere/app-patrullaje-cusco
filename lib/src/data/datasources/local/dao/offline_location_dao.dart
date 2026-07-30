// import 'package:drift/drift.dart';

// import '../database/offline_database.dart';
// import '../database/tables/offline_location_table.dart';
// import '../models/local_sync_status.dart';
// import '../models/offline_location_input.dart';

// part 'offline_location_dao.g.dart';

// @DriftAccessor(tables: [OfflineLocations])
// class OfflineLocationDao extends DatabaseAccessor<OfflineDatabase>
//     with _$OfflineLocationDaoMixin {
//   OfflineLocationDao(super.db);

//   // ======================================================
//   // INSERTAR
//   // ======================================================

//   Future<int> insertLocation(OfflineLocationInput input) {
//     return into(offlineLocations).insert(
//       OfflineLocationsCompanion.insert(
//         clientId: input.clientId,
//         usuarioId: input.usuarioId,
//         patrullajeId: input.patrullajeId,
//         latitud: input.latitud,
//         longitud: input.longitud,
//         velocidad: Value(input.velocidad),
//         precision: Value(input.precision),
//         fechaHora: input.fechaHora,
//         tipo: Value(input.tipo),
//       ),
//       mode: InsertMode.insertOrIgnore,
//     );
//   }

//   // ======================================================
//   // OBTENER POR ID
//   // ======================================================

//   Future<OfflineLocationData?> getById(int id) {
//     return (select(
//       offlineLocations,
//     )..where((table) => table.id.equals(id))).getSingleOrNull();
//   }

//   Future<OfflineLocationData?> getByClientId(String clientId) {
//     return (select(
//       offlineLocations,
//     )..where((table) => table.clientId.equals(clientId))).getSingleOrNull();
//   }

//   // ======================================================
//   // PENDIENTES
//   // ======================================================

//   Future<List<OfflineLocationData>> getPendingLocations({
//     int limit = 100,
//     int? usuarioId,
//     int? patrullajeId,
//   }) {
//     final query = select(offlineLocations);

//     query.where((table) {
//       Expression<bool> condition =
//           table.syncStatus.equals(LocalSyncStatus.pending.value) |
//           table.syncStatus.equals(LocalSyncStatus.failed.value);

//       if (usuarioId != null) {
//         condition = condition & table.usuarioId.equals(usuarioId);
//       }

//       if (patrullajeId != null) {
//         condition = condition & table.patrullajeId.equals(patrullajeId);
//       }

//       return condition;
//     });

//     query
//       ..orderBy([(table) => OrderingTerm.asc(table.fechaHora)])
//       ..limit(limit);

//     return query.get();
//   }

//   Stream<List<OfflineLocationData>> watchPendingLocations({int? usuarioId}) {
//     final query = select(offlineLocations);

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
//   // ACTUALIZAR ESTADOS
//   // ======================================================

//   Future<int> markAsSyncing(List<int> ids) {
//     if (ids.isEmpty) return Future.value(0);

//     return (update(
//       offlineLocations,
//     )..where((table) => table.id.isIn(ids))).write(
//       OfflineLocationsCompanion(
//         syncStatus: Value(LocalSyncStatus.syncing.value),
//         updatedAt: Value(DateTime.now()),
//         lastError: const Value(null),
//       ),
//     );
//   }

//   Future<int> markAsSynced(List<int> ids) {
//     if (ids.isEmpty) return Future.value(0);

//     final now = DateTime.now();

//     return (update(
//       offlineLocations,
//     )..where((table) => table.id.isIn(ids))).write(
//       OfflineLocationsCompanion(
//         syncStatus: Value(LocalSyncStatus.synced.value),
//         syncedAt: Value(now),
//         updatedAt: Value(now),
//         lastError: const Value(null),
//       ),
//     );
//   }

//   Future<void> markAsFailed({
//     required List<int> ids,
//     required String error,
//   }) async {
//     if (ids.isEmpty) return;

//     await transaction(() async {
//       for (final id in ids) {
//         final current = await getById(id);

//         if (current == null) continue;

//         await (update(
//           offlineLocations,
//         )..where((table) => table.id.equals(id))).write(
//           OfflineLocationsCompanion(
//             syncStatus: Value(LocalSyncStatus.failed.value),
//             retryCount: Value(current.retryCount + 1),
//             lastError: Value(error),
//             updatedAt: Value(DateTime.now()),
//           ),
//         );
//       }
//     });
//   }

//   Future<int> resetSyncingToPending() {
//     return (update(offlineLocations)..where(
//           (table) => table.syncStatus.equals(LocalSyncStatus.syncing.value),
//         ))
//         .write(
//           OfflineLocationsCompanion(
//             syncStatus: Value(LocalSyncStatus.pending.value),
//             updatedAt: Value(DateTime.now()),
//           ),
//         );
//   }

//   // ======================================================
//   // CONTADORES
//   // ======================================================

//   Future<int> countPending({int? usuarioId}) async {
//     final countExpression = offlineLocations.id.count();

//     final query = selectOnly(offlineLocations)..addColumns([countExpression]);

//     Expression<bool> condition =
//         offlineLocations.syncStatus.equals(LocalSyncStatus.pending.value) |
//         offlineLocations.syncStatus.equals(LocalSyncStatus.failed.value);

//     if (usuarioId != null) {
//       condition = condition & offlineLocations.usuarioId.equals(usuarioId);
//     }

//     query.where(condition);

//     final result = await query.getSingle();

//     return result.read(countExpression) ?? 0;
//   }

//   // ======================================================
//   // ELIMINACIÓN
//   // ======================================================

//   Future<int> deleteById(int id) {
//     return (delete(
//       offlineLocations,
//     )..where((table) => table.id.equals(id))).go();
//   }

//   Future<int> deleteSyncedBefore(DateTime date) {
//     return (delete(offlineLocations)..where(
//           (table) =>
//               table.syncStatus.equals(LocalSyncStatus.synced.value) &
//               table.syncedAt.isNotNull() &
//               table.syncedAt.isSmallerThanValue(date),
//         ))
//         .go();
//   }

//   Future<int> deleteAllByUser(int usuarioId) {
//     return (delete(
//       offlineLocations,
//     )..where((table) => table.usuarioId.equals(usuarioId))).go();
//   }
// }
