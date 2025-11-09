import 'package:get/get.dart';
import '../../../../domain/entities/user.dart';
import '../../../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../../../domain/usecases/auth/login_usecase.dart';
import '../../../../domain/usecases/auth/logout_usecase.dart';
import '../../../../domain/usecases/auth/register_usecase.dart';
import '../../../../core/config/routes.dart';

class AuthController extends GetxController {
  // Observable state
  final Rx<User?> currentUser = Rx<User?>(null);
  final RxBool isLoading = false.obs;
  final RxString errorMessage = ''.obs;
  final RxString selectedRole = 'Paciente'.obs;

  final LoginUseCase loginUseCase;
  final RegisterUseCase registerUseCase;
  final LogoutUseCase logoutUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;

  AuthController({
    required this.loginUseCase,
    required this.registerUseCase,
    required this.logoutUseCase,
    required this.getCurrentUserUseCase,
  });

  @override
  void onInit() {
    super.onInit();
    _loadCurrentUser(); // Load user on startup
  }

  // Computed properties for UI
  RxString get userName => (currentUser.value?.nombre ?? 'Usuario').obs;
  RxString get userEmail => (currentUser.value?.email ?? '').obs;
  RxString get userRole => (currentUser.value?.rol ?? '').obs;

  String? get patientUuid => currentUser.value?.uuid;

  // Role helpers
  bool get isPaciente => currentUser.value?.isPaciente ?? false;
  bool get isTutor => currentUser.value?.isTutor ?? false;
  bool get isTerapeuta => currentUser.value?.isTerapeuta ?? false;
  bool get canAccessChat => isTutor || isTerapeuta;

  // Login
  Future<void> login({
    required String email,
    required String password,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await loginUseCase(
        email: email,
        password: password,
      );

      currentUser.value = user;

      // Navigate based on role
      _navigateByRole(user.rol);

      Get.snackbar(
        '¡Éxito!',
        'Bienvenido ${user.nombre}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Register
  Future<void> register({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    String? fechaNacimiento,
    String? cedula,
  }) async {
    try {
      isLoading.value = true;
      errorMessage.value = '';

      final user = await registerUseCase(
        nombre: nombre,
        email: email,
        password: password,
        rol: rol,
        fechaNacimiento: fechaNacimiento,
        cedula: cedula,
      );

      currentUser.value = user;

      // Navigate based on role
      _navigateByRole(user.rol);

      Get.snackbar(
        '¡Éxito!',
        'Registro exitoso. Bienvenido ${user.nombre}',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
      Get.snackbar(
        'Error',
        errorMessage.value,
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await logoutUseCase();
      currentUser.value = null;
      Get.offAllNamed(Routes.login);
      Get.snackbar(
        'Sesión cerrada',
        'Hasta pronto',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'Error al cerrar sesión',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // Navigate based on user role
  void _navigateByRole(String rol) {
    switch (rol) {
      case 'Paciente':
        Get.offAllNamed(Routes.home);
        break;
      case 'Terapeuta':
        Get.offAllNamed(Routes.home);
        break;
      case 'Tutor':
        Get.offAllNamed(Routes.home);
        break;
      default:
        Get.offAllNamed(Routes.home);
    }
  }

  // Check if user is logged in
  bool get isLoggedIn => currentUser.value != null;

  Future<void> _loadCurrentUser() async {
    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        currentUser.value = user;
        print('✓ User loaded: ${user.nombre}');
      }
    } catch (e) {
      print('✗ Error loading user: $e');
    }
  }



  Future<void> checkAutoLogin() async {
    // A small delay to let the splash screen be visible
    await Future.delayed(const Duration(seconds: 2));

    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        currentUser.value = user;
        print('✓ Auto-login successful for: ${user.nombre}');
        // Navigate to home since we found a user
        Get.offAllNamed(Routes.home);
      } else {
        // Navigate to login if no user is in cache
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      print('✗ No cached user found or error loading user: $e');
      // Navigate to login on any error
      Get.offAllNamed(Routes.login);
    }
  }

}



