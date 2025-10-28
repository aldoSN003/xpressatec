import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/package_download/controllers/audio_package_controller.dart';

class PackageDownloadScreen extends StatelessWidget {
  const PackageDownloadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AudioPackageController>();

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            // Show loading while checking available assistants
            if (controller.isChecking.value) {
              return const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Verificando paquetes disponibles...'),
                  ],
                ),
              );
            }

            // Show download UI
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Icon
                Icon(
                  Icons.download_rounded,
                  size: 80,
                  color: Theme.of(context).primaryColor,
                ),
                const SizedBox(height: 24),

                // Title
                const Text(
                  'Descarga de Paquete de Audio',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 16),

                // Description
                const Text(
                  'Para optimizar el rendimiento, descarga el paquete de audio de tu asistente preferido.',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Assistant selector (only if multiple available)
                if (controller.availableAssistants.length > 1) ...[
                  const Text(
                    'Selecciona un asistente:',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: controller.availableAssistants.map((assistant) {
                      final isSelected = controller.selectedAssistant.value == assistant;
                      return ChoiceChip(
                        label: Text(assistant),
                        selected: isSelected,
                        onSelected: controller.isDownloading.value
                            ? null
                            : (selected) {
                          if (selected) {
                            controller.selectedAssistant.value = assistant;
                          }
                        },
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 32),
                ],

                // Download progress
                if (controller.isDownloading.value) ...[
                  LinearProgressIndicator(
                    value: controller.downloadProgress.value,
                    minHeight: 8,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Descargando ${controller.currentFile.value} de ${controller.totalFiles.value}',
                    style: const TextStyle(fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    controller.currentWord.value,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.grey,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),
                ],

                // Error message
                if (controller.errorMessage.isNotEmpty) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      controller.errorMessage.value,
                      style: TextStyle(color: Colors.red.shade900),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // Download button
                ElevatedButton.icon(
                  onPressed: controller.isDownloading.value
                      ? null
                      : () => controller.downloadPackage(),
                  icon: const Icon(Icons.download),
                  label: Text(
                    controller.isDownloading.value
                        ? 'Descargando...'
                        : 'Descargar Paquete',
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
                const SizedBox(height: 12),

                // Skip button
                TextButton(
                  onPressed: controller.isDownloading.value
                      ? null
                      : () => controller.skipDownload(),
                  child: const Text('Omitir (descargar después)'),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}