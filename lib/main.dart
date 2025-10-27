import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squeeze_pix/routes.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  // Choose Game ID based on platform
  String gameId = Platform.isAndroid
      ? '5970117' //Android game ID
      : '5970116'; // Apple game ID

  await UnityAds.init(
    gameId: gameId,
    testMode: false, //ToDo:::: Turn off (false) for release build
    onComplete: () => debugPrint('Unity Ads Initialized for $gameId'),
    onFailed: (error, message) => debugPrint('Initialization Failed: $message'),
  );
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
