import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';

class BottomActionBar extends GetView<CompressorController> {
  const BottomActionBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppTheme.gradient,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Obx(
            () => Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: controller.isPicking.value
                        ? 'Loading...'
                        : 'Pick Images',
                    onPressed: controller.isPicking.value
                        ? () {}
                        : () => controller.pickImages(),
                    icon: controller.isPicking.value
                        ? Icons.hourglass_empty
                        : Icons.photo_library_outlined,
                  ),
                ),
                if (controller.isPicking.value) ...[
                  const SizedBox(width: 16),
                  CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ],
                const SizedBox(width: 16),
                IconButton.filled(
                  style: IconButton.styleFrom(
                    padding: const EdgeInsets.all(16),
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: controller.isPicking.value
                      ? null
                      : () => controller.pickSingleFromCamera(),
                  icon: const Icon(Icons.camera_alt_outlined),
                  tooltip: 'Use Camera',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
