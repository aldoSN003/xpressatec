import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:xpressatec/core/bindings/auth_binding.dart';
import 'package:xpressatec/core/bindings/home_binding.dart';
import 'package:xpressatec/presentation/features/auth/screens/login_screen.dart';

import 'package:xpressatec/presentation/features/home/screens/home_screen.dart';


import 'package:xpressatec/presentation/features/settings/screens/about_screen.dart';
import 'package:xpressatec/presentation/features/settings/screens/settings_screen.dart';
import 'package:xpressatec/presentation/features/splash/screens/splash_screen.dart';

import '../../presentation/features/audio_testing/audio_testing_screen.dart';
import '../../presentation/features/auth/screens/register_screen.dart';
import '../../presentation/features/profile/screens/link_therapist_screen.dart';

// Route constants
class Routes {
  static const String splash = '/';
  static const String login = '/login';
  static const String register = '/register';
  static const String home = '/home';
  static const String linkTherapist = '/link-therapist';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String audioTesting = '/audio-testing';
}

class AppRoutes {
  static final routes = [
    GetPage(
      name: Routes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: Routes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: Routes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: Routes.linkTherapist,
      page: () => const LinkTherapistScreen(),
    ),
    GetPage(
      name: Routes.settings,
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: Routes.about,
      page: () => const AboutScreen(),
    ),

    GetPage(
      name: Routes.audioTesting,
      page: () => const AudioTestingScreen(),
    ),
  ];
}