import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xpressatec/data/models/category_model.dart';
import 'package:xpressatec/data/models/image_model.dart';
import 'package:xpressatec/domain/repositories/teacch_repository.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/tts_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/llm_controller.dart';

import 'package:xpressatec/presentation/features/teacch_board/widgets/phrase_result_dialog.dart';



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

  // ✨ Color de la categoría actual
  Color? _currentCategoryColor;

  // Getters
  RxList<String> get imagesForGrid => (categoryAssets[selectedSubcategory.value] ?? <String>[]).obs;
  RxList<String> get subcategoryNames => categoryAssets.keys.toList().obs;
  bool get hasSubcategories => categoryAssets.length > 1 || (categoryAssets.length == 1 && categoryAssets.keys.first != 'main');




  Future<void> generateAndShowPhrase() async {
    if (selectedItems.isEmpty) {
      Get.snackbar(
        'Aviso',
        'Selecciona al menos un pictograma',
        snackPosition: SnackPosition.BOTTOM,
      );
      return;
    }

    // Get controllers
    final llmController = Get.find<LlmController>();
    final ttsController = Get.find<TtsController>();

    // Extract words from selectedItems
    List<String> words = selectedItems.map((item) => item.text).toList();

    print('Generando frase con palabras: $words');

    // Generate phrase using LLM
    final phrase = await llmController.generatePhrase(words);

    if (phrase != null) {
      // Play the generated phrase using TTS and GET THE AUDIO FILE PATH
      final String? audioFilePath = await ttsController.tellPhrase11labs(phrase);

      if (audioFilePath != null) {
        // Show dialog with the audio file path
        Get.dialog(
          PhraseResultDialog(
            phrase: phrase,
            words: words,
            audioFilePath: audioFilePath, // 🆕 ADD THIS LINE
            onSuccess: () {
              // Clear selected items after successful save
              clearSelectedItems();
            },
          ),
          barrierDismissible: false,
        );
      } else {
        Get.snackbar(
          'Error',
          'No se pudo generar el audio',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } else {
      Get.snackbar(
        'Error',
        'No se pudo generar la frase. Verifica tu conexión a internet.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

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