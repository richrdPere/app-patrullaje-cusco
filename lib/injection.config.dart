// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:connectivity_plus/connectivity_plus.dart' as _i895;
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:record/record.dart' as _i1039;
import 'package:sis_patrullaje_cusco/src/config/core/sync/sync_manager.dart'
    as _i674;
import 'package:sis_patrullaje_cusco/src/data/datasources/local/index_local.dart'
    as _i842;
import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart'
    as _i118;
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/index_service.dart'
    as _i506;
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/connectivity_service.dart'
    as _i415;
import 'package:sis_patrullaje_cusco/src/di/AppModule.dart' as _i1038;
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart'
    as _i224;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart'
    as _i422;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart'
    as _i952;
import 'package:sis_patrullaje_cusco/src/presentation/global/bloc/sync_bloc.dart'
    as _i900;
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart'
    as _i362;
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/loading/bloc/loading_bloc.dart'
    as _i318;
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/splash/bloc/splash_bloc.dart'
    as _i717;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.factory<_i183.ImagePicker>(() => appModule.imagePicker);
    gh.factory<_i1039.AudioRecorder>(() => appModule.audioRecorder);
    gh.factory<_i118.SharefPref>(() => appModule.sharedPref);
    gh.factory<_i506.AuthService>(() => appModule.authService);
    gh.factory<_i506.UsersService>(() => appModule.usersService);
    gh.factory<_i506.PatrullajeService>(() => appModule.patrullajeService);
    gh.factory<_i506.IncidenciaService>(() => appModule.incidenteService);
    gh.factory<_i506.HistorialPatrullajeService>(
      () => appModule.historialPatrullajeService,
    );
    gh.factory<_i506.FcmTokenService>(() => appModule.fcmTokenService);
    gh.factory<_i842.AlertaService>(() => appModule.alertaService);
    gh.factory<_i506.ClasificadoresService>(
      () => appModule.clasificadoresService,
    );
    gh.factory<_i506.OcurrenciaService>(() => appModule.ocurrenciaService);
    gh.factory<_i224.AuthRepository>(() => appModule.authRepository);
    gh.factory<_i224.GeolocatorRepository>(
      () => appModule.geolocatorRepository,
    );
    gh.factory<_i224.GeocodingRepository>(() => appModule.geocodingRepository);
    gh.factory<_i224.DirectionsRepository>(
      () => appModule.directionsRepository,
    );
    gh.factory<_i224.IncidenteRepository>(() => appModule.incidenteRepository);
    gh.factory<_i224.HistorialPatrullajeRepository>(
      () => appModule.historialPatrullajeRepository,
    );
    gh.factory<_i224.UsersRepository>(() => appModule.usersRepository);
    gh.factory<_i224.MediaRepository>(() => appModule.mediaRepository);
    gh.factory<_i224.AlertRepository>(() => appModule.alertRepository);
    gh.factory<_i224.AlertaRepository>(
      () => appModule.alertaNotificacionRepository,
    );
    gh.factory<_i224.ClasificadoresRepository>(
      () => appModule.clasificadoresRepository,
    );
    gh.factory<_i224.OcurrenciasRepository>(
      () => appModule.ocurrenciasRepository,
    );
    gh.factory<_i952.AuthUsesCases>(() => appModule.authUseCases);
    gh.factory<_i952.GeolocatorUseCases>(() => appModule.geolocatorUseCases);
    gh.factory<_i952.GeocodingUsesCases>(() => appModule.geocodingUsesCases);
    gh.factory<_i952.DirectionsUsesCase>(() => appModule.directionsUsesCase);
    gh.factory<_i952.AlertUseCases>(() => appModule.alertUseCases);
    gh.factory<_i952.IncidenteUseCases>(() => appModule.incidentUseCases);
    gh.factory<_i952.HistorialPatrullajeUseCases>(
      () => appModule.historialPatrullajeUseCases,
    );
    gh.factory<_i952.UsersUseCases>(() => appModule.usersUseCases);
    gh.factory<_i952.MultimediasUseCases>(() => appModule.multimediasUseCases);
    gh.factory<_i952.AlertaNotificacionUsesCases>(
      () => appModule.alertaNotificacionUsesCases,
    );
    gh.factory<_i952.ClasificadoresUsesCases>(
      () => appModule.clasificadoresUsesCases,
    );
    gh.factory<_i952.OcurrenciaUsesCases>(() => appModule.ocurrenciaUsesCases);
    gh.lazySingleton<_i506.FirebaseMessagingService>(
      () => appModule.firebaseMessagingService,
    );
    gh.lazySingleton<_i842.AppDatabasePatrullaje>(
      () => appModule.appDatabasePatrullaje,
    );
    gh.lazySingleton<_i224.SocketRepository>(
      () => appModule.socketRepository(),
    );
    gh.lazySingleton<_i895.Connectivity>(() => appModule.connectivity());
    gh.factory<String>(
      () => appModule.googleMapsApiKey,
      instanceName: 'googleMapsApiKey',
    );
    gh.lazySingleton<_i842.UbicacionPendienteDao>(
      () => appModule.ubicacionPendienteDao(gh<_i842.AppDatabasePatrullaje>()),
    );
    gh.lazySingleton<_i842.IncidenciaPendienteDao>(
      () => appModule.incidenciaPendienteDao(gh<_i842.AppDatabasePatrullaje>()),
    );
    gh.lazySingleton<_i842.EvidenciaPendienteDao>(
      () => appModule.evidenciaPendienteDao(gh<_i842.AppDatabasePatrullaje>()),
    );
    gh.lazySingleton<_i415.ConnectivityService>(
      () => appModule.connectivityService(gh<_i895.Connectivity>()),
    );
    gh.factory<_i318.LoadingBloc>(
      () => _i318.LoadingBloc(gh<_i422.AuthUsesCases>()),
    );
    gh.factory<_i717.SplashBloc>(
      () => _i717.SplashBloc(gh<_i422.AuthUsesCases>()),
    );
    gh.factory<_i224.PatrullajeRepository>(
      () => appModule.patrullajeRepository(
        gh<_i506.PatrullajeService>(),
        gh<_i224.SocketRepository>(),
      ),
    );
    gh.lazySingleton<_i674.SyncManager>(
      () => appModule.syncManager(gh<_i415.ConnectivityService>()),
    );
    gh.factory<_i224.TrackingRepository>(
      () => appModule.trackingRepository(gh<_i224.SocketRepository>()),
    );
    gh.lazySingleton<_i952.SocketUseCases>(
      () => appModule.socketUseCases(gh<_i224.SocketRepository>()),
    );
    gh.lazySingleton<_i842.IncidenciaOfflineDao>(
      () => appModule.incidenciaOfflineDao(
        gh<_i842.AppDatabasePatrullaje>(),
        gh<_i842.IncidenciaPendienteDao>(),
        gh<_i842.EvidenciaPendienteDao>(),
      ),
    );
    gh.lazySingleton<_i362.SocketBloc>(
      () => appModule.socketBloc(
        gh<_i952.SocketUseCases>(),
        gh<_i952.AuthUsesCases>(),
      ),
    );
    gh.factory<_i952.PatrullajeUseCases>(
      () => appModule.patrullajeUseCases(gh<_i224.PatrullajeRepository>()),
    );
    gh.factory<_i952.TrackingUseCases>(
      () => appModule.trackingUseCases(gh<_i224.TrackingRepository>()),
    );
    gh.factory<_i900.SyncBloc>(
      () => appModule.syncBloc(gh<_i674.SyncManager>()),
    );
    return this;
  }
}

class _$AppModule extends _i1038.AppModule {}
