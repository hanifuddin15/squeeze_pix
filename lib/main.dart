import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squeeze_pix/pages/compressor_page.dart';
import 'package:squeeze_pix/pages/home_page.dart';
import 'package:squeeze_pix/pages/splash_page.dart';
import 'package:squeeze_pix/routes.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // await MobileAds.instance.initialize();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'SqueezePix',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      initialBinding: BindingsBuilder(() {
        Get.put(CompressorController());
      }),
      getPages: AppPages.pages,

      initialRoute: '/splash',
    );
  }
}
