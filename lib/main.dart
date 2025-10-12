import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';
import 'package:xpressatec/core/bindings/initial_binding.dart';
import 'package:xpressatec/core/config/routes.dart';

import 'data/datasources/local/local_storage.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await LocalStorage().init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TEACCH App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: AppRoutes.routes,
      initialBinding: InitialBinding(),
    );
  }
}
