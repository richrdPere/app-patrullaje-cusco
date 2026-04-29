import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
//import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';

abstract class PatrullajeRepository {
  Future<PatrullajeModel?> getPatrullajeActivo();
  Future<void> startPatrullaje(int patrullajeId);
  Future<void> endPatrullaje(int patrullajeId);
  Future<void> sendLocation(LocationEntity location);

  // Socket - listen
  Stream<PatrullajeModel> listenNuevoPatrullaje();
  Stream<int> listenPatrullajeFinalizado();

  // Socket - emit
  void iniciarPatrullajeSocket(int patrullajeId);
  void finalizarPatrullajeSocket(int patrullajeId);

  // (opcional pero recomendado)
  void joinPatrullaje(int patrullajeId);
  void leavePatrullaje(int patrullajeId);
}
