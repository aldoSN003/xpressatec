import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xpressatec/data/models/image_model.dart';
import 'package:xpressatec/presentation/features/teacch_board/widgets/teacch_card_widget.dart';
import '../controllers/teacch_controller.dart';


class SubcategorySelector extends StatelessWidget {
  // Necesitamos el color de la categoría para pasárselo a las tarjetas.
  final Color categoryColor;
  
  const SubcategorySelector({super.key, required this.categoryColor});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacchController>();

    return Obx(
      () => SizedBox(
        // Aumentamos la altura para que quepan las tarjetas cuadradas.
        height: 140, 
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Row(
            children: controller.subcategoryNames.map((name) {
              final isSelected = name == controller.selectedSubcategory.value;
              
              // Construimos la ruta a la imagen de portada de la subcategoría.
              final coverPath = '${controller.currentCategoryPath.value}/$name/portada.png';

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4.0),
                // Usamos un SizedBox para definir el tamaño de la tarjeta en la lista.
                child: SizedBox(
                  width: 120,
                  child: TeacchCardWidget.image(
                    imageModel: ImageModel(imagePath: coverPath),
                    color: categoryColor,
                    text: name.capitalizeFirst!,
                    showLabel: true,
                    // La propiedad isSelected activará el brillo azul.
                    isSelected: isSelected,
                    // Hacemos el borde más delgado para que no sea tan pesado visualmente.
                    borderThickness: 4, 
                    onTap: () => controller.selectSubcategory(name),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}