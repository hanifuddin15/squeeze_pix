import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/glassmorphic_button.dart';

class ProUpgradeScreen extends StatelessWidget {
  const ProUpgradeScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final iapController = Get.find<IAPController>();
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                "Upgrade to Ultra",
                style: TextStyle(fontSize: 32, color: Colors.white),
              ),
              const SizedBox(height: 20),
              GlassmorphicButton(
                onPressed: () => iapController.buyUltra(),
                width: 220,
                height: 50,
                child: const Text(
                  "Buy Ultra - ৳299",
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
