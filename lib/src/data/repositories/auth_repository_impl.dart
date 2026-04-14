import 'package:shared_preferences/shared_preferences.dart';
import 'package:sis_patrullaje_cusco/src/data/datasources/local/SharefPref.dart';

import 'package:sis_patrullaje_cusco/src/data/datasources/remote/services/auth_service.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/user_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/repositories/auth_repository.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthService _authService;
  SharefPref sharedPref;

  AuthRepositoryImpl(this._authService, this.sharedPref);

  @override
  Future<Resource<AuthResponse>> login(String username, String password) {
    return _authService.login(username, password);
  }

  @override
  Future<AuthResponse> register(UserEntity user) {
    // TODO: implement register
    throw UnimplementedError();
  }

  @override
  Future<bool> logout() async {
    final prefs = await SharedPreferences.getInstance();

    return await prefs.remove("user");
  }

  @override
  Future<AuthResponse?> getUserSession() async {
    final data = await sharedPref.read("user");

    if (data != null) {
      AuthResponse authResponse = AuthResponse.fromJson(data);
      return authResponse;
    }
    return null;
  }

  @override
  Future<void> saveUserSession(AuthResponse authResponse) async {
    sharedPref.save('user', authResponse.toJson());
  }
}
