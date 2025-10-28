import '../../../data/models/phrase_model.dart';
import '../../repositories/phrase_repository.dart';

class GetUserPhrasesUseCase {
  final PhraseRepository _repository;

  GetUserPhrasesUseCase({required PhraseRepository repository})
      : _repository = repository;

  /// Execute the use case
  Future<List<PhraseModel>> call(String userId) async {
    if (userId.isEmpty) {
      throw Exception('User ID is required');
    }

    return await _repository.getUserPhrases(userId);
  }
}
