// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:image_picker/image_picker.dart' as _i183;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart'
    as _i118;
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/index_service.dart'
    as _i506;
import 'package:sis_patrullaje_cusco/src/di/AppModule.dart' as _i1038;
import 'package:sis_patrullaje_cusco/src/domain/repositories/index_repository.dart'
    as _i224;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart'
    as _i422;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart'
    as _i952;
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
    gh.factory<_i118.SharefPref>(() => appModule.sharedPref);
    gh.factory<_i506.AuthService>(() => appModule.authService);
    gh.factory<_i506.UsersService>(() => appModule.usersService);
    gh.factory<_i506.PatrullajeService>(() => appModule.patrullajeService);
    gh.factory<_i506.IncidenciaService>(() => appModule.incidenteService);
    gh.factory<_i506.HistorialPatrullajeService>(
      () => appModule.historialPatrullajeService,
    );
    gh.factory<_i224.AuthRepository>(() => appModule.authRepository);
    gh.factory<_i224.GeolocatorRepository>(
      () => appModule.geolocatorRepository,
    );
    gh.factory<_i224.IncidenteRepository>(() => appModule.incidenteRepository);
    gh.factory<_i224.HistorialPatrullajeRepository>(
      () => appModule.historialPatrullajeRepository,
    );
    gh.factory<_i224.UsersRepository>(() => appModule.usersRepository);
    gh.factory<_i224.MediaRepository>(() => appModule.mediaRepository);
    gh.factory<_i224.AlertRepository>(() => appModule.alertRepository);
    gh.factory<_i952.AuthUsesCases>(() => appModule.authUseCases);
    gh.factory<_i952.GeolocatorUseCases>(() => appModule.geolocatorUseCases);
    gh.factory<_i952.AlertUseCases>(() => appModule.alertUseCases);
    gh.factory<_i952.IncidenteUseCases>(() => appModule.incidentUseCases);
    gh.factory<_i952.HistorialPatrullajeUseCases>(
      () => appModule.historialPatrullajeUseCases,
    );
    gh.factory<_i952.UsersUseCases>(() => appModule.usersUseCases);
    gh.factory<_i952.MultimediasUseCases>(() => appModule.multimediasUseCases);
    gh.lazySingleton<_i224.SocketRepository>(
      () => appModule.socketRepository(),
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
    gh.factory<_i224.TrackingRepository>(
      () => appModule.trackingRepository(gh<_i224.SocketRepository>()),
    );
    gh.lazySingleton<_i952.SocketUseCases>(
      () => appModule.socketUseCases(gh<_i224.SocketRepository>()),
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
    return this;
  }
}

class _$AppModule extends _i1038.AppModule {}
