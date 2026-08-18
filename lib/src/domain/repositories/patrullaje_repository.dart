import 'package:sis_patrullaje_cusco/src/data/models/common/api_response.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_paginated.dart';
import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_sereno_query_params.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class PatrullajeRepository {
  // API REST

  /// 1. GET PATRULLAJE ACTIVO
  Future<Resource<PatrullajeData?>> getPatrullajeActivo();

  /// 2. INICIAR PATRULLAJE
  Future<Resource<bool>> startPatrullaje(int patrullajeId);

  /// 3. FINALIZAR PATRULLAJE
  Future<Resource<PatrullajeData>> endPatrullaje({
    required int patrullajeId,
    String? observacionFinal,
  });

  /// 4. ENVIAR UBICACIÓN
  Future<Resource<bool>> sendLocation(LocationEntity location);

  /// 5. OBTENER MIS PATRULLAJES PAGINADOS
  Future<Resource<ApiResponse<PatrullajeSerenoPaginated>>>
  getMisPatrullajesPaginados({required PatrullajeSerenoQueryParams params});

  // Socket - listen
  Stream<PatrullajeData> listenNuevoPatrullaje();
  Stream<PatrullajeData> listenPatrullajeActualizado();
  Stream<int> listenPatrullajeFinalizado();

  // Socket - emit
  void iniciarPatrullajeSocket(int patrullajeId);
  void finalizarPatrullajeSocket(int patrullajeId);
  void joinPatrullaje(int patrullajeId);
  void leavePatrullaje(int patrullajeId);
}
