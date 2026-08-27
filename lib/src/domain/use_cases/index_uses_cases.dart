// =======================================
// ALERTAS
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/alerta_use_case/SendAlertUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/AlertUseCases.dart';

// =======================================
// AUTH
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/GetUserSessionUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LoginUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LogoutUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/RegisterUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/SaveUserSessionUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';

// =======================================
// GEOLOCATOR
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/CheckLocationPermissionUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetCurrentLocationUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetLastKnowLocationUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/GetLocationStreamUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/IsLocationServiceEnableUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/OpenAppSettingsUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/OpenLocationSettingsUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/geolocator_use_cases/RequestLocationPermissionUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';

// =======================================
// HISTORIAL PATRULLAJE
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/ArchivarHistorialUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/CreateHistorialUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/CreateObservacionConArchivosUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetContextoZonaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetHistorialByIdUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetHistorialByPatrullajeUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/GetParaSiguienteTurnoUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/historial_patrullaje_use_cases/UpdateHistorialUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';

// =======================================
// INCIDENTE
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/AddArchivosIncidenciaUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/CreateIncidenteUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetArchivosIncidenciaUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciaByIdUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciasByPatrullajeUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciasByZonaUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetIncidenciasCercanasUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/GetMisIncidenciasUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/incidente_use_cases/RemoveEvidenciaIncidenteUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';

// =======================================
// MULTIMEDIAS
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/PickImageUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/PickVideoUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StartAudioRecordingUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StartVideoRecordingUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StopAudioRecordingUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/StopVideoRecordingUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/multimedias_use_case/TakePhotoUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';

// =======================================
// PATRULLAJE
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/EndPatrullajeSocketUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/EndPatrullajeUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/GetMisPatrullajesPaginadosUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/GetPatrullajeActivoUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/JoinPatrullajeUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/LeavePatrullajeUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenNewPatrullajeUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenPatrullajeActualizadoUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/ListenPatrullajeEndUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/SendLocationUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/StartPatrullajeSocketUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/patrullaje_use_cases/StartPatrullajeUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';

// =======================================
// SOCKET
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/ConnectSocketUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/DisconnetSocketUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/socket_use_Cases/GetSocketUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';

// =======================================
// TRACKING
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/tracking_use_case/GetLocationUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/tracking_use_case/SendLocationUserUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/tracking_use_case/SyncPendingLocationsUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/TrackingUseCases.dart';

// =======================================
// USERS
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/users/users_uses_cases/UpdateUserUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/users/UsersUseCases.dart';

// =======================================
// GEOCODING
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geocoding/geocoding_uses_cases/GetPlacemarkFromLocationUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/geocoding/GeocodingUsesCases.dart';

// =======================================
// DIRECTIONS
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/directions/directions_uses_cases/GetRouteUseCase.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/directions/DirectionsUsesCase.dart';

// =======================================
// ALERTAS - NOTIFICACIONES
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/ActivarAlertaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/cancelarAlertaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/DesactivarDispositivoUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/GetAlertaActivaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/GetAlertaDetalleUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/GetMisAlertasResumenUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/GetMisAlertasUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/MarcarAtendidaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/MarcarLeidaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/MarcarRecibidaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/RegistrarDispositivoUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/alerta_notificacion_uses_cases/ResponderAlertaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta_notificacion/AlertaNotificacionUsesCases.dart';

// =======================================
// CLASIFICADORES
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/clasificadores/clasificadores_uses_cases/GetClasificadorArbolUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/clasificadores/clasificadores_uses_cases/GetClasificadorByCodigoUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/clasificadores/clasificadores_uses_cases/GetClasificadoresPaginadoUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/clasificadores/ClasificadoresUsesCases.dart';

// =======================================
// OCURRENCIAS
// =======================================
export 'package:sis_patrullaje_cusco/src/domain/use_cases/ocurrencias/ocurrencia_uses_cases/CreateOcurrenciaUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/ocurrencias/ocurrencia_uses_cases/GetOcurrenciaByIdUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/ocurrencias/ocurrencia_uses_cases/GetOcurrenciaPdfUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/ocurrencias/ocurrencia_uses_cases/GetOcurrenciasPaginadoUC.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/ocurrencias/OcurrenciaUsesCases.dart';
export 'package:sis_patrullaje_cusco/src/domain/use_cases/ocurrencias/ocurrencia_uses_cases/GetIncidenciasSelectorUC.dart';
