import 'package:path/path.dart' as p;

class MediaPathMapper {
  static const String _assetsPrefix = 'assets/';
  static const String _assetsImagesPrefix = 'assets/images/';

  const MediaPathMapper._();

  /// Normalizes an [relativePath] ensuring forward slashes and removing
  /// duplicate separators. The canonical format always starts with
  /// `assets/`.
  static String normalize(String relativePath) {
    final sanitized = relativePath.replaceAll('\\', '/');
    if (sanitized.startsWith(_assetsPrefix)) {
      return sanitized;
    }
    return '$_assetsPrefix${sanitized.startsWith('/') ? sanitized.substring(1) : sanitized}';
  }

  /// Returns the path that should be used under the `/media` endpoint.
  /// Example: `assets/images/amarillo/Amigo.png` → `amarillo/Amigo.png`.
  static String toServerPath(String relativePath) {
    final normalized = normalize(relativePath);
    if (normalized.startsWith(_assetsImagesPrefix)) {
      return normalized.substring(_assetsImagesPrefix.length);
    }
    if (normalized.startsWith(_assetsPrefix)) {
      return normalized.substring(_assetsPrefix.length);
    }
    return normalized;
  }

  /// Utility to resolve the local absolute path within [rootDirectoryPath]
  /// maintaining the original logical tree (assets/images/...).
  static String joinWithRoot(String rootDirectoryPath, String relativePath) {
    final normalized = normalize(relativePath);
    final joined = p.join(rootDirectoryPath, normalized);
    return p.normalize(joined);
  }
}
