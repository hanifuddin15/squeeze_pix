import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/glass_card.dart';
import 'package:squeeze_pix/widgets/shimmer_button.dart';

class EditorHub extends StatelessWidget {
  const EditorHub({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: GlassCard(
            child: Column(
              children: [
                const Text(
                  "Editor Hub",
                  style: TextStyle(fontSize: 28, color: Colors.white),
                ),
                const SizedBox(height: 20),
                ShimmerButton(
                  onPressed: () {},
                  child: const Text("Compress Image"),
                ),
                ShimmerButton(
                  onPressed: () {},
                  child: const Text("Remove Background"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
