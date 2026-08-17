import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_pdf_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_query_params.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class OcurrenciasRepository {
  /// 1.- Crear ocurrencia
  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> createOcurrencia({
    required CreateOcurrenciaRequest request,
  });

  /// 2.- Obtener ocurrencias paginadas
  Future<Resource<ApiResponse<OcurrenciaPaginated>>> getOcurrenciasPaginado({
    required OcurrenciaQueryParams params,
  });

  /// 3.- Obtener ocurrencia por ID
  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> getOcurrenciaById({
    required int ocurrenciaId,
  });

  /// 4.- Obtener PDF de la ocurrencia
  Future<Resource<OcurrenciaPdfData>> getOcurrenciaPdf({
    required int ocurrenciaId,
  });
}
