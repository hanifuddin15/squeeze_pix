import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/services/ai_service.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';

class AIHeadshotScreen extends StatefulWidget {
  const AIHeadshotScreen({super.key});

  @override
  State<AIHeadshotScreen> createState() => _AIHeadshotScreenState();
}

class _AIHeadshotScreenState extends State<AIHeadshotScreen> {
  File? _image;
  bool _isProcessing = false;
  String _selectedStyle = "Suit & Tie";
  final IAPController _iapController = Get.find<IAPController>();

  final List<String> _styles = ["Suit & Tie", "Business Casual", "Tuxedo", "Doctor Coat", "Cyan Suit", "Red Dress"];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("AI Headshot Pro"),
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
              child: _image == null
                  ? _buildPicker()
                  : _buildEditor(),
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
          const Icon(Icons.diamond, color: Colors.cyanAccent),
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
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.person_pin_outlined, size: 80, color: Colors.white70),
          const SizedBox(height: 20),
          const Text(
            "Create Professional Headshots",
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _pickImage,
            style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: Colors.black),
            child: const Text("Select Selfie"),
          ),
        ],
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
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
        Container(
          height: 120,
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: _styles.length,
            itemBuilder: (context, index) {
              final style = _styles[index];
              final isSelected = _selectedStyle == style;
              return GestureDetector(
                onTap: () => setState(() => _selectedStyle = style),
                child: Container(
                  width: 100,
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? Colors.cyanAccent.withOpacity(0.2) : Colors.black12,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: isSelected ? Colors.cyanAccent : Colors.transparent, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    style,
                    textAlign: TextAlign.center,
                    style: TextStyle(color: isSelected ? Colors.white : Colors.white60, fontWeight: FontWeight.bold),
                  ),
                ),
              );
            },
          ),
        ),
        if (_isProcessing)
           Column(
            children: const [
              CircularProgressIndicator(color: Colors.white),
              SizedBox(height: 10),
              Text(
                "Generating Headshot... (Takes ~15-30s)",
                style: TextStyle(color: Colors.white70),
              ),
            ],
          )
        else
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: ElevatedButton.icon(
              onPressed: _processHeadshot,
              icon: const Icon(Icons.auto_awesome),
              label: const Text("Generate Headshot (1 Token)"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.cyan,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                textStyle: const TextStyle(fontWeight: FontWeight.bold),
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

  Future<void> _processHeadshot() async {
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
        final aiService = Get.put(AIService());
        
        final prompt = "wearing a $_selectedStyle";
        final resultFile = await aiService.generateHeadshot(_image!, prompt);

        if (resultFile != null) {
          setState(() {
             _image = resultFile; 
             _isProcessing = false;
          });
          showSuccessSnackkbar(message: "Headshot Generated Successfully!");
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
