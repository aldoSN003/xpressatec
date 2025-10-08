import 'package:get/get.dart';
import 'package:xpressatec/data/repositories/teacch_repository_impl.dart';
import 'package:xpressatec/domain/repositories/teacch_repository.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
import 'package:xpressatec/presentation/features/chat/controllers/chat_controller.dart';
import 'package:xpressatec/presentation/features/customization/controllers/customization_controller.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';
import 'package:xpressatec/presentation/features/profile/controllers/profile_controller.dart';
import 'package:xpressatec/presentation/features/statistics/controllers/statistics_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/teacch_controller.dart';



class HomeBinding extends Bindings {
  @override
  void dependencies() {
        // 1. Registra la implementación del repositorio.
    //    GetX usará TeacchRepositoryImpl cuando se pida un TeacchRepository.
    Get.lazyPut<TeacchRepository>(() => TeacchRepositoryImpl());

    Get.lazyPut(() => NavigationController());
     Get.lazyPut(() => TeacchController(Get.find()));
    Get.lazyPut(() => ChatController());
    Get.lazyPut(() => CustomizationController());
    Get.lazyPut(() => StatisticsController());
    Get.lazyPut(() => ProfileController());
    Get.lazyPut(() => AuthController());
  }
}