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
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: DrawerMenuItem(
                  icon: Icons.link,
                  label: 'Enlazar tutor',
                  subtitle: 'Comparte tu código QR con tu tutor',
                  isActive: Get.currentRoute == Routes.linkTutor,
                  onTap: () => Get.toNamed(Routes.linkTutor),
                ),
              );
            } else {
              return const SizedBox.shrink();
            }
          }),
          // Escanear QR y Mis citas - Solo mostrar para tutores
          Obx(() {
            if (authController.isTutor) {
              return Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: DrawerMenuItem(
                      icon: Icons.qr_code_scanner,
                      label: 'Escanear QR',
                      subtitle: 'Escanea el código del paciente para enlazar',
                      isActive: Get.currentRoute == Routes.scanQr,
                      onTap: () => Get.toNamed(Routes.scanQr),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    child: DrawerMenuItem(
                      icon: Icons.event_note,
                      label: 'Mis citas',
                      subtitle: 'Consulta el calendario de sesiones programadas',
                      isActive: Get.currentRoute == Routes.tutorCalendar,
                      onTap: () => Get.toNamed(Routes.tutorCalendar),
                    ),
                  ),
                ],
              );
            }
            return const SizedBox.shrink();
          }),
          Obx(() {
            if (authController.isTutor || authController.isPaciente) {
              return Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                child: DrawerMenuItem(
                  icon: Icons.person_search,
                  label: 'Buscar terapeuta',
                  isActive: Get.currentRoute == Routes.communicationTherapists,
                  onTap: () => Get.toNamed(Routes.communicationTherapists),
                ),
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

class DrawerMenuItem extends StatelessWidget {
  const DrawerMenuItem({
    super.key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.isActive = false,
    this.subtitle,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final bool isActive;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final Color activeColor = colorScheme.primary;
    final Color inactiveColor = colorScheme.onSurface.withOpacity(0.8);
    final Color foregroundColor = isActive ? activeColor : inactiveColor;
    final Color subtitleColor = isActive
        ? activeColor.withOpacity(0.8)
        : colorScheme.onSurface.withOpacity(0.6);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            color: isActive ? activeColor.withOpacity(0.08) : Colors.transparent,
            borderRadius: BorderRadius.circular(16),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment:
                subtitle != null ? CrossAxisAlignment.start : CrossAxisAlignment.center,
            children: [
              Icon(icon, color: foregroundColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      label,
                      style: theme.textTheme.titleMedium?.copyWith(
                        color: foregroundColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: Text(
                          subtitle!,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: subtitleColor,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: foregroundColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
