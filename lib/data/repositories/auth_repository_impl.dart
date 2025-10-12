import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDatasource remoteDatasource;
  final LocalStorage localStorage;

  AuthRepositoryImpl({
    required this.remoteDatasource,
    required this.localStorage,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Call remote API
      final userModel = await remoteDatasource.login(
        email: email,
        password: password,
      );

      // Save user to local storage
      await localStorage.saveUser(userModel.toJson());

      // Return as domain entity
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  }) async {
    try {
      // Call remote API
      final userModel = await remoteDatasource.register(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
        fechaNacimiento: fechaNacimiento,
        cedula: cedula,
      );

      // Save user to local storage
      await localStorage.saveUser(userModel.toJson());

      // Return as domain entity
      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await localStorage.clearUser();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final userData = await localStorage.getUser();
      if (userData == null) return null;

      final userModel = UserModel.fromJson(userData);
      return userModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }
}