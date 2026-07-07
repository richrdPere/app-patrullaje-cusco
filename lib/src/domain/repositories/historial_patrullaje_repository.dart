import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';

abstract class HistorialPatrullajeRepository {
  // =========================================================
  // REGISTRAR HISTORIAL
  // POST /historial/crear
  // =========================================================
  Future<HistorialPatrullajeModel> registrarHistorial(
    HistorialPatrullajeModel historial,
  );

  // =========================================================
  // OBTENER HISTORIAL DE UN PATRULLAJE
  // GET /historial/patrullaje/:id
  // =========================================================
  Future<List<HistorialPatrullajeModel>> obtenerHistorialPorPatrullaje(
    int patrullajeId,
  );

  // =========================================================
  // OBTENER DETALLE DEL HISTORIAL
  // GET /historial/detalle/:id
  // =========================================================
  Future<HistorialPatrullajeModel> obtenerDetalleHistorial(int historialId);

  // =========================================================
  // EDITAR HISTORIAL
  // PUT /historial/editar/:id
  // =========================================================
  Future<HistorialPatrullajeModel> editarHistorial(
    HistorialPatrullajeModel historial,
  );

  // =========================================================
  // ARCHIVAR HISTORIAL
  // PATCH /historial/archivar/:id
  // =========================================================
  Future<void> archivarHistorial(int historialId);
}
