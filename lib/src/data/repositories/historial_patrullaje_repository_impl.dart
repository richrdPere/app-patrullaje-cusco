import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/historial_patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class HistorialPatrullajeRepositoryImpl extends HistorialPatrullajeRepository {
  final HistorialPatrullajeService historialService;

  HistorialPatrullajeRepositoryImpl(this.historialService);

  // REGISTRAR HISTORIAL
  @override
  Future<HistorialPatrullajeModel> registrarHistorial(
    HistorialPatrullajeModel historial,
  ) async {
    final response = await historialService.registrarHistorial(historial);

    if (response == null) {
      throw Exception('No se pudo registrar historial');
    }

    return response;
  }

  // OBTENER HISTORIAL POR PATRULLAJE
  @override
  Future<List<HistorialPatrullajeModel>> obtenerHistorialPorPatrullaje(
    int patrullajeId,
  ) async {
    return await historialService.obtenerHistorialPorPatrullaje(patrullajeId);
  }

  // OBTENER CONTEXTO OPERATIVO DE ZONA
  @override
  Future<Map<String, dynamic>> obtenerContextoZona(int zonaId) async {
    return await historialService.obtenerContextoZona(zonaId);
  }

  // OBTENER RESUMEN DE ZONA
  @override
  Future<Map<String, dynamic>> obtenerResumenZona(int zonaId) async {
    return await historialService.obtenerResumenZona(zonaId);
  }

  // ARCHIVAR HISTORIAL
  @override
  Future<void> archivarHistorial(int historialId) async {
    await historialService.archivarHistorial(historialId);
  }
}
