import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

abstract class UpdateProfileEvent {}

class ProfileUpdateInitEvent extends UpdateProfileEvent {
  final Usuario? user;
  ProfileUpdateInitEvent({required this.user});
}

class NameChanged extends UpdateProfileEvent {
  final BlocFormItem name;
  NameChanged({required this.name});
}

class LastNameChanged extends UpdateProfileEvent {
  final BlocFormItem lastname;
  LastNameChanged({required this.lastname});
}

class PhoneNumberChanged extends UpdateProfileEvent {
  final BlocFormItem phone;
  PhoneNumberChanged({required this.phone});
}

class FormSubmit extends UpdateProfileEvent {}
