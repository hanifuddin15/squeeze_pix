import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class History extends GetView<CompressorController> {
  const History({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.history.isEmpty) return const SizedBox.shrink();

      return Card(
        margin: const EdgeInsets.all(16),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradient,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Recently Compressed',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  height: 100,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemBuilder: (_, i) => ClipRRect(
                      borderRadius: BorderRadius.circular(12),
                      child: Image.file(
                        File(controller.history[i]),
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                      ),
                    ),
                    separatorBuilder: (_, __) => const SizedBox(width: 12),
                    itemCount: controller.history.length,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }
}
