
import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:xpressatec/core/bindings/auth_binding.dart';
import 'package:xpressatec/core/bindings/home_binding.dart';
import 'package:xpressatec/presentation/features/auth/screens/login_screen.dart';
import 'package:xpressatec/presentation/features/auth/screens/register_screen.dart';
import 'package:xpressatec/presentation/features/home/screens/home_screen.dart';
import 'package:xpressatec/presentation/features/profile/screens/link_therapist_screen.dart';
import 'package:xpressatec/presentation/features/settings/screens/about_screen.dart';
import 'package:xpressatec/presentation/features/settings/screens/settings_screen.dart';

class AppRoutes {
  static final routes = [
    GetPage(
      name: '/login',
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/register',
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: '/home',
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: '/link-therapist',
      page: () => const LinkTherapistScreen(),
    ),
    GetPage(
      name: '/settings',
      page: () => const SettingsScreen(),
    ),
    GetPage(
      name: '/about',
      page: () => const AboutScreen(),
    ),
  ];
}