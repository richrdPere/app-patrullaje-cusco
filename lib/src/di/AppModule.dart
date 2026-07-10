import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';

// Service
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/index_service.dart';

// Repository - DOMAIN
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart';

// Repository Impl - DATA
import 'package:sis_patrullaje_cusco/src/data/repositories/index_repository_impl.dart';

// Use Cases
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';

@module
abstract class AppModule {
  @lazySingleton
  SocketRepository socketRepository() => SocketRepositoryImpl();

  @injectable
  ImagePicker get imagePicker => ImagePicker();

  @injectable
  SharefPref get sharedPref => SharefPref();

  // =============================================================
  // 1. SERVICES (DATA SOURCE REMOTO)
  // =============================================================
  @injectable
  AuthService get authService => AuthService();

  @injectable
  UsersService get usersService => UsersService();

  @injectable
  PatrullajeService get patrullajeService => PatrullajeService();

  @injectable
  IncidenciaService get incidenteService => IncidenciaService();

  @injectable
  HistorialPatrullajeService get historialPatrullajeService =>
      HistorialPatrullajeService();

  // =============================================================
  // 2. REPOSITORY
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
  ) => PatrullajeRepositoryImpl(
    patrullajeService,
    authRepository,
    socketRepository,
  );

  @injectable
  TrackingRepository trackingRepository(SocketRepository socketRepository) =>
      TrackingRepositoryImpl(geolocatorRepository, socketRepository);

  @injectable
  IncidenteRepository get incidenteRepository =>
      IncidenteRepositoryImpl(incidenteService, authRepository);

  @injectable
  HistorialPatrullajeRepository get historialPatrullajeRepository =>
      HistorialPatrullajeRepositoryImpl(
        historialPatrullajeService,
        authRepository,
      );

  @injectable
  UsersRepository get usersRepository =>
      UsersRepositoryImpl(usersService, authRepository);

  @injectable
  MediaRepository get mediaRepository => MediaRepositoryImpl(imagePicker);

  @injectable
  AlertRepository get alertRepository =>
      AlertRepositoryImpl(geolocatorRepository);

  // =============================================================
  // 3. USES CASES
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

  // - Patrullaje
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

  // - Tracking
  @injectable
  TrackingUseCases trackingUseCases(TrackingRepository trackingRepository) =>
      TrackingUseCases(
        getLocationStream: GetLocationUseCase(trackingRepository),
        sendLocation: SendLocationUserUseCase(trackingRepository),
      );

  // - Alert
  @injectable
  AlertUseCases get alertUseCases =>
      AlertUseCases(sendAlert: SendAlertUseCase(alertRepository));

  // - Incidencia
  @injectable
  IncidenteUseCases get incidentUseCases => IncidenteUseCases(
    addArchivosIncidencia: AddArchivosIncidenciaUseCase(incidenteRepository),
    createIncidente: CreateIncidenteUseCase(incidenteRepository),
    getEvidenciasIncidente: GetArchivoIncidenciaUseCase(incidenteRepository),
    getIncidenciaById: GetIncidenciaByIdUseCase(incidenteRepository),
    getIncidenciasCercanas: GetIncidenciasCercanasUseCase(incidenteRepository),
    getMisIncidencias: GetMisIncidenciasUseCase(incidenteRepository),
    removeEvidenciaIncidente: RemoveArchivoIncidenciaUseCase(
      incidenteRepository,
    ),
  );

  // - Historial Patrullaje
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

  // - Users
  @injectable
  UsersUseCases get usersUseCases =>
      UsersUseCases(updateUser: UpdateUserUseCase(usersRepository));

  // - Multimedias
  @injectable
  MultimediasUseCases get multimediasUseCases => MultimediasUseCases(
    takePhoto: TakePhotoUseCase(mediaRepository),
    recordVideo: RecordVideoUseCase(mediaRepository),
    pickImage: PickImageUseCase(mediaRepository),
    pickVideo: PickVideoUseCase(mediaRepository),
  );

  // =============================================================
  // 4. SOCKETS
  // =============================================================

  // - Socket
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
