import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/constants/pictogram_paths.dart';
import '../../../../core/utils/media_path_mapper.dart';
import '../../../../data/datasources/local/local_asset_storage.dart';
import '../../../../data/datasources/local/local_storage.dart';
import '../../../../data/datasources/remote/media_api_datasource.dart';

class CustomizationController extends GetxController {
  CustomizationController({
    required this.mediaApiDatasource,
    required this.localAssetStorage,
    required this.localStorage,
    ImagePicker? imagePicker,
  }) : _imagePicker = imagePicker ?? ImagePicker();

  final MediaApiDatasource mediaApiDatasource;
  final LocalAssetStorage localAssetStorage;
  final LocalStorage localStorage;
  final ImagePicker _imagePicker;

  final RxBool isDownloading = false.obs;
  final RxInt downloadedCount = 0.obs;
  final RxInt totalCount = 0.obs;
  final RxBool downloadFailed = false.obs;
  final RxBool assetsReady = false.obs;

  static const String _downloadedKey = 'custom_assets_downloaded';
  static const String _promptedKey = 'asked_for_custom_assets';

  final Map<String, ImageProvider> _providerCache = {};
  final Set<String> _localCache = <String>{};

  bool _initialized = false;

  Future<void> initCustomization({bool promptUser = true}) async {
    if (_initialized) return;
    _initialized = true;

    final bool alreadyDownloaded = localStorage.getBool(_downloadedKey) ?? false;
    if (alreadyDownloaded) {
      assetsReady.value = true;
      await _hydrateLocalCache();
      return;
    }

    if (!promptUser) {
      return;
    }

    final bool hasBeenPrompted = localStorage.getBool(_promptedKey) ?? false;
    if (!hasBeenPrompted) {
      final bool shouldDownload = await _askUserForDownload();
      await localStorage.saveBool(_promptedKey, true);
      if (shouldDownload) {
        await downloadAllAssets();
      }
    }
  }

  Future<void> downloadAllAssets() async {
    if (isDownloading.value) return;

    isDownloading.value = true;
    downloadFailed.value = false;
    downloadedCount.value = 0;
    totalCount.value = PictogramPaths.values.length;

    _showProgressDialog();

    for (final relativePath in PictogramPaths.values) {
      try {
        final bytes = await mediaApiDatasource.downloadImage(relativePath);
        await localAssetStorage.saveImage(relativePath, bytes);
        final normalized = MediaPathMapper.normalize(relativePath);
        _localCache.add(normalized);
        _providerCache.remove(normalized);
        downloadedCount.value++;
      } catch (e) {
        downloadFailed.value = true;
        debugPrint('❌ Error descargando $relativePath: $e');
      }
    }

    isDownloading.value = false;
    if (Get.isDialogOpen == true) {
      Get.back();
    }

    if (!downloadFailed.value) {
      await localStorage.saveBool(_downloadedKey, true);
      assetsReady.value = true;
      Get.snackbar(
        'Descarga completa',
        'Los pictogramas se guardaron en el dispositivo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      Get.snackbar(
        'Descarga incompleta',
        'Usaremos las imágenes en línea mientras tanto.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<void> replaceImage(String relativePath) async {
    try {
      final XFile? file = await _imagePicker.pickImage(source: ImageSource.gallery);
      if (file == null) {
        return;
      }
      final bytes = await file.readAsBytes();
      await localAssetStorage.saveImage(relativePath, bytes);
      final normalized = MediaPathMapper.normalize(relativePath);
      _localCache.add(normalized);
      _providerCache.remove(normalized);
      update();
      Get.snackbar(
        'Imagen actualizada',
        'El cambio aplica solo en este dispositivo.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar la imagen seleccionada.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  Future<ImageProvider> getImageProvider(String relativePath) async {
    final normalized = MediaPathMapper.normalize(relativePath);

    if (_providerCache.containsKey(normalized)) {
      return _providerCache[normalized]!;
    }

    if (_localCache.contains(normalized) || await localAssetStorage.exists(normalized)) {
      final localFile = await localAssetStorage.getLocalImage(normalized);
      if (localFile != null) {
        final provider = FileImage(localFile);
        _providerCache[normalized] = provider;
        _localCache.add(normalized);
        return provider;
      }
    }

    final url = mediaApiDatasource.buildRemoteUrl(normalized);
    final provider = NetworkImage(url);
    _providerCache[normalized] = provider;
    return provider;
  }

  String buildRemoteUrl(String relativePath) {
    return mediaApiDatasource.buildRemoteUrl(relativePath);
  }

  Future<void> _hydrateLocalCache() async {
    for (final path in PictogramPaths.values) {
      if (await localAssetStorage.exists(path)) {
        _localCache.add(MediaPathMapper.normalize(path));
      }
    }
  }

  Future<bool> _askUserForDownload() async {
    final result = await Get.dialog<bool>(
      WillPopScope(
        onWillPop: () async => false,
        child: AlertDialog(
          title: const Text('Descargar pictogramas'),
          content: const Text(
            'Para poder personalizar los pictogramas necesitamos descargarlos en el dispositivo. ¿Quieres hacerlo ahora?',
          ),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Más tarde'),
            ),
            FilledButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Descargar'),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
    );
    return result ?? false;
  }

  void _showProgressDialog() {
    if (Get.isDialogOpen == true) {
      return;
    }
    Get.dialog(
      WillPopScope(
        onWillPop: () async => false,
        child: Obx(
          () {
            final total = totalCount.value;
            final completed = downloadedCount.value;
            final progress = total == 0 ? 0.0 : completed / total;
            return AlertDialog(
              title: const Text('Descargando pictogramas'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  LinearProgressIndicator(value: total == 0 ? null : progress),
                  const SizedBox(height: 12),
                  Text('$completed / $total archivos'),
                ],
              ),
            );
          },
        ),
      ),
      barrierDismissible: false,
    );
  }
}
