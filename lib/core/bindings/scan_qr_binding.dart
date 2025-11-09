import 'package:get/get.dart';

import '../../presentation/features/profile/controllers/scan_qr_controller.dart';

class ScanQrBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ScanQrController>(
      () => ScanQrController(),
    );
  }
}
