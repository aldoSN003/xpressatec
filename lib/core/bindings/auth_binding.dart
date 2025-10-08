import 'package:get/get.dart';

import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
     Get.lazyPut<AuthController>(() => AuthController());
  }
}