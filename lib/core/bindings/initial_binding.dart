import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';

import '../../data/datasources/local/local_storage.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    // Inicializar servicios globales aquí
    Get.put<LocalStorage>(LocalStorage(), permanent: true);
  }
}
