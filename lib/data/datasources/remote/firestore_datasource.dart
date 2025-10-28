import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/phrase_model.dart';

abstract class FirestoreDatasource {
  /// Save a phrase to Firestore
  Future<String> savePhrase(PhraseModel phrase);

  /// Get all phrases for a specific user
  Future<List<PhraseModel>> getUserPhrases(String userId);

  /// Get phrases within a date range
  Future<List<PhraseModel>> getPhrasesInRange({
    required String userId,
    required DateTime startDate,
    required DateTime endDate,
  });

  /// Delete a phrase
  Future<void> deletePhrase(String phraseId);
}

class FirestoreDatasourceImpl implements FirestoreDatasource {
  final FirebaseFirestore _firestore;

  FirestoreDatasourceImpl({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Future<String> savePhrase(PhraseModel phrase) async {
    try {
      print('💾 Saving phrase to Firestore for user: ${phrase.userId}');

      // Path: users/{userId}/phrases/{phraseId}
      final docRef = await _firestore
          .collection('users')
          .doc(phrase.userId)
          .collection('phrases')
          .add(phrase.toJson());

      print('✅ Phrase saved with ID: ${docRef.id}');
      return docRef.id;
    } catch (e) {
      print('❌ Error saving phrase to Firestore: $e');
      rethrow;
    }
  }

  @override
  Future<List<PhraseModel>> getUserPhrases(String userId) async {
    try {
      print('📥 Fetching phrases for user: $userId');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('phrases')
          .orderBy('timestamp', descending: true)
          .get();

      final phrases = querySnapshot.docs
          .map((doc) => PhraseModel.fromJson(doc.data(), doc.id))
          .toList();

      print('✅ Fetched ${phrases.length} phrases');
      return phrases;
    } catch (e) {
      print('❌ Error fetching user phrases: $e');
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
      print('📥 Fetching phrases for user $userId from $startDate to $endDate');

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('phrases')
          .where('timestamp',
          isGreaterThanOrEqualTo: Timestamp.fromDate(startDate))
          .where('timestamp', isLessThanOrEqualTo: Timestamp.fromDate(endDate))
          .orderBy('timestamp', descending: true)
          .get();

      final phrases = querySnapshot.docs
          .map((doc) => PhraseModel.fromJson(doc.data(), doc.id))
          .toList();

      print('✅ Fetched ${phrases.length} phrases in range');
      return phrases;
    } catch (e) {
      print('❌ Error fetching phrases in range: $e');
      rethrow;
    }
  }

  @override
  Future<void> deletePhrase(String phraseId) async {
    try {
      print('🗑️ Deleting phrase: $phraseId');
      // Note: Need to know userId to delete. Consider passing it or restructuring.
      // For now, this is a placeholder
      print('⚠️ Delete phrase not fully implemented - need userId');
      throw UnimplementedError('Delete requires userId context');
    } catch (e) {
      print('❌ Error deleting phrase: $e');
      rethrow;
    }
  }
}