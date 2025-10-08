
import 'package:get/get.dart';
class AuthController extends GetxController {
  final selectedRole = 'paciente'.obs;
  final isLoading = false.obs;
  
  // Datos del usuario
  final userName = 'Nombre del Usuario'.obs;
  final userEmail = 'correo@ejemplo.com'.obs;
  final userRole = 'Paciente'.obs;

  void login(String email, String password) {
    // TODO: Implementar lógica de login
    // Simular guardado de datos del usuario
    userEmail.value = email.isNotEmpty ? email : 'usuario@ejemplo.com';
    Get.offAllNamed('/home');
  }

  void register(String name, String email, String password) {
    // TODO: Implementar lógica de registro
    // Simular guardado de datos del usuario
    userName.value = name.isNotEmpty ? name : 'Nuevo Usuario';
    userEmail.value = email.isNotEmpty ? email : 'usuario@ejemplo.com';
    userRole.value = selectedRole.value.capitalizeFirst ?? 'Paciente';
    Get.offAllNamed('/home');
  }

  void logout() {
    // TODO: Implementar lógica de logout
    // Limpiar datos del usuario
    userName.value = 'Nombre del Usuario';
    userEmail.value = 'correo@ejemplo.com';
    userRole.value = 'Paciente';
    Get.offAllNamed('/login');
  }
}
