import 'package:equatable/equatable.dart';
import 'package:flutter/cupertino.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/persona_model.dart';
import 'package:sis_patrullaje_cusco/src/domain/models/usuarios.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

class UpdateProfileState extends Equatable {
  final int id;
  final BlocFormItem name;
  final BlocFormItem lastname;
  final BlocFormItem phone;
  final Resource? response;
  final GlobalKey<FormState>? formKey;

  toUser() => Usuario(
    id: id,
    username: '',
    correo: '',
    estado: true,
    persona: Persona(
      id: 0,
      documentoIdentidad: '',
      nombres: name.value,
      apellidos: lastname.value,
      telefono: phone.value,
    ),
  );

  const UpdateProfileState({
    this.id = 0,
    this.name = const BlocFormItem(error: 'Ingresa el nombre'),
    this.lastname = const BlocFormItem(error: 'Ingresa el apellido'),
    this.phone = const BlocFormItem(error: 'Ingresa el teléfono'),
    this.response,
    this.formKey,
  });

  UpdateProfileState copyWith({
    int? id,
    BlocFormItem? name,
    BlocFormItem? lastname,
    BlocFormItem? phone,
    GlobalKey<FormState>? formKey,
    Resource? response,
  }) {
    return UpdateProfileState(
      id: id ?? this.id,
      name: name ?? this.name,
      lastname: lastname ?? this.lastname,
      phone: phone ?? this.phone,
      formKey: formKey,
      response: response,
    );
  }

  @override
  List<Object?> get props => [id, name, lastname, phone, response];
}
