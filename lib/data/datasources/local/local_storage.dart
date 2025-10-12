import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class LocalStorage {
  late SharedPreferences _prefs;

  // Singleton pattern
  static final LocalStorage _instance = LocalStorage._internal();
  factory LocalStorage() => _instance;
  LocalStorage._internal();

  /// Initialize SharedPreferences
  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    print('✓ LocalStorage initialized');
  }

  // ==================== PHRASES ====================

  /// Save phrases history
  Future<void> savePhrases(List<Map<String, dynamic>> phrases) async {
    try {
      final String encoded = jsonEncode(phrases);
      await _prefs.setString('saved_phrases', encoded);
      print('✓ Phrases saved: ${phrases.length} items');
    } catch (e) {
      print('✗ Error saving phrases: $e');
    }
  }

  /// Get saved phrases
  Future<List<Map<String, dynamic>>> getSavedPhrases() async {
    try {
      final String? encoded = _prefs.getString('saved_phrases');
      if (encoded != null && encoded.isNotEmpty) {
        final List<dynamic> decoded = jsonDecode(encoded);
        return decoded.map((e) => Map<String, dynamic>.from(e)).toList();
      }
      return [];
    } catch (e) {
      print('✗ Error getting phrases: $e');
      return [];
    }
  }

  /// Add a single phrase to history
  Future<void> addPhrase({
    required String phrase,
    required List<String> words,
  }) async {
    try {
      List<Map<String, dynamic>> phrases = await getSavedPhrases();

      phrases.add({
        'phrase': phrase,
        'words': words,
        'timestamp': DateTime.now().toIso8601String(),
      });

      await savePhrases(phrases);
      print('✓ Phrase added: $phrase');
    } catch (e) {
      print('✗ Error adding phrase: $e');
    }
  }

  /// Clear all saved phrases
  Future<void> clearPhrases() async {
    try {
      await _prefs.remove('saved_phrases');
      print('✓ All phrases cleared');
    } catch (e) {
      print('✗ Error clearing phrases: $e');
    }
  }

  // ==================== USER DATA ====================

  /// Save user token
  Future<void> saveToken(String token) async {
    await _prefs.setString('auth_token', token);
  }

  /// Get user token
  String? getToken() {
    return _prefs.getString('auth_token');
  }

  /// Remove token (logout)
  Future<void> removeToken() async {
    await _prefs.remove('auth_token');
  }

  /// Check if user is logged in
  bool isLoggedIn() {
    return _prefs.containsKey('auth_token');
  }

  /// Save user ID
  Future<void> saveUserId(String userId) async {
    await _prefs.setString('user_id', userId);
  }

  /// Get user ID
  String? getUserId() {
    return _prefs.getString('user_id');
  }

  /// Save user role
  Future<void> saveUserRole(String role) async {
    await _prefs.setString('user_role', role);
  }

  /// Get user role
  String? getUserRole() {
    return _prefs.getString('user_role');
  }

  // ==================== SETTINGS ====================

  /// Save selected assistant
  Future<void> saveSelectedAssistant(String assistant) async {
    await _prefs.setString('selected_assistant', assistant);
  }

  /// Get selected assistant
  String getSelectedAssistant() {
    return _prefs.getString('selected_assistant') ?? 'emmanuel';
  }

  /// Save theme mode (dark/light)
  Future<void> saveThemeMode(bool isDark) async {
    await _prefs.setBool('is_dark_mode', isDark);
  }

  /// Get theme mode
  bool isDarkMode() {
    return _prefs.getBool('is_dark_mode') ?? false;
  }

  // ==================== TEACCH BOARD ====================

  /// Save custom board configuration
  Future<void> saveBoardConfig(Map<String, dynamic> config) async {
    try {
      final String encoded = jsonEncode(config);
      await _prefs.setString('board_config', encoded);
    } catch (e) {
      print('✗ Error saving board config: $e');
    }
  }

  /// Get board configuration
  Future<Map<String, dynamic>?> getBoardConfig() async {
    try {
      final String? encoded = _prefs.getString('board_config');
      if (encoded != null) {
        return jsonDecode(encoded);
      }
      return null;
    } catch (e) {
      print('✗ Error getting board config: $e');
      return null;
    }
  }

  // ==================== GENERAL ====================

  /// Clear all data (full logout)
  Future<void> clearAll() async {
    await _prefs.clear();
    print('✓ All local storage cleared');
  }

  /// Save generic string
  Future<void> saveString(String key, String value) async {
    await _prefs.setString(key, value);
  }

  /// Get generic string
  String? getString(String key) {
    return _prefs.getString(key);
  }

  /// Save generic bool
  Future<void> saveBool(String key, bool value) async {
    await _prefs.setBool(key, value);
  }

  /// Get generic bool
  bool? getBool(String key) {
    return _prefs.getBool(key);
  }

  /// Save generic int
  Future<void> saveInt(String key, int value) async {
    await _prefs.setInt(key, value);
  }

  /// Get generic int
  int? getInt(String key) {
    return _prefs.getInt(key);
  }

  /// Remove specific key
  Future<void> remove(String key) async {
    await _prefs.remove(key);
  }

  /// Check if key exists
  bool containsKey(String key) {
    return _prefs.containsKey(key);
  }



// ==================== USER DATA ====================

  /// Save complete user data
  Future<void> saveUser(Map<String, dynamic> userData) async {
    try {
      final String encoded = jsonEncode(userData);
      await _prefs.setString('user_data', encoded);
      print('✓ User data saved');
    } catch (e) {
      print('✗ Error saving user data: $e');
      rethrow;
    }
  }

  /// Get complete user data
  Future<Map<String, dynamic>?> getUser() async {
    try {
      final String? encoded = _prefs.getString('user_data');
      if (encoded != null && encoded.isNotEmpty) {
        return jsonDecode(encoded) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('✗ Error getting user data: $e');
      return null;
    }
  }

  /// Clear user data (logout)
  Future<void> clearUser() async {
    try {
      await _prefs.remove('user_data');
      await removeToken();
      print('✓ User data cleared');
    } catch (e) {
      print('✗ Error clearing user data: $e');
      rethrow;
    }
  }



}




