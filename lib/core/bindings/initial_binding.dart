import 'package:get/get.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../presentation/features/auth/controllers/auth_controller.dart';
import '../network/api_client.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Core dependencies - available globally
    Get.put<ApiClient>(ApiClient(), permanent: true);
    Get.put<LocalStorage>(LocalStorage(), permanent: true);

    // Auth dependencies - available globally
    Get.put<AuthRemoteDatasource>(
      AuthRemoteDatasourceImpl(apiClient: Get.find<ApiClient>()),
      permanent: true,
    );

    Get.put<AuthRepository>(
      AuthRepositoryImpl(
        remoteDatasource: Get.find<AuthRemoteDatasource>(),
        localStorage: Get.find<LocalStorage>(),
      ),
      permanent: true,
    );

    Get.put<LoginUseCase>(
      LoginUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<RegisterUseCase>(
      RegisterUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    Get.put<LogoutUseCase>(
      LogoutUseCase(repository: Get.find<AuthRepository>()),
      permanent: true,
    );

    // ADD THIS - Register GetCurrentUserUseCase BEFORE AuthController
    Get.put<GetCurrentUserUseCase>(
      GetCurrentUserUseCase(Get.find<AuthRepository>()),
      permanent: true,
    );

    // AuthController - available globally across all screens
    Get.put<AuthController>(
      AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(), // Now this will work!
      ),
      permanent: true,
    );
  }
}