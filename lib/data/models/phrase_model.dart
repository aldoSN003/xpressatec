import 'package:cloud_firestore/cloud_firestore.dart';

class PhraseModel {
  final String id;
  final String userId;
  final String phrase;
  final List<String> words;
  final DateTime timestamp;
  final String assistant;
  final String? audioUrl;

  const PhraseModel({
    required this.id,
    required this.userId,
    required this.phrase,
    required this.words,
    required this.timestamp,
    required this.assistant,
    this.audioUrl,
  });

  /// Create from JSON (Firestore)
  factory PhraseModel.fromJson(Map<String, dynamic> json, String docId) {
    return PhraseModel(
      id: docId,
      userId: json['userId'] ?? '',
      phrase: json['phrase'] ?? '',
      words: List<String>.from(json['words'] ?? []),
      timestamp: json['timestamp'] is Timestamp
          ? (json['timestamp'] as Timestamp).toDate()
          : DateTime.parse(json['timestamp']),
      assistant: json['assistant'] ?? 'emmanuel',
      audioUrl: json['audioUrl'],
    );
  }

  /// Convert to JSON (for Firestore)
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'phrase': phrase,
      'words': words,
      'timestamp': Timestamp.fromDate(timestamp),
      'assistant': assistant,
      'audioUrl': audioUrl,
    };
  }

  /// CopyWith method
  PhraseModel copyWith({
    String? id,
    String? userId,
    String? phrase,
    List<String>? words,
    DateTime? timestamp,
    String? assistant,
    String? audioUrl,
  }) {
    return PhraseModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      phrase: phrase ?? this.phrase,
      words: words ?? this.words,
      timestamp: timestamp ?? this.timestamp,
      assistant: assistant ?? this.assistant,
      audioUrl: audioUrl ?? this.audioUrl,
    );
  }

  @override
  String toString() {
    return 'PhraseModel(id: $id, phrase: $phrase, words: $words, timestamp: $timestamp)';
  }
}