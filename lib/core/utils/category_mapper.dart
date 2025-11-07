import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:xpressatec/core/constants/app_constants.dart';
// ❓ Note: You had 'package:flutter/material.dart' at the end of your file,
// it should be here if AppConstants or other dependencies need it.
import 'package:flutter/material.dart';

/// 🆕 Represents a node in the asset tree (either a directory or an image file)
///
/// A node can be a directory (which contains other nodes) or a leaf (an image).
/// Directories can also have a 'portadaPath' if a 'portada.png' exists inside them.
class AssetNode {
  /// The file or folder name (e.g., "casa", "baño.png")
  final String name;

  /// The full asset path (e.g., "assets/images/cafe/casa" or "assets/images/cafe/casa/baño.png")
  final String path;

  /// True if this node is a directory, false if it's a file.
  final bool isDirectory;

  /// Child nodes (if this is a directory).
  /// This is a mutable list that gets populated during the tree build.
  final List<AssetNode> children;

  /// The path to the cover image (portada.png) if this is a directory.
  String? portadaPath;

  AssetNode({
    required this.name,
    required this.path,
    required this.isDirectory,
    // Provide a mutable list for directories, const empty for files
    List<AssetNode>? children,
    this.portadaPath,
  }) : children = children ?? (isDirectory ? [] : const []);

  /// Helper to get a display-friendly name (e.g., "baño.png" -> "baño")
  String get displayName => name.replaceAll('.png', '');

  @override
  String toString() {
    return 'AssetNode(name: $name, isDirectory: $isDirectory, children: ${children.length})';
  }
}

class CategoryMapper {
  // Singleton pattern
  static final CategoryMapper _instance = CategoryMapper._internal();
  factory CategoryMapper() => _instance;
  CategoryMapper._internal();

  // Cache the mapping to avoid repeated asset loading
  Map<String, String>? _wordToCategoryCache;
  Map<String, String>? _categoryToColorCache;

  /// 🆕 Cache for the asset tree structure
  Map<String, List<AssetNode>>? _categoryTreeCache;

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
    _categoryTreeCache = {}; // 🆕 Initialize new cache

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

        // 🆕 Get ALL asset paths in this category
        final allPaths = manifestMap.keys
            .where((String key) => key.startsWith(rootPath))
            .toList();

        // 🆕 Build and cache the tree for this category
        _categoryTreeCache![colorFolder] = _buildTree(rootPath, allPaths);

        // --- Existing logic for flat map ---
        // Filter for just the PNGs for the flat map
        final categoryPaths = allPaths
            .where((String key) => key.endsWith('.png'))
            .toList();

        for (final path in categoryPaths) {
          // Extract filename without extension
          // e.g., "assets/images/amarillo/Abuela.png" → "abuela"
          final fileName =
          path.split('/').last.replaceAll('.png', '').toLowerCase();

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

      print(
          '✅ CategoryMapper initialized: ${_wordToCategoryCache!.length} words mapped');
      print('✅ CategoryMapper: Asset trees built for ${_categoryTreeCache!.length} categories');
    } catch (e) {
      print('❌ Error initializing CategoryMapper: $e');
      _wordToCategoryCache = {};
      _categoryToColorCache = {};
      _categoryTreeCache = {}; // 🆕 Also clear on error
    }
  }

  /// 🆕 Builds a tree structure from a list of asset paths.
  ///
  /// This method creates a hierarchy of [AssetNode] objects based on the
  /// file paths provided.
  ///
  /// Note: This relies on the AssetManifest.json. **Empty directories
  /// will not be included** as they are not listed in the manifest.
  List<AssetNode> _buildTree(String rootPath, List<String> allPaths) {
    // This map holds all *directory* nodes as they are built.
    // Key: The full path of the directory (e.g., "assets/images/cafe/casa")
    // Value: The AssetNode object for that directory
    final Map<String, AssetNode> dirNodes = {};

    // Create a virtual root node to hold the top-level items for this category
    final rootNode =
    AssetNode(name: 'root', path: rootPath, isDirectory: true);
    dirNodes[rootPath] = rootNode;

    // Filter for PNG images only, as they are the content we care about
    final imagePaths = allPaths.where((path) => path.endsWith('.png'));

    for (final path in imagePaths) {
      // e.g., path = "assets/images/cafe/casa/baño.png"
      // parts = ["assets", "images", "cafe", "casa", "baño.png"]
      final parts = path.split('/');

      // Get the file name and its parent directory path
      // fileName = "baño.png"
      // parentPath = "assets/images/cafe/casa"
      final fileName = parts.last;
      final parentPath = parts.sublist(0, parts.length - 1).join('/');

      // Ensure all parent directories exist up to this file
      // This will recursively create nodes for "cafe" and "casa" if they don't exist
      AssetNode parentNode =
      _ensureParentDirsExist(parentPath, rootPath, dirNodes);

      // Now that we have the immediate parent ("casa"), add the file
      if (fileName.toLowerCase() == 'portada.png') {
        // This is a cover image, assign it to the parent directory
        parentNode.portadaPath = path;
      } else {
        // This is a regular image file, add it as a child
        final fileNode = AssetNode(
          name: fileName,
          path: path,
          isDirectory: false,
        );
        parentNode.children.add(fileNode);
      }
    }

    // Return the children of the virtual root (i.e., the top-level items)
    return rootNode.children;
  }

  /// 🆕 Helper method for [_buildTree].
  ///
  /// Recursively ensures that a directory node exists for the given [dirPath]
  /// and returns it. If it or its parents don't exist, they are created.
  AssetNode _ensureParentDirsExist(
      String dirPath, String rootPath, Map<String, AssetNode> dirNodes) {
    // Base case: The directory already exists in our map
    if (dirNodes.containsKey(dirPath)) {
      return dirNodes[dirPath]!;
    }

    // Recursive case: The directory doesn't exist.
    // We must create it, but first, we ensure its parent exists.

    // e.g., dirPath = "assets/images/cafe/casa"
    // parts = ["assets", "images", "cafe", "casa"]
    final parts = dirPath.split('/');
    final dirName = parts.last; // "casa"
    final parentPath = parts.sublist(0, parts.length - 1).join('/'); // "assets/images/cafe"

    // Find the parent node. This recursive call will stop when parentPath == rootPath,
    // which we already added to dirNodes.
    AssetNode parentNode = _ensureParentDirsExist(parentPath, rootPath, dirNodes);

    // Now that we have the parent ("cafe"), create the new node ("casa")
    final newNode = AssetNode(
      name: dirName,
      path: dirPath,
      isDirectory: true,
    );

    // Add the new node to the map and to its parent's children list
    dirNodes[dirPath] = newNode;
    parentNode.children.add(newNode);

    return newNode;
  }

  /// 🆕 Get the asset tree for a specific category name
  ///
  /// Returns a list of [AssetNode] objects representing the top-level
  /// files and sub-directories for the given category (e.g., "¿Dónde?").
  List<AssetNode> getAssetTreeForCategory(String categoryName) {
    if (_categoryTreeCache == null) {
      print('⚠️ CategoryMapper not initialized!');
      return [];
    }

    // Map categoryName (e.g., "¿Dónde?") to colorFolder (e.g., "cafe")
    final colorFolder = getColorForCategory(categoryName);
    if (colorFolder == null) {
      return [];
    }

    // Return the cached tree for that color folder
    return _categoryTreeCache![colorFolder] ?? [];
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

  /// Helper function to recursively print the asset tree
  void printTree(List<AssetNode> nodes, {String prefix = ''}) {
    for (var node in nodes) {
      // Print the current node with indentation
      print('$prefix- ${node.name} (Directory: ${node.isDirectory})');

      // If it's a directory and has children, recurse
      if (node.isDirectory && node.children.isNotEmpty) {
        printTree(node.children, prefix: '$prefix  ');
      }
    }
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
    _categoryTreeCache = null; // 🆕 Clear the tree cache
  }
}