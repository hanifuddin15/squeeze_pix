import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';

class ClearAllAlertDialog extends GetView<CompressorController> {
  const ClearAllAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Clear All?'),
      content: const Text('This will remove all picked images. Are you sure?'),
      actions: [
        TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
        FilledButton(
          onPressed: () {
            controller.images.clear();
            controller.selected.value = null;
            Get.back();
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
