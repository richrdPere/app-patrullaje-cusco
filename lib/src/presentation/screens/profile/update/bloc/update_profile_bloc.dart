import 'package:bloc/bloc.dart';
import 'package:flutter/cupertino.dart';

import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/update/bloc/update_profile_state.dart';
import 'package:sis_patrullaje_cusco/src/presentation/shared/utils/BlocFormItem.dart';

class UpdateProfileBloc extends Bloc<UpdateProfileEvent, UpdateProfileState> {
  final formKey = GlobalKey<FormState>();

  UpdateProfileBloc() : super(UpdateProfileState()) {
    on<ProfileUpdateInitEvent>((event, emit) {
      emit(
        state.copyWith(
          name: BlocFormItem(value: event.user?.nombre ?? ''),
          lastname: BlocFormItem(value: event.user?.apellidos ?? ''),
          phone: BlocFormItem(value: event.user?.telefono ?? ''),
          formKey: formKey,
        ),
      );
    });

    on<NameChanged>((event, emit) {
      emit(
        state.copyWith(
          name: BlocFormItem(
            value: event.name.value,
            error: event.name.value.isEmpty ? 'Ingresa el nombre' : null,
          ),
          formKey: formKey,
        ),
      );
    });

    on<LastNameChanged>((event, emit) {
      emit(
        state.copyWith(
          lastname: BlocFormItem(
            value: event.lastname.value,
            error: event.lastname.value.isEmpty ? 'Ingresa el apellido' : null,
          ),
          formKey: formKey,
        ),
      );
    });

    on<PhoneNumberChanged>((event, emit) {
      emit(
        state.copyWith(
          phone: BlocFormItem(
            value: event.phone.value,
            error: event.phone.value.isEmpty ? 'Ingresa el teléfono' : null,
          ),
          formKey: formKey,
        ),
      );
    });

    on<FormSubmit>((event, emit) {
      print("ENVIANDO FORM EDIT PROFILE");
      print('Name: ${state.name.value}');
      print('LastName: ${state.lastname.value}');
      print('Phone: ${state.phone.value}');
    });
  }
}
