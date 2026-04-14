import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

class UpdateProfileState extends Equatable {
  final BlocFormItem name;
  final BlocFormItem lastname;
  final BlocFormItem phone;
  final GlobalKey<FormState>? formKey;

  const UpdateProfileState({
    this.name = const BlocFormItem(error: 'Ingresa el nombre'),
    this.lastname = const BlocFormItem(error: 'Ingresa el apellido'),
    this.phone = const BlocFormItem(error: 'Ingresa el teléfono'),
    this.formKey,
  });

  UpdateProfileState copyWith({
    BlocFormItem? name,
    BlocFormItem? lastname,
    BlocFormItem? phone,
    GlobalKey<FormState>? formKey,
  }) {
    return UpdateProfileState(
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      formKey: formKey,
    );
  }

  @override
  List<Object> get props => [name, lastname, phone];
}
