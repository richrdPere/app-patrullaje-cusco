import 'dart:io';

import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';

class AddEvidenciasIncidenteUseCase {
  final IncidenteRepository incidenteRepository;

  AddEvidenciasIncidenteUseCase(this.incidenteRepository);

  Future<void> run({required int incidenciaId, required List<File> archivos}) {
    return incidenteRepository.addEvidencias(incidenciaId, archivos);
  }
}
