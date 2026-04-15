import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class PatrullajeRepositoryImpl implements PatrullajeRepository {
  final PatrullajeService remote;

  PatrullajeRepositoryImpl(this.remote);

  @override
  Future<PatrullajeModel?> getPatrullajeActivo() {
    return remote.getPatrullajeActivo();
  }

  @override
  Future<void> endPatrullaje(int patrullajeId) {
    return remote.endPatrullaje(patrullajeId);
  }

  @override
  Future<void> startPatrullaje(int patrullajeId) {
    return remote.startPatrullaje(patrullajeId);
  }

  @override
  Future<void> sendLocation(LocationEntity location) {
    return remote.sendLocation(location);
  }
}
