import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/patrullaje_entity.dart';

abstract class PatrullajeRepository {
  Future<PatrullajeEntity?> getPatrullajeActivo();
  Future<void> startPatrullaje(int patrullajeId);
  Future<void> endPatrullaje(int patrullajeId);
  Future<void> sendLocation(LocationEntity location);
  Stream<LocationEntity> getLocationStream();
}
