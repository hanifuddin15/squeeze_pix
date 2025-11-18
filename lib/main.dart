// lib/main.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:squeeze_pix/app_bindings.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Get.put(IAPController(), permanent: true);
  await GetStorage.init();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Squeeze Pix 2.0',
      debugShowCheckedModeBanner: false,
      initialBinding: AppBindings(),
      getPages: AppRoutes.pages,
      initialRoute: '/splash',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        scaffoldBackgroundColor: Colors.grey[50],
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: GoogleFonts.poppins().fontFamily,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.teal,
          brightness: Brightness.dark,
        ),
      ),
      themeMode: ThemeMode.system,
    );
  }
}
