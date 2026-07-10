import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';

import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class PatrullajeRepository {
  // API REST
  Future<Resource<PatrullajeData?>> getPatrullajeActivo();
  Future<Resource<bool>> startPatrullaje(int patrullajeId);
  Future<Resource<bool>> endPatrullaje(int patrullajeId);
  Future<Resource<bool>> sendLocation(LocationEntity location);

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
