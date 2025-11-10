import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/chat/screens/chat_screen.dart';
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
    final theme = Theme.of(context);

    return Obx(() {
      final section = navController.currentSection;
      Widget body;

      switch (section) {
        case NavigationSection.teacch:
          body = const TeacchBoardScreen();
          break;
        case NavigationSection.chat:
          body = const ChatScreen();
          break;
        case NavigationSection.statistics:
          body = const StatisticsScreen();
          break;
      }

      return Scaffold(
        appBar: section == NavigationSection.chat
            ? null
            : AppBar(
                automaticallyImplyLeading: true,
                elevation: 0,
                backgroundColor: Colors.transparent,
                foregroundColor: theme.colorScheme.onSurface,
              ),
        drawer: const CustomDrawer(),
        body: body,
        bottomNavigationBar: const BottomNavBar(),
      );
    });
  }
}