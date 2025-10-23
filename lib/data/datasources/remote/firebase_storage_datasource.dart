import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

abstract class FirebaseStorageDatasource {
  /// Upload audio file to Firebase Storage
  Future<String> uploadAudio({
    required File audioFile,
    required String word,
    required String assistant,
  });

  /// Download audio file from Firebase Storage to local path
  Future<File?> downloadAudio({
    required String word,
    required String assistant,
    required String localPath,
  });

  /// Check if audio exists in Firebase Storage
  Future<bool> audioExists({
    required String word,
    required String assistant,
  });

  /// Get download URL for audio (for streaming, if needed later)
  Future<String?> getAudioUrl({
    required String word,
    required String assistant,
  });
}

class FirebaseStorageDatasourceImpl implements FirebaseStorageDatasource {
  final FirebaseStorage _storage;

  FirebaseStorageDatasourceImpl({
    FirebaseStorage? storage,
  }) : _storage = storage ?? FirebaseStorage.instance;

  /// Build the Firebase Storage path for an audio file
  String _buildStoragePath(String word, String assistant) {
    // Path: audios/shared/{assistant}/{word}.mp3
    final sanitizedWord = word.trim().toLowerCase();
    return 'audios/shared/$assistant/$sanitizedWord.mp3';
  }

  @override
  Future<String> uploadAudio({
    required File audioFile,
    required String word,
    required String assistant,
  }) async {
    final path = _buildStoragePath(word, assistant);

    try {
      final ref = _storage.ref().child(path);

      print('📤 Uploading audio to Firebase: $path');

      // Upload file
      await ref.putFile(audioFile);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      print('✅ Upload successful: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading audio to Firebase: $e');
      rethrow;
    }
  }

  @override
  Future<File?> downloadAudio({
    required String word,
    required String assistant,
    required String localPath,
  }) async {
    final path = _buildStoragePath(word, assistant);

    try {
      final ref = _storage.ref().child(path);

      print('📥 Downloading audio from Firebase: $path');

      // Create local file
      final file = File(localPath);
      await file.parent.create(recursive: true);

      // Download file
      await ref.writeToFile(file);

      print('✅ Download successful: $localPath');
      return file;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        print('ℹ️ Audio not found in Firebase: $path');
        return null;
      }
      print('❌ Error downloading audio from Firebase: $e');
      rethrow;
    } catch (e) {
      print('❌ Error downloading audio: $e');
      rethrow;
    }
  }

  @override
  Future<bool> audioExists({
    required String word,
    required String assistant,
  }) async {
    final path = _buildStoragePath(word, assistant);

    try {
      final ref = _storage.ref().child(path);

      // Try to get metadata - if it exists, this will succeed
      await ref.getMetadata();
      return true;
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return false;
      }
      rethrow;
    }
  }

  @override
  Future<String?> getAudioUrl({
    required String word,
    required String assistant,
  }) async {
    final path = _buildStoragePath(word, assistant);

    try {
      final ref = _storage.ref().child(path);
      return await ref.getDownloadURL();
    } on FirebaseException catch (e) {
      if (e.code == 'object-not-found') {
        return null;
      }
      rethrow;
    }
  }
}