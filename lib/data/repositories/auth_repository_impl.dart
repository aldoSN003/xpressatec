import 'dart:typed_data';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/api_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  AuthRepositoryImpl({
    required this.apiAuthDatasource,
    required this.localStorage,
  });

  final ApiAuthDatasource apiAuthDatasource;
  final LocalStorage localStorage;

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await apiAuthDatasource.signInWithEmail(
        email: email,
        password: password,
      );

      await localStorage.saveUser(userModel.toJson());
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
      final userModel = await apiAuthDatasource.signUpWithEmail(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
        fechaNacimiento: fechaNacimiento,
        cedula: cedula,
      );

      await localStorage.saveUser(userModel.toJson());
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
      if (userData == null) {
        return null;
      }
      final userModel = UserModel.fromJson(userData);
      return userModel.toEntity();
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isLoggedIn() async {
    try {
      final userData = await localStorage.getUser();
      return userData != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<Uint8List> getPatientQr(String uuid) {
    return apiAuthDatasource.getPatientQr(uuid);
  }
}
