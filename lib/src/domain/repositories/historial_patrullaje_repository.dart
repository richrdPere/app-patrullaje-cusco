import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';

abstract class HistorialPatrullajeRepository {

  // =========================================================
  // REGISTRAR HISTORIAL OPERATIVO
  // POST /historial
  // =========================================================
  Future<HistorialPatrullajeModel> registrarHistorial(
    HistorialPatrullajeModel historial
  );

  // =========================================================
  // OBTENER HISTORIAL POR PATRULLAJE
  // GET /historial/patrullaje/:patrullajeId
  // =========================================================
  Future<List<HistorialPatrullajeModel>>
      obtenerHistorialPorPatrullaje(
    int patrullajeId
  );

  // =========================================================
  // OBTENER CONTEXTO OPERATIVO DE ZONA
  // GET /historial/zona/:zonaId
  //
  // Incluye:
  // - historial
  // - incidencias
  // - recomendaciones
  // - observaciones
  // =========================================================
  Future<Map<String, dynamic>> obtenerContextoZona(
    int zonaId
  );

  // =========================================================
  // OBTENER RESUMEN OPERATIVO DE ZONA
  // GET /historial/zona/:zonaId/resumen
  // =========================================================
  Future<Map<String, dynamic>> obtenerResumenZona(
    int zonaId
  );

  // =========================================================
  // ARCHIVAR HISTORIAL
  // PUT /historial/archivar/:historialId
  // =========================================================
  Future<void> archivarHistorial(
    int historialId
  );
}