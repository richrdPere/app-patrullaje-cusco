import 'package:injectable/injectable.dart';
// import 'package:sis_patrullaje_cusco/injection.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/socket_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/ConnectSocketUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/DisconnetSocketUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/GetSocketUseCase.dart';
// import 'package:socket_io_client/socket_io_client.dart';

import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/auth_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/alert_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/auth_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/geolocator_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/patrullaje_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/alert_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/AlertUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/alerta_use_case/SendAlertUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/GetUserSessionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LoginUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LogoutUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/RegisterUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/SaveUserSessionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/CreateMarkerUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/FindPositionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetLocationStreamUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetMarkerUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetPlaceMarkDataUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetPolyLineUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/EndPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/GetPatrullajeActivoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/SendLocationUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/StartPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';

@module
abstract class AppModule {
  @lazySingleton
  SocketRepository socketRepository() => SocketRepositoryImpl();

  // SERVICES
  @injectable
  AuthService get authService => AuthService();

  @injectable
  SharefPref get sharedPref => SharefPref();

  // REPOSITORY IMPL
  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

  @injectable
  GeolocatorRepository get geolocatorRepository => GeolocatorRepositoryImpl();

  @injectable
  PatrullajeRepository get patrullajeRepository =>
      PatrullajeRepositoryImpl(patrullajeService);

  @injectable
  PatrullajeService get patrullajeService => PatrullajeService(authRepository);

  // USES CASES

  // - Auth
  @injectable
  AuthUsesCases get authUseCases => AuthUsesCases(
    login: LoginUseCase(authRepository),
    register: RegisterUseCase(authRepository),
    saveUserSession: SaveUserSessionUseCase(authRepository),
    getUserSession: GetUserSessionUseCase(authRepository),
    logoutSession: LogoutUseCase(authRepository),
  );

  // - Geolocator
  @injectable
  GeolocatorUseCases get geolocatorUseCases => GeolocatorUseCases(
    findPosition: FindPositionUseCase(geolocatorRepository),
    createMarker: CreateMarkerUseCase(geolocatorRepository),
    getMarker: GetMarkerUseCase(geolocatorRepository),
    getPlaceMarkData: GetPlaceMarkDataUseCase(geolocatorRepository),
    getPolyline: GetPolylineUseCase(geolocatorRepository),
    getLocationStream: GetLocationStreamUseCase(geolocatorRepository),
  );

  // Patrullaje
  @injectable
  PatrullajeUseCases get patrullajeUseCases => PatrullajeUseCases(
    getPatrullajeActivo: GetPatrullajeActivoUseCase(patrullajeRepository),
    endPatrullaje: EndPatrullajeUseCase(patrullajeRepository),
    startPatrullaje: StartPatrullajeUseCase(patrullajeRepository),
    sendLocation: SendLocationUseCase(patrullajeRepository),
  );

  // Alert
  @injectable
  AlertUseCases get alertUseCases =>
      AlertUseCases(sendAlert: SendAlertUseCase(alertRepository));

  // Tracking
  // @injectable
  // TrackingUseCases get trackingUseCases => TrackingUseCases(
  //   getLocationStream: GetLocationStreamUseCase(trackingRepository),
  //   startTracking: StartTrackingUseCase(trackingRepository),
  //   stopTracking: StopTrackingUseCase(trackingRepository),
  // );

  @injectable
  AlertRepository get alertRepository =>
      AlertRepositoryImpl(geolocatorUseCases);

  // Socket
  @lazySingleton
  SocketUseCases socketUseCases(SocketRepository socketRepository) =>
      SocketUseCases(
        connectSocket: ConnectSocketUseCase(socketRepository),
        disconnetSocket: DisconnetSocketUseCase(socketRepository),
        getSocket: GetSocketUseCase(socketRepository),
      );
  // @injectable
  // SocketUseCases get socketUseCases => SocketUseCases(
  //   connectSocket: ConnectSocketUseCase(socketRepository),
  //   disconnetSocket: DisconnetSocketUseCase(socketRepository),
  //   getSocket: GetSocketUseCase(socketRepository),
  // );

  @lazySingleton
  SocketBloc socketBloc(
    SocketUseCases socketUseCases,
    AuthUsesCases authUsesCases,
  ) => SocketBloc(socketUseCases, authUsesCases);
}
