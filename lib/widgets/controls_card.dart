// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/widgets/compression_slider.dart';
import 'package:squeeze_pix/widgets/gradient_dropdown.dart';

class ControlsCard extends GetView<CompressorController> {
  final int compressionMode; // 0: Quality, 1: Target Size, 2: Format
  const ControlsCard({required this.compressionMode, super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final bool isCompressing = controller.isCompressing.value;

      switch (compressionMode) {
        case 0: // Quality
          return _buildQualityControls(context, isCompressing);
        case 1: // Target Size
          return _buildTargetSizeControls(context, isCompressing);
        case 2: // Format
          return _buildFormatControls(context, isCompressing);
        default:
          return const SizedBox.shrink();
      }
    });
  }

  Widget _buildQualityControls(BuildContext context, bool isCompressing) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Quality: ${controller.quality.value}%',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        CompressionSlider(
          value: controller.quality.value.toDouble(),
          onChanged: isCompressing
              ? null
              : (v) => controller.quality.value = v.round(),
        ),
      ],
    );
  }

  Widget _buildTargetSizeControls(BuildContext context, bool isCompressing) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Set a target file size for the output image.',
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: 16),
        TextField(
          decoration: InputDecoration(
            labelText: 'Target Size (KB)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
            filled: true,
            fillColor: Theme.of(context).colorScheme.surfaceVariant,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          enabled: !isCompressing,
          onChanged: (value) {
            final parsed = int.tryParse(value);
            controller.targetSizeKB.value = parsed;
          },
        ),
      ],
    );
  }

  Widget _buildFormatControls(BuildContext context, bool isCompressing) {
    return Column(
      children: [
        GradientDropdown(
          selectedValue: controller.outputFormat,
          items: ['jpg', 'png', 'webp'],
          isDisabled: isCompressing,
          onChanged: (newValue) => controller.outputFormat.value = newValue,
        ),
        const SizedBox(height: 12),
        SwitchListTile(
          title: const Text('Strip Image Metadata (EXIF)'),
          value: controller.stripExif.value,
          onChanged: isCompressing
              ? null
              : (val) => controller.stripExif.value = val,
          activeColor: Theme.of(context).colorScheme.secondary,
          dense: true,
        ),
      ],
    );
  }
}
