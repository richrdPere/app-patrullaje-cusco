import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_arbol_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_query_params.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class ClasificadoresRepository {
  /// 1.- Obtener el arbol de clasificadores
  Future<Resource<ApiResponse<ClasificadorArbolData>>> getClasificadorArbol();

  /// 2.- Obtener clasificador por código
  Future<Resource<ApiResponse<ClasificadorCodigoData>>>
  getClasificadorByCodigo({required String codigo});

  /// 3.- Obtener clasificadores paginados
  Future<Resource<ApiResponse<ClasificadorPaginated>>>
  getClasificadoresPaginado({required ClasificadorQueryParams params});
}
