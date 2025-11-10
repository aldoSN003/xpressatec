import 'package:get/get.dart';
import '../../data/datasources/local/local_storage.dart';
import '../../data/datasources/remote/api_auth_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/usecases/auth/get_current_user_usecase.dart';
import '../../domain/usecases/auth/get_patient_qr_usecase.dart';
import '../../domain/usecases/auth/login_usecase.dart';
import '../../domain/usecases/auth/logout_usecase.dart';
import '../../domain/usecases/auth/register_usecase.dart';
import '../../presentation/features/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    // Datasources
    Get.lazyPut<ApiAuthDatasource>(
          () => ApiAuthDatasourceImpl(),
    );

    Get.lazyPut<LocalStorage>(() => LocalStorage());

    // Repository
    Get.lazyPut<AuthRepositoryImpl>(
          () => AuthRepositoryImpl(
        apiAuthDatasource: Get.find<ApiAuthDatasource>(),
        localStorage: Get.find<LocalStorage>(),
      ),
    );

    // Use Cases
    Get.lazyPut(() => LoginUseCase(repository: Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => RegisterUseCase(repository: Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => LogoutUseCase(repository: Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => GetCurrentUserUseCase(repository: Get.find<AuthRepositoryImpl>()));
    Get.lazyPut(() => GetPatientQrUseCase(repository: Get.find<AuthRepositoryImpl>()));

    // Controller
    Get.lazyPut(
          () => AuthController(
        loginUseCase: Get.find<LoginUseCase>(),
        registerUseCase: Get.find<RegisterUseCase>(),
        logoutUseCase: Get.find<LogoutUseCase>(),
        getCurrentUserUseCase: Get.find<GetCurrentUserUseCase>(),
      ),
    );
  }
}