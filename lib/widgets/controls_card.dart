import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/widgets/compression_slider.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';

class ControlsCard extends GetView<CompressorController> {
  const ControlsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCompressing = controller.isCompressing.value;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Quality: ${controller.quality.value}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              CompressionSlider(
                value: controller.quality.value.toDouble(),
                onChanged: isCompressing
                    ? null
                    : (v) => controller.quality.value = v.round(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: isCompressing ? 'Compressing...' : 'Compress',
                      onPressed: isCompressing
                          ? () {}
                          : () => controller.compressSelected(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: isCompressing ? 'Working...' : 'Compress & Share',
                      onPressed: isCompressing
                          ? () {}
                          : () async {
                              await controller.compressSelected();
                              final f = controller.lastCompressed.value;
                              if (f != null) {
                                await SharePlus.instance.share(
                                  ShareParams(
                                    text: 'Check out this compressed image!',
                                    files: [XFile(f.path)],
                                  ),
                                );
                              }
                            },
                    ),
                  ),
                ],
              ),
              if (isCompressing) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      );
    });
  }
}
