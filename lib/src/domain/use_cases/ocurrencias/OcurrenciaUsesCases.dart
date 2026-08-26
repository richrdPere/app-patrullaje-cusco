import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';


class OcurrenciaUsesCases {
  CreateOcurrenciaUC createOcurrenciaUC;
  GetOcurrenciaByIdUC getOcurrenciaByIdUC;
  GetOcurrenciaPdfUC getOcurrenciaPdfUC;
  GetOcurrenciasPaginadoUC getOcurrenciasPaginadoUC;
  GetIncidenciasSelectorUC getIncidenciasSelectorUC;

  OcurrenciaUsesCases({
    required this.createOcurrenciaUC,
    required this.getOcurrenciaByIdUC,
    required this.getOcurrenciaPdfUC,
    required this.getOcurrenciasPaginadoUC,
    required this.getIncidenciasSelectorUC
  });
}
