import 'package:sis_patrullaje_cusco/src/domain/entities/location_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

class GetRouteUseCase {
  final DirectionsRepository directionsRepository;

  GetRouteUseCase(this.directionsRepository);

  Future<List<LocationEntity>> run({
    required LocationEntity origin,
    required LocationEntity destination,
  }) => directionsRepository.getRoute(origin: origin, destination: destination);
}
