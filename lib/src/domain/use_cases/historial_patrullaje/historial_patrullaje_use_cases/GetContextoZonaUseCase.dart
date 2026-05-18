import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class GetContextoZonaUseCase {
  final HistorialPatrullajeRepository historialRepository;
  GetContextoZonaUseCase(this.historialRepository);

  run(int zonaId) => historialRepository.obtenerContextoZona(zonaId);
}
