import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class GetDashboardIncidentesUseCase {
  final IncidenteRepository incidenteRepository;

  GetDashboardIncidentesUseCase(this.incidenteRepository);

  Future<Map<String, dynamic>> run() {
    return incidenteRepository.getDashboard();
  }
}
