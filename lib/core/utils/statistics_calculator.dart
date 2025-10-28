import 'package:xpressatec/data/models/phrase_model.dart';
import 'package:xpressatec/domain/entities/phrase_statistics.dart';
import 'package:xpressatec/core/utils/category_mapper.dart';

class StatisticsCalculator {
  /// Calculate statistics from a list of phrases
  static PhraseStatistics calculate(List<PhraseModel> phrases) {
    if (phrases.isEmpty) {
      return PhraseStatistics.empty();
    }

    // Total phrases
    final totalPhrases = phrases.length;

    // Calculate date range
    final dates = phrases.map((p) => p.timestamp).toList()..sort();
    final firstDate = dates.first;
    final lastDate = dates.last;
    final daysDiff = lastDate.difference(firstDate).inDays + 1;

    // Average phrases per day
    final avgPhrasesPerDay = daysDiff > 0 ? totalPhrases / daysDiff.toDouble() : 0.0;

    // Word frequency analysis
    final Map<String, int> wordFrequency = {};
    final List<String> allWords = [];
    int totalWords = 0;

    for (var phrase in phrases) {
      for (var word in phrase.words) {
        final normalizedWord = word.toLowerCase().trim();
        wordFrequency[normalizedWord] = (wordFrequency[normalizedWord] ?? 0) + 1;
        allWords.add(normalizedWord);
        totalWords++;
      }
    }

    // Most used word
    String mostUsedWord = '-';
    int maxCount = 0;
    wordFrequency.forEach((word, count) {
      if (count > maxCount) {
        maxCount = count;
        mostUsedWord = word;
      }
    });

    // Top 10 words
    final topWords = Map.fromEntries(
      (wordFrequency.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)))
          .take(10),
    );

    // Unique words
    final uniqueWords = wordFrequency.length;

    // Average words per phrase
    final avgWordsPerPhrase = totalWords > 0 ? totalWords / totalPhrases.toDouble() : 0.0;

    // Phrases per day (for timeline chart)
    final Map<DateTime, int> phrasesPerDay = {};
    for (var phrase in phrases) {
      final date = DateTime(
        phrase.timestamp.year,
        phrase.timestamp.month,
        phrase.timestamp.day,
      );
      phrasesPerDay[date] = (phrasesPerDay[date] ?? 0) + 1;
    }

    // Category usage (using CategoryMapper)
    final categoryMapper = CategoryMapper();
    final Map<String, int> categoryUsage = categoryMapper.calculateCategoryUsage(allWords);

    return PhraseStatistics(
      totalPhrases: totalPhrases,
      avgPhrasesPerDay: avgPhrasesPerDay,
      mostUsedWord: mostUsedWord,
      uniqueWords: uniqueWords,
      phrasesPerDay: phrasesPerDay,
      topWords: topWords,
      categoryUsage: categoryUsage,
      avgWordsPerPhrase: avgWordsPerPhrase,
    );
  }

  /// Filter phrases by date range
  static List<PhraseModel> filterByDateRange(
      List<PhraseModel> phrases,
      DateTime startDate,
      DateTime endDate,
      ) {
    return phrases.where((phrase) {
      return phrase.timestamp.isAfter(startDate.subtract(const Duration(seconds: 1))) &&
          phrase.timestamp.isBefore(endDate.add(const Duration(days: 1)));
    }).toList();
  }

  /// Get phrases for last N days
  static List<PhraseModel> getLastNDays(List<PhraseModel> phrases, int days) {
    final now = DateTime.now();
    final startDate = DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: days - 1));
    return filterByDateRange(phrases, startDate, now);
  }

  /// Get phrases for "All Time" (no filtering)
  static List<PhraseModel> getAllTime(List<PhraseModel> phrases) {
    return phrases;
  }
}