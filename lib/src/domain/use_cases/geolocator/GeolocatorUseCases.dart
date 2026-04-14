import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/CreateMarkerUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/FindPositionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetMarkerUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetPlaceMarkDataUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetPolyLineUseCase.dart';

class GeolocatorUseCases {
  FindPositionUseCase findPosition;
  CreateMarkerUseCase createMarker;
  GetMarkerUseCase getMarker;
  GetPlaceMarkDataUseCase getPlaceMarkData;
  GetPolylineUseCase getPolyline;

  GeolocatorUseCases({
    required this.findPosition,
    required this.createMarker,
    required this.getMarker,
    required this.getPlaceMarkData,
    required this.getPolyline,
  });
}
