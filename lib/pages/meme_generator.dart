// lib/widgets/pixel_lab/meme_generator.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class MemeGenerator extends StatefulWidget {
  const MemeGenerator({super.key});

  @override
  State<MemeGenerator> createState() => _MemeGeneratorState();
}

class _MemeGeneratorState extends State<MemeGenerator> {
  File? image;
  String textTop = "Top Text";
  String textBottom = "Bottom Text";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Meme Generator")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Pick Image"),
          ),
          if (image != null) ...[
            Expanded(child: Image.file(image!)),
            TextField(
              onChanged: (v) => setState(() => textTop = v),
              decoration: const InputDecoration(labelText: "Top Text"),
            ),
            TextField(
              onChanged: (v) => setState(() => textBottom = v),
              decoration: const InputDecoration(labelText: "Bottom Text"),
            ),
            ElevatedButton(
              onPressed: _generateMeme,
              child: const Text("Generate Meme"),
            ),
          ],
        ],
      ),
    );
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) setState(() => image = File(picked.path));
  }

  void _generateMeme() {
    // Add text to image logic
    Get.snackbar("Success", "Meme generated!");
  }
}
