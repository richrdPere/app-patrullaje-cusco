import 'package:sqflite/sqflite.dart';

// Tablas
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/db_incidentes_sqlite/incidencia_database.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/db_incidentes_sqlite/incidencia_tablas.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_incidencia_pendiente_model.dart';

// Utils
import 'package:sis_patrullaje_cusco/src/data/utils/estado_sync.dart';

class IncidenciaPendienteDao {
  final AppDatabasePatrullaje appDatabase;

  const IncidenciaPendienteDao({required this.appDatabase});

  /// Inserta una incidencia pendiente.
  ///
  /// Si ya existe el mismo UUID local, se ignora el registro para evitar
  /// duplicados.
  Future<int> insertar(IncidenciaPendienteModel incidencia) async {
    final db = await appDatabase.database;

    return db.insert(
      IncidenciaTablas.tablaIncidenciasPendientes,
      incidencia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  /// Método interno para usar dentro de una transacción compartida.
  Future<int> insertarConExecutor(
    DatabaseExecutor executor,
    IncidenciaPendienteModel incidencia,
  ) {
    return executor.insert(
      IncidenciaTablas.tablaIncidenciasPendientes,
      incidencia.toMap(),
      conflictAlgorithm: ConflictAlgorithm.abort,
    );
  }

  /// 3. oBTENER TODAS LAS INCIDENCIAS PENDIENTES
  Future<List<IncidenciaPendienteModel>> obtenerPendientes({
    int limite = 20,
    int? usuarioId,
  }) async {
    final db = await appDatabase.database;

    final where = <String>['ipe_estado_sync IN (?, ?)'];

    final whereArgs = <Object?>[EstadoSync.pendiente, EstadoSync.error];

    if (usuarioId != null) {
      where.add('ipe_usuario_id = ?');
      whereArgs.add(usuarioId);
    }

    final result = await db.query(
      IncidenciaTablas.tablaIncidenciasPendientes,
      where: where.join(' AND '),
      whereArgs: whereArgs,
      orderBy: 'ipe_fecha_hora ASC',
      limit: limite,
    );

    return result.map(IncidenciaPendienteModel.fromMap).toList(growable: false);
  }

  Future<List<IncidenciaPendienteModel>> obtenerTodasPorUsuario(
    int usuarioId,
  ) async {
    final db = await appDatabase.database;

    final result = await db.query(
      IncidenciaTablas.tablaIncidenciasPendientes,
      where: 'ipe_usuario_id = ?',
      whereArgs: [usuarioId],
      orderBy: 'ipe_fecha_creacion_local DESC',
    );

    return result.map(IncidenciaPendienteModel.fromMap).toList(growable: false);
  }

  Future<IncidenciaPendienteModel?> obtenerPorUuid(String uuidLocal) async {
    final db = await appDatabase.database;

    final result = await db.query(
      IncidenciaTablas.tablaIncidenciasPendientes,
      where: 'ipe_uuid_local = ?',
      whereArgs: [uuidLocal],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return IncidenciaPendienteModel.fromMap(result.first);
  }

  Future<IncidenciaPendienteModel?> obtenerPorId(int id) async {
    final db = await appDatabase.database;

    final result = await db.query(
      IncidenciaTablas.tablaIncidenciasPendientes,
      where: 'ipe_id = ?',
      whereArgs: [id],
      limit: 1,
    );

    if (result.isEmpty) return null;

    return IncidenciaPendienteModel.fromMap(result.first);
  }

  Future<int> contarPendientes({int? usuarioId}) async {
    final db = await appDatabase.database;

    final where = <String>['ipe_estado_sync IN (?, ?)'];

    final args = <Object?>[EstadoSync.pendiente, EstadoSync.error];

    if (usuarioId != null) {
      where.add('ipe_usuario_id = ?');
      args.add(usuarioId);
    }

    final result = await db.rawQuery('''
      SELECT COUNT(*) AS total
      FROM ${IncidenciaTablas.tablaIncidenciasPendientes}
      WHERE ${where.join(' AND ')}
      ''', args);

    return Sqflite.firstIntValue(result) ?? 0;
  }

  Future<void> marcarSincronizando(String uuidLocal) async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaIncidenciasPendientes,
      {
        'ipe_estado_sync': EstadoSync.sincronizando,
        'ipe_fecha_ultimo_intento': DateTime.now().toUtc().toIso8601String(),
        'ipe_ultimo_error': null,
      },
      where: 'ipe_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  /// Se ejecuta cuando el backend ya creó la incidencia, aunque todavía
  /// falte subir una o más evidencias.
  Future<void> guardarIdServidor({
    required String uuidLocal,
    required int incidenciaServidorId,
  }) async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaIncidenciasPendientes,
      {
        'ipe_incidencia_servidor_id': incidenciaServidorId,
        'ipe_estado_local': 'REGISTRADA_SERVIDOR',
        'ipe_fecha_ultimo_intento': DateTime.now().toUtc().toIso8601String(),
        'ipe_ultimo_error': null,
      },
      where: 'ipe_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  Future<void> marcarSincronizada({
    required String uuidLocal,
    required int incidenciaServidorId,
  }) async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaIncidenciasPendientes,
      {
        'ipe_estado_local': 'REGISTRADA',
        'ipe_estado_sync': EstadoSync.sincronizado,
        'ipe_incidencia_servidor_id': incidenciaServidorId,
        'ipe_ultimo_error': null,
        'ipe_fecha_ultimo_intento': DateTime.now().toUtc().toIso8601String(),
      },
      where: 'ipe_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  Future<void> marcarError({
    required String uuidLocal,
    required String error,
  }) async {
    final db = await appDatabase.database;

    await db.rawUpdate(
      '''
      UPDATE ${IncidenciaTablas.tablaIncidenciasPendientes}
      SET
        ipe_estado_sync = ?,
        ipe_intentos = ipe_intentos + 1,
        ipe_ultimo_error = ?,
        ipe_fecha_ultimo_intento = ?
      WHERE ipe_uuid_local = ?
      ''',
      [
        EstadoSync.error,
        error,
        DateTime.now().toUtc().toIso8601String(),
        uuidLocal,
      ],
    );
  }

  Future<void> restablecerComoPendiente(String uuidLocal) async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaIncidenciasPendientes,
      {'ipe_estado_sync': EstadoSync.pendiente, 'ipe_ultimo_error': null},
      where: 'ipe_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  Future<void> recuperarSincronizacionesInterrumpidas() async {
    final db = await appDatabase.database;

    await db.update(
      IncidenciaTablas.tablaIncidenciasPendientes,
      {
        'ipe_estado_sync': EstadoSync.pendiente,
        'ipe_ultimo_error': 'Sincronización interrumpida',
      },
      where: 'ipe_estado_sync = ?',
      whereArgs: [EstadoSync.sincronizando],
    );
  }

  Future<int> eliminarPorUuid(String uuidLocal) async {
    final db = await appDatabase.database;

    return db.delete(
      IncidenciaTablas.tablaIncidenciasPendientes,
      where: 'ipe_uuid_local = ?',
      whereArgs: [uuidLocal],
    );
  }

  Future<int> eliminarSincronizadasAntiguas(DateTime fechaLimite) async {
    final db = await appDatabase.database;

    return db.delete(
      IncidenciaTablas.tablaIncidenciasPendientes,
      where: '''
        ipe_estado_sync = ?
        AND ipe_fecha_creacion_local < ?
      ''',
      whereArgs: [
        EstadoSync.sincronizado,
        fechaLimite.toUtc().toIso8601String(),
      ],
    );
  }
}
