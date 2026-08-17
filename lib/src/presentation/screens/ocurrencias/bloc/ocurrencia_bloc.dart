import 'package:flutter_bloc/flutter_bloc.dart';

// Modelos
import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_detalle_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/ocurrencias/ocurrencia_pdf_data.dart';

// Uses Cases
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

import 'ocurrencia_event.dart';
import 'ocurrencia_state.dart';

class OcurrenciaBloc extends Bloc<OcurrenciaEvent, OcurrenciaState> {
  final OcurrenciaUsesCases ocurrenciaUsesCases;

  OcurrenciaBloc(this.ocurrenciaUsesCases) : super(OcurrenciaState.initial()) {
    on<CreateOcurrencia>(_onCreateOcurrencia);
    on<GetOcurrenciasPaginado>(_onGetOcurrenciasPaginado);
    on<GetOcurrenciaById>(_onGetOcurrenciaById);
    on<GetOcurrenciaPdf>(_onGetOcurrenciaPdf);

    on<ClearOcurrenciaCreateResponse>(_onClearCreateResponse);

    on<ClearOcurrenciaDetailResponse>(_onClearDetailResponse);

    on<ClearOcurrenciaPdfResponse>(_onClearPdfResponse);

    on<ClearOcurrenciaPaginatedResponse>(_onClearPaginatedResponse);

    on<ResetOcurrenciaState>(_onResetState);
  }

  // *********************************************************
  // 1.- Crear ocurrencia
  // *********************************************************
  Future<void> _onCreateOcurrencia(
    CreateOcurrencia event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        createResponse: Loading<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );

    final response = await ocurrenciaUsesCases.createOcurrenciaUC.run(
      request: event.request,
    );

    emit(state.copyWith(createResponse: response));
  }

  // *********************************************************
  // 2.- Obtener ocurrencias paginadas
  // *********************************************************
  Future<void> _onGetOcurrenciasPaginado(
    GetOcurrenciasPaginado event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        paginatedResponse: Loading<ApiResponse<OcurrenciaPaginated>>(),
      ),
    );

    final response = await ocurrenciaUsesCases.getOcurrenciasPaginadoUC.run(
      params: event.params,
    );

    emit(state.copyWith(paginatedResponse: response));
  }

  // *********************************************************
  // 3.- Obtener ocurrencia por ID
  // *********************************************************
  Future<void> _onGetOcurrenciaById(
    GetOcurrenciaById event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(
      state.copyWith(
        detailResponse: Loading<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );

    final response = await ocurrenciaUsesCases.getOcurrenciaByIdUC.run(
      ocurrenciaId: event.ocurrenciaId,
    );

    emit(state.copyWith(detailResponse: response));
  }

  // *********************************************************
  // 4.- Obtener PDF
  // *********************************************************
  Future<void> _onGetOcurrenciaPdf(
    GetOcurrenciaPdf event,
    Emitter<OcurrenciaState> emit,
  ) async {
    emit(state.copyWith(pdfResponse: Loading<OcurrenciaPdfData>()));

    final response = await ocurrenciaUsesCases.getOcurrenciaPdfUC.run(
      ocurrenciaId: event.ocurrenciaId,
    );

    emit(state.copyWith(pdfResponse: response));
  }

  // *********************************************************
  // 5.- Limpiar respuesta de creación
  // *********************************************************
  void _onClearCreateResponse(
    ClearOcurrenciaCreateResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(
      state.copyWith(
        createResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );
  }

  // *********************************************************
  // 6.- Limpiar detalle
  // *********************************************************
  void _onClearDetailResponse(
    ClearOcurrenciaDetailResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(
      state.copyWith(
        detailResponse: Initial<ApiResponse<OcurrenciaDetalleData>>(),
      ),
    );
  }

  // *********************************************************
  // 7.- Limpiar PDF
  // *********************************************************
  void _onClearPdfResponse(
    ClearOcurrenciaPdfResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(state.copyWith(pdfResponse: Initial<OcurrenciaPdfData>()));
  }

  // *********************************************************
  // 8.- Limpiar paginado
  // *********************************************************
  void _onClearPaginatedResponse(
    ClearOcurrenciaPaginatedResponse event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(
      state.copyWith(
        paginatedResponse: Initial<ApiResponse<OcurrenciaPaginated>>(),
      ),
    );
  }

  // *********************************************************
  // 9.- Restablecer BLoC
  // *********************************************************
  void _onResetState(
    ResetOcurrenciaState event,
    Emitter<OcurrenciaState> emit,
  ) {
    emit(OcurrenciaState.initial());
  }
}
