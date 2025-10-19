import 'package:get/get.dart';
import 'package:squeeze_pix/pages/splash_page.dart';
import 'pages/home_page.dart';
import 'pages/compressor_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/', page: () => const HomePage()),
    GetPage(name: '/compress', page: () => const CompressorPage()),
    GetPage(name: '/splash', page: () => const SplashScreen()),
  ];
}
