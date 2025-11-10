import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/core/config/routes.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Usa Get.find con una verificación de seguridad
    final AuthController authController = Get.find<AuthController>();

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Drawer(
      backgroundColor: colorScheme.background,
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                 Colors.lightBlue,
                  colorScheme.primaryContainer,
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: colorScheme.onPrimary,
                  child: Icon(Icons.person, size: 40, color: colorScheme.primary),
                ),
                const SizedBox(height: 12),
                Obx(() => Text(
                  authController.userName.value,
                  style: theme.textTheme.titleMedium?.copyWith(
                    color: colorScheme.onPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                )),
                Obx(() => Text(
                  authController.userEmail.value,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.8),
                  ),
                )),
                Obx(() => Text(
                  'Rol: ${authController.userRole.value}',
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: colorScheme.onPrimary.withOpacity(0.7),
                  ),
                )),
              ],
            ),
          ),
          // Enlazar tutor (Destacado) - Solo mostrar para pacientes
          Obx(() {
            if (authController.isPaciente) {
              return Container(
                margin: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.lightBlue,
                      colorScheme.primaryContainer,
                    ],
                  ),
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: colorScheme.primary.withOpacity(0.25),
                      blurRadius: 8,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: ListTile(
                  onTap: () => Get.toNamed(Routes.linkTutor),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: colorScheme.onPrimary,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.link, color: colorScheme.primary),
                  ),
                  title: Text(
                    'Enlazar tutor',
                    style: theme.textTheme.titleMedium?.copyWith(
                      color: colorScheme.onPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  subtitle: Text(
                    'Comparte tu código QR con tu tutor',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: colorScheme.onPrimary.withOpacity(0.8),
                    ),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.onPrimary),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          // Escanear QR - Solo mostrar para tutores
          Obx(() {
            if (authController.isTutor) {
              return Column(
                children: [
                  Container(
                    margin: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          colorScheme.primary,
                          colorScheme.primaryContainer,
                        ],
                      ),
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.25),
                          blurRadius: 8,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () => Get.toNamed(Routes.scanQr),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.onPrimary,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.qr_code_scanner, color: colorScheme.primary),
                      ),
                      title: Text(
                        'Escanear QR',
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: colorScheme.onPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Escanea el código del paciente para enlazar',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onPrimary.withOpacity(0.8),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.onPrimary),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: colorScheme.primary.withOpacity(0.1)),
                      boxShadow: [
                        BoxShadow(
                          color: colorScheme.primary.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: ListTile(
                      onTap: () => Get.toNamed(Routes.tutorCalendar),
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: colorScheme.primary.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Icon(Icons.calendar_month, color: colorScheme.primary),
                      ),
                      title: Text(
                        'Mis citas',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Consulta el calendario de sesiones programadas',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withOpacity(0.7),
                        ),
                      ),
                      trailing: Icon(Icons.arrow_forward_ios, color: colorScheme.primary),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (authController.isTutor || authController.isPaciente) {
              return ListTile(
                leading: Icon(Icons.person_search, color: colorScheme.primary),
                title: const Text('Buscar terapeuta'),
                onTap: () => Get.toNamed(Routes.communicationTherapists),
              );
            }
            return const SizedBox.shrink();
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
          ListTile(
            leading: const Icon(Icons.mic, color: Colors.orange),
            title: const Text('Generador de Audios'),
            subtitle: const Text('Generar y subir audios a Firebase', style: TextStyle(fontSize: 12)),
            onTap: () => Get.toNamed('/audio-testing'),
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