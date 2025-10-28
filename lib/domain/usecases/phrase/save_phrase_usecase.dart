import '../../repositories/phrase_repository.dart';

class SavePhraseUseCase {
  final PhraseRepository _repository;

  SavePhraseUseCase({required PhraseRepository repository})
      : _repository = repository;

  /// Execute the use case
  Future<String> call({
    required String userId,
    required String phrase,
    required List<String> words,
    required String assistant,
    required String localAudioPath,
  }) async {
    // Validate inputs
    if (userId.isEmpty) {
      throw Exception('User ID is required');
    }
    if (phrase.isEmpty) {
      throw Exception('Phrase cannot be empty');
    }
    if (words.isEmpty) {
      throw Exception('Words list cannot be empty');
    }

    // Execute repository method
    return await _repository.savePhrase(
      userId: userId,
      phrase: phrase,
      words: words,
      assistant: assistant,
      localAudioPath: localAudioPath,
    );
  }
}