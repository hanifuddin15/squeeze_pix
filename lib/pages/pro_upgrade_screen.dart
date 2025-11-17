import 'package:flutter/material.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/shimmer_button.dart';

class ProUpgradeScreen extends StatelessWidget {
  const ProUpgradeScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
              ShimmerButton(
                onPressed: () {},
                child: const Text("Buy Ultra - ৳299"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
