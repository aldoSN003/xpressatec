import 'package:get/get.dart';

import '../../domain/usecases/auth/get_patient_qr_usecase.dart';
import '../../presentation/features/auth/controllers/auth_controller.dart';
import '../../presentation/features/profile/controllers/link_tutor_controller.dart';

class LinkTutorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LinkTutorController>(
      () => LinkTutorController(
        getPatientQrUseCase: Get.find<GetPatientQrUseCase>(),
        authController: Get.find<AuthController>(),
      ),
    );
  }
}
