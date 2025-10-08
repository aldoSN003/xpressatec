import 'package:get/get.dart';
class SettingsController extends GetxController {
  final notificationsEnabled = true.obs;
  final darkModeEnabled = false.obs;
  final selectedLanguage = 'Español'.obs;

  void toggleNotifications(bool value) {
    notificationsEnabled.value = value;
  }

  void toggleDarkMode(bool value) {
    darkModeEnabled.value = value;
  }
}