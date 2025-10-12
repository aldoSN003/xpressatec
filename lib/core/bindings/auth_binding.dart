import 'package:get/get.dart';
import 'package:xpressatec/domain/usecases/auth/get_current_user_usecase.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../presentation/features/auth/controllers/auth_controller.dart';
import '../network/api_client.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Core dependencies (if not already registered)
    if (!Get.isRegistered<ApiClient>()) {
      Get.lazyPut<ApiClient>(() => ApiClient(), fenix: true);
    }
    if (!Get.isRegistered<LocalStorage>()) {
      Get.lazyPut<LocalStorage>(() => LocalStorage(), fenix: true);
    }

    // Data sources
    Get.lazyPut<AuthRemoteDatasource>(
          () => AuthRemoteDatasourceImpl(
        apiClient: Get.find<ApiClient>(),
      ),
    );

    // Repository
    Get.lazyPut<AuthRepository>(
          () => AuthRepositoryImpl(
        remoteDatasource: Get.find<AuthRemoteDatasource>(),
        localStorage: Get.find<LocalStorage>(),
      ),
    );

    // Use cases
    Get.lazyPut<LoginUseCase>(
          () => LoginUseCase(repository: Get.find<AuthRepository>()),
    );

    Get.lazyPut<RegisterUseCase>(
          () => RegisterUseCase(repository: Get.find<AuthRepository>()),
    );

    Get.lazyPut<LogoutUseCase>(
          () => LogoutUseCase(repository: Get.find<AuthRepository>()),
    );

    // ADD THIS - Register GetCurrentUserUseCase
    Get.lazyPut<GetCurrentUserUseCase>(
          () => GetCurrentUserUseCase(Get.find<AuthRepository>()),
    );

    // Controller
    Get.lazyPut<AuthController>(
          () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(), // Now this will work
      ),
    );
  }
}