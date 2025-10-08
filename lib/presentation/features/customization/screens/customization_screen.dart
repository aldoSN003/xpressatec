import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/customization/controllers/customization_controller.dart';
class CustomizationScreen extends GetView<CustomizationController> {
  const CustomizationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.photo_library, size: 80, color: Colors.orange),
          const SizedBox(height: 24),
          const Text(
            'Personalización del Tablero',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          const Text(
            'Cargar y actualizar imágenes',
            style: TextStyle(color: Colors.grey),
          ),
          const SizedBox(height: 32),
          ElevatedButton.icon(
            onPressed: () {},
            icon: const Icon(Icons.upload),
            label: const Text('Subir Imagen'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }
}