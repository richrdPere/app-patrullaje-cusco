import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'incidencia_tablas.dart';

class AppDatabasePatrullaje {
  static const _dbName = 'sis_patrullaje_cusco.db';
  static const _dbVersion = 1;

  Database? _db;

  Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  Future<Database> _initDB() async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, _dbName);

    return await openDatabase(
      path,
      version: _dbVersion,
      onConfigure: (db) async {
        await db.execute('PRAGMA foreign_keys = ON');
      },
      onCreate: (db, version) async {
        // Para Incidencias
        await db.execute(IncidenciaTablas.sqlUbicacionesPendientes);
        await db.execute(IncidenciaTablas.sqlIncidenciasPendientes);
        await db.execute(IncidenciaTablas.sqlEvidenciasPendientes);
      },
    );
  }
}
