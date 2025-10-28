class StorageKeys {
  StorageKeys._();

  // Auth keys (existing)
  static const String authToken = 'auth_token';
  static const String userId = 'user_id';
  static const String userRole = 'user_role';
  static const String userData = 'user_data';

  // Settings keys (existing)
  static const String selectedAssistant = 'selected_assistant';
  static const String isDarkMode = 'is_dark_mode';

  // 🆕 AUDIO PACKAGE KEYS
  static const String audioPackageDownloaded = 'audio_package_downloaded';
  static const String audioPackageVersion = 'audio_package_version';
  static const String downloadedAssistants = 'downloaded_assistants'; // JSON list
  static const String lastPackageCheck = 'last_package_check';
}