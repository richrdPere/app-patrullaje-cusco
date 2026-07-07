import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/AuthUseCases.dart';

import 'logout_event.dart';
import 'logout_state.dart';

class LogoutBloc extends Bloc<LogoutEvent, LogoutState> {
  final AuthUsesCases authUsesCases;

  LogoutBloc(this.authUsesCases) : super(LogoutInitial()) {
    on<LogoutRequested>(_logout);
  }

  Future<void> _logout(LogoutRequested event, Emitter<LogoutState> emit) async {
    emit(LogoutLoading());

    try {
      await authUsesCases.logoutSession.run();

      /// Simular carga 
      /// Posteriormente aquí irán las llamadas al backend
      await Future.delayed(const Duration(seconds: 2));

      emit(LogoutSuccess());
    } catch (e) {
      emit(LogoutFailure(e.toString()));
    }
  }
}
