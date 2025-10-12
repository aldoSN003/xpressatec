import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/llm_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/tts_controller.dart';
import 'package:xpressatec/data/datasources/local/local_storage.dart';

class PhraseResultDialog extends StatelessWidget {
  final String phrase;
  final List<String> words;
  final VoidCallback onSuccess;

  const PhraseResultDialog({
    Key? key,
    required this.phrase,
    required this.words,
    required this.onSuccess,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final llmController = Get.find<LlmController>();
    final ttsController = Get.find<TtsController>();
    final localStorage = Get.find<LocalStorage>();

    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Title
            const Text(
              'Frase Generada',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            // Generated Phrase
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Obx(() => Text(
                llmController.generatedPhrase.value,
                style: const TextStyle(
                  fontSize: 20,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              )),
            ),
            const SizedBox(height: 24),

            // Buttons Row
            Obx(() => llmController.isLoading.value
                ? const CircularProgressIndicator()
                : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Retry Button
                _buildActionButton(
                  icon: Icons.refresh,
                  label: 'Reintentar',
                  color: Colors.orange,
                  onPressed: () async {
                    final newPhrase = await llmController.generatePhrase(words);
                    if (newPhrase != null) {
                      // Automatically play the new phrase
                      await ttsController.tellPhraseWithPreview(newPhrase);
                    } else {
                      Get.snackbar(
                        'Error',
                        'No se pudo regenerar la frase',
                        snackPosition: SnackPosition.BOTTOM,
                      );
                    }
                  },
                ),

                // Replay Button
                _buildActionButton(
                  icon: Icons.volume_up,
                  label: 'Repetir',
                  color: Colors.blue,
                  onPressed: () async {
                    await ttsController.tellPhraseWithPreview(
                      llmController.generatedPhrase.value,
                    );
                  },
                ),

                // Save/Check Button
                _buildActionButton(
                  icon: Icons.check,
                  label: 'Guardar',
                  color: Colors.green,
                  onPressed: () async {
                    // Save phrase to local storage
                    await _savePhrase(
                      localStorage,
                      llmController.generatedPhrase.value,
                      words,
                    );

                    // Close dialog
                    Get.back();

                    // Show success message
                    Get.snackbar(
                      'Éxito',
                      'Frase guardada correctamente',
                      snackPosition: SnackPosition.BOTTOM,
                      backgroundColor: Colors.green,
                      colorText: Colors.white,
                    );

                    // Call success callback
                    onSuccess();
                  },
                ),
              ],
            ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onPressed,
  }) {
    return Column(
      children: [
        ElevatedButton(
          onPressed: onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: color,
            shape: const CircleBorder(),
            padding: const EdgeInsets.all(20),
          ),
          child: Icon(icon, size: 30, color: Colors.white),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _savePhrase(
      LocalStorage localStorage,
      String phrase,
      List<String> words,
      ) async {
    try {
      // Get existing phrases
      List<Map<String, dynamic>> savedPhrases =
          await localStorage.getSavedPhrases() ?? [];

      // Add new phrase
      savedPhrases.add({
        'phrase': phrase,
        'words': words,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Save back to storage
      await localStorage.savePhrases(savedPhrases);

      print('✓ Frase guardada: $phrase');
    } catch (e) {
      print('✗ Error al guardar frase: $e');
    }
  }
}