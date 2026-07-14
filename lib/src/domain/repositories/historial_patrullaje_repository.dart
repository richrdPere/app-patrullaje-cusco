import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_request.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class HistorialPatrullajeRepository {
  /// Registrar historial
  Future<Resource<HistorialPatrullajeModel>> registerHistorial(
    HistorialPatrullajeRequest historial,
  );

  /// Obtener historial por patrullaje
  Future<Resource<List<HistorialPatrullajeModel>>> getHistorialByPatrullaje(
    int patrullajeId,
  );

  /// Registrar historial por ID
  Future<Resource<HistorialPatrullajeModel>> getHistorialById(int historialId);

  /// Actualizar historial
  Future<Resource<HistorialPatrullajeModel>> updateHistorial({
    required int idHistorial,
    required HistorialPatrullajeRequest historial,
  });

  /// Archivar historial
  Future<Resource<bool>> archivedHistorial(int historialId);
}
