import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_pdf_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class OcurrenciaState extends Equatable {
  /// Respuesta al crear una ocurrencia.
  final Resource<ApiResponse<OcurrenciaDetalleData>> createResponse;

  /// Respuesta del listado paginado.
  final Resource<ApiResponse<OcurrenciaPaginated>> paginatedResponse;

  /// Respuesta del detalle por ID.
  final Resource<ApiResponse<OcurrenciaDetalleData>> detailResponse;

  /// Respuesta del PDF.
  final Resource<OcurrenciaPdfData> pdfResponse;

  const OcurrenciaState({
    required this.createResponse,
    required this.paginatedResponse,
    required this.detailResponse,
    required this.pdfResponse,
  });

  factory OcurrenciaState.initial() {
    return OcurrenciaState(
      createResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      paginatedResponse: Initial<ApiResponse<OcurrenciaPaginated>>(),
      detailResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      pdfResponse: Initial<OcurrenciaPdfData>(),
    );
  }

  OcurrenciaState copyWith({
    Resource<ApiResponse<OcurrenciaDetalleData>>? createResponse,
    Resource<ApiResponse<OcurrenciaPaginated>>? paginatedResponse,
    Resource<ApiResponse<OcurrenciaDetalleData>>? detailResponse,
    Resource<OcurrenciaPdfData>? pdfResponse,
  }) {
    return OcurrenciaState(
      createResponse: createResponse ?? this.createResponse,
      paginatedResponse: paginatedResponse ?? this.paginatedResponse,
      detailResponse: detailResponse ?? this.detailResponse,
      pdfResponse: pdfResponse ?? this.pdfResponse,
    );
  }

  // ==========================================================
  // GETTERS DE CARGA
  // ==========================================================

  bool get isCreating => createResponse is Loading;

  bool get isLoadingPaginated => paginatedResponse is Loading;

  bool get isLoadingDetail => detailResponse is Loading;

  bool get isLoadingPdf => pdfResponse is Loading;

  bool get hasAnyLoading {
    return isCreating || isLoadingPaginated || isLoadingDetail || isLoadingPdf;
  }

  // ==========================================================
  // DATOS EXITOSOS
  // ==========================================================

  ApiResponse<OcurrenciaDetalleData>? get createdOcurrencia {
    final resource = createResponse;

    if (resource is Success<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.data;
    }

    return null;
  }

  ApiResponse<OcurrenciaPaginated>? get paginatedOcurrencias {
    final resource = paginatedResponse;

    if (resource is Success<ApiResponse<OcurrenciaPaginated>>) {
      return resource.data;
    }

    return null;
  }

  ApiResponse<OcurrenciaDetalleData>? get ocurrenciaDetail {
    final resource = detailResponse;

    if (resource is Success<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.data;
    }

    return null;
  }

  OcurrenciaPdfData? get ocurrenciaPdf {
    final resource = pdfResponse;

    if (resource is Success<OcurrenciaPdfData>) {
      return resource.data;
    }

    return null;
  }

  // ==========================================================
  // ERRORES
  // ==========================================================

  String? get createError {
    final resource = createResponse;

    if (resource is ErrorData<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.message;
    }

    return null;
  }

  String? get paginatedError {
    final resource = paginatedResponse;

    if (resource is ErrorData<ApiResponse<OcurrenciaPaginated>>) {
      return resource.message;
    }

    return null;
  }

  String? get detailError {
    final resource = detailResponse;

    if (resource is ErrorData<ApiResponse<OcurrenciaDetalleData>>) {
      return resource.message;
    }

    return null;
  }

  String? get pdfError {
    final resource = pdfResponse;

    if (resource is ErrorData<OcurrenciaPdfData>) {
      return resource.message;
    }

    return null;
  }

  @override
  List<Object?> get props => [
    createResponse,
    paginatedResponse,
    detailResponse,
    pdfResponse,
  ];
}
