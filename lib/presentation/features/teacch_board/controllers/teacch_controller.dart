import 'package:get/get.dart';

import 'package:xpressatec/data/models/category_model.dart';
import 'package:xpressatec/domain/repositories/teacch_repository.dart';

class TeacchController extends GetxController {
  final TeacchRepository _teacchRepository;

  TeacchController(this._teacchRepository);

  // Estado para el modal
  final RxBool isLoading = false.obs;
  final RxMap<String, List<String>> categoryAssets = <String, List<String>>{}.obs;
  final RxString selectedSubcategory = ''.obs;
  
  // ✨ NUEVO: Guardamos la ruta de la categoría actual.
  final RxString currentCategoryPath = ''.obs;

  // ... (getters se mantienen igual) ...
  RxList<String> get imagesForGrid => (categoryAssets[selectedSubcategory.value] ?? <String>[]).obs;
  RxList<String> get subcategoryNames => categoryAssets.keys.toList().obs;
  bool get hasSubcategories => categoryAssets.length > 1 || (categoryAssets.length == 1 && categoryAssets.keys.first != 'main');

  Future<void> loadCategoryDetails(CategoryModel category) async {
    isLoading.value = true;
    categoryAssets.clear();
    selectedSubcategory.value = '';
    
    // ✨ GUARDAMOS LA RUTA
    currentCategoryPath.value = category.contentPath; 

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
}