import 'package:sis_patrullaje_cusco/src/domain/models/incidencia_model.dart';
// import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
// import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class CreateIncidenteUseCase {
  // final AuthRepository authRepository;
  // final PatrullajeRepository patrullajeRepository;
  final IncidenteRepository incidenteRepository;

  CreateIncidenteUseCase(
    // this.authRepository,
    // this.patrullajeRepository,
    this.incidenteRepository,
  );

  run(IncidenteModel params) => incidenteRepository.crearIncidencia(params);
}
