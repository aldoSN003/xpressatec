// lib/presentation/features/teacch_board/widgets/selected_items_bar.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/teacch_controller.dart';
import '../controllers/tts_controller.dart';
import 'teacch_card_widget.dart';

class SelectedItemsBar extends StatelessWidget {
  const SelectedItemsBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Find the controller
    final controller = Get.find<TeacchController>();
    final ttsController = Get.find<TtsController>();
    return Obx(
          () {
        // Hide the widget if no items are selected
        if (controller.selectedItems.isEmpty) {
          return const SizedBox.shrink();
        }

        // Display the horizontally scrollable list of selected items
        return SizedBox(
          height: 140,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: controller.selectedItems.map((item) {
                return Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4.0),
                  child: SizedBox(
                    width: 120,
                    child: Stack(
                      children: [
                        // The card itself
                        TeacchCardWidget.image(
                          imageModel: item.imageModel,
                          color: item.color,
                          text: item.text,
                          showLabel: true,
                          borderThickness: 4,
                          onTap: () {
                            print('Selected item:${item.text}' );
                      ttsController.tellPhrase11labs(item.text);
                          },
                        ),

                        // ✨ Red remove button in top-right corner
                        Positioned(
                          top: 4,
                          right: 4,
                          child: GestureDetector(
                            onTap: () {
                              controller.removeSelectedItem(item);
                            },
                            child: Container(
                              width: 28,
                              height: 28,
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.close,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }
}