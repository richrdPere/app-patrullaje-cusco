import 'package:equatable/equatable.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

abstract class RegisterEvent extends Equatable {
  const RegisterEvent();

  // Props
  @override
  List<Object?> get props => [];
}

class RegisterInitEvent extends RegisterEvent {
  const RegisterInitEvent();
}

// *************************************************
// 1.- FUNCIONES CHANGED
// *************************************************
// Name Changed
class RegisterNameChanged extends RegisterEvent {
  final BlocFormItem name;
  const RegisterNameChanged({required this.name});
  @override
  List<Object?> get props => [name];
}
// Lastname Changed
class RegisterLastnameChanged extends RegisterEvent {
  final BlocFormItem lastname;
  const RegisterLastnameChanged({required this.lastname});
  @override
  List<Object?> get props => [lastname];
}
// Email Changed
class RegisterEmailChanged extends RegisterEvent {
  final BlocFormItem email;
  const RegisterEmailChanged({required this.email});
  @override
  List<Object?> get props => [email];
}
// Phone Changed
class RegisterPhoneChanged extends RegisterEvent {
  final BlocFormItem phone;
  const RegisterPhoneChanged({required this.phone});
  @override
  List<Object?> get props => [phone];
}
// DNI Changed
class RegisterDNIChanged extends RegisterEvent {
  final BlocFormItem dni;
  const RegisterDNIChanged({required this.dni});
  @override
  List<Object?> get props => [dni];
}
// Username Changed
class RegisterUsernameChanged extends RegisterEvent {
  final BlocFormItem username;
  const RegisterUsernameChanged({required this.username});
  @override
  List<Object?> get props => [username];
}
// Password Changed
class RegisterPasswordChanged extends RegisterEvent {
  final BlocFormItem password;
  const RegisterPasswordChanged({required this.password});
  @override
  List<Object?> get props => [password];
}
// Confirm Password Changed
class RegisterConfirmPasswordChanged extends RegisterEvent {
  final BlocFormItem confirmPassword;
  const RegisterConfirmPasswordChanged({required this.confirmPassword});
  @override
  List<Object?> get props => [confirmPassword];
}

// *************************************************
// 2.- Envio del Formulario
// *************************************************
// Envio de Register Form
class RegisterFormSubmit extends RegisterEvent {
  const RegisterFormSubmit();
}
// Reset de Register Form
class RegisterFormReset extends RegisterEvent {
  const RegisterFormReset();
}