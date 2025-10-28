import 'package:get/get.dart';
import 'package:xpressatec/data/datasources/local/audio_package_manager.dart';
import 'package:xpressatec/core/config/routes.dart';

class AudioPackageController extends GetxController {
  final AudioPackageManager _packageManager;

  AudioPackageController({required AudioPackageManager packageManager})
      : _packageManager = packageManager;

  // Observable state
  final RxBool isDownloading = false.obs;
  final RxBool isChecking = true.obs;
  final RxDouble downloadProgress = 0.0.obs;
  final RxString currentWord = ''.obs;
  final RxInt currentFile = 0.obs;
  final RxInt totalFiles = 0.obs;
  final RxString errorMessage = ''.obs;
  final RxList<String> availableAssistants = <String>[].obs;
  final RxString selectedAssistant = 'emmanuel'.obs;

  @override
  void onInit() {
    super.onInit();
    _checkAvailableAssistants();
  }

  /// Check which assistants are available in Firebase
  Future<void> _checkAvailableAssistants() async {
    try {
      isChecking.value = true;
      final assistants = await _packageManager.getAvailableAssistants();
      availableAssistants.value = assistants;

      // Set default to emmanuel if available
      if (assistants.contains('emmanuel')) {
        selectedAssistant.value = 'emmanuel';
      } else if (assistants.isNotEmpty) {
        selectedAssistant.value = assistants.first;
      }
    } catch (e) {
      print('❌ Error checking assistants: $e');
      errorMessage.value = 'Error al verificar asistentes disponibles';
    } finally {
      isChecking.value = false;
    }
  }

  /// Start downloading the selected assistant package
  Future<void> downloadPackage() async {
    try {
      isDownloading.value = true;
      errorMessage.value = '';
      downloadProgress.value = 0.0;
      currentFile.value = 0;
      totalFiles.value = 0;

      print('📥 Starting download for: ${selectedAssistant.value}');

      final success = await _packageManager.downloadPackageForAssistant(
        selectedAssistant.value,
        onProgress: (current, total, word) {
          currentFile.value = current;
          totalFiles.value = total;
          currentWord.value = word;
          downloadProgress.value = current / total;
        },
      );

      if (success) {
        Get.snackbar(
          '✅ Descarga completa',
          'Paquete de audio instalado correctamente',
          snackPosition: SnackPosition.BOTTOM,
        );

        // Navigate to login after successful download
        await Future.delayed(const Duration(seconds: 1));
        Get.offAllNamed(Routes.login);
      } else {
        errorMessage.value = 'Error al descargar el paquete completo. Intenta nuevamente.';
      }
    } catch (e) {
      print('❌ Error downloading package: $e');
      errorMessage.value = 'Error: $e';
    } finally {
      isDownloading.value = false;
    }
  }

  /// Skip download and go to login (will download on-demand)
  void skipDownload() {
    Get.offAllNamed(Routes.login);
  }
}