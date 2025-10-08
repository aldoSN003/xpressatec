abstract class TeacchRepository {
  // ... tus otros métodos
  
  /// Obtiene los paths de las subcarpetas o imágenes para una ruta de asset dada.
  Future<Map<String, List<String>>> getAssetPaths(String rootPath);
}