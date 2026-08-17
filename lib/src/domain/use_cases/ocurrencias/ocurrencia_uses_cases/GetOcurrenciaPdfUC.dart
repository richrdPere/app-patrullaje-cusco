import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_pdf_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetOcurrenciaPdfUC {
  final OcurrenciasRepository ocurrenciasRepository;
  GetOcurrenciaPdfUC(this.ocurrenciasRepository);

  Future<Resource<OcurrenciaPdfData>> run({required int ocurrenciaId}) =>
      ocurrenciasRepository.getOcurrenciaPdf(ocurrenciaId: ocurrenciaId);
}
