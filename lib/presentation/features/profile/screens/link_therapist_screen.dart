import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/profile/controllers/profile_controller.dart';
class LinkTherapistScreen extends GetView<ProfileController> {
  const LinkTherapistScreen({super.key});

  @override
  Widget build(BuildContext context) {
    Get.put(ProfileController());
    
    return Scaffold(
      appBar: AppBar(title: const Text('Enlazar con Terapeuta')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Espacio para imagen SVG
              Container(
                width: 200,
                height: 200,
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.shade300, width: 2),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: Colors.grey.shade400),
                    const SizedBox(height: 8),
                    Text(
                      'Espacio para SVG',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Conecta con tu Terapeuta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              const Text(
                'Ingresa el código proporcionado por tu terapeuta',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 32),
              // Campo para código
              TextField(
                decoration: InputDecoration(
                  hintText: 'Código del terapeuta',
                  prefixIcon: const Icon(Icons.vpn_key),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onChanged: (value) => controller.therapistCode.value = value,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => controller.linkTherapist(controller.therapistCode.value),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Vincular'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
