import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/login/bloc/login_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

class LoginBloc extends Bloc<LoginEvent, LoginState> {
  AuthUsesCases authUsesCases;

  LoginBloc(this.authUsesCases) : super(LoginState()) {
    on<InitEvent>(_onInitEvent);
    on<UsernameChanged>(_onUsernameChanged);
    on<PasswordChanged>(_onPasswordChanged);
    on<LoginSubmit>(_onLoginSubmit);
    on<LoginFormReset>(_onLoginFormReset);
    on<SaveUserSession>(_onSaveUserSession);
    on<LogoutEvent>(_onLogoutEvent);
  }

  final formKey = GlobalKey<FormState>();

  // FUNCIONES
  Future<void> _onInitEvent(InitEvent event, Emitter<LoginState> emit) async {
    AuthResponse? authResponse = await authUsesCases.getUserSession.run();
    emit(state.copyWith(formKey: formKey));

    // print("Auth response session: ${authResponse?.toJson()}");

    // Usuario Inicio sesion
    if (authResponse != null) {
      // Usuario con sesión
      emit(
        state.copyWith(
          response: Success(authResponse), // AuthResponse -> user, token
          formKey: formKey,
          isLoggedOut: false,
        ),
      );
    }
    // Usuario no inicio sesion
    else {
      // Usuario SIN sesión (CLAVE)
      emit(state.copyWith(response: null, isLoggedOut: true, formKey: formKey));
    }
  }

  Future<void> _onSaveUserSession(
    SaveUserSession event,
    Emitter<LoginState> emit,
  ) async {
    await authUsesCases.saveUserSession.run(event.authResponse);
  }

  Future<void> _onLoginFormReset(
    LoginFormReset event,
    Emitter<LoginState> emit,
  ) async {
    state.formKey?.currentState?.reset();
  }

  Future<void> _onUsernameChanged(
    UsernameChanged event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        username: BlocFormItem(
          value: event.username.value,
          error: event.username.value.isNotEmpty ? null : 'Ingrese su Username',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onPasswordChanged(
    PasswordChanged event,
    Emitter<LoginState> emit,
  ) async {
    emit(
      state.copyWith(
        password: BlocFormItem(
          value: event.password.value,
          error:
              event.password.value.isNotEmpty &&
                  event.password.value.length >= 5
              ? null
              : 'Ingrese su Contraseña',
        ),
        formKey: formKey,
      ),
    );
  }

  Future<void> _onLoginSubmit(
    LoginSubmit event,
    Emitter<LoginState> emit,
  ) async {
    emit(state.copyWith(response: Loading(), formKey: formKey));
    Resource<AuthResponse> response = await authUsesCases.login.run(
      state.username.value,
      state.password.value,
    );

    if (response is Success<AuthResponse>) {
      // Guardar sesión automáticamente
      await authUsesCases.saveUserSession.run(response.data);
    }

    emit(
      state.copyWith(response: response, formKey: formKey, isLoggedOut: false),
    );
  }

  Future<void> _onLogoutEvent(
    LogoutEvent event,
    Emitter<LoginState> emit,
  ) async {
    await authUsesCases.logoutSession.run();

    // emit(state.copyWith(response: null, isLoggedOut: true));
    emit(LoginState(formKey: formKey, isLoggedOut: true));
  }
}
