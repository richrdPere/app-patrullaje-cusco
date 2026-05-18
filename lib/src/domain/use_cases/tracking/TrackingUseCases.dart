import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/tracking_use_case/GetLocationUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/tracking_use_case/SendLocationUserUseCase.dart';

class TrackingUseCases {
  GetLocationUseCase getLocationStream;
  SendLocationUserUseCase sendLocation;

  TrackingUseCases({
    required this.getLocationStream,
    required this.sendLocation,
  });
}
