import 'dart:io';

import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class AddArchivosIncidenciaUseCase {
  final IncidenteRepository incidenteRepository;

  AddArchivosIncidenciaUseCase(this.incidenteRepository);

  Future<Resource<ApiResponse<AgregarArchivosIncidenciaData>>> run({
    required int incidenciaId,
    required List<File> archivos,
  }) {
    return incidenteRepository.addArchivosIncidencia(
      incidenciaId: incidenciaId,
      archivos: archivos,
    );
  }
}
