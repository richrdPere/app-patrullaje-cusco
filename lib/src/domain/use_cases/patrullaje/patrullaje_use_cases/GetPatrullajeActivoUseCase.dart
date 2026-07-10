import 'package:sis_patrullaje_cusco/src/data/models/patrullaje/patrullaje_data.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class GetPatrullajeActivoUseCase {
  PatrullajeRepository patrullajeRepository;

  GetPatrullajeActivoUseCase(this.patrullajeRepository);

  Future<Resource<PatrullajeData?>> run() =>
      patrullajeRepository.getPatrullajeActivo();
}
