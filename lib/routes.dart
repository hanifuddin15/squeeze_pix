// lib/routes/app_routes.dart
import 'package:get/get.dart';
import 'package:squeeze_pix/pages/editor_hub.dart';
import 'package:squeeze_pix/pages/home_page.dart';
import 'package:squeeze_pix/pages/splash_page.dart';

class AppRoutes {
  static final pages = [
    GetPage(name: '/splash', page: () => const SplashScreen()),
    GetPage(name: '/home', page: () => const HomeScreen()),
    GetPage(name: '/editor', page: () => const EditorHub()),
    // GetPage(name: '/result', page: () => const ResultScreen(compressed: null)),
  ];
}
