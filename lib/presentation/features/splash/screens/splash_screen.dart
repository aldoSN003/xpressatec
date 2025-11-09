import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';
import 'package:xpressatec/data/datasources/local/audio_package_manager.dart';
import 'package:xpressatec/core/config/routes.dart';
import 'package:xpressatec/presentation/features/customization/controllers/customization_controller.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000),
      vsync: this,
    )..forward();

    _animation = Tween<double>(begin: 0.0, end: 25.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // 🆕 Check package first, then auth
    _checkPackageAndAuth();
  }

  /// Check if audio package is downloaded, then check auth
  Future<void> _checkPackageAndAuth() async {
    await Future.delayed(const Duration(seconds: 2));

    try {
      final customizationController = Get.find<CustomizationController>();
      await customizationController.initCustomization();

      // Get package manager
      final packageManager = Get.find<AudioPackageManager>();

      // Check if package is downloaded
      final bool isPackageDownloaded = await packageManager.isPackageDownloaded();

      if (!isPackageDownloaded) {
        // No package downloaded - go to download screen
        print('📦 No audio package found, navigating to download screen');
        Get.offAllNamed(Routes.packageDownload);
        return;
      }

      // Package exists - proceed with normal auth check
      print('✅ Audio package found, checking authentication');
      final authController = Get.find<AuthController>();
      authController.checkAutoLogin();

    } catch (e) {
      print('❌ Error checking package: $e');
      // On error, go to login anyway
      Get.offAllNamed(Routes.login);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Transform.scale(
              scale: _animation.value,
              child: child,
            );
          },
          child: SvgPicture.asset(
            'assets/images/splash.svg',
            width: 150,
          ),
        ),
      ),
    );
  }
}