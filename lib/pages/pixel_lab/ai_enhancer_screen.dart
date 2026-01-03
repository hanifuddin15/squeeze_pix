import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/services/ai_service.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';

class AIEnhancerScreen extends StatefulWidget {
  const AIEnhancerScreen({super.key});

  @override
  State<AIEnhancerScreen> createState() => _AIEnhancerScreenState();
}

class _AIEnhancerScreenState extends State<AIEnhancerScreen> {
  File? _image;
  bool _isProcessing = false;
  final IAPController _iapController = Get.find<IAPController>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("AI Photo Enhancer"),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Column(
          children: [
            const SizedBox(height: 100),
            _buildTokenInfo(),
            Expanded(
              child: Center(
                child: _image == null
                    ? _buildPicker()
                    : _buildPreview(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTokenInfo() {
    return Obx(() => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white24),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.bolt, color: Colors.amber),
          const SizedBox(width: 8),
          Text(
            _iapController.isUltraUser
                ? "${_iapController.dailyTokensUsed}/${IAPController.maxDailyTokens} Used"
                : "Ultra Feature (20 Gen/Day)",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    ));
  }

  Widget _buildPicker() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Icons.enhance_photo_translate, size: 80, color: Colors.white70),
        const SizedBox(height: 20),
        const Text(
          "Enhance blur photos to HD",
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
          child: const Text("Select Photo"),
        ),
      ],
    );
  }

  Widget _buildPreview() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: Image.file(_image!),
            ),
          ),
        ),
        if (_isProcessing)
          Column(
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 10),
              Text(
                "Enhancing Photo... (Takes ~5-10s)",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: _processEnhance,
              icon: const Icon(Icons.auto_fix_high),
              label: const Text("Enhance (1 Token)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.amber,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
              ),
            ),
          ),
        TextButton(
          onPressed: () => setState(() => _image = null),
          child: const Text("Pick Another", style: TextStyle(color: Colors.white70)),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _processEnhance() async {
    if (!_iapController.isUltraUser) {
      Get.to(() => const ProUpgradeScreen());
      return;
    }

    if (!_iapController.hasTokens()) {
      showErrorSnackkbar(message: "Daily token limit reached. Please come back tomorrow!");
      return;
    }

    if (_iapController.useToken()) {
      setState(() => _isProcessing = true);
      
      try {
        // Use the real AI Service
        final aiService = Get.put(AIService()); 
        
        // This might take 5-10 seconds
        final resultFile = await aiService.enhancePhoto(_image!);
        
        if (resultFile != null) {
          setState(() {
             _image = resultFile; 
             _isProcessing = false;
          });
          showSuccessSnackkbar(message: "Photo Enhanced Successfully!");
        } else {
           throw Exception("Result was null");
        }
      } catch (e) {
         setState(() => _isProcessing = false);
         showErrorSnackkbar(message: "AI Error: $e");
      }
    }
  }
}
