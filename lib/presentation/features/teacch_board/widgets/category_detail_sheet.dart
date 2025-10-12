import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/data/models/image_model.dart';

import '../controllers/tts_controller.dart';
import 'board_grid.dart';
import 'subcategory_selector.dart';
import 'teacch_card_widget.dart';
import '../controllers/teacch_controller.dart';

class CategoryDetailSheet extends StatelessWidget {
  final Color categoryColor;

  const CategoryDetailSheet({super.key, required this.categoryColor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacchController>();
  final ttsController = Get.find<TtsController>();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: Scaffold(
        backgroundColor: Colors.grey.shade100,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 1,
          automaticallyImplyLeading: false,
          title: const Text("Selecciona una imagen", style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.close, size: 28),
              onPressed: () => Get.back(),
            ),
          ],
        ),
        body: Obx(() {
          if (controller.isLoading.value) {
            return const Center(child: CircularProgressIndicator());
          }

          final imagePaths = controller.imagesForGrid;

          final imageCards = imagePaths.map((path) {
            // Extraer el nombre del archivo para usarlo como etiqueta
            final name = path.split('/').last.split('.').first.replaceAll('_', ' ');

            return TeacchCardWidget.image(
              imageModel: ImageModel(imagePath: path),
              color: categoryColor,
              text: name.capitalizeFirst!,
              showLabel: true,
              onTap: () {
                // Lógica para cuando se selecciona una imagen final
                print("Imagen seleccionada: $name");

                // ✅ ADD THIS LINE - Añadir el item seleccionado al controller
                controller.addSelectedItem(path, name.capitalizeFirst!);
                ttsController.tellPhraseWithPreview(name);


                Get.back(); // Cerrar el modal al seleccionar
              },
            );
          }).toList();

          return Column(
            children: [
              // Mostrar el selector solo si hay subcategorías
              if (controller.hasSubcategories) SubcategorySelector(categoryColor: categoryColor),
              Expanded(
                child: BoardGrid(cards: imageCards),
              ),
            ],
          );
        }),
      ),
    );
  }
}