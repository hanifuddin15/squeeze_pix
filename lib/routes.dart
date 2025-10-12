import 'package:get/get.dart';
import 'pages/home_page.dart';
import 'pages/compressor_page.dart';

class AppPages {
  static final pages = [
    GetPage(name: '/', page: () => const HomePage()),
    GetPage(name: '/compress', page: () => const CompressorPage()),
  ];
}
