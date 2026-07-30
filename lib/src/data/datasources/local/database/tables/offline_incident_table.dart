import 'package:drift/drift.dart';

@DataClassName('OfflineIncidentData')
class OfflineIncidents extends Table {
  IntColumn get id => integer().autoIncrement()();

  // UUID generado en Flutter.
  TextColumn get clientId => text().unique()();

  // Usuario que registró la incidencia.
  IntColumn get usuarioId => integer()();
  IntColumn get patrullajeId => integer().nullable()();
  IntColumn get zonaId => integer().nullable()();
  TextColumn get tipo => text()();
  TextColumn get descripcion => text()();
  RealColumn get latitud => real()();
  RealColumn get longitud => real()();

  // Fecha real del incidente o de su registro en campo.
  DateTimeColumn get fechaHora => dateTime()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  // ID asignado por MySQL después de sincronizar.
  IntColumn get serverId => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
