import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';




// Register Event y State
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/auth/register/bloc/register_state.dart';

// Auth Uses Cases
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';

// Bloc_Form_Items
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';


class RegisterBloc extends Bloc<RegisterEvent, RegisterState> {
  AuthUsesCases authUsesCases;

  RegisterBloc(this.authUsesCases) : super(RegisterState()) {
    on<RegisterInitEvent>(_onInitEvent);
    on<RegisterNameChanged>(_onNameChanged);
    on<RegisterLastnameChanged>(_onLastnameChanged);
    on<RegisterEmailChanged>(_onEmailChanged);
    on<RegisterPhoneChanged>(_onPhoneChanged);
    on<RegisterDNIChanged>(_onDniChanged);
    on<RegisterUsernameChanged>(_onUsernameChanged);
    on<RegisterPasswordChanged>(_onPasswordChanged);
    on<RegisterConfirmPasswordChanged>(_onConfirmPasswordChanged);
    on<RegisterFormSubmit>(_onFormSubmit);
    on<RegisterFormReset>(_onFormReset);
  }

  final formKey = GlobalKey<FormState>();

  // Funcion Principal
  Future<void> _onInitEvent(
    RegisterInitEvent event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(formKey: formKey));
  }

  // *************************************************
  // 1.- Eventos Changed
  // *************************************************
  // Name
  Future<void> _onNameChanged(
    RegisterNameChanged event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        name: BlocFormItem(
          value: event.name.value,
          error: event.name.value.isNotEmpty
              ? null
              : 'Ingrese su Nombre completo',
        ),
        formKey: formKey,
      ),
    );
  }

  // Lastname
  Future<void> _onLastnameChanged(
    RegisterLastnameChanged event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        lastname: BlocFormItem(
          value: event.lastname.value,
          error: event.lastname.value.isNotEmpty
              ? null
              : 'Ingrese sus Apellidos',
        ),
        formKey: formKey,
      ),
    );
  }

  // Email
  Future<void> _onEmailChanged(
    RegisterEmailChanged event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        email: BlocFormItem(
          value: event.email.value,
          error: event.email.value.isNotEmpty ? null : 'Ingrese su Email',
        ),
        formKey: formKey,
      ),
    );
  }

  // Phone
  Future<void> _onPhoneChanged(
    RegisterPhoneChanged event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        phone: BlocFormItem(
          value: event.phone.value,
          error: event.phone.value.isNotEmpty ? null : 'Ingrese su Teléfono',
        ),
        formKey: formKey,
      ),
    );
  }

  // DNI
  Future<void> _onDniChanged(
    RegisterDNIChanged event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        dni: BlocFormItem(
          value: event.dni.value,
          error: event.dni.value.isNotEmpty ? null : 'Ingrese su DNI',
        ),
        formKey: formKey,
      ),
    );
  }

  // Username
  Future<void> _onUsernameChanged(
    RegisterUsernameChanged event,
    Emitter<RegisterState> emit,
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

  // Password
  Future<void> _onPasswordChanged(
    RegisterPasswordChanged event,
    Emitter<RegisterState> emit,
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

  // Confirm Password
  Future<void> _onConfirmPasswordChanged(
    RegisterConfirmPasswordChanged event,
    Emitter<RegisterState> emit,
  ) async {
    emit(
      state.copyWith(
        confirmPassword: BlocFormItem(
          value: event.confirmPassword.value,
          error:
              event.confirmPassword.value.isNotEmpty &&
                  event.confirmPassword.value.length >= 5
              ? null
              : 'Confirme su Contraseña',
        ),
        formKey: formKey,
      ),
    );
  }

  // *************************************************
  // 2.- Eventos Submit y Reset
  // *************************************************
  // Submit
  Future<void> _onFormSubmit(
    RegisterFormSubmit event,
    Emitter<RegisterState> emit,
  ) async {
    emit(state.copyWith(response: Loading(), formKey: formKey));
    Resource<AuthResponse> response = await authUsesCases.register.run(
      state.toUser(),
    );
    emit(state.copyWith(response: response, formKey: formKey));
  }

  // Reset
  Future<void> _onFormReset(
    RegisterFormReset event,
    Emitter<RegisterState> emit,
  ) async {
    state.formKey?.currentState?.reset();
  }
}
