import 'package:equatable/equatable.dart';

// Utils

import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

abstract class LoginEvent extends Equatable {
  const LoginEvent();

  @override
  List<Object?> get props => [];
}

class InitEvent extends LoginEvent {
  const InitEvent();
}

// Reset campos
class LoginFormReset extends LoginEvent {
  const LoginFormReset();
}

// Login Save User Session
class SaveUserSession extends LoginEvent {
  final AuthResponse authResponse;
  const SaveUserSession({required this.authResponse});
  @override
  List<Object?> get props => [authResponse];
}

// Username Changed
class UsernameChanged extends LoginEvent {
  final BlocFormItem username;
  const UsernameChanged({required this.username});
  @override
  List<Object?> get props => [username];
}

// Password Changed
class PasswordChanged extends LoginEvent {
  final BlocFormItem password;
  const PasswordChanged({required this.password});
  @override
  List<Object?> get props => [password];
}

// Login Submit
class LoginSubmit extends LoginEvent {
  const LoginSubmit();
}

