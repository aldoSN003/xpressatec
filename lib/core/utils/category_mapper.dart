import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:xpressatec/core/constants/app_constants.dart';

class CategoryMapper {
  // Singleton pattern
  static final CategoryMapper _instance = CategoryMapper._internal();
  factory CategoryMapper() => _instance;
  CategoryMapper._internal();

  // Cache the mapping to avoid repeated asset loading
  Map<String, String>? _wordToCategoryCache;
  Map<String, String>? _categoryToColorCache;

  /// 🔧 Build category names dynamically from AppConstants
  Map<String, String> get _categoryNames {
    final Map<String, String> names = {};

    for (var category in AppConstants.mainCategories) {
      // Extract color folder name from contentPath
      // e.g., "assets/images/amarillo" -> "amarillo"
      final parts = category.contentPath.split('/');
      final colorFolder = parts.last;
      names[colorFolder] = category.name;
    }
//print (names);
    return names;
  }

  /// Build the word → category mapping from AssetManifest
  Future<void> initialize() async {
    if (_wordToCategoryCache != null) {
      return; // Already initialized
    }

    print('🗺️ Initializing CategoryMapper...');

    _wordToCategoryCache = {};
    _categoryToColorCache = {};

    try {
      // Load AssetManifest
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // Get category names dynamically
      final categoryNames = _categoryNames;

      // Process each category folder
      for (var colorFolder in categoryNames.keys) {
        final categoryName = categoryNames[colorFolder]!;
        final rootPath = 'assets/images/$colorFolder';

        // Get all image paths in this category
        final categoryPaths = manifestMap.keys
            .where((String key) => key.startsWith(rootPath) && key.endsWith('.png'))
            .toList();

        for (final path in categoryPaths) {
          // Extract filename without extension
          // e.g., "assets/images/amarillo/Abuela.png" → "abuela"
          final fileName = path.split('/').last.replaceAll('.png', '').toLowerCase();

          // Skip "portada" files
          //if (fileName == 'portada') continue;

          // Map word to category
          _wordToCategoryCache![fileName] = categoryName;
          _categoryToColorCache![categoryName] = colorFolder;

          // Also handle variations (with accents removed)
          final normalized = _normalizeWord(fileName);
          if (normalized != fileName) {
            _wordToCategoryCache![normalized] = categoryName;
          }
        }
      }

      print('✅ CategoryMapper initialized: ${_wordToCategoryCache!.length} words mapped');
    } catch (e) {
      print('❌ Error initializing CategoryMapper: $e');
      _wordToCategoryCache = {};
      _categoryToColorCache = {};
    }
  }

  /// Get category for a specific word
  String getCategoryForWord(String word) {
    if (_wordToCategoryCache == null) {
      print('⚠️ CategoryMapper not initialized!');
      return 'Otros';
    }

    final normalized = _normalizeWord(word.toLowerCase().trim());
    return _wordToCategoryCache![normalized] ?? 'Otros';
  }

  /// Get color folder for a category name
  String? getColorForCategory(String categoryName) {
    return _categoryToColorCache?[categoryName];
  }

  /// 🆕 Get Color object for a category name
  Color? getColorObjectForCategory(String categoryName) {
    // Find the category in AppConstants
    final category = AppConstants.mainCategories.firstWhere(
          (cat) => cat.name == categoryName,
      orElse: () => AppConstants.mainCategories.first,
    );

    return category.color;
  }

  /// Calculate category usage from a list of words
  Map<String, int> calculateCategoryUsage(List<String> allWords) {
    final Map<String, int> categoryUsage = {};

    for (var word in allWords) {
      final category = getCategoryForWord(word);
      categoryUsage[category] = (categoryUsage[category] ?? 0) + 1;
    }

    return categoryUsage;
  }

  /// Normalize word (remove accents, special chars)
  String _normalizeWord(String word) {
    return word
        .toLowerCase()
        .replaceAll('á', 'a')
        .replaceAll('é', 'e')
        .replaceAll('í', 'i')
        .replaceAll('ó', 'o')
        .replaceAll('ú', 'u')
        .replaceAll('ñ', 'n')
        .replaceAll('ü', 'u')
        .replaceAll('¿', '')
        .replaceAll('?', '')
        .replaceAll(' ', '')
        .trim();
  }

  /// Get all available categories
  List<String> getAllCategories() {
    return AppConstants.mainCategories.map((cat) => cat.name).toList();
  }

  /// Clear cache (for testing or reloading)
  void clearCache() {
    _wordToCategoryCache = null;
    _categoryToColorCache = null;
  }
}