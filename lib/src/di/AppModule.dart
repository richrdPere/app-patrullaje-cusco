import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/historial_patrullaje_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/incidente_service.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/users_service.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/historial_patrullaje_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/incidente_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/media_repository_impl.dart';
// import 'package:sis_patrullaje_cusco/injection.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/socket_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/tracking_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/data/repositories/users_repository_impl.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/historial_patrullaje_repository.dart';
// import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/incidente_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/media_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/tracking_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/users_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/ArchivarHistorialUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetHistorialByIdUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetHistorialByPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/RegisterHistorialUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/UpdateHistorialUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/AddEvidenciasIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/CreateIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetDashboardIncidentesUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetEvidenciasIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetMapaIncidentesUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetNearbyIncidenciaUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/RemoveEvidenciaIncidenteUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/PickImageUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/PickVideoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/RecordVideoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/TakePhotoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/EndPatrullajeSocketUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/JoinPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/LeavePatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenNewPatrullajeUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenPatrullajeActualizadoUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenPatrullajeEndUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/StartPatrullajeSocketUseCase.dart';
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
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/TrackingUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/tracking_use_case/GetLocationUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/tracking_use_case/SendLocationUserUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/users/UsersUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/users/users_uses_cases/UpdateUserUseCase.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';

@module
abstract class AppModule {
  @lazySingleton
  SocketRepository socketRepository() => SocketRepositoryImpl();

  @injectable
  ImagePicker get imagePicker => ImagePicker();

  @injectable
  SharefPref get sharedPref => SharefPref();

  // =============================================================
  // SERVICES (DATA SOURCE REMOTO)
  // =============================================================
  @injectable
  AuthService get authService => AuthService();

  @injectable
  UsersService get usersService => UsersService(authRepository);

  @injectable
  PatrullajeService get patrullajeService => PatrullajeService(authRepository);

  @injectable
  IncidenteService get incidenteService => IncidenteService(authRepository);

  @injectable
  HistorialPatrullajeService get historialPatrullajeService =>
      HistorialPatrullajeService(authRepository);

  // =============================================================
  // REPOSITORY IMPL
  // =============================================================
  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

  @injectable
  GeolocatorRepository get geolocatorRepository => GeolocatorRepositoryImpl();

  @injectable
  PatrullajeRepository patrullajeRepository(
    PatrullajeService patrullajeService,
    SocketRepository socketRepository,
  ) => PatrullajeRepositoryImpl(patrullajeService, socketRepository);

  @injectable
  TrackingRepository trackingRepository(SocketRepository socketRepository) =>
      TrackingRepositoryImpl(geolocatorRepository, socketRepository);

  @injectable
  IncidenteRepository get incidenteRepository =>
      IncidenteRepositoryImpl(incidenteService);

  @injectable
  HistorialPatrullajeRepository get historialPatrullajeRepository =>
      HistorialPatrullajeRepositoryImpl(historialPatrullajeService);

  @injectable
  UsersRepository get usersRepository => UsersRepositoryImpl(usersService);

  @injectable
  MediaRepository get mediaRepository => MediaRepositoryImpl(imagePicker);

  @injectable
  AlertRepository get alertRepository =>
      AlertRepositoryImpl(geolocatorUseCases);

  // =============================================================
  // USES CASES
  // =============================================================

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
  PatrullajeUseCases patrullajeUseCases(
    PatrullajeRepository patrullajeRepository,
  ) => PatrullajeUseCases(
    getPatrullajeActivo: GetPatrullajeActivoUseCase(patrullajeRepository),
    endPatrullaje: EndPatrullajeUseCase(patrullajeRepository),
    startPatrullaje: StartPatrullajeUseCase(patrullajeRepository),
    sendLocation: SendLocationUseCase(patrullajeRepository),
    listenNewPatrullaje: ListenNewPatrullajeUseCase(patrullajeRepository),
    listenPatrullajeActualizado: ListenPatrullajeActualizadoUseCase(
      patrullajeRepository,
    ),
    listenPatrullajeEnd: ListenPatrullajeEndUseCase(patrullajeRepository),
    startPatrullajeSocket: StartPatrullajeSocketUseCase(patrullajeRepository),
    endPatrullajeSocket: EndPatrullajeSocketUseCase(patrullajeRepository),
    joinPatrullaje: JoinPatrullajeUseCase(patrullajeRepository),
    leavePatrullaje: LeavePatrullajeUseCase(patrullajeRepository),
  );

  // Tracking
  @injectable
  TrackingUseCases trackingUseCases(TrackingRepository trackingRepository) =>
      TrackingUseCases(
        getLocationStream: GetLocationUseCase(trackingRepository),
        sendLocation: SendLocationUserUseCase(trackingRepository),
      );

  // Alert
  @injectable
  AlertUseCases get alertUseCases =>
      AlertUseCases(sendAlert: SendAlertUseCase(alertRepository));

  // Incident
  @injectable
  IncidenteUseCases get incidentUseCases => IncidenteUseCases(
    createIncidente: CreateIncidenteUseCase(incidenteRepository),
    addEvidenciasIncidente: AddEvidenciasIncidenteUseCase(incidenteRepository),
    removeEvidenciaIncidente: RemoveEvidenciaIncidenteUseCase(
      incidenteRepository,
    ),
    getDashboardIncidentes: GetDashboardIncidentesUseCase(incidenteRepository),
    getEvidenciasIncidente: GetEvidenciasIncidenteUseCase(incidenteRepository),
    getIncidencia: GetIncidenciaUseCase(incidenteRepository),
    getMapaIncidentes: GetMapaIncidentesUseCase(incidenteRepository),
    getNearbyIncidentes: GetNearbyIncidentesUseCase(incidenteRepository),
  );

  // Historial Patrullaje
  @injectable
  HistorialPatrullajeUseCases
  get historialPatrullajeUseCases => HistorialPatrullajeUseCases(
    archivedHistorial: ArchivarHistorialUseCase(historialPatrullajeRepository),
    getHistorialById: GetHistorialByIdUseCase(historialPatrullajeRepository),
    getHistorialByPatrullaje: GetHistorialByPatrullajeUseCase(
      historialPatrullajeRepository,
    ),
    updateHistorial: UpdateHistorialUseCase(historialPatrullajeRepository),
    createHistorial: RegisterHistorialUseCase(historialPatrullajeRepository),
  );

  // Users
  @injectable
  UsersUseCases get usersUseCases =>
      UsersUseCases(updateUser: UpdateUserUseCase(usersRepository));

  // Multimedias
  @injectable
  MultimediasUseCases get multimediasUseCases => MultimediasUseCases(
    takePhoto: TakePhotoUseCase(mediaRepository),
    recordVideo: RecordVideoUseCase(mediaRepository),
    pickImage: PickImageUseCase(mediaRepository),
    pickVideo: PickVideoUseCase(mediaRepository),
  );

  // Socket
  @lazySingleton
  SocketUseCases socketUseCases(SocketRepository socketRepository) =>
      SocketUseCases(
        connectSocket: ConnectSocketUseCase(socketRepository),
        disconnetSocket: DisconnetSocketUseCase(socketRepository),
        getSocket: GetSocketUseCase(socketRepository),
      );

  @lazySingleton
  SocketBloc socketBloc(
    SocketUseCases socketUseCases,
    AuthUsesCases authUsesCases,
  ) => SocketBloc(socketUseCases, authUsesCases);
}
