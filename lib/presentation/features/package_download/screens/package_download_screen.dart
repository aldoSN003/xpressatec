import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/package_download/controllers/audio_package_controller.dart';

import '../../settings/widgets/settings_detail_layout.dart';

class PackageDownloadScreen extends StatelessWidget {
  const PackageDownloadScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<AudioPackageController>();
    final colorScheme = Theme.of(context).colorScheme;

    return SettingsDetailLayout(
      title: 'Descargar paquetes de audio',
      subtitle:
          'Gestiona las voces disponibles para tus asistentes y mantenlas listas sin conexión.',
      child: Obx(() {
        return Container(
          width: double.infinity,
          decoration: SettingsDetailLayout.cardDecoration(colorScheme),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: _buildContent(context, controller, colorScheme),
        );
      }),
    );
  }

  Widget _buildContent(
    BuildContext context,
    AudioPackageController controller,
    ColorScheme colorScheme,
  ) {
    if (controller.isChecking.value) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Verificando paquetes disponibles...'),
          ],
        ),
      );
    }

    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.center,
          child: Icon(
            Icons.download_rounded,
            size: 72,
            color: colorScheme.primary,
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'Descarga el paquete de audio de tu asistente preferido y úsalo sin conexión.',
          style: theme.textTheme.bodyLarge?.copyWith(
            color: colorScheme.onSurfaceVariant,
          ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 24),
        if (controller.availableAssistants.length > 1) ...[
          Text(
            'Selecciona un asistente:',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
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
          const SizedBox(height: 24),
        ],
        if (controller.isDownloading.value) ...[
          LinearProgressIndicator(
            value: controller.downloadProgress.value,
            minHeight: 8,
          ),
          const SizedBox(height: 16),
          Text(
            'Descargando ${controller.currentFile.value} de ${controller.totalFiles.value}',
            style: theme.textTheme.bodyMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            controller.currentWord.value,
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurfaceVariant,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
        ],
        if (controller.errorMessage.isNotEmpty) ...[
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: colorScheme.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              controller.errorMessage.value,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: colorScheme.error,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 16),
        ],
        FilledButton.icon(
          onPressed:
              controller.isDownloading.value ? null : controller.downloadPackage,
          icon: const Icon(Icons.download),
          label: Text(
            controller.isDownloading.value
                ? 'Descargando...'
                : 'Descargar paquete',
          ),
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 16),
          ),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed:
              controller.isDownloading.value ? null : controller.skipDownload,
          child: const Text('Omitir (descargar después)'),
        ),
      ],
    );
  }
}