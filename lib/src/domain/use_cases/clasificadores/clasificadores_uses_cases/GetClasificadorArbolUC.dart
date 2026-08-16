import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_arbol_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetClasificadorArbolUC {
  final ClasificadoresRepository clasificadoresRepository;
  GetClasificadorArbolUC(this.clasificadoresRepository);

  Future<Resource<ApiResponse<ClasificadorArbolData>>> run() =>
      clasificadoresRepository.getClasificadorArbol();
}
