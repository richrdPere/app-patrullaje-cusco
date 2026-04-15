import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/patrullaje_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';

class PatrullajeRepositoryImpl implements PatrullajeRepository {
  final PatrullajeService remote;

  PatrullajeRepositoryImpl(this.remote);

  @override
  Future<PatrullajeModel?> getPatrullajeActivo() {
    return remote.getPatrullajeActivo();
  }
}