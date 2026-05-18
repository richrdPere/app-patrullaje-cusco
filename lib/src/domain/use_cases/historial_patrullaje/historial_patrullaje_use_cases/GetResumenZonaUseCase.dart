import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';

class GetResumenZonaUseCase {
  final HistorialPatrullajeRepository historialRepository;
  GetResumenZonaUseCase(this.historialRepository);

  run(int zonaId) => historialRepository.obtenerResumenZona(zonaId);
}
