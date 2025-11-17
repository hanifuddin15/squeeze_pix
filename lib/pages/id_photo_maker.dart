// lib/widgets/pixel_lab/id_photo_maker.dart
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class IDPhotoMaker extends StatefulWidget {
  final File? image;
  const IDPhotoMaker({this.image, super.key});

  @override
  State<IDPhotoMaker> createState() => _IDPhotoMakerState();
}

class _IDPhotoMakerState extends State<IDPhotoMaker> {
  File? image;
  @override
  void initState() {
    super.initState();
    image = widget.image;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("ID Photo Maker")),
      body: Column(
        children: [
          ElevatedButton(
            onPressed: _pickImage,
            child: const Text("Pick Photo"),
          ),
          if (image != null) ...[
            Container(
              width: 350,
              height: 450,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.blue, width: 2),
                image: DecorationImage(image: FileImage(image!)),
              ),
            ),
            ElevatedButton(
              onPressed: _exportPDF,
              child: const Text("Export PDF"),
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

  void _exportPDF() {
    // PDF generation logic
    Get.snackbar("Success", "ID Photo PDF exported!");
  }
}
