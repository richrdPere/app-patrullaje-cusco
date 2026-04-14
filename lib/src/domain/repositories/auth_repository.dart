// Model
import 'package:sis_patrullaje_cusco/src/domain/entities/auth_response.dart';
import 'package:sis_patrullaje_cusco/src/domain/entities/user_entity.dart';
import 'package:sis_patrullaje_cusco/src/domain/utils/Resource.dart';

abstract class AuthRepository {
  /// Obtener sesión almacenada localmente
  Future<AuthResponse?> getUserSession();

  /// Guardar sesión del usuario
  Future<void> saveUserSession(AuthResponse authResponse);

  /// Login
  Future<Resource<AuthResponse>> login(String username, String password);

  /// Registro de usuario
  Future<AuthResponse> register(UserEntity user);

  /// Eliminar sesión
  Future<bool> logout();
}
