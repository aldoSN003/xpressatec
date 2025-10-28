import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../../../core/config/routes.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          ListTile(
            leading: const Icon(Icons.notifications),
            title: const Text('Notificaciones'),
            trailing: Switch(value: true, onChanged: (_) {}),
          ),
          ListTile(
            leading: const Icon(Icons.language),
            title: const Text('Idioma'),
            trailing: const Text('Español'),
          ),
          ListTile(
            leading: const Icon(Icons.dark_mode),
            title: const Text('Tema oscuro'),
            trailing: Switch(value: false, onChanged: (_) {}),
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.privacy_tip),
            title: const Text('Privacidad'),
          ),
          ListTile(
            leading: const Icon(Icons.help),
            title: const Text('Ayuda'),
          ),

          // Add this widget in your SettingsScreen build method:

          ListTile(
            leading: const Icon(Icons.download),
            title: const Text('Descargar Paquetes de Audio'),
            subtitle: const Text('Gestionar voces de asistentes'),
            onTap: () {
              Get.toNamed(Routes.packageDownload);
            },
          ),
        ],
      ),
    );
  }
}
