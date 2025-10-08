import 'package:flutter/material.dart';

import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/chat/screens/chat_screen.dart';
import 'package:xpressatec/presentation/features/customization/screens/customization_screen.dart';
import 'package:xpressatec/presentation/features/home/controllers/navigation_controller.dart';
import 'package:xpressatec/presentation/features/home/widgets/bottom_nav_bar.dart';
import 'package:xpressatec/presentation/features/home/widgets/custom_drawer.dart';
import 'package:xpressatec/presentation/features/statistics/screens/statistics_screen.dart';
import 'package:xpressatec/presentation/features/teacch_board/screens/teacch_board_screen.dart';
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final NavigationController navController = Get.find();

    return Scaffold(
      appBar: AppBar(
        title: Obx(() {
          switch (navController.currentIndex.value) {
            case 0: return const Text('Tablero TEACCH');
            case 1: return const Text('Chat con Terapeuta');
            case 2: return const Text('Personalización');
            case 3: return const Text('Estadísticas');
            default: return const Text('TEACCH App');
          }
        }),
      ),
      drawer: const CustomDrawer(),
      body: Obx(() {
        switch (navController.currentIndex.value) {
          case 0: return const TeacchBoardScreen();
          case 1: return const ChatScreen();
          case 2: return const CustomizationScreen();
          case 3: return const StatisticsScreen();
          default: return const TeacchBoardScreen();
        }
      }),
      bottomNavigationBar: const BottomNavBar(),
    );
  }
}