// presentation/features/splash/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Find the AuthController instance (created by InitialBinding)
    // and call our new centralized method.
    final authController = Get.find<AuthController>();
    authController.checkAutoLogin();
  }

  @override
  Widget build(BuildContext context) {
    // The UI remains the same. It just shows a loading indicator
    // while the AuthController decides where to go.
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(), // Or your app logo
      ),
    );
  }
}