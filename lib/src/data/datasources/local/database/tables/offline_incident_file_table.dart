import 'package:drift/drift.dart';

import 'offline_incident_table.dart';

@DataClassName('OfflineIncidentFileData')
class OfflineIncidentFiles extends Table {
  IntColumn get id => integer().autoIncrement()();

  // Relación con la incidencia local.
  IntColumn get offlineIncidentId => integer().references(
    OfflineIncidents,
    #id,
    onDelete: KeyAction.cascade,
  )();

  // UUID propio del archivo.
  TextColumn get clientId => text().unique()();

  // Ruta absoluta donde se copió el archivo.
  TextColumn get localPath => text()();
  TextColumn get fileName => text()();
  TextColumn get mimeType => text()();

  // IMAGEN, VIDEO o PDF.
  TextColumn get categoria => text()();

  // Tamaño para validar o mostrar información.
  IntColumn get sizeBytes => integer().nullable()();
  TextColumn get syncStatus => text().withDefault(const Constant('PENDING'))();
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  TextColumn get lastError => text().nullable()();

  // URL devuelta por S3 una vez sincronizado.
  TextColumn get remoteUrl => text().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get updatedAt => dateTime().withDefault(currentDateAndTime)();
  DateTimeColumn get syncedAt => dateTime().nullable()();
}
