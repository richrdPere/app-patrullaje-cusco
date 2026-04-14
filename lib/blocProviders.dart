import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/injection.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/geolocator/GeolocatorUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/gps/gps_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa/mapa_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/mapa/blocs/mapa_incident/mapa_incident_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_bloc.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_bloc.dart';

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
  // BlocProvider<RolesBloc>(
  //   create: (BuildContext context) => RolesBloc(locator<AuthUsesCases>()),
  // ),

  // Profile
  // - Info
  BlocProvider<ProfileBloc>(
    create: (BuildContext context) =>
        ProfileBloc(locator<AuthUsesCases>())..add(GetUserInfo()),
  ),

  // - Edit
  BlocProvider<UpdateProfileBloc>(
    create: (BuildContext context) => UpdateProfileBloc(),
  ),

  // GPS
  BlocProvider<GpsBloc>(create: (BuildContext context) => GpsBloc()),
  BlocProvider<MapaBloc>(
    create: (BuildContext context) =>
        MapaBloc(locator<GeolocatorUseCases>()),
  ),

   BlocProvider<MapaIncidentBloc>(
    create: (BuildContext context) =>
        MapaIncidentBloc(locator<GeolocatorUseCases>()),
  ),
];
