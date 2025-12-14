// lib/widgets/pixel_lab/background_remover.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/services/bg_remover_service.dart';

class BackgroundRemover extends StatefulWidget {
  const BackgroundRemover({super.key});

  @override
  State<BackgroundRemover> createState() => _BackgroundRemoverState();
}

class _BackgroundRemoverState extends State<BackgroundRemover> {
  File? image;
  File? result;

  @override
  Widget build(BuildContext context) {
    final iap = Get.find<IAPController>();
    // ignore: unrelated_type_equality_checks
    if (!(iap.isUltra == true)) {
      return Scaffold(
        body: Center(
          child: ElevatedButton(
            onPressed: () => Get.to(() => ProUpgradeScreen()),
            child: const Text("Upgrade to Ultra"),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Remove Background")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Pick Image"),
          ),
          if (image != null) ...[
            Expanded(child: Image.file(image!)),
            ElevatedButton(
              onPressed: _removeBG,
              child: const Text("Remove BG"),
            ),
          ],
          if (result != null) Image.file(result!),
        ],
      ),
    );
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  void _removeBG() async {
    result = await Get.find<BgRemoverService>().remove(image!);
    setState(() {});
  }
}
