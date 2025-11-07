import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/core/theme/app_colors.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';
class BottomNavBar extends StatelessWidget {
  const BottomNavBar({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController controller = Get.find();

    return Obx(() => NavigationBar(
      selectedIndex: controller.currentIndex.value,
      onDestinationSelected: controller.changePage,
      indicatorColor: AppColors.secondary,
      backgroundColor: Colors.white,
      destinations: const [
        NavigationDestination(
          icon: Icon(Icons.dashboard_outlined),
          selectedIcon: Icon(Icons.dashboard, color: Colors.white,),
          label: 'Tablero',
        ),
        NavigationDestination(
          icon: Icon(Icons.chat_bubble_outline),
          selectedIcon: Icon(Icons.chat_bubble, color: Colors.white),
          label: 'Chat',
        ),
        NavigationDestination(
          icon: Icon(Icons.palette_outlined),
          selectedIcon: Icon(Icons.palette, color: Colors.white),
          label: 'Personalizar',
        ),
        NavigationDestination(
          icon: Icon(Icons.bar_chart_outlined),
          selectedIcon: Icon(Icons.bar_chart, color: Colors.white),
          label: 'Estadísticas',
        ),
      ],
    ));
  }
}

