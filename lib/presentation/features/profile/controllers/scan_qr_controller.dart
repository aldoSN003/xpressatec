import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class ScanQrController extends GetxController {
  ScanQrController();

  final MobileScannerController scannerController = MobileScannerController(
    formats: const [BarcodeFormat.qrCode],
    detectionSpeed: DetectionSpeed.noDuplicates,
  );

  final RxnString scannedUuid = RxnString();
  final RxString statusMessage = 'Apunta la cámara hacia el código QR.'.obs;
  final RxBool hasError = false.obs;

  void onDetect(BarcodeCapture capture) {
    if (scannedUuid.value != null) {
      return;
    }

    String? value;
    for (final barcode in capture.barcodes) {
      final rawValue = barcode.rawValue?.trim();
      if (rawValue != null && rawValue.isNotEmpty) {
        value = rawValue;
        break;
      }
    }

    if (value == null) {
      _setError(
        'Este código no es válido. Intenta con un código generado en la app del paciente.',
      );
      return;
    }

    scannedUuid.value = value;
    hasError.value = false;
    statusMessage.value = 'QR leído correctamente.';
    scannerController.stop();
  }

  Future<void> toggleTorch() async {
    await scannerController.toggleTorch();
  }

  Future<void> resumeScanning() async {
    scannedUuid.value = null;
    hasError.value = false;
    statusMessage.value = 'Apunta la cámara hacia el código QR.';
    await scannerController.start();
  }

  void _setError(String message) {
    scannedUuid.value = null;
    hasError.value = true;
    statusMessage.value = message;
  }

  @override
  void onClose() {
    scannerController.dispose();
    super.onClose();
  }
}
