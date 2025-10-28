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
  Future<String> uploadGeneratedAudio({
    required File audioFile,
    required String userId,
    required String phraseId,
  });

  /// List all audio files for a specific assistant
  Future<List<String>> listAllAudios(String assistant);

  /// List all available assistant folders
  Future<List<String>> listAssistants();


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
  Future<List<String>> listAllAudios(String assistant) async {
    try {
      final ref = _storage.ref().child('audios/shared/$assistant');
      final ListResult result = await ref.listAll();

      // Extract file names without .mp3 extension
      final List<String> words = result.items
          .map((item) => item.name.replaceAll('.mp3', ''))
          .toList();

      print('📋 Found ${words.length} audio files for $assistant');
      return words;
    } catch (e) {
      print('❌ Error listing audios for $assistant: $e');
      return [];
    }
  }

  @override
  Future<List<String>> listAssistants() async {
    try {
      final ref = _storage.ref().child('audios/shared');
      final ListResult result = await ref.listAll();

      // Get folder names (assistant names)
      final List<String> assistants = result.prefixes
          .map((prefix) => prefix.name)
          .toList();

      print('📋 Available assistants: $assistants');
      return assistants;
    } catch (e) {
      print('❌ Error listing assistants: $e');
      return [];
    }
  }
  @override
  Future<String> uploadGeneratedAudio({
    required File audioFile,
    required String userId,
    required String phraseId,
  }) async {
    try {
      // Path: generated_audios/{userId}/{phraseId}.mp3
      final path = 'generated_audios/$userId/$phraseId.mp3';

      print('📤 Uploading generated audio to Firebase: $path');

      final ref = _storage.ref().child(path);

      // Upload file
      await ref.putFile(audioFile);

      // Get download URL
      final downloadUrl = await ref.getDownloadURL();

      print('✅ Generated audio uploaded: $downloadUrl');
      return downloadUrl;
    } catch (e) {
      print('❌ Error uploading generated audio: $e');
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