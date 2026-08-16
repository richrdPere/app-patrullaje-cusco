
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

class ClasificadoresUsesCases {
  GetClasificadorArbolUC getClasificadorArbolUC;
  GetClasificadorByCodigoUC getClasificadorByCodigoUC;
  GetClasificadoresPaginadoUC getClasificadoresPaginadoUC;

  ClasificadoresUsesCases({
    required this.getClasificadorArbolUC,
    required this.getClasificadorByCodigoUC,
    required this.getClasificadoresPaginadoUC,
  });
}
