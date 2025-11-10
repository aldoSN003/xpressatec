import 'dart:typed_data';

import '../entities/user.dart';

abstract class AuthRepository {
  Future<User> login({
    required String email,
    required String password,
  });

  Future<User> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  });

  Future<void> logout();

  Future<User?> getCurrentUser();

  Future<bool> isLoggedIn();

  Future<Uint8List> getPatientQr(String uuid);
}
