import 'package:bloc/bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_event.dart';
import 'package:sis_patrullaje_cusco/src/presentation/screens/profile/info/bloc/profile_state.dart';

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  AuthUsesCases authUsesCases;

  ProfileBloc(this.authUsesCases) : super(ProfileState()) {
    on<GetUserInfo>((event, emit) async {
      AuthResponse authResponse = await authUsesCases.getUserSession.run();

      emit(state.copyWith(user: authResponse.usuario));
    });
  }
}
