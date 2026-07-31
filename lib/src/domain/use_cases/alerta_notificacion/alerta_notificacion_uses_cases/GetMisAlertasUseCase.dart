import 'package:sis_patrullaje_cusco/src/data/models/alertas/alerta_paginated.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetMisAlertasUseCase {
  final AlertaRepository alertaRepository;

  GetMisAlertasUseCase(this.alertaRepository);

  Future<Resource<AlertaPaginated>> run({
    int page = 1,
    int limit = 10,
    String? estado,
    String? tipo,
    String? prioridad,
    bool? requiereConfirmacion,
  }) => alertaRepository.getMisAlertas(
    page: page,
    limit: limit,
    estado: estado,
    tipo: tipo,
    prioridad: prioridad,
    requiereConfirmacion: requiereConfirmacion,
  );
}
