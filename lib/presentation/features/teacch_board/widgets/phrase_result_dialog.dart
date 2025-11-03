import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/llm_controller.dart';
import 'package:xpressatec/presentation/features/teacch_board/controllers/tts_controller.dart';
import 'package:xpressatec/data/datasources/local/local_storage.dart';
import 'package:xpressatec/domain/usecases/phrase/save_phrase_usecase.dart'; // 🆕 ADD
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart'; // 🆕 ADD

class PhraseResultDialog extends StatefulWidget { // 🔧 CHANGED to StatefulWidget
  final String phrase;
  final List<String> words;
  final String audioFilePath; // 🆕 ADD
  final VoidCallback onSuccess;

  const PhraseResultDialog({
    Key? key,
    required this.phrase,
    required this.words,
    required this.audioFilePath, // 🆕 ADD
    required this.onSuccess,
  }) : super(key: key);

  @override
  State<PhraseResultDialog> createState() => _PhraseResultDialogState();
}

class _PhraseResultDialogState extends State<PhraseResultDialog> {
  bool _isSaving = false; // 🆕 ADD - Track save state
  String _currentAudioPath = ''; // 🆕 ADD - Track current audio path

  @override
  void initState() {
    super.initState();
    _currentAudioPath = widget.audioFilePath; // 🆕 ADD - Initialize with passed path
  }

  @override
  Widget build(BuildContext context) {
    final llmController = Get.find<LlmController>();
    final ttsController = Get.find<TtsController>();


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
                  onPressed: _isSaving ? null : () async { // 🔧 DISABLE when saving
                    final newPhrase = await llmController.generatePhrase(widget.words);
                    if (newPhrase != null) {
                      // Generate and play the new phrase
                      final newAudioPath = await ttsController.tellPhrase11labs(newPhrase);

                      // 🆕 UPDATE current audio path
                      if (newAudioPath != null) {
                        setState(() {
                          _currentAudioPath = newAudioPath;
                        });
                      }
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
                  onPressed: _isSaving ? null : () async { // 🔧 DISABLE when saving
                    await ttsController.tellPhrase11labs(
                      llmController.generatedPhrase.value,
                    );
                  },
                ),

                // Save Button
                _buildActionButton(
                  icon: _isSaving ? Icons.hourglass_empty : Icons.check, // 🔧 CHANGE icon when saving
                  label: _isSaving ? 'Guardando...' : 'Guardar', // 🔧 CHANGE label when saving
                  color: Colors.green,
                  onPressed: _isSaving ? null : () => _savePhraseToFirebase(), // 🔧 NEW METHOD
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
    required VoidCallback? onPressed, // 🔧 CHANGED to nullable
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

  // 🆕 NEW METHOD - Save to Firebase (Firestore + Storage)
  Future<void> _savePhraseToFirebase() async {
    setState(() {
      _isSaving = true;
    });

    try {
      // Get dependencies
      final authController = Get.find<AuthController>();
      final ttsController = Get.find<TtsController>();
      final savePhraseUseCase = Get.find<SavePhraseUseCase>();
      final llmController = Get.find<LlmController>();
      final localStorage = Get.find<LocalStorage>();

      // Get userId
      final userId = authController.currentUser.value?.uuid;
      if (userId == null || userId.isEmpty) {
        throw Exception('Usuario no autenticado');
      }

      // Save phrase to Firebase (Firestore + Storage)
      await savePhraseUseCase(
        userId: userId,
        phrase: llmController.generatedPhrase.value,
        words: widget.words,
        assistant: ttsController.selectedAssistant.value,
        localAudioPath: _currentAudioPath, // Use current audio path (updated on retry)
      );

      // Also save to local storage as backup
      await _savePhraseLocally(
        localStorage,
        llmController.generatedPhrase.value,
        widget.words,
      );

      if (!mounted) return;

      // Close dialog
      Get.back();

      // Show success message
      Get.snackbar(
        '✅ Guardado',
        'Frase guardada en la nube correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );

      // Call success callback
      widget.onSuccess();
    } catch (e) {
      print('❌ Error saving phrase to Firebase: $e');

      if (!mounted) return;

      Get.snackbar(
        '❌ Error',
        'No se pudo guardar la frase: ${e.toString()}',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isSaving = false;
        });
      }
    }
  }

  // 🔧 RENAMED - Keep local storage as backup
  Future<void> _savePhraseLocally(
      LocalStorage localStorage,
      String phrase,
      List<String> words,
      ) async {
    try {
      // Get existing phrases
      List<Map<String, dynamic>> savedPhrases =
      await localStorage.getSavedPhrases();

      // Add new phrase
      savedPhrases.add({
        'phrase': phrase,
        'words': words,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Save back to storage
      await localStorage.savePhrases(savedPhrases);

      print('✓ Frase guardada localmente: $phrase');
    } catch (e) {
      print('✗ Error al guardar frase localmente: $e');
    }
  }
}