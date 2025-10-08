import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
class RegisterScreen extends GetView<AuthController> {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Registro')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.person_add_outlined, size: 80, color: Colors.blue),
              const SizedBox(height: 32),
              const Text(
                'Crear Nueva Cuenta',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 32),
              // Selector de Rol
              const Text('Selecciona tu rol:'),
              const SizedBox(height: 16),
              Obx(() => SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: 'paciente', label: Text('Paciente')),
                  ButtonSegment(value: 'tutor', label: Text('Tutor')),
                  ButtonSegment(value: 'terapeuta', label: Text('Terapeuta')),
                ],
                selected: {controller.selectedRole.value},
                onSelectionChanged: (Set<String> newSelection) {
                  controller.selectedRole.value = newSelection.first;
                },
              )),
              const SizedBox(height: 32),
              // TODO: Agregar campos de registro
              ElevatedButton(
                onPressed: () => controller.register('', '', ''),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                ),
                child: const Text('Registrarse'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}