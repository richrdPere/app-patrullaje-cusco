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

  // ARCHIVAR HISTORIAL
  @override
  Future<void> archivarHistorial(int historialId) async {
    await historialService.archivarHistorial(historialId);
  }

  @override
  Future<HistorialPatrullajeModel> editarHistorial(
    HistorialPatrullajeModel historial,
  ) async {
    return await historialService.editarHistorial(historial);
  }

  @override
  Future<HistorialPatrullajeModel> obtenerDetalleHistorial(
    int historialId,
  ) async {
    return await historialService.obtenerDetalleHistorial(historialId);
  }
}
