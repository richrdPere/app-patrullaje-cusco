// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart'
    as _i118;
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/auth_service.dart'
    as _i501;
import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/patrullaje_service.dart'
    as _i647;
import 'package:sis_patrullaje_cusco/src/di/AppModule.dart' as _i1038;
import 'package:sis_patrullaje_cusco/src/domain/repositories/alert_repository.dart'
    as _i574;
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart'
    as _i606;
import 'package:sis_patrullaje_cusco/src/domain/repositories/geolocator_repository.dart'
    as _i175;
import 'package:sis_patrullaje_cusco/src/domain/repositories/patrullaje_repository.dart'
    as _i313;
import 'package:sis_patrullaje_cusco/src/domain/repositories/socket_repository.dart'
    as _i481;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/AlertUseCases.dart'
    as _i607;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart'
    as _i422;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart'
    as _i549;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart'
    as _i1030;
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart'
    as _i427;
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart'
    as _i362;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final appModule = _$AppModule();
    gh.factory<_i501.AuthService>(() => appModule.authService);
    gh.factory<_i118.SharefPref>(() => appModule.sharedPref);
    gh.factory<_i606.AuthRepository>(() => appModule.authRepository);
    gh.factory<_i175.GeolocatorRepository>(
      () => appModule.geolocatorRepository,
    );
    gh.factory<_i313.PatrullajeRepository>(
      () => appModule.patrullajeRepository,
    );
    gh.factory<_i647.PatrullajeService>(() => appModule.patrullajeService);
    gh.factory<_i422.AuthUsesCases>(() => appModule.authUseCases);
    gh.factory<_i549.GeolocatorUseCases>(() => appModule.geolocatorUseCases);
    gh.factory<_i1030.PatrullajeUseCases>(() => appModule.patrullajeUseCases);
    gh.factory<_i607.AlertUseCases>(() => appModule.alertUseCases);
    gh.factory<_i574.AlertRepository>(() => appModule.alertRepository);
    gh.lazySingleton<_i481.SocketRepository>(
      () => appModule.socketRepository(),
    );
    gh.lazySingleton<_i427.SocketUseCases>(
      () => appModule.socketUseCases(gh<_i481.SocketRepository>()),
    );
    gh.lazySingleton<_i362.SocketBloc>(
      () => appModule.socketBloc(
        gh<_i427.SocketUseCases>(),
        gh<_i422.AuthUsesCases>(),
      ),
    );
    return this;
  }
}

class _$AppModule extends _i1038.AppModule {}
