
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/local/local_storage.dart';
import '../datasources/remote/firebase_auth_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthDatasource firebaseAuthDatasource;
  final LocalStorage localStorage;

  AuthRepositoryImpl({
    required this.firebaseAuthDatasource,
    required this.localStorage,
  });

  @override
  Future<User> login({
    required String email,
    required String password,
  }) async {
    try {
      // Sign in with Firebase
      final userModel = await firebaseAuthDatasource.signInWithEmail(
        email: email,
        password: password,
      );

      // Save to local storage for offline access
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
      // Create account in Firebase
      final userModel = await firebaseAuthDatasource.signUpWithEmail(
        email: email,
        password: password,
        nombre: nombre,
        rol: rol,
        fechaNacimiento: fechaNacimiento,
        cedula: cedula,
      );

      // Save to local storage
      await localStorage.saveUser(userModel.toJson());

      return userModel.toEntity();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> logout() async {
    try {
      await Future.wait([
        firebaseAuthDatasource.signOut(),
        localStorage.clearUser(),
      ]);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // Try to get from Firebase first
      final userModel = await firebaseAuthDatasource.getCurrentUser();
      if (userModel != null) {
        // Update local storage
        await localStorage.saveUser(userModel.toJson());
        return userModel.toEntity();
      }

      // Fallback to local storage if offline
      final userData = await localStorage.getUser();
      if (userData == null) return null;

      final localUserModel = UserModel.fromJson(userData);
      return localUserModel.toEntity();
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