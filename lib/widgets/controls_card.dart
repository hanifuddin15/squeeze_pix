import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/compression_slider.dart';
import 'package:squeeze_pix/widgets/gradient_dropdown.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';

class ControlsCard extends GetView<CompressorController> {
  const ControlsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCompressing = controller.isCompressing.value;
      final double progress = controller.isCompressing.value
          ? controller.quality.value / 100
          : 0.0;
      return Card(
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Text(
                  'Quality: ${controller.quality.value}%',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                CompressionSlider(
                  value: controller.quality.value.toDouble(),
                  onChanged: isCompressing
                      ? null
                      : (v) => controller.quality.value = v.round(),
                ),
                const SizedBox(height: 12),
                GradientDropdown(
                  selectedValue: controller.outputFormat,
                  items: ['jpg', 'png'],
                  isDisabled: isCompressing,
                  onChanged: (newValue) =>
                      controller.outputFormat.value = newValue,
                ),

                const SizedBox(height: 12),
                TextField(
                  decoration: InputDecoration(
                    labelText: 'Target Size (KB)',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Theme.of(
                      context,
                    ).colorScheme.surface.withOpacity(0.8),
                  ),
                  keyboardType: TextInputType.number,
                  enabled: !isCompressing,
                  onChanged: (value) {
                    final parsed = double.tryParse(value);
                    controller.targetSizeKB.value = parsed;
                  },
                ),
                const SizedBox(height: 16),
                if (isCompressing) ...[
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 60,
                        height: 60,
                        child: CircularProgressIndicator(
                          value: progress,
                          strokeWidth: 6,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Theme.of(context).colorScheme.secondary,
                          ),
                        ),
                      ),
                      Text(
                        '${(progress * 100).toInt()}%',
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: Theme.of(context).colorScheme.onPrimary,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
                Row(
                  children: [
                    Expanded(
                      child: PrimaryButton(
                        label: isCompressing ? 'Compressing...' : 'Compress',
                        onPressed: isCompressing
                            ? () {}
                            : () async {
                                await controller.compressSelected();
                                if (controller.lastCompressed.value != null) {
                                  Get.snackbar(
                                    'Compression Complete',
                                    'Image compressed successfully!',
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        icon: Icons.compress,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: PrimaryButton(
                        label: isCompressing
                            ? 'Working...'
                            : 'Compress & Share',
                        onPressed: isCompressing
                            ? () {}
                            : () async {
                                await controller.compressSelected();
                                final f = controller.lastCompressed.value;
                                if (f != null) {
                                  await Share.shareXFiles([
                                    XFile(f.path),
                                  ], text: 'Check out this compressed image!');
                                  Get.snackbar(
                                    'Shared',
                                    'Image shared successfully!',
                                    backgroundColor: Theme.of(
                                      context,
                                    ).colorScheme.primary,
                                    colorText: Colors.white,
                                  );
                                }
                              },
                        icon: Icons.share,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
