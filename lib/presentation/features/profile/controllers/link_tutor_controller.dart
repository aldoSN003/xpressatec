import 'dart:typed_data';

import 'package:get/get.dart';

import '../../../../domain/usecases/auth/get_patient_qr_usecase.dart';
import '../../auth/controllers/auth_controller.dart';

class LinkTutorController extends GetxController {
  LinkTutorController({
    required this.getPatientQrUseCase,
    required this.authController,
  });

  final GetPatientQrUseCase getPatientQrUseCase;
  final AuthController authController;

  final RxBool isLoading = false.obs;
  final Rx<Uint8List?> qrBytes = Rx<Uint8List?>(null);
  final RxString errorMessage = ''.obs;

  String? get patientUuid => authController.uuid;

  bool get canLoadQr => authController.isPaciente;

  @override
  void onInit() {
    super.onInit();
    loadQr();
  }

  Future<void> loadQr() async {
    isLoading.value = true;
    errorMessage.value = '';
    qrBytes.value = null;

    if (!canLoadQr) {
      errorMessage.value =
          'Esta función solo está disponible para pacientes.';
      isLoading.value = false;
      return;
    }

    final uuid = patientUuid;
    if (uuid == null || uuid.isEmpty) {
      errorMessage.value =
          'No se encontró el identificador del paciente. Por favor, vuelve a iniciar sesión.';
      isLoading.value = false;
      return;
    }

    try {
      final bytes = await getPatientQrUseCase(uuid);
      qrBytes.value = bytes;
    } catch (e) {
      errorMessage.value = e.toString().replaceAll('Exception: ', '');
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> refreshQr() => loadQr();
}
