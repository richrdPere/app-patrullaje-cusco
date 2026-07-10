import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class HistorialPatrullajeRepository {
  Future<Resource<HistorialPatrullajeModel>> registerHistorial(
    HistorialPatrullajeModel historial,
  );

  Future<Resource<List<HistorialPatrullajeModel>>>
  getHistorialByPatrullaje(int patrullajeId);

  Future<Resource<HistorialPatrullajeModel>> getHistorialById(
    int historialId,
  );

  Future<Resource<HistorialPatrullajeModel>> updateHistorial(
    HistorialPatrullajeModel historial,
  );

  Future<Resource<bool>> archivedHistorial(int historialId);
}
