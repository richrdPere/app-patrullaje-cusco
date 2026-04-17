import 'package:flutter/material.dart';
import 'package:equatable/equatable.dart';

// Models
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

class LoginState extends Equatable {
  final BlocFormItem username;
  final BlocFormItem password;
  final Resource? response;
  final GlobalKey<FormState>? formKey;
  final bool isLoggedOut;

  const LoginState({
    this.username = const BlocFormItem(error: 'Ingresa su Username'),
    this.password = const BlocFormItem(error: 'Ingrese su Contraseña'),
    this.formKey,
    this.response,
    this.isLoggedOut = false,
  });

  LoginState copyWith({
    BlocFormItem? username,
    BlocFormItem? password,
    Resource? response,
    GlobalKey<FormState>? formKey,
    bool? isLoggedOut,
  }) {
    return LoginState(
      username: username ?? this.username,
      password: password ?? this.password,
      formKey: formKey,
      response: response,
      isLoggedOut: isLoggedOut ?? this.isLoggedOut,
    );
  }

  @override
  List<Object?> get props => [username, password, response, isLoggedOut];
}
