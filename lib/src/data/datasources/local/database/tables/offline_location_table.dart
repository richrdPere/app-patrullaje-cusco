import 'package:drift/drift.dart';

@DataClassName('OfflineLocationData')
class OfflineLocations extends Table {
  // ID local autoincremental.
  IntColumn get id => integer().autoIncrement()();

  // Identificador generado en el dispositivo.
  // Se enviará también al backend para evitar duplicados.
  TextColumn get clientId => text().unique()();

  // Usuario que generó la ubicación.
  IntColumn get usuarioId => integer()();

  // Patrullaje al que pertenece la ubicación.
  IntColumn get patrullajeId => integer()();

  RealColumn get latitud => real()();

  RealColumn get longitud => real()();

  RealColumn get velocidad => real().nullable()();

  RealColumn get precision => real().nullable()();

  TextColumn get tipo => text().withDefault(const Constant('TRACKING'))();

  // Fecha real en la que fue capturada la ubicación.
  DateTimeColumn get fechaHora => dateTime()();

  // PENDING, SYNCING, SYNCED o FAILED.
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();

  // Cantidad de intentos fallidos.
  IntColumn get retryCount => integer().withDefault(const Constant(0))();

  // Último error registrado durante la sincronización.
  TextColumn get lastError => text().nullable()();

  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();

  DateTimeColumn get syncedAt => dateTime().nullable()();
}
