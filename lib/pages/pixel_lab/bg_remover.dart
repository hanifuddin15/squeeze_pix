// lib/widgets/pixel_lab/background_remover.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';


import 'package:squeeze_pix/services/bg_remover_service.dart';
import '../../controllers/unity_ads_controller.dart';

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

    // The blocker is removed to allow ad-supported access for all users.
    // Pro/Ultra users will bypass ads via performAction in _removeBG.

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
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      result = await Get.find<BgRemoverService>().remove(image!);
      setState(() {});
    });
  }
}
