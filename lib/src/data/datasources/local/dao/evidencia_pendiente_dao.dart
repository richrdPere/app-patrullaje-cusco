import 'package:sqflite/sqflite.dart';

// Tablas
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/db_incidentes_sqlite/incidencia_database.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/db_incidentes_sqlite/incidencia_tablas.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_evidencia_pendiente_model.dart';

// Utils
import 'package:sis_patrullaje_cusco/src/data/utils/estado_sync.dart';

class EvidenciaPendienteDao {
  final AppDatabasePatrullaje appDatabase;

  const EvidenciaPendienteDao({required this.appDatabase});

  // 1. INSERTAR
  Future<int> insertar(EvidenciaPendienteModel evidencia) async {
    final db = await appDatabase.database;

    return db.insert(
      IncidenciaTablas.tablaEvidenciasPendientes,
      evidencia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  // 2. INSERTAR CON EXECUTOR
  Future<int> insertarConExecutor(
    DatabaseExecutor executor,
    EvidenciaPendienteModel evidencia,
  ) {
    return executor.insert(
      IncidenciaTablas.tablaEvidenciasPendientes,
      evidencia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  // 3. INSERTAR TODAS
  Future<void> insertarTodas(List<EvidenciaPendienteModel> evidencias) async {
    if (evidencias.isEmpty) return;

    final db = await appDatabase.database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final evidencia in evidencias) {
        batch.insert(
          IncidenciaTablas.tablaEvidenciasPendientes,
          evidencia.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  // 4. INSERTAR TODAS CON EXECUTOR
  Future<void> insertarTodasConExecutor(
    DatabaseExecutor executor,
    List<EvidenciaPendienteModel> evidencias,
  ) async {
    if (evidencias.isEmpty) return;

    final batch = executor.batch();

    for (final evidencia in evidencias) {
      batch.insert(
        IncidenciaTablas.tablaEvidenciasPendientes,
        evidencia.toMap(),
        conflictAlgorithm: ConflictAlgorithm.abort,
      );
    }

    await batch.commit(noResult: true);
  }

  // 5. OBTENER POR INCIDENCIA
  Future<List<EvidenciaPendienteModel>> obtenerPorIncidencia(
    String incidenciaUuidLocal,
  ) async {
    final db = await appDatabase.database;

    final result = await db.query(
      IncidenciaTablas.tablaEvidenciasPendientes,
      where: 'evp_incidencia_uuid_local = ?',
      whereArgs: [incidenciaUuidLocal],
      orderBy: 'evp_fecha_creacion_local ASC',
    );

    return result.map(EvidenciaPendienteModel.fromMap).toList(growable: false);
  }

  // 6. OBTENER PENDIENTES POR INCIDENCIA
  Future<List<EvidenciaPendienteModel>> obtenerPendientesPorIncidencia(
    String incidenciaUuidLocal,
  ) async {
    final db = await appDatabase.database;

    final result = await db.query(
      IncidenciaTablas.tablaEvidenciasPendientes,
      where: '''
        evp_incidencia_uuid_local = ?
        AND evp_estado_sync IN (?, ?)
      ''',
      whereArgs: [incidenciaUuidLocal, EstadoSync.pendiente, EstadoSync.error],
      orderBy: 'evp_fecha_creacion_local ASC',
    );

    return result.map(EvidenciaPendienteModel.fromMap).toList(growable: false);
  }

  // 7. OBTENER POR UUID
  Future<EvidenciaPendienteModel?> obtenerPorUuid(String uuidLocal) async {
    final db = await appDatabase.database;

    final result = await db.query(
      IncidenciaTablas.tablaEvidenciasPendientes,
      where: 'evp_uuid_local = ?',
      whereArgs: [uuidLocal],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return EvidenciaPendienteModel.fromMap(result.first);
  }

  // 8. OBTENER POR ID
  Future<int> contarPendientes({String? incidenciaUuidLocal}) async {
    final db = await appDatabase.database;

    final where = <String>['evp_estado_sync IN (?, ?)'];

    final args = <Object?>[EstadoSync.pendiente, EstadoSync.error];

    if (incidenciaUuidLocal != null) {
      where.add('evp_incidencia_uuid_local = ?');
      args.add(incidenciaUuidLocal);
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM ${IncidenciaTablas.tablaEvidenciasPendientes}
      WHERE ${where.join(' AND ')}
      ''', args);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  // 9. MARCAR COMO SINCRONIZANDO
  Future<void> marcarSincronizando(String uuidLocal) async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaEvidenciasPendientes,
      {'evp_estado_sync': EstadoSync.sincronizando, 'evp_ultimo_error': null},
      where: 'evp_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  // 10. MARCAR COMO SINCRONIZADA
  Future<void> marcarSincronizada({
    required String uuidLocal,
    String? urlRemota,
  }) async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaEvidenciasPendientes,
      {
        'evp_estado_sync': EstadoSync.sincronizado,
        'evp_url_remota': urlRemota,
        'evp_ultimo_error': null,
      },
      where: 'evp_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  // 11. MARCAR COMO ERROR
  Future<void> marcarError({
    required String uuidLocal,
    required String error,
  }) async {
    final db = await appDatabase.database;

    await db.rawUpdate(
      '''
      UPDATE ${IncidenciaTablas.tablaEvidenciasPendientes}
      SET
        evp_estado_sync = ?,
        evp_intentos = evp_intentos + 1,
        evp_ultimo_error = ?
      WHERE evp_uuid_local = ?
      ''',
      [EstadoSync.error, error, uuidLocal],
    );
  }

  // 12. RECUPERAR SINCRONIZACIONES INTERRUPTAS
  Future<void> recuperarSincronizacionesInterrumpidas() async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaEvidenciasPendientes,
      {
        'evp_estado_sync': EstadoSync.pendiente,
        'evp_ultimo_error': 'Sincronización interrumpida',
      },
      where: 'evp_estado_sync = ?',
      whereArgs: [EstadoSync.sincronizando],
    );
  }

  // 13. VERIFICAR SI TODAS ESTÁN SINCRONIZADAS
  Future<bool> todasSincronizadas(String incidenciaUuidLocal) async {
    final pendientes = await contarPendientes(
      incidenciaUuidLocal: incidenciaUuidLocal,
    );

    return pendientes == 0;
  }

  // 14. ELIMINAR POR UUID
  Future<int> eliminarPorUuid(String uuidLocal) async {
    final db = await appDatabase.database;

    return db.delete(
      IncidenciaTablas.tablaEvidenciasPendientes,
      where: 'evp_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  // 15. ELIMINAR POR INCIDENCIA
  Future<int> eliminarPorIncidencia(String incidenciaUuidLocal) async {
    final db = await appDatabase.database;

    return db.delete(
      IncidenciaTablas.tablaEvidenciasPendientes,
      where: 'evp_incidencia_uuid_local = ?',
      whereArgs: [incidenciaUuidLocal],
    );
  }
}
