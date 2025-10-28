class PhraseStatistics {
  final int totalPhrases;
  final double avgPhrasesPerDay;
  final String mostUsedWord;
  final int uniqueWords;
  final Map<DateTime, int> phrasesPerDay; // For timeline chart
  final Map<String, int> topWords; // Top 10 words with counts
  final Map<String, int> categoryUsage; // Category name -> count
  final double avgWordsPerPhrase;

  const PhraseStatistics({
    required this.totalPhrases,
    required this.avgPhrasesPerDay,
    required this.mostUsedWord,
    required this.uniqueWords,
    required this.phrasesPerDay,
    required this.topWords,
    required this.categoryUsage,
    required this.avgWordsPerPhrase,
  });

  factory PhraseStatistics.empty() {
    return const PhraseStatistics(
      totalPhrases: 0,
      avgPhrasesPerDay: 0.0,
      mostUsedWord: '-',
      uniqueWords: 0,
      phrasesPerDay: {},
      topWords: {},
      categoryUsage: {},
      avgWordsPerPhrase: 0.0,
    );
  }
}