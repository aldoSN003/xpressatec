import 'package:flutter/services.dart';
import 'dart:convert';

import '../../domain/repositories/teacch_repository.dart';

class TeacchRepositoryImpl implements TeacchRepository {
  // ... tus otras implementaciones

  @override
  Future<Map<String, List<String>>> getAssetPaths(String rootPath) async {
    try {
      // 1. Cargar el manifiesto de assets que genera Flutter.
      final manifestContent = await rootBundle.loadString('AssetManifest.json');
      final Map<String, dynamic> manifestMap = json.decode(manifestContent);

      // 2. Filtrar los paths que están dentro de nuestra carpeta raíz.
      final allPaths = manifestMap.keys.where((String key) => key.startsWith(rootPath)).toList();

      final Map<String, List<String>> result = {};
      final List<String> directImages = [];
      final Set<String> subdirectories = {};

      for (final path in allPaths) {
        // Extrae la parte del path que viene después de la raíz.
        final relativePath = path.substring(rootPath.length + 1);
        
        // Si contiene un '/', es una subcarpeta.
        if (relativePath.contains('/')) {
          final subDir = relativePath.split('/').first;
          subdirectories.add(subDir);
        } else if (relativePath.isNotEmpty) {
          // Si no, es una imagen directa.
          directImages.add(path);
        }
      }

      if (subdirectories.isNotEmpty) {
        // Si hay subdirectorios, los procesamos.
        for (final dir in subdirectories) {
          final dirPath = '$rootPath/$dir';
          result[dir] = allPaths.where((p) => p.startsWith(dirPath) && !p.endsWith('portada.png')).toList();
        }
      } else {
        // Si no hay subdirectorios, devolvemos las imágenes directas.
        result['main'] = directImages;
      }
        print("Assets encontrados para '$rootPath': $result");
      return result;

    } catch (e) {
      print("Error loading asset paths: $e");
      return {};
    }
  }
}