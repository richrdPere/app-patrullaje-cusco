// Services
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/index_service.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/selector-incidencias/incidencias_selector_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/selector-incidencias/incidencias_selector_query_params.dart';

// Repository
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_create_req.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_pdf_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_query_params.dart';

class OcurrenciasRepositoryImpl implements OcurrenciasRepository {
  final OcurrenciaService ocurrenciaService;
  final AuthRepository authRepository;

  OcurrenciasRepositoryImpl(this.ocurrenciaService, this.authRepository);

  // *********************************************************
  // 1.- Crear ocurrencia
  // *********************************************************
  @override
  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> createOcurrencia({
    required CreateOcurrenciaRequest request,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return await ocurrenciaService.createOcurrencia(
      token: token,
      request: request,
    );
  }

  // *********************************************************
  // 2.- Obtener ocurrencias paginadas
  // *********************************************************
  @override
  Future<Resource<ApiResponse<OcurrenciaPaginated>>> getOcurrenciasPaginado({
    required OcurrenciaQueryParams params,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return await ocurrenciaService.getOcurrenciasPaginado(
      token: token,
      params: params,
    );
  }

  // *********************************************************
  // 3.- Obtener ocurrencia por ID
  // *********************************************************
  @override
  Future<Resource<ApiResponse<OcurrenciaDetalleData>>> getOcurrenciaById({
    required int ocurrenciaId,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return await ocurrenciaService.getOcurrenciaById(
      token: token,
      ocurrenciaId: ocurrenciaId,
    );
  }

  // *********************************************************
  // 4.- Obtener PDF de la ocurrencia
  // *********************************************************
  @override
  Future<Resource<OcurrenciaPdfData>> getOcurrenciaPdf({
    required int ocurrenciaId,
  }) async {
    final token = await authRepository.getToken();

    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return ocurrenciaService.getOcurrenciaPdf(
      token: token,
      ocurrenciaId: ocurrenciaId,
    );
  }

  // *********************************************************
  // 5.- Obtener incidencias disponibles para una ocurrencia
  // *********************************************************
  @override
  Future<Resource<ApiResponse<IncidenciasSelectorPaginated>>>
  getIncidenciasSelector({
    required IncidenciasSelectorQueryParams params,
  }) async {
    final token = await authRepository.getToken();
    if (token == null) {
      return ErrorData(error: "No existe una sesión iniciada.", message: '');
    }

    return ocurrenciaService.getIncidenciasSelector(
      token: token,
      params: params,
    );
  }
}
