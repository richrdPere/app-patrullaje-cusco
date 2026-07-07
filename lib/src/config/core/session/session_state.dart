import 'package:sis_patrullaje_cusco/src/data/models/login/auth_response.dart';

class SessionState {
  final AuthResponse? user;
  final bool isAuthenticated;
  final bool isChecking;

  SessionState({
    this.user,
    this.isAuthenticated = false,
    this.isChecking = false,
  });

  SessionState copyWith({
    AuthResponse? user,
    bool? isAuthenticated,
    bool? isChecking,
  }) {
    return SessionState(
      user: user ?? this.user,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isChecking: isChecking ?? this.isChecking,
    );
  }
}
