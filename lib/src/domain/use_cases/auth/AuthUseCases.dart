import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/GetUserSessionUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LoginUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/LogoutUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/RegisterUseCase.dart';
import 'package:sis_patrullaje_cusco/src/domain/use_cases/auth/auth_use_cases/SaveUserSessionUseCase.dart';

class AuthUsesCases {
  LoginUseCase login;
  RegisterUseCase register;
  SaveUserSessionUseCase saveUserSession;
  GetUserSessionUseCase getUserSession;
  LogoutUseCase logoutSession;

  AuthUsesCases({
    required this.login,
    required this.register,
    required this.saveUserSession,
    required this.getUserSession,
    required this.logoutSession
  });
}
