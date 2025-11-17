// lib/screens/splash_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/pages/home_page.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    _controller = AnimationController(vsync: this, duration: 2.seconds);
    _controller.forward().then((_) => Get.offAll(() => HomeScreen()));
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Center(
          child: ScaleTransition(
            scale: _controller,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.compress, size: 100, color: Colors.white),
                Text(
                  "Squeeze Pix 2.0",
                  style: TextStyle(fontSize: 32, color: Colors.white),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
