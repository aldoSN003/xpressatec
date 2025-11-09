import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

import '../controllers/scan_qr_controller.dart';

class ScanQrScreen extends GetView<ScanQrController> {
  const ScanQrScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Escanear QR'), centerTitle: true),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              colorScheme.primary.withOpacity(0.08),
              colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 24, 24, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Escanea el código del paciente para ver su información.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: colorScheme.onSurface,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Apunta la cámara hacia el código QR y mantenla estable hasta que se detecte.',
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Container(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 8,
                    ),
                    constraints: const BoxConstraints(maxWidth: 420),
                    child: AspectRatio(
                      aspectRatio: 0.95,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(28),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            MobileScanner(
                              controller: controller.scannerController,
                              onDetect: controller.onDetect,
                            ),
                            Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    Colors.black26,
                                    Colors.transparent,
                                    Colors.black38,
                                  ],
                                  stops: [0.0, 0.5, 1.0],
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.center,
                              child: Container(
                                margin: const EdgeInsets.all(32),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(
                                    color: colorScheme.primary,
                                    width: 4,
                                  ),
                                ),
                              ),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Container(
                                width: double.infinity,
                                padding: const EdgeInsets.all(12),
                                color: Colors.black54,
                                child: Text(
                                  'Apunta la cámara hacia el código QR.',
                                  textAlign: TextAlign.center,
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 16,
                ),
                child: Obx(() {
                  final message = controller.statusMessage.value;
                  final isError = controller.hasError.value;
                  final scannedUuid = controller.scannedUuid.value;
                  final bool hasResult = scannedUuid != null;

                  final Color containerColor = isError
                      ? colorScheme.errorContainer
                      : hasResult
                      ? colorScheme.primaryContainer
                      : colorScheme.surface;
                  final Color textColor = isError
                      ? colorScheme.onErrorContainer
                      : hasResult
                      ? colorScheme.onPrimaryContainer
                      : colorScheme.onSurface;

                  IconData iconData;
                  if (hasResult) {
                    iconData = Icons.check_circle;
                  } else if (isError) {
                    iconData = Icons.error_outline;
                  } else {
                    iconData = Icons.qr_code_2;
                  }

                  return AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 24,
                    ),
                    decoration: BoxDecoration(
                      color: containerColor,
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.shadow.withOpacity(0.08),
                          blurRadius: 16,
                          offset: const Offset(0, 8),
                        ),
                      ],
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(iconData, color: textColor),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                message,
                                textAlign: TextAlign.center,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: textColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (scannedUuid != null) ...[
                          const SizedBox(height: 20),
                          Text(
                            'UUID del paciente',
                            style: theme.textTheme.labelLarge?.copyWith(
                              color: textColor.withOpacity(0.8),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SelectableText(
                            scannedUuid,
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: textColor,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.6,
                            ),
                          ),
                        ],
                      ],
                    ),
                  );
                }),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 0, 24, 28),
                child: Row(
                  children: [
                    Expanded(
                      child: Obx(() {
                        final isOn = controller.isTorchOn.value;
                        return FilledButton.icon(
                          onPressed: controller.toggleTorch,
                          icon: Icon(isOn ? Icons.flash_off : Icons.flash_on),
                          label: Text(
                            isOn ? 'Apagar linterna' : 'Encender linterna',
                          ),
                        );
                      }),
                    ),

                    const SizedBox(width: 12),
                    Expanded(
                      child: Obx(() {
                        final hasResult =
                            controller.scannedUuid.value != null ||
                            controller.hasError.value;
                        final String label = hasResult
                            ? 'Escanear de nuevo'
                            : 'Cancelar';
                        final IconData icon = hasResult
                            ? Icons.refresh
                            : Icons.close;
                        return OutlinedButton.icon(
                          onPressed: hasResult
                              ? () {
                                  controller.resumeScanning();
                                }
                              : () {
                                  Get.back();
                                },
                          icon: Icon(icon),
                          label: Text(label),
                        );
                      }),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
