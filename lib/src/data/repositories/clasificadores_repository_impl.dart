// Services
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/index_service.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_arbol_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_codigo_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/clasificadores/clasificador_query_params.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';

// Repository
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class ClasificadoresRepositoryImpl implements ClasificadoresRepository {
  final ClasificadoresService clasificadoresService;
  final AuthRepository authRepository;

  ClasificadoresRepositoryImpl(this.clasificadoresService, this.authRepository);

  // *********************************************************
  // 1.- Obtener el arbol de clasificadores
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ClasificadorArbolData>>>
  getClasificadorArbol() async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return await clasificadoresService.getClasificadorArbol(token: token);
  }

  // *********************************************************
  // 2.- Obtener clasificador por código
  // *********************************************************
  @override
  Future<Resource<ApiResponse<ClasificadorCodigoData>>>
  getClasificadorByCodigo({required String codigo}) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return await clasificadoresService.getClasificadorByCodigo(
      token: token,
      codigo: codigo,
    );
  }

  // *********************************************************
  // 3.- Obtener clasificadores paginados
  // *********************************************************

  @override
  Future<Resource<ApiResponse<ClasificadorPaginated>>>
  getClasificadoresPaginado({required ClasificadorQueryParams params}) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return await clasificadoresService.getClasificadoresPaginado(
      token: token,
      params: params,
    );
  }
}
