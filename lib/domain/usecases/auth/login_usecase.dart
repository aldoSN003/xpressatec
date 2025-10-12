import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class LoginUseCase {
  final AuthRepository repository;

  LoginUseCase({required this.repository});

  Future<User> call({
    required String email,
    required String password,
  }) async {
    // Add validation if needed
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Email y contraseña son requeridos');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Email inválido');
    }

    return await repository.login(
      email: email,
      password: password,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}