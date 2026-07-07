import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:sis_patrullaje_cusco/src/config/core/session/session_state.dart';
import 'package:sis_patrullaje_cusco/src/data/models/login/auth_response.dart';

class SessionBloc extends Cubit<SessionState> {
  SessionBloc() : super(SessionState());

  void updateSession(AuthResponse session) {
    emit(SessionState(user: session, isAuthenticated: true));
  }

  void logout() {
    emit(SessionState(user: null, isAuthenticated: false));
  }
}
