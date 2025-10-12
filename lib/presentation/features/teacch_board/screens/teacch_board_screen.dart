import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/core/constants/app_constants.dart';
import 'package:xpressatec/data/models/image_model.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/teacch_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/widgets/category_detail_sheet.dart';
import '../controllers/tts_controller.dart';
import '../widgets/board_grid.dart';
import '../widgets/selected_items_bar.dart';
import '../widgets/teacch_card_widget.dart';

class TeacchBoardScreen extends StatelessWidget {
  const TeacchBoardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<TeacchController>();
    final ttsController = Get.find<TtsController>();

    // ✅ Use AppConstants instead of direct variables
    final List<TeacchCardWidget> categoryCards = List.generate(
      AppConstants.mainCategories.length,
          (index) {
        final category = AppConstants.mainCategories[index];
        final icon = AppConstants.categoryIcons[index];

        return TeacchCardWidget.icon(
          color: category.color,
          iconData: icon,
          text: category.name,
          showLabel: true,
          onTap: () async {
            await controller.loadCategoryDetails(category);
            ttsController.tellPhrase11labs(category.name);

            Get.bottomSheet(
              FractionallySizedBox(
                heightFactor: 0.85,
                child: CategoryDetailSheet(categoryColor: category.color),
              ),
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
            );
          },
        );
      },
    );

    return Scaffold(
      body: Column(
        children: [
          // ✨ Scrollable selected items bar (only visible when items are selected)
          SelectedItemsBar(),

          Expanded(
            child: BoardGrid(
              cards: categoryCards,
            ),
          ),
        ],
      ),

      // ✨ NEW: Floating Action Button (visible only with 2+ items)
      floatingActionButton: Obx(() {
        // Only show FAB if 2 or more items are selected
        if (controller.selectedItems.length >= 2) {
          return FloatingActionButton.extended(
            onPressed: () {
              // Generate and show phrase dialog
              controller.generateAndShowPhrase();
            },
            backgroundColor: Colors.green,
            icon: const Icon(Icons.auto_awesome, color: Colors.white),
            label: const Text(
              'Generar Frase',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          );
        } else {
          // Return empty SizedBox when less than 2 items
          return const SizedBox.shrink();
        }
      }),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}