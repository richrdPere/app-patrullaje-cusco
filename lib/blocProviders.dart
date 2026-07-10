import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/injection.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/AlertUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/historial_patrullaje/HistorialPatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/incidente/IncidenteUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/multimedias/MultimediasUsesCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/patrullaje/PatrullajeUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/socket/SocketUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/tracking/TrackingUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/users/UsersUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/home/home_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/socket/socket_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/home/blocs/tracking/tracking_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/alerta/alerta_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/gps/gps_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/incidente/blocs/incidencia/incidente_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/loading/bloc/loading_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/logout/bloc/logout_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/splash/bloc/splash_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/screens/splash/bloc/splash_event.dart';

// import 'package:sirh_mob/injection.dart';

List<BlocProvider> blocProviders = [
  // Autenticación
  BlocProvider<LoginBloc>(
    create: (BuildContext context) =>
        LoginBloc(locator<AuthUsesCases>())..add(InitEvent()),
  ),
  BlocProvider<RegisterBloc>(
    create: (BuildContext context) =>
        RegisterBloc(locator<AuthUsesCases>())..add(RegisterInitEvent()),
  ),

  // SPLASH
  BlocProvider<SplashBloc>(
    create: (BuildContext context) =>
        SplashBloc(locator<AuthUsesCases>())..add(const SplashStarted()),
  ),

  // Socket (SIN AUTOCONECTAR)
  BlocProvider<SocketBloc>.value(value: locator<SocketBloc>()),
  // BlocProvider<SocketBloc>(
  //   create: (_) =>
  //       SocketBloc(locator<SocketUseCases>(), locator<AuthUsesCases>()),
  // ),

  // ======================================================
  // LOADING y LOGOUT
  // ======================================================
  BlocProvider<LoadingBloc>(
    create: (BuildContext context) => LoadingBloc(locator<AuthUsesCases>()),
  ),

  // ======================================================
  // SESSION
  // ======================================================
  BlocProvider<SessionBloc>(
    create: (BuildContext context) =>
        SessionBloc(), //..add(const LoadingStarted()),
  ),
  BlocProvider<LogoutBloc>(
    create: (BuildContext context) => LogoutBloc(locator<AuthUsesCases>()),
  ),

  // Profile
  // - Info
  BlocProvider<ProfileBloc>(
    create: (BuildContext context) =>
        ProfileBloc(locator<AuthUsesCases>())..add(GetUserInfo()),
  ),

  // - Edit
  BlocProvider<UpdateProfileBloc>(
    create: (BuildContext context) =>
        UpdateProfileBloc(locator<UsersUseCases>()),
  ),

  // GPS y Mapa
  BlocProvider<GpsBloc>(create: (BuildContext context) => GpsBloc()),
  BlocProvider<MapaBloc>(
    create: (BuildContext context) => MapaBloc(locator<GeolocatorUseCases>()),
  ),

  BlocProvider<MapaIncidentBloc>(
    create: (BuildContext context) =>
        MapaIncidentBloc(locator<GeolocatorUseCases>()),
  ),

  // Home y Tracking
  BlocProvider<HomeBloc>(
    create: (BuildContext context) => HomeBloc(locator<PatrullajeUseCases>()),
  ),

  BlocProvider<TrackingBloc>(
    create: (BuildContext context) => TrackingBloc(locator<TrackingUseCases>()),
  ),

  // Alert
  BlocProvider<AlertBloc>(
    create: (BuildContext context) => AlertBloc(locator<SocketUseCases>()),
  ),

  // Incident
  BlocProvider<IncidenteBloc>(
    create: (BuildContext context) => IncidenteBloc(
      locator<IncidenteUseCases>(),
      locator<GeolocatorUseCases>(),
      locator<MultimediasUseCases>(),
      locator<HistorialPatrullajeUseCases>(),
    ),
  ),

  // Historial patrullaje
  BlocProvider<HistorialPatrullajeBloc>(
    create: (BuildContext context) => HistorialPatrullajeBloc(
      locator<HistorialPatrullajeUseCases>(),
      locator<PatrullajeUseCases>(),
    )..add(LoadHistorialPatrullajeEvent()),
  ),
];
