import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:xpressatec/data/datasources/local/local_storage.dart';
import 'package:xpressatec/data/datasources/remote/firebase_storage_datasource.dart';
import 'package:xpressatec/core/constants/storage_keys.dart';

class AudioPackageManager {
  final FirebaseStorageDatasource _firebaseStorage;
  final LocalStorage _localStorage;

  AudioPackageManager({
    required FirebaseStorageDatasource firebaseStorage,
    required LocalStorage localStorage,
  })  : _firebaseStorage = firebaseStorage,
        _localStorage = localStorage;

  /// Check if any audio package is downloaded
  Future<bool> isPackageDownloaded() async {
    return _localStorage.getBool(StorageKeys.audioPackageDownloaded) ?? false;
  }

  /// Mark package as downloaded
  Future<void> markPackageAsDownloaded(String assistant) async {
    await _localStorage.saveBool(StorageKeys.audioPackageDownloaded, true);
    await _localStorage.saveString(
      StorageKeys.audioPackageVersion,
      DateTime.now().toIso8601String(),
    );

    // Save downloaded assistant
    List<String> assistants = await getDownloadedAssistants();
    if (!assistants.contains(assistant)) {
      assistants.add(assistant);
      await _localStorage.saveString(
        StorageKeys.downloadedAssistants,
        assistants.join(','),
      );
    }
  }

  /// Get list of downloaded assistants
  Future<List<String>> getDownloadedAssistants() async {
    final String? assistantsStr = _localStorage.getString(StorageKeys.downloadedAssistants);
    if (assistantsStr == null || assistantsStr.isEmpty) {
      return [];
    }
    return assistantsStr.split(',');
  }

  Future<bool> downloadPackageForAssistant(
      String assistant, {
        Function(int current, int total, String word)? onProgress,
      }) async {
    try {
      print('📦 Starting package download for assistant: $assistant');

      final List<String> audioFiles = await _firebaseStorage.listAllAudios(assistant);

      if (audioFiles.isEmpty) {
        print('⚠️ No audio files found for $assistant');
        return false;
      }

      print('📋 Found ${audioFiles.length} audio files to download');

      final directory = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${directory.path}/audio_cache');
      await cacheDir.create(recursive: true);

      int successCount = 0;
      for (int i = 0; i < audioFiles.length; i++) {
        final word = audioFiles[i];

        onProgress?.call(i + 1, audioFiles.length, word);

        // 🔧 FIX: Sanitize the word to match TTS controller expectations
        final sanitizedWord = _sanitizeWord(word); // 🆕 ADD THIS

        // Build local file path with sanitized name: audio_cache/emmanuel_cuando.mp3
        final localPath = '${cacheDir.path}/${assistant}_$sanitizedWord.mp3'; // 🔧 CHANGED

        try {
          final file = await _firebaseStorage.downloadAudio(
            word: word, // Keep original for Firebase path
            assistant: assistant,
            localPath: localPath,
          );

          if (file != null) {
            successCount++;
            print('✅ Downloaded: $word → $sanitizedWord ($successCount/${audioFiles.length})');
          }
        } catch (e) {
          print('❌ Failed to download $word: $e');
        }
      }

      final bool success = successCount >= (audioFiles.length * 0.8);
      if (success) {
        await markPackageAsDownloaded(assistant);
        print('✅ Package download completed: $successCount/${audioFiles.length} files');
      } else {
        print('⚠️ Package download incomplete: $successCount/${audioFiles.length} files');
      }

      return success;
    } catch (e) {
      print('❌ Error downloading package: $e');
      return false;
    }
  }

// 🆕 ADD THIS HELPER METHOD (copy from TTS controller logic)
  String _sanitizeWord(String word) {
    String lowercased = word.toLowerCase();
    String withoutDiacritics = lowercased
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u');
    RegExp invalidChars = RegExp(r'[^a-z0-9]');
    String sanitized = withoutDiacritics.replaceAll(invalidChars, '');
    return sanitized;
  }

  /// Check available assistants in Firebase (which folders exist)
  Future<List<String>> getAvailableAssistants() async {
    try {
      return await _firebaseStorage.listAssistants();
    } catch (e) {
      print('❌ Error getting available assistants: $e');
      return ['emmanuel']; // Default fallback
    }
  }
}