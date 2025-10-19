import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';

class BottomActionBar extends GetView<CompressorController> {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(
          () => Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: c.isPicking.value ? 'Loading...' : 'Pick Images',
                  onPressed: c.isPicking.value ? () {} : () => c.pickImages(),
                  icon: c.isPicking.value
                      ? null // Or a spinner icon
                      : Icons.photo_library_outlined,
                ),
              ),
              if (c.isPicking.value) ...[
                const SizedBox(width: 12),
                const CircularProgressIndicator(),
              ],
              const SizedBox(width: 12),
              IconButton.filled(
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: c.isPicking.value
                    ? null
                    : () => c.pickSingleFromCamera(),
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Use Camera',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
