import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/widgets/controls_card.dart';
import 'package:squeeze_pix/widgets/original_image_card.dart';
import 'package:squeeze_pix/widgets/result_card.dart';
import '../controllers/compressor_controller.dart';

class CompressorPage extends GetView<CompressorController> {
  const CompressorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Compress & Save'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            controller.lastCompressed.value = null; // Clear result on back
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        final selectedFile = controller.selected.value;
        if (selectedFile == null) {
          return const Center(child: Text('No image selected.'));
        }
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            OriginalImageCard(file: selectedFile),
            const SizedBox(height: 16),
            ControlsCard(),
            const SizedBox(height: 16),
            ResultCard(resultFile: controller.lastCompressed.value ?? File('')),
          ],
        );
      }),
    );
  }
}
