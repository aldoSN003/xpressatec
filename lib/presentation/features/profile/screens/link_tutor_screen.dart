import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/link_tutor_controller.dart';

class LinkTutorScreen extends GetView<LinkTutorController> {
  const LinkTutorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Enlazar tutor')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }

            final error = controller.errorMessage.value;
            if (error.isNotEmpty) {
              return _ErrorState(
                message: error,
                onRetry: controller.refreshQr,
              );
            }

            final qrData = controller.qrBytes.value;
            if (qrData == null) {
              return _ErrorState(
                message: 'No se pudo cargar el código QR. Inténtalo nuevamente.',
                onRetry: controller.refreshQr,
              );
            }

            return _QrContent(
              qrBytes: qrData,
              onRefresh: controller.refreshQr,
            );
          }),
        ),
      ),
    );
  }
}

class _QrContent extends StatelessWidget {
  const _QrContent({
    required this.qrBytes,
    required this.onRefresh,
  });

  final Uint8List qrBytes;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 16,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.memory(
              qrBytes,
              width: 220,
              height: 220,
              fit: BoxFit.contain,
            ),
          ),
        ),
        const SizedBox(height: 24),
        const Text(
          'Pide a tu tutor que escanee este código para completar el enlace.',
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 16),
        ),
        const SizedBox(height: 24),
        OutlinedButton.icon(
          onPressed: onRefresh,
          icon: const Icon(Icons.refresh),
          label: const Text('Actualizar código'),
        ),
      ],
    );
  }
}

class _ErrorState extends StatelessWidget {
  const _ErrorState({
    required this.message,
    required this.onRetry,
  });

  final String message;
  final Future<void> Function() onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, color: Theme.of(context).colorScheme.error, size: 48),
          const SizedBox(height: 16),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: onRetry,
            icon: const Icon(Icons.refresh),
            label: const Text('Reintentar'),
          ),
        ],
      ),
    );
  }
}
