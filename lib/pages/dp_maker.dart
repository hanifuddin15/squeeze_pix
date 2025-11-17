// lib/widgets/pixel_lab/dp_maker.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class DPMaker extends StatefulWidget {
  final File? image;
  const DPMaker({this.image, super.key});

  @override
  State<DPMaker> createState() => _DPMakerState();
}

class _DPMakerState extends State<DPMaker> {
  File? selectedImage;
  @override
  void initState() {
    super.initState();
    selectedImage = widget.image;
  }

  Future<void> pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() => selectedImage = File(picked.path));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("DP Maker")),
      body: Column(
        children: [
          ElevatedButton(onPressed: pickImage, child: const Text("Pick Image")),
          if (selectedImage != null) ...[
            Expanded(
              child: InteractiveViewer(
                child: ClipOval(child: Image.file(selectedImage!)),
              ),
            ),
            ElevatedButton(
              onPressed: () => _saveDP(),
              child: const Text("Save as DP"),
            ),
          ],
        ],
      ),
    );
  }

  void _saveDP() {
    // Save logic + ad
    Get.snackbar("Success", "DP saved to gallery!");
  }
}
