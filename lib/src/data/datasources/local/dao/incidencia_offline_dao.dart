// Database
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/db_incidentes_sqlite/incidencia_database.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_evidencia_pendiente_model.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/database/models/off_incidencia_pendiente_model.dart';

// DTO's
import 'evidencia_pendiente_dao.dart';
import 'incidencia_pendiente_dao.dart';

class IncidenciaOfflineDao {
  final AppDatabasePatrullaje appDatabase;
  final IncidenciaPendienteDao incidenciaDao;
  final EvidenciaPendienteDao evidenciaDao;

  const IncidenciaOfflineDao({
    required this.appDatabase,
    required this.incidenciaDao,
    required this.evidenciaDao,
  });

  /// Guarda la incidencia y todas sus evidencias de manera atómica.
  ///
  /// Si falla una evidencia, se revierte también la incidencia.
  Future<void> guardarIncidenciaCompleta({
    required IncidenciaPendienteModel incidencia,
    required List<EvidenciaPendienteModel> evidencias,
  }) async {
    final db = await appDatabase.database;

    await db.transaction((txn) async {
      await incidenciaDao.insertarConExecutor(txn, incidencia);

      await evidenciaDao.insertarTodasConExecutor(txn, evidencias);
    });
  }

  Future<IncidenciaOfflineDetalle?> obtenerDetalle(
    String incidenciaUuidLocal,
  ) async {
    final incidencia = await incidenciaDao.obtenerPorUuid(incidenciaUuidLocal);

    if (incidencia == null) return null;

    final evidencias = await evidenciaDao.obtenerPorIncidencia(
      incidenciaUuidLocal,
    );

    return IncidenciaOfflineDetalle(
      incidencia: incidencia,
      evidencias: evidencias,
    );
  }

  Future<List<IncidenciaOfflineDetalle>> obtenerPendientesConEvidencias({
    int limite = 20,
    int? usuarioId,
  }) async {
    final incidencias = await incidenciaDao.obtenerPendientes(
      limite: limite,
      usuarioId: usuarioId,
    );

    final resultado = <IncidenciaOfflineDetalle>[];

    for (final incidencia in incidencias) {
      final evidencias = await evidenciaDao.obtenerPendientesPorIncidencia(
        incidencia.uuidLocal,
      );

      resultado.add(
        IncidenciaOfflineDetalle(
          incidencia: incidencia,
          evidencias: evidencias,
        ),
      );
    }

    return resultado;
  }

  /// Eliminar la incidencia elimina también las evidencias gracias
  /// al ON DELETE CASCADE.
  Future<void> eliminarIncidenciaCompleta(String incidenciaUuidLocal) async {
    await incidenciaDao.eliminarPorUuid(incidenciaUuidLocal);
  }
}

class IncidenciaOfflineDetalle {
  final IncidenciaPendienteModel incidencia;
  final List<EvidenciaPendienteModel> evidencias;

  const IncidenciaOfflineDetalle({
    required this.incidencia,
    required this.evidencias,
  });
}
