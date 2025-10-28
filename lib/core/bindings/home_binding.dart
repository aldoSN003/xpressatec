import 'package:get/get.dart';
import 'package:xpressatec/data/repositories/teacch_repository_impl.dart';
import 'package:xpressatec/domain/repositories/teacch_repository.dart';
import 'package:xpressatec/presentation/features/chat/controllers/chat_controller.dart';
import 'package:xpressatec/presentation/features/customization/controllers/customization_controller.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';
import 'package:xpressatec/presentation/features/profile/controllers/profile_controller.dart';
import 'package:xpressatec/presentation/features/statistics/controllers/statistics_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/teacch_controller.dart';

import '../../domain/usecases/phrase/get_user_phrases_usecase.dart';
import '../../presentation/features/auth/controllers/auth_controller.dart';
import '../../presentation/features/teacch_board/controllers/llm_controller.dart';
import '../../presentation/features/teacch_board/controllers/tts_controller.dart';

class HomeBinding extends Bindings {
  @override
  void dependencies() {
    // Repository
    Get.lazyPut<TeacchRepository>(() => TeacchRepositoryImpl());

    // Controllers
    Get.lazyPut(() => NavigationController());
    Get.lazyPut(() => TeacchController(Get.find()));
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => CustomizationController());
    // 🆕 Statistics Controller (with dependency injection)
    Get.lazyPut<StatisticsController>(
          () => StatisticsController(
        getUserPhrasesUseCase: Get.find<GetUserPhrasesUseCase>(),
      ),
    );
    Get.lazyPut(() => ProfileController());
    Get.lazyPut<TtsController>(() => TtsController());
    Get.lazyPut(() => LlmController());

    // Reuse AuthController if it exists, otherwise it will be created by AuthBinding
    // This makes sure AuthController is available in home screens
    if (!Get.isRegistered<AuthController>()) {
      // If for some reason it doesn't exist, we need to register it
      // But this shouldn't happen if coming from login
    }
  }
}