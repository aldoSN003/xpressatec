import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrController extends GetxController {
  final MobileScannerController scannerController = MobileScannerController();

  final RxBool isTorchOn = false.obs;
  final RxString statusMessage = 'Escanea un código QR para comenzar.'.obs;
  final RxBool hasError = false.obs;
  final RxnString scannedUuid = RxnString();

  void onDetect(BarcodeCapture capture) {
    if (capture.barcodes.isEmpty) return;

    final raw = capture.barcodes.first.rawValue;
    if (raw == null || raw.isEmpty) {
      hasError.value = true;
      statusMessage.value = 'El código escaneado no es válido.';
      return;
    }

    scannedUuid.value = raw;
    hasError.value = false;
    statusMessage.value = 'QR leído correctamente.';
    // NO llamamos aún a ningún endpoint.
    scannerController.stop();
  }

  Future<void> toggleTorch() async {
    await scannerController.toggleTorch();
    isTorchOn.value = !isTorchOn.value;
  }

  void resumeScanning() {
    scannedUuid.value = null;
    hasError.value = false;
    statusMessage.value = 'Escanea un código QR para comenzar.';
    scannerController.start();
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
