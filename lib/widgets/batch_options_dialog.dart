import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';

class BatchOptionsDialog extends GetView<CompressorController> {
  const BatchOptionsDialog({super.key});

  @override
  Widget build(BuildContext context) {
    final textController = TextEditingController(
      text: controller.zipFileName.value,
    );

    return AlertDialog(
      title: const Text('Batch Compression Options'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: textController,
            decoration: const InputDecoration(
              labelText: 'ZIP File Name (without extension)',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) => controller.zipFileName.value = value,
          ),
          const SizedBox(height: 16),
          const Text(
            'You will be prompted to select a save location after continuing.',
            style: TextStyle(fontSize: 12),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        PrimaryButton(
          label: 'Continue',
          onPressed: () {
            if (controller.zipFileName.value.isEmpty) {
              controller.zipFileName.value = 'squeezepix_batch';
            }
            // Get.back();
            controller.compressAll();
            Navigator.of(context).popUntil((route) => route.isFirst);
          },
        ),
      ],
    );
  }
}
