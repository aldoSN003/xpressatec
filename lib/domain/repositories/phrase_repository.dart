import '../../data/models/phrase_model.dart';

abstract class PhraseRepository {
  /// Save a phrase with audio to Firebase (Storage + Firestore)
  Future<String> savePhrase({
    required String userId,
    required String phrase,
    required List<String> words,
    required String assistant,
    required String localAudioPath,
  });

  /// Get all phrases for a user
  Future<List<PhraseModel>> getUserPhrases(String userId);

  /// Get phrases within a date range
  Future<List<PhraseModel>> getPhrasesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Delete a phrase
  Future<void> deletePhrase(String userId, String phraseId);
}