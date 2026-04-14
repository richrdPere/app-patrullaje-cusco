import 'package:injectable/injectable.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/auth_service.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/auth_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/geolocator_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/GetUserSessionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LoginUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LogoutUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/RegisterUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/SaveUserSessionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/CreateMarkerUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/FindPositionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetMarkerUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetPlaceMarkDataUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetPolyLineUseCase.dart';

@module
abstract class AppModule {
  @injectable
  AuthService get authService => AuthService();

  @injectable
  SharefPref get sharedPref => SharefPref();

  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

  @injectable
  GeolocatorRepository get geolocatorRepository => GeolocatorRepositoryImpl();

  @injectable
  AuthUsesCases get authUseCases => AuthUsesCases(
    login: LoginUseCase(authRepository),
    register: RegisterUseCase(authRepository),
    saveUserSession: SaveUserSessionUseCase(authRepository),
    getUserSession: GetUserSessionUseCase(authRepository),
    logoutSession: LogoutUseCase(authRepository),
  );

  @injectable
  GeolocatorUseCases get geolocatorUseCases => GeolocatorUseCases(
    findPosition: FindPositionUseCase(geolocatorRepository),
    createMarker: CreateMarkerUseCase(geolocatorRepository),
    getMarker: GetMarkerUseCase(geolocatorRepository),
    getPlaceMarkData: GetPlaceMarkDataUseCase(geolocatorRepository),
    getPolyline: GetPolylineUseCase(geolocatorRepository),
  );
}
