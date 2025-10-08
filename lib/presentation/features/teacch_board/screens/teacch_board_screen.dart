import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:xpressatec/data/models/category_model.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/teacch_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/widgets/category_detail_sheet.dart';
// No necesitamos ImageModel en esta pantalla ahora
// import 'package:xpresatecch/data/models/image_model.dart'; 
import '../widgets/board_grid.dart';
import '../widgets/teacch_card_widget.dart';

class TeacchBoardScreen extends StatelessWidget {
  const TeacchBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // La definición de colores y categorías se mantiene igual
    final Map<String, Color> colorMap = {
      'amarillo': Colors.yellow.shade700,
      'azul': Colors.blue.shade500,
      'cafe': Colors.brown.shade500,
      'morado': Colors.purple.shade500,
      'naranja': Colors.orange.shade500,
      'rojo': Colors.red.shade500,
      'rosa': Colors.pink.shade300,
      'verde': Colors.green.shade500,
    };

    final List<CategoryModel> mainCategories = [
      CategoryModel(name: '¿Quién es?', color: colorMap['amarillo']!, contentPath: 'assets/images/amarillo', coverImagePath: ''),
      CategoryModel(name: '¿Qué es?', color: colorMap['azul']!, contentPath: 'assets/images/azul', coverImagePath: ''),
      CategoryModel(name: '¿Qué hace?', color: colorMap['verde']!, contentPath: 'assets/images/verde', coverImagePath: ''),
      CategoryModel(name: '¿Cómo?', color: colorMap['morado']!, contentPath: 'assets/images/morado', coverImagePath: ''),
      CategoryModel(name: '¿Dónde?', color: colorMap['cafe']!, contentPath: 'assets/images/cafe', coverImagePath: ''),
      CategoryModel(name: '¿Cuándo?', color: colorMap['rojo']!, contentPath: 'assets/images/rojo', coverImagePath: ''),
      CategoryModel(name: '¿Por qué?', color: colorMap['rosa']!, contentPath: 'assets/images/rosa', coverImagePath: ''),
      CategoryModel(name: '¿Para qué?', color: colorMap['naranja']!, contentPath: 'assets/images/naranja', coverImagePath: ''),
    ];

    // ✨ 1. Añadimos la lista de íconos.
    // He elegido íconos que corresponden temáticamente a tus categorías.
    final List<IconData> iconsList = [
    Icons.face,              // ¿Quién es?
    Icons.help_outline,        // ¿Qué es?
    Icons.sports_gymnastics, // ¿Qué hace?
    Icons.settings,            // ¿Cómo?
    Icons.place,               // ¿Dónde?
    Icons.schedule,            // ¿Cuándo?
    Icons.lightbulb_outline,   // ¿Por qué?
    Icons.flag,                // ¿Para qué?
    ];

    // ✨ 2. Cambiamos la forma de generar las tarjetas para usar los íconos.
final List<TeacchCardWidget> categoryCards = List.generate(
  mainCategories.length,
  (index) {
    final category = mainCategories[index];
    final icon = iconsList[index];

    return TeacchCardWidget.icon(
      color: category.color,
      iconData: icon,
      text: category.name,
      showLabel: true,
      onTap: () async {
        // --- LÓGICA DE NAVEGACIÓN ACTUALIZADA ---
        final controller = Get.find<TeacchController>();
        await controller.loadCategoryDetails(category);

        // Mostrar el BottomSheet
        Get.bottomSheet(
          FractionallySizedBox(
            heightFactor: 0.85, // Ocupa el 85% de la altura de la pantalla
            child: CategoryDetailSheet(categoryColor: category.color),
          ),
          isScrollControlled: true, // Permite que el modal ocupe más de la mitad de la pantalla
          backgroundColor: Colors.transparent, // El color de fondo lo controla el widget
        );
      },
    );
  },
);


    return Scaffold(
    
      body: BoardGrid(
        cards: categoryCards,
      ),
    );
  }
}