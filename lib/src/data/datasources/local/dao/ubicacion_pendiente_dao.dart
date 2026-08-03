import 'package:sqflite/sqflite.dart';

// Tablas
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/db_incidentes_sqlite/incidencia_database.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/db_incidentes_sqlite/incidencia_tablas.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_ubicacion_pendiente_model.dart';

// Utils
import 'package:sis_patrullaje_cusco/src/data/utils/estado_sync.dart';

class UbicacionPendienteDao {
  final AppDatabasePatrullaje appDatabase;

  const UbicacionPendienteDao({required this.appDatabase});

  /// Inserta una ubicación pendiente.
  ///
  /// Si ya existe el mismo UUID local, se ignora el registro para evitar
  /// duplicados.
  Future<int> insertar(UbicacionPendienteModel ubicacion) async {
    final db = await appDatabase.database;

    return db.insert(
      IncidenciaTablas.tablaUbicacionesPendientes,
      ubicacion.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Inserta varias ubicaciones en una sola transacción.
  Future<void> insertarTodas(List<UbicacionPendienteModel> ubicaciones) async {
    if (ubicaciones.isEmpty) return;

    final db = await appDatabase.database;

    await db.transaction((txn) async {
      final batch = txn.batch();

      for (final ubicacion in ubicaciones) {
        batch.insert(
          IncidenciaTablas.tablaUbicacionesPendientes,
          ubicacion.toMap(),
          conflictAlgorithm: ConflictAlgorithm.ignore,
        );
      }

      await batch.commit(noResult: true);
    });
  }

  /// Obtiene ubicaciones pendientes o con error para volver a enviarlas.
  Future<List<UbicacionPendienteModel>> obtenerPendientes({
    int limite = 100,
    int? usuarioId,
    int? patrullajeId,
  }) async {
    final db = await appDatabase.database;

    final where = <String>['ubc_estado_sync IN (?, ?)'];

    final whereArgs = <Object?>[EstadoSync.pendiente, EstadoSync.error];

    if (usuarioId != null) {
      where.add('ubc_usuario_id = ?');
      whereArgs.add(usuarioId);
    }

    if (patrullajeId != null) {
      where.add('ubc_patrullaje_id = ?');
      whereArgs.add(patrullajeId);
    }

    final result = await db.query(
      IncidenciaTablas.tablaUbicacionesPendientes,
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'ubc_fecha_hora ASC',
      limit: limite,
    );

    return result.map(UbicacionPendienteModel.fromMap).toList(growable: false);
  }

  Future<UbicacionPendienteModel?> obtenerPorUuid(String uuidLocal) async {
    final db = await appDatabase.database;

    final result = await db.query(
      IncidenciaTablas.tablaUbicacionesPendientes,
      where: 'ubc_uuid_local = ?',
      whereArgs: [uuidLocal],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return UbicacionPendienteModel.fromMap(result.first);
  }

  Future<int> contarPendientes({int? usuarioId}) async {
    final db = await appDatabase.database;

    final where = <String>['ubc_estado_sync IN (?, ?)'];

    final whereArgs = <Object?>[EstadoSync.pendiente, EstadoSync.error];

    if (usuarioId != null) {
      where.add('ubc_usuario_id = ?');
      whereArgs.add(usuarioId);
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM ${IncidenciaTablas.tablaUbicacionesPendientes}
      WHERE ${where.join(' AND ')}
      ''', whereArgs);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> marcarSincronizando(List<String> uuids) async {
    if (uuids.isEmpty) return;

    final db = await appDatabase.database;
    final placeholders = List.filled(uuids.length, '?').join(',');

    await db.update(
      IncidenciaTablas.tablaUbicacionesPendientes,
      {
        'ubc_estado_sync': EstadoSync.sincronizando,
        'ubc_fecha_ultimo_intento': DateTime.now().toUtc().toIso8601String(),
        'ubc_ultimo_error': null,
      },
      where: 'ubc_uuid_local IN ($placeholders)',
      whereArgs: uuids,
    );
  }

  Future<void> marcarSincronizada(String uuidLocal) async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaUbicacionesPendientes,
      {
        'ubc_estado_sync': EstadoSync.sincronizado,
        'ubc_ultimo_error': null,
        'ubc_fecha_ultimo_intento': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'ubc_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  Future<void> marcarVariasSincronizadas(List<String> uuids) async {
    if (uuids.isEmpty) return;

    final db = await appDatabase.database;
    final placeholders = List.filled(uuids.length, '?').join(',');

    await db.update(
      IncidenciaTablas.tablaUbicacionesPendientes,
      {
        'ubc_estado_sync': EstadoSync.sincronizado,
        'ubc_ultimo_error': null,
        'ubc_fecha_ultimo_intento': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'ubc_uuid_local IN ($placeholders)',
      whereArgs: uuids,
    );
  }

  Future<void> marcarError({
    required String uuidLocal,
    required String error,
  }) async {
    final db = await appDatabase.database;

    await db.rawUpdate(
      '''
      UPDATE ${IncidenciaTablas.tablaUbicacionesPendientes}
      SET
        ubc_estado_sync = ?,
        ubc_intentos = ubc_intentos + 1,
        ubc_ultimo_error = ?,
        ubc_fecha_ultimo_intento = ?
      WHERE ubc_uuid_local = ?
      ''',
      [
        EstadoSync.error,
        error,
        DateTime.now().toUtc().toIso8601String(),
        uuidLocal,
      ],
    );
  }

  /// Devuelve a PENDIENTE registros que quedaron SINCRONIZANDO por un cierre
  /// inesperado de la aplicación.
  Future<void> recuperarSincronizacionesInterrumpidas() async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaUbicacionesPendientes,
      {
        'ubc_estado_sync': EstadoSync.pendiente,
        'ubc_ultimo_error': 'Sincronización interrumpida',
      },
      where: 'ubc_estado_sync = ?',
      whereArgs: [EstadoSync.sincronizando],
    );
  }

  Future<int> eliminarSincronizadasAntiguas(DateTime fechaLimite) async {
    final db = await appDatabase.database;

    return db.delete(
      IncidenciaTablas.tablaUbicacionesPendientes,
      where: '''
        ubc_estado_sync = ?
        AND ubc_fecha_creacion_local < ?
      ''',
      whereArgs: [
        EstadoSync.sincronizado,
        fechaLimite.toUtc().toIso8601String(),
      ],
    );
  }

  Future<int> eliminarPorUuid(String uuidLocal) async {
    final db = await appDatabase.database;

    return db.delete(
      IncidenciaTablas.tablaUbicacionesPendientes,
      where: 'ubc_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }
}
