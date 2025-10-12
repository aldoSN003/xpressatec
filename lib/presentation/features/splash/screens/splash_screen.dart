// presentation/features/splash/screens/splash_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:xpressatec/presentation/features/auth/controllers/auth_controller.dart';

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

    // MODIFIED: Set a duration for the one-time zoom animation.
    _controller = AnimationController(
      duration: const Duration(milliseconds: 3000), // A slightly faster duration feels good
      vsync: this,
    )..forward(); // MODIFIED: Play the animation forward ONCE instead of repeating.

    // MODIFIED: Define the animation range from 0 to a large scale factor.
    _animation = Tween<double>(begin: 0.0, end: 25.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // This logic remains the same and runs while the animation plays.
    final authController = Get.find<AuthController>();
    authController.checkAutoLogin();
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
          // The initial size is set here, the animation will scale it up from this.
          child: SvgPicture.asset(
            'assets/images/splash.svg', // Ensure this is the correct path to your logo
            width: 150,
          ),
        ),
      ),
    );
  }
}