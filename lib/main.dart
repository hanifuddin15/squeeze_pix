import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/pages/home_page.dart';
import 'app_bindings.dart';
import 'routes.dart';
import 'theme.dart';
import 'package:get_storage/get_storage.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await GetStorage.init();
  runApp(const SqueezePixApp());
}

class SqueezePixApp extends StatelessWidget {
  const SqueezePixApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SqueezePix',
      theme: AppTheme.lightTheme,
      initialBinding: AppBindings(),
      getPages: AppPages.pages,
      home: const HomePage(),
    );
  }
}
