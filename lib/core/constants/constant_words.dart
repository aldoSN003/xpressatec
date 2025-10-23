class ConstantWords {
  /// Automatically detect if a word is constant based on simple rules:
  /// - Single word (no spaces) = Constant pictogram word
  /// - Multiple words (has spaces) = Dynamic Gemini phrase
  static bool isConstant(String text) {
    final trimmed = text.trim();

    // If it contains spaces, it's a Gemini phrase (dynamic)
    if (trimmed.contains(' ')) {
      return false;
    }

    // Single word = pictogram constant word
    return true;
  }

  /// Normalize text for Firebase Storage filename
  /// Converts "Rojo" → "rojo", "Mamá" → "mama"
  static String normalize(String text) {
    return text
        .toLowerCase()
        .trim()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u');
  }
}