// lib/widgets/pixel_lab/background_remover.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


import 'package:squeeze_pix/services/ai_service.dart';
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
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,

      appBar: AppBar(title: const Text("Remove Background",),backgroundColor: Colors.transparent,
        elevation: 0,),
      body: Container(
        padding: const EdgeInsets.only(top: 100),
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
              if (_isLoading)
                 const Padding(
                   padding: EdgeInsets.all(8.0),
                   child: CircularProgressIndicator(color: Colors.white),
                 )
              else
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
    if (picked != null) {
      setState(() {
         image = File(picked.path);
         result = null; 
      });
    }
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
       setState(() => _isLoading = true);
       try {
          // Use Replicate AI Service instead of BgRemoverService
          final aiService = Get.put(AIService());
          
          final resultFile = await aiService.removeBackground(image!);
          
          if (resultFile != null) {
              setState(() {
                result = resultFile; 
                _isLoading = false;
              });
              showSuccessSnackkbar(message: "Background removed! Tokens remaining: ${_iapController.remainingTokens}");
          } else {
             throw Exception("Result was null");
          }

       } catch (e) {
          setState(() => _isLoading = false);
          showErrorSnackkbar(message: "Error processing image: $e");
       }
    }
  }
}
