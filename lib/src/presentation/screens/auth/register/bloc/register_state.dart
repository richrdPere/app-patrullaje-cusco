import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';


// Resource
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

// Bloc_Form_Item
import 'package:sis_patrullaje_cusco/src/domain/entities/user_entity.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

class RegisterState extends Equatable {
  final BlocFormItem name;
  final BlocFormItem lastname;
  final BlocFormItem email;
  final BlocFormItem phone;
  final BlocFormItem dni;
  final BlocFormItem username;
  final BlocFormItem password;
  final BlocFormItem confirmPassword;

  final GlobalKey<FormState>? formKey;
  final Resource? response;

  // Constructor
  const RegisterState({
    this.name = const BlocFormItem(error: 'Ingrese su nombre completo'),
    this.lastname = const BlocFormItem(error: 'Ingrese sus apellidos'),
    this.email = const BlocFormItem(error: 'Ingrese su email'),
    this.phone = const BlocFormItem(error: 'Ingrese su teléfono'),
    this.dni = const BlocFormItem(error: 'Ingrese su DNI'),
    this.username = const BlocFormItem(),
    this.password = const BlocFormItem(error: 'Ingrese una contraseña'),
    this.confirmPassword = const BlocFormItem(error: 'Confirme su contraseña'),
    this.formKey,
    this.response,
  });

  // Metodos
  toUser() => UserEntity(
    firstName: name.value,
    lastName: lastname.value,
    email: email.value,
    phone: phone.value,
    dni: dni.value,
    username: dni.value,
    password: password.value,
    role: 'sereno',
  );

  RegisterState copyWith({
    BlocFormItem? name,
    BlocFormItem? lastname,
    BlocFormItem? email,
    BlocFormItem? phone,
    BlocFormItem? dni,
    BlocFormItem? username,
    BlocFormItem? password,
    BlocFormItem? confirmPassword,
    GlobalKey<FormState>? formKey,
    Resource? response,
  }) {
    return RegisterState(
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      dni: dni ?? this.dni,
      username: username ?? this.username,
      password: password ?? this.password,
      confirmPassword: confirmPassword ?? this.confirmPassword,
      formKey: formKey,
      response: response,
    );
  }

  // Props
  @override
  List<Object?> get props => [
    name,
    lastname,
    email,
    phone,
    dni,
    username,
    password,
    confirmPassword,
    response,
  ];
}
