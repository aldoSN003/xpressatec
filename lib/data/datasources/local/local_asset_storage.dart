import 'dart:io';
import 'dart:typed_data';

import 'package:path_provider/path_provider.dart';

import '../../../core/utils/media_path_mapper.dart';

class LocalAssetStorage {
  Directory? _cachedRootDir;

  Future<Directory> getRootDir() async {
    if (_cachedRootDir != null) {
      return _cachedRootDir!;
    }
    final documents = await getApplicationDocumentsDirectory();
    final customAssetsDir = Directory('${documents.path}/custom_assets');
    if (!await customAssetsDir.exists()) {
      await customAssetsDir.create(recursive: true);
    }
    _cachedRootDir = customAssetsDir;
    return customAssetsDir;
  }

  Future<File> saveImage(String relativePath, Uint8List bytes) async {
    final file = await _resolveFile(relativePath);
    if (!await file.parent.exists()) {
      await file.parent.create(recursive: true);
    }
    return file.writeAsBytes(bytes, flush: true);
  }

  Future<File?> getLocalImage(String relativePath) async {
    final file = await _resolveFile(relativePath);
    if (await file.exists()) {
      return file;
    }
    return null;
  }

  Future<bool> exists(String relativePath) async {
    final file = await _resolveFile(relativePath);
    return file.exists();
  }

  Future<File> _resolveFile(String relativePath) async {
    final root = await getRootDir();
    final fullPath = MediaPathMapper.joinWithRoot(root.path, relativePath);
    return File(fullPath);
  }
}
