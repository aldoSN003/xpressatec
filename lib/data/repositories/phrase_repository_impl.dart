import 'dart:io';
import '../../domain/repositories/phrase_repository.dart';
import '../datasources/remote/firestore_datasource.dart';
import '../datasources/remote/firebase_storage_datasource.dart';
import '../models/phrase_model.dart';

class PhraseRepositoryImpl implements PhraseRepository {
  final FirestoreDatasource _firestoreDatasource;
  final FirebaseStorageDatasource _firebaseStorageDatasource;

  PhraseRepositoryImpl({
    required FirestoreDatasource firestoreDatasource,
    required FirebaseStorageDatasource firebaseStorageDatasource,
  })  : _firestoreDatasource = firestoreDatasource,
        _firebaseStorageDatasource = firebaseStorageDatasource;

  @override
  Future<String> savePhrase({
    required String userId,
    required String phrase,
    required List<String> words,
    required String assistant,
    required String localAudioPath,
  }) async {
    try {
      print('📦 PhraseRepository: Starting save process...');

      // Step 1: Generate a temporary phraseId for storage path
      final tempPhraseId = DateTime.now().millisecondsSinceEpoch.toString();

      // Step 2: Upload audio to Firebase Storage
      String? audioUrl;
      try {
        final audioFile = File(localAudioPath);

        if (await audioFile.exists()) {
          print('📤 Uploading audio file...');
          audioUrl = await _firebaseStorageDatasource.uploadGeneratedAudio(
            audioFile: audioFile,
            userId: userId,
            phraseId: tempPhraseId,
          );
          print('✅ Audio uploaded: $audioUrl');
        } else {
          print('⚠️ Audio file not found at: $localAudioPath');
        }
      } catch (e) {
        print('⚠️ Error uploading audio (continuing without URL): $e');
        // Continue without audio URL - phrase data is more important
      }

      // Step 3: Create phrase model
      final phraseModel = PhraseModel(
        id: tempPhraseId,
        userId: userId,
        phrase: phrase,
        words: words,
        timestamp: DateTime.now(),
        assistant: assistant,
        audioUrl: audioUrl,
      );

      // Step 4: Save to Firestore
      print('💾 Saving phrase to Firestore...');
      final phraseId = await _firestoreDatasource.savePhrase(phraseModel);

      print('✅ PhraseRepository: Save completed! ID: $phraseId');
      return phraseId;
    } catch (e) {
      print('❌ PhraseRepository: Error saving phrase: $e');
      rethrow;
    }
  }

  @override
  Future<List<PhraseModel>> getUserPhrases(String userId) async {
    try {
      return await _firestoreDatasource.getUserPhrases(userId);
    } catch (e) {
      print('❌ PhraseRepository: Error getting user phrases: $e');
      rethrow;
    }
  }

  @override
  Future<List<PhraseModel>> getPhrasesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  }) async {
    try {
      return await _firestoreDatasource.getPhrasesInRange(
        userId: userId,
        startDate: startDate,
        endDate: endDate,
      );
    } catch (e) {
      print('❌ PhraseRepository: Error getting phrases in range: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePhrase(String userId, String phraseId) async {
    try {
      // TODO: Also delete audio file from Storage if needed
      await _firestoreDatasource.deletePhrase(phraseId);
    } catch (e) {
      print('❌ PhraseRepository: Error deleting phrase: $e');
      rethrow;
    }
  }
}