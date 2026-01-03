// lib/widgets/pixel_lab/background_remover.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


import 'package:squeeze_pix/services/bg_remover_service.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';

class BackgroundRemover extends StatefulWidget {
  const BackgroundRemover({super.key});

  @override
  State<BackgroundRemover> createState() => _BackgroundRemoverState();
}

class _BackgroundRemoverState extends State<BackgroundRemover> {
  File? image;
  File? result;
  final IAPController _iapController = Get.find<IAPController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(title: const Text("Remove Background",),backgroundColor: Colors.transparent,
        elevation: 0,),
      body: Container(
        padding: EdgeInsets.only(top: 100),
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Obx(() => Text(
                _iapController.isUltraUser 
                    ? "Daily Tokens: ${_iapController.dailyTokensUsed}/${IAPController.maxDailyTokens}" 
                    : "Premium Feature (Ultra Only)",
                style: const TextStyle(fontWeight: FontWeight.bold),
              )),
            ),
            ElevatedButton(
              onPressed: _pickImage,
              child: const Text("Pick Image"),
            ),
            if (image != null) ...[
              Expanded(child: Image.file(image!)),
              ElevatedButton(
                onPressed: _removeBG,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
                child: const Text("Remove BG (1 Token)"),
              ),
            ],
            if (result != null) Expanded(child: Image.file(result!)),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  void _removeBG() async {
    if (!_iapController.isUltraUser) {
      Get.to(() => const ProUpgradeScreen());
      return;
    }

    if (!_iapController.hasTokens()) {
      showErrorSnackkbar(message: "Daily token limit reached (20/20). Resets tomorrow.");
      return;
    }

    // Proceed
    if (_iapController.useToken()) {
       try {
          result = await Get.find<BgRemoverService>().remove(image!);
          setState(() {});
          showSuccessSnackkbar(message: "Background removed! Tokens remaining: ${_iapController.remainingTokens}");
       } catch (e) {
          showErrorSnackkbar(message: "Error processing image: $e");
       }
    }
  }
}
