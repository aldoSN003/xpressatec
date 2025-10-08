import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa Get.find con una verificación de seguridad
    final AuthController authController = Get.find<AuthController>();
    
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(
              color: Colors.blue,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Colors.white,
                  child: Icon(Icons.person, size: 40, color: Colors.blue),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                  authController.userName.value,
                  style: const TextStyle(color: Colors.white, fontSize: 16),
                )),
                Obx(() => Text(
                  authController.userEmail.value,
                  style: const TextStyle(color: Colors.white70, fontSize: 14),
                )),
                Obx(() => Text(
                  'Rol: ${authController.userRole.value}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                )),
              ],
            ),
          ),
          // Enlazar con Terapeuta (Destacado) - Solo mostrar para pacientes y tutores
          Obx(() {
            if (authController.userRole.value.toLowerCase() != 'terapeuta') {
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue.shade400, Colors.blue.shade600],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () => Get.toNamed('/link-therapist'),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.link, color: Colors.blue),
                  ),
                  title: const Text(
                    'Enlazar con Terapeuta',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: const Text(
                    'Conecta con tu especialista',
                    style: TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings),
            title: const Text('Ajustes'),
            onTap: () => Get.toNamed('/settings'),
          ),
          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('Acerca de'),
            onTap: () => Get.toNamed('/about'),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: Colors.red),
            title: const Text('Cerrar Sesión', style: TextStyle(color: Colors.red)),
            onTap: () => authController.logout(),
          ),
        ],
      ),
    );
  }
}