import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../../customization/controllers/customization_controller.dart';

class DownloadPictogramsScreen extends StatefulWidget {
  const DownloadPictogramsScreen({super.key});

  @override
  State<DownloadPictogramsScreen> createState() =>
      _DownloadPictogramsScreenState();
}

class _DownloadPictogramsScreenState extends State<DownloadPictogramsScreen> {
  late final CustomizationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = Get.find<CustomizationController>();
    _controller.refreshDownloadStatus();
  }

  Future<void> _handleDownload() async {
    final status = await _controller.downloadPictogramsIfNeeded(
      showProgressDialog: false,
      showFeedback: false,
    );

    if (!mounted) return;

    switch (status) {
      case PictogramDownloadStatus.alreadyDownloaded:
        Get.snackbar(
          'Pictogramas disponibles',
          'Los pictogramas ya están descargados en este dispositivo.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case PictogramDownloadStatus.success:
        Get.snackbar(
          'Descarga exitosa',
          'Pictogramas descargados correctamente.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
      case PictogramDownloadStatus.failure:
        Get.snackbar(
          'Error',
          'Ocurrió un error al descargar los pictogramas. Intenta nuevamente.',
          snackPosition: SnackPosition.BOTTOM,
        );
        break;
    }

    await _controller.refreshDownloadStatus();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white10,
        iconTheme: const IconThemeData(color: Colors.black),
        centerTitle: true,
        title: SvgPicture.asset(
          'assets/images/imagen.svg',
          height: 180,
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white,
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
              child: Obx(() {
                final bool isDownloading = _controller.isDownloading.value;
                final bool downloaded =
                    _controller.assetsReady.value || _controller.hasDownloadedPictograms;
                final bool failed = _controller.downloadFailed.value;
                final int total = _controller.totalCount.value;
                final int completed = _controller.downloadedCount.value;
                final double? progress = total == 0 ? null : completed / total;

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Descargar pictogramas',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Para personalizar tu experiencia, puedes descargar los pictogramas desde el servidor a tu almacenamiento local. Solo es necesario hacerlo una vez.',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 24),
                    Container(
                      width: double.infinity,
                      decoration: _cardDecoration(colorScheme),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 32,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (downloaded)
                            _buildStatusBanner(
                              colorScheme,
                              icon: Icons.check_circle,
                              background: colorScheme.primary.withOpacity(0.1),
                              iconColor: colorScheme.primary,
                              text:
                                  'Los pictogramas ya están descargados en este dispositivo.',
                            )
                          else if (failed)
                            _buildStatusBanner(
                              colorScheme,
                              icon: Icons.error_outline,
                              background: colorScheme.error.withOpacity(0.1),
                              iconColor: colorScheme.error,
                              text:
                                  'Ocurrió un error al descargar los pictogramas. Intenta nuevamente.',
                            )
                          else
                            _buildStatusBanner(
                              colorScheme,
                              icon: Icons.cloud_download_outlined,
                              background: colorScheme.primary.withOpacity(0.08),
                              iconColor: colorScheme.primary,
                              text:
                                  'Descarga los pictogramas para usarlos sin conexión.',
                            ),
                          if (isDownloading) ...[
                            const SizedBox(height: 24),
                            LinearProgressIndicator(value: progress),
                            const SizedBox(height: 12),
                            Text(
                              total == 0
                                  ? 'Preparando descarga...'
                                  : '$completed de $total pictogramas',
                              style: theme.textTheme.bodyMedium?.copyWith(
                                color: colorScheme.onSurface,
                              ),
                            ),
                          ],
                          const SizedBox(height: 24),
                          FilledButton.icon(
                            onPressed:
                                (!isDownloading && !downloaded) ? _handleDownload : null,
                            style: FilledButton.styleFrom(
                              backgroundColor: Colors.lightBlue,
                              foregroundColor: Colors.white,
                              minimumSize: const Size.fromHeight(48),
                            ),
                            icon: const Icon(Icons.download),
                            label: Text(
                              downloaded
                                  ? 'Pictogramas ya descargados'
                                  : 'Descargar pictogramas',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(ColorScheme colorScheme) {
    return BoxDecoration(
      color: colorScheme.surface,
      borderRadius: BorderRadius.circular(24),
      boxShadow: [
        BoxShadow(
          color: colorScheme.primary.withOpacity(0.18),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ],
      border: Border.all(
        color: colorScheme.primary.withOpacity(0.35),
        width: 1.4,
      ),
    );
  }

  Widget _buildStatusBanner(
    ColorScheme colorScheme, {
    required IconData icon,
    required Color background,
    required Color iconColor,
    required String text,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: background,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: iconColor),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurface,
                  ),
            ),
          ),
        ],
      ),
    );
  }
}
