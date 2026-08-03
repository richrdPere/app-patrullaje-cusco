class IncidenciaTablas {
  static const String tablaUbicacionesPendientes = 'sp_ubicaciones_pendientes';
  static const String tablaIncidenciasPendientes = 'sp_incidencias_pendientes';
  static const String tablaEvidenciasPendientes = 'sp_evidencias_pendientes';

  // 1.- sp_ubicaciones
  static const String sqlUbicacionesPendientes =
      '''
  CREATE TABLE $tablaUbicacionesPendientes (
    ubc_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ubc_uuid_local TEXT NOT NULL UNIQUE,
    ubc_patrullaje_id INTEGER NOT NULL,
    ubc_usuario_id INTEGER,
    ubc_latitud REAL NOT NULL,
    ubc_longitud REAL NOT NULL,
    ubc_velocidad REAL,
    ubc_precision REAL,
    ubc_tipo TEXT NOT NULL DEFAULT 'TRACKING',
    ubc_fecha_hora TEXT NOT NULL,
    ubc_estado_sync TEXT NOT NULL DEFAULT 'PENDIENTE',
    ubc_intentos INTEGER NOT NULL DEFAULT 0,
    ubc_ultimo_error TEXT,
    ubc_fecha_creacion_local TEXT NOT NULL,
    ubc_fecha_ultimo_intento TEXT
  );
  ''';

  // 2.- sp_incidencias_pendientes
  static const String sqlIncidenciasPendientes =
      '''
  CREATE TABLE $tablaIncidenciasPendientes (
    ipe_id INTEGER PRIMARY KEY AUTOINCREMENT,
    ipe_uuid_local TEXT NOT NULL UNIQUE,
    ipe_usuario_id INTEGER NOT NULL,
    ipe_patrullaje_id INTEGER,
    ipe_zona_id INTEGER,
    ipe_tipo TEXT NOT NULL,
    ipe_descripcion TEXT NOT NULL,
    ipe_latitud REAL NOT NULL,
    ipe_longitud REAL NOT NULL,
    ipe_fecha_hora TEXT NOT NULL,
    ipe_origen TEXT NOT NULL DEFAULT 'APP_MOVIL',
    ipe_estado_local TEXT NOT NULL DEFAULT 'PENDIENTE',
    ipe_estado_sync TEXT NOT NULL DEFAULT 'PENDIENTE',
    ipe_incidencia_servidor_id INTEGER,
    ipe_intentos INTEGER NOT NULL DEFAULT 0,
    ipe_ultimo_error TEXT,
    ipe_fecha_creacion_local TEXT NOT NULL,
    ipe_fecha_ultimo_intento TEXT
  );
  ''';

  // 3.- sp_evidencias_pendientes
  static const String sqlEvidenciasPendientes =
      '''
  CREATE TABLE $tablaEvidenciasPendientes (
    evp_id INTEGER PRIMARY KEY AUTOINCREMENT,
    evp_uuid_local TEXT NOT NULL UNIQUE,
    evp_incidencia_uuid_local TEXT NOT NULL,
    evp_ruta_local TEXT NOT NULL,
    evp_nombre_archivo TEXT,
    evp_tipo_archivo TEXT NOT NULL,
    evp_mime_type TEXT,
    evp_tamanio INTEGER,
    evp_estado_sync TEXT NOT NULL DEFAULT 'PENDIENTE',
    evp_url_remota TEXT,
    evp_intentos INTEGER NOT NULL DEFAULT 0,
    evp_ultimo_error TEXT,
    evp_fecha_creacion_local TEXT NOT NULL,

    FOREIGN KEY (evp_incidencia_uuid_local)
      REFERENCES $tablaIncidenciasPendientes(ipe_uuid_local)
      ON DELETE CASCADE
  );
  ''';
}
