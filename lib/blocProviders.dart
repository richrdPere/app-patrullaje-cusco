import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/injection.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/domain/use_cases/alerta/AlertUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/index_uses_cases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/global/bloc/sync_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/global/bloc/sync_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/alertas/bloc/alertas_bloc.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/clasificadores/bloc/clasificadores_bloc.dart';
// import 'package:sis_patrullaje_cusco/src/presentation/screens/historial_patrullaje/bloc/historial_patrullaje_event.dart';
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
import 'package:sis_patrullaje_cusco/src/presentation/screens/ocurrencias/bloc/ocurrencia_bloc.dart';
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

  // SYNC
  BlocProvider<SyncBloc>(
    create: (_) => locator<SyncBloc>()..add(const StartSyncEvent()),
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
    create: (BuildContext context) => MapaBloc(
      locator<GeolocatorUseCases>(),
      locator<GeocodingUsesCases>(),
      locator<DirectionsUsesCase>(),
    ),
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
    create: (BuildContext context) =>
        HistorialPatrullajeBloc(locator<HistorialPatrullajeUseCases>()),
  ),

  // Alertas notificacion
  BlocProvider<AlertaBloc>(
    create: (BuildContext context) =>
        AlertaBloc(locator<AlertaNotificacionUsesCases>()),
  ),

  // Clasificadores
  BlocProvider<ClasificadoresBloc>(
    create: (BuildContext context) =>
        ClasificadoresBloc(locator<ClasificadoresUsesCases>()),
  ),

  // Ocurrencia
  BlocProvider<OcurrenciaBloc>(
    create: (BuildContext context) =>
        OcurrenciaBloc(locator<OcurrenciaUsesCases>()),
  ),
];
