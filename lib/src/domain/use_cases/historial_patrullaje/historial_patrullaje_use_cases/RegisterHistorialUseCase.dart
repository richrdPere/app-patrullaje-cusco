import 'package:sis_patrullaje_cusco/src/domain/models/historial_patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class RegisterHistorialUseCase {
  final HistorialPatrullajeRepository historialRepository;
  RegisterHistorialUseCase(this.historialRepository);

  run(HistorialPatrullajeModel historial) =>
      historialRepository.registrarHistorial(historial);
}
