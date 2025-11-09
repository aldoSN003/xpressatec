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

  final RxString userName = 'Usuario'.obs;
  final RxString userEmail = ''.obs;
  final RxString userRole = ''.obs;
  final RxnString userUuid = RxnString();

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
  String? get uuid => userUuid.value ?? currentUser.value?.uuid;

  String? get patientUuid => uuid;

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

      _setCurrentUser(user);

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

      _setCurrentUser(user);

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
      _setCurrentUser(null);
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
        _setCurrentUser(user);
        print('✓ User loaded: ${user.nombre}');
      } else {
        _setCurrentUser(null);
      }
    } catch (e) {
      print('✗ Error loading user: $e');
    }
  }

  void _setCurrentUser(User? user) {
    currentUser.value = user;
    userName.value = user?.nombre ?? 'Usuario';
    userEmail.value = user?.email ?? '';
    userRole.value = user?.rol ?? '';
    userUuid.value = user?.uuid;
  }

  Future<void> checkAutoLogin() async {
    // A small delay to let the splash screen be visible
    await Future.delayed(const Duration(seconds: 2));

    try {
      final user = await getCurrentUserUseCase();
      if (user != null) {
        _setCurrentUser(user);
        print('✓ Auto-login successful for: ${user.nombre}');
        // Navigate to home since we found a user
        Get.offAllNamed(Routes.home);
      } else {
        // Navigate to login if no user is in cache
        _setCurrentUser(null);
        Get.offAllNamed(Routes.login);
      }
    } catch (e) {
      print('✗ No cached user found or error loading user: $e');
      // Navigate to login on any error
      _setCurrentUser(null);
      Get.offAllNamed(Routes.login);
    }
  }

}



