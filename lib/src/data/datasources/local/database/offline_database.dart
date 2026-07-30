// import 'package:drift/drift.dart';
// import 'package:drift_flutter/drift_flutter.dart';

// import '../dao/offline_incident_dao.dart';
// import '../dao/offline_location_dao.dart';
// import 'tables/offline_incident_file_table.dart';
// import 'tables/offline_incident_table.dart';
// import 'tables/offline_location_table.dart';

// part 'offline_database.g.dart';

// @DriftDatabase(
//   tables: [OfflineLocations, OfflineIncidents, OfflineIncidentFiles],
//   daos: [OfflineLocationDao, OfflineIncidentDao],
// )
// class OfflineDatabase extends _$OfflineDatabase {
//   OfflineDatabase() : super(_openConnection());

//   // Constructor para pruebas unitarias.
//   OfflineDatabase.forTesting(super.executor);

//   @override
//   int get schemaVersion => 1;

//   static QueryExecutor _openConnection() {
//     return driftDatabase(
//       name: 'sis_patrullaje_offline',
//       native: const DriftNativeOptions(
//         // Será útil posteriormente cuando Workmanager
//         // abra la base desde otro isolate.
//         shareAcrossIsolates: true,
//       ),
//     );
//   }

//   @override
//   MigrationStrategy get migration {
//     return MigrationStrategy(
//       onCreate: (migrator) async {
//         await migrator.createAll();
//       },

//       onUpgrade: (migrator, from, to) async {
//         // Schema versión 1: todavía no existen migraciones.
//         //
//         // Cuando agregues tablas o columnas:
//         // 1. incrementa schemaVersion;
//         // 2. agrega aquí la migración correspondiente.
//       },

//       beforeOpen: (details) async {
//         // SQLite no siempre habilita foreign keys automáticamente.
//         await customStatement('PRAGMA foreign_keys = ON');

//         // Si la aplicación se cerró mientras sincronizaba,
//         // los registros SYNCING deben volver a PENDING.
//         await offlineLocationDao.resetSyncingToPending();
//         await offlineIncidentDao.resetSyncingIncidentsToPending();
//       },
//     );
//   }
// }
