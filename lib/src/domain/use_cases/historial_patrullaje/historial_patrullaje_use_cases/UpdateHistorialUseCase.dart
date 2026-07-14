import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/data/models/historial_patrullaje/historial_patrullaje_request.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class UpdateHistorialUseCase {
  final HistorialPatrullajeRepository historialRepository;

  UpdateHistorialUseCase(this.historialRepository);

  Future<Resource<HistorialPatrullajeModel>> run({
    required int idHistorial,
    required HistorialPatrullajeRequest historial,
  }) => historialRepository.updateHistorial(
    idHistorial: idHistorial,
    historial: historial,
  );
}
