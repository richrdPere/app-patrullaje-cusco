import 'dart:io';
import 'package:sis_patrullaje_cusco/src/data/models/models.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class CreateObservacionConArchivosUC {
  final HistorialPatrullajeRepository historialRepository;
  CreateObservacionConArchivosUC(this.historialRepository);

  Future<Resource<ApiResponse<HistorialData>>> run({
    required CreateHistorialRequest request,
    required List<File> archivos,
  }) => historialRepository.createObservacionConArchivos(
    request: request,
    archivos: archivos,
  );
}
