import 'package:image_picker/image_picker.dart';
import 'package:injectable/injectable.dart';
import 'package:record/record.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/alerta_service.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_backend;

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
  @Named('googleMapsApiKey')
  String get googleMapsApiKey => url_backend.Environment.googleMapsAPI;

  @lazySingleton
  SocketRepository socketRepository() => SocketRepositoryImpl();

  // FIREBASE MESSAGING
  @lazySingleton
  FirebaseMessagingService get firebaseMessagingService =>
      FirebaseMessagingService.instance;

  // MEDIA
  @injectable
  ImagePicker get imagePicker => ImagePicker();

  @injectable
  AudioRecorder get audioRecorder => AudioRecorder();

  // SHAREF PREF
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

  @injectable
  FcmTokenService get fcmTokenService => FcmTokenService();

  @injectable // Notificaciones
  AlertaService get alertaService => AlertaService();

  // =============================================================
  // 2. REPOSITORY
  // =============================================================

  // - Auth
  @injectable
  AuthRepository get authRepository =>
      AuthRepositoryImpl(authService, sharedPref);

  // - Geolocator
  @injectable
  GeolocatorRepository get geolocatorRepository => GeolocatorRepositoryImpl();

  // - Geocoding
  @injectable
  GeocodingRepository get geocodingRepository => GeocodingRepositoryImpl();

  // - Directions
  @injectable
  DirectionsRepository get directionsRepository =>
      DirectionsRepositoryImpl(googleMapsApiKey: googleMapsApiKey);

  // - Patrullaje
  @injectable
  PatrullajeRepository patrullajeRepository(
    PatrullajeService patrullajeService,
    SocketRepository socketRepository,
  ) => PatrullajeRepositoryImpl(
    patrullajeService,
    authRepository,
    socketRepository,
  );

  // - Tracking
  @injectable
  TrackingRepository trackingRepository(SocketRepository socketRepository) =>
      TrackingRepositoryImpl(geolocatorRepository, socketRepository);

  // - Incidente
  @injectable
  IncidenteRepository get incidenteRepository =>
      IncidenteRepositoryImpl(incidenteService, authRepository);

  // - Historial patrullaje
  @injectable
  HistorialPatrullajeRepository get historialPatrullajeRepository =>
      HistorialPatrullajeRepositoryImpl(
        historialPatrullajeService,
        authRepository,
      );

  // - Users
  @injectable
  UsersRepository get usersRepository =>
      UsersRepositoryImpl(usersService, authRepository);

  // - Media audiovisla
  @injectable
  MediaRepository get mediaRepository =>
      MediaRepositoryImpl(picker: imagePicker, audioRecorder: audioRecorder);

  // - Alerta
  @injectable
  AlertRepository get alertRepository =>
      AlertRepositoryImpl(geolocatorRepository);

  // - Alerta notificaciones
  @injectable
  AlertaRepository get alertaNotificacionRepository =>
      AlertaRepositoryImpl(alertaService, fcmTokenService, authRepository);

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
    checkLocationPermission: CheckLocationPermissionUseCase(
      geolocatorRepository,
    ),
    getCurrentLocation: GetCurrentLocationUseCase(geolocatorRepository),
    getLastKnowLocation: GetLastKnowLocationUseCase(geolocatorRepository),
    getLocationStream: GetLocationStreamUseCase(geolocatorRepository),
    isLocationServiceEnable: IsLocationServiceEnableUseCase(
      geolocatorRepository,
    ),
    openAppSettings: OpenAppSettingsUseCase(geolocatorRepository),
    openLocationSettings: OpenLocationSettingsUseCase(geolocatorRepository),
    requestLocationPermission: RequestLocationPermissionUseCase(
      geolocatorRepository,
    ),
  );

  // - Geocoding
  @injectable
  GeocodingUsesCases get geocodingUsesCases => GeocodingUsesCases(
    getPlacemarkFromLocation: GetPlacemarkFromLocationUseCase(
      geocodingRepository,
    ),
  );

  // - Directions
  @injectable
  DirectionsUsesCase get directionsUsesCase =>
      DirectionsUsesCase(getRoute: GetRouteUseCase(directionsRepository));

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
    getArchivosIncidente: GetArchivoIncidenciaUseCase(incidenteRepository),
    getIncidenciaById: GetIncidenciaByIdUseCase(incidenteRepository),
    getIncidenciasByPatrullaje: GetIncidenciasByPatrullajeUseCase(
      incidenteRepository,
    ),
    getIncidenciasByZona: GetIncidenciasByZonaUseCase(incidenteRepository),
    getIncidenciasCercanas: GetIncidenciasCercanasUseCase(incidenteRepository),
    getMisIncidencias: GetMisIncidenciasUseCase(incidenteRepository),
    removeArchivoIncidente: RemoveArchivoIncidenciaUseCase(incidenteRepository),
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
    pickImage: PickImageUseCase(mediaRepository),
    pickVideo: PickVideoUseCase(mediaRepository),
    startAudioRecording: StartAudioRecordingUseCase(mediaRepository),
    startVideoRecording: StartVideoRecordingUseCase(mediaRepository),
    stopAudioRecording: StopAudioRecordingUseCase(mediaRepository),
    stopVideoRecording: StopVideoRecordingUseCase(mediaRepository),
    takePhoto: TakePhotoUseCase(mediaRepository),
  );

  // - Alertas Notificacion
  @injectable
  AlertaNotificacionUsesCases get alertaNotificacionUsesCases =>
      AlertaNotificacionUsesCases(
        desactivarDispositivo: DesactivarDispositivoUseCase(
          alertaNotificacionRepository,
        ),
        getMisAlertasResumen: GetMisAlertasResumenUseCase(
          alertaNotificacionRepository,
        ),
        getMisAlertas: GetMisAlertasUseCase(alertaNotificacionRepository),
        marcarAtendida: MarcarAtendidaUseCase(alertaNotificacionRepository),
        marcarLeida: MarcarLeidaUseCase(alertaNotificacionRepository),
        marcarRecibida: MarcarRecibidaUseCase(alertaNotificacionRepository),
        registrarDispositivo: RegistrarDispositivoUseCase(
          alertaNotificacionRepository,
        ),
        responderAlerta: ResponderAlertaUseCase(alertaNotificacionRepository),
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
