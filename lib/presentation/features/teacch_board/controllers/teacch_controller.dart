import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xpressatec/data/models/category_model.dart';
import 'package:xpressatec/data/models/image_model.dart';
import 'package:xpressatec/domain/repositories/teacch_repository.dart';

class TeacchController extends GetxController {
  final TeacchRepository _teacchRepository;

  TeacchController(this._teacchRepository);

  // Estado para el modal
  final RxBool isLoading = false.obs;
  final RxMap<String, List<String>> categoryAssets = <String, List<String>>{}.obs;
  final RxString selectedSubcategory = ''.obs;

  // ✨ Guardamos la ruta de la categoría actual
  final RxString currentCategoryPath = ''.obs;

  // ✨ Lista de items seleccionados (carne, chocolate, abuela, etc.)
  final RxList<SelectedItem> selectedItems = <SelectedItem>[].obs;

  // ✨ Color de la categoría actual - SOLO ESTA LÍNEA, BORRA CUALQUIER OTRA
  Color? _currentCategoryColor;

  // Getters
  RxList<String> get imagesForGrid => (categoryAssets[selectedSubcategory.value] ?? <String>[]).obs;
  RxList<String> get subcategoryNames => categoryAssets.keys.toList().obs;
  bool get hasSubcategories => categoryAssets.length > 1 || (categoryAssets.length == 1 && categoryAssets.keys.first != 'main');

  Future<void> loadCategoryDetails(CategoryModel category) async {
    isLoading.value = true;
    categoryAssets.clear();
    selectedSubcategory.value = '';

    // ✨ Guardamos la ruta y el color
    currentCategoryPath.value = category.contentPath;
    _currentCategoryColor = category.color; // ✅ Guardamos el color

    final assets = await _teacchRepository.getAssetPaths(category.contentPath);
    categoryAssets.value = assets;

    if (categoryAssets.isNotEmpty) {
      selectedSubcategory.value = categoryAssets.keys.first;
    }

    isLoading.value = false;
  }

  void selectSubcategory(String subcategoryName) {
    selectedSubcategory.value = subcategoryName;
  }

  // ✨ Añadir item seleccionado
  void addSelectedItem(String imagePath, String itemName) {
    final item = SelectedItem(
      imageModel: ImageModel(imagePath: imagePath),
      color: _currentCategoryColor ?? const Color(0xFF9E9E9E), // ✅ Usamos el color guardado
      text: itemName,
    );

    // Evitar duplicados
    if (!selectedItems.any((i) => i.text == itemName)) {
      selectedItems.add(item);
      print('Item añadido: $itemName'); // Debug
    }
  }

  // ✨ Remover item seleccionado
  void removeSelectedItem(SelectedItem item) {
    selectedItems.remove(item);
    print('Item removido: ${item.text}'); // Debug
  }

  // ✨ Limpiar todos los items seleccionados
  void clearSelectedItems() {
    selectedItems.clear();
    print('Items limpiados'); // Debug
  }
}

// ✨ Clase simple para items seleccionados
class SelectedItem {
  final ImageModel imageModel;
  final Color color;
  final String text;

  SelectedItem({
    required this.imageModel,
    required this.color,
    required this.text,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is SelectedItem &&
              runtimeType == other.runtimeType &&
              text == other.text;

  @override
  int get hashCode => text.hashCode;
}