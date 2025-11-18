import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/editor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/controllers/glassmorphic_button.dart';
import 'package:squeeze_pix/widgets/glass_card.dart';

class EditorHub extends StatelessWidget {
  final File? imageFile;
  const EditorHub({this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    Get.lazyPut(() => EditorController());
    final controller = Get.find<EditorController>();
    controller.selected.value = imageFile;

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
                GlassmorphicButton(
                  width: 250,
                  height: 50,
                  onPressed: () => controller.compress(),
                  child: const Text(
                    "Compress Image",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                GlassmorphicButton(
                  width: 250,
                  height: 50,
                  onPressed: () => controller.removeBackground(),
                  child: const Text(
                    "Remove Background",
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
      ),
    );
  }
}
