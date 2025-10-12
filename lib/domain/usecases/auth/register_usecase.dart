import '../../entities/user.dart';
import '../../repositories/auth_repository.dart';

class RegisterUseCase {
  final AuthRepository repository;

  RegisterUseCase({required this.repository});

  Future<User> call({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  }) async {
    // Validation
    if (nombre.isEmpty || email.isEmpty || password.isEmpty || rol.isEmpty) {
      throw Exception('Todos los campos obligatorios son requeridos');
    }

    if (!_isValidEmail(email)) {
      throw Exception('Email inválido');
    }

    if (password.length < 6) {
      throw Exception('La contraseña debe tener al menos 6 caracteres');
    }

    if (!['Paciente', 'Terapeuta', 'Tutor'].contains(rol)) {
      throw Exception('Rol inválido');
    }

    // Role-specific validation
    if (rol == 'Terapeuta' && (cedula == null || cedula.isEmpty)) {
      throw Exception('Cédula profesional requerida para Terapeuta');
    }

    if ((rol == 'Paciente' || rol == 'Tutor') && (fechaNacimiento == null || fechaNacimiento.isEmpty)) {
      throw Exception('Fecha de nacimiento requerida');
    }

    return await repository.register(
      nombre: nombre,
      email: email,
      password: password,
      rol: rol,
      fechaNacimiento: fechaNacimiento,
      cedula: cedula,
    );
  }

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }
}