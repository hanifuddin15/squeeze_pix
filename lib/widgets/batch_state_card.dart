import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';

class BatchStatsCard extends GetView<CompressorController> {
  const BatchStatsCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (controller.batchStats.isEmpty) return const SizedBox.shrink();
      return Card(
        margin: const EdgeInsets.all(10),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.gradient,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch Compression Summary',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Images Processed: ${controller.batchStats['count']}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Size Reduced: ${(controller.batchStats['sizeReduction'] / 1024).toStringAsFixed(1)} KB',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                if (controller.lastZipFile.value != null) ...[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      PrimaryButton(
                        label: 'Share Zip',
                        onPressed: () => controller.shareZipFile(),
                        icon: Icons.share,
                      ),
                      const SizedBox(width: 12),
                      PrimaryButton(
                        label: 'Open Folder',
                        onPressed: () => controller.openZipFolderLocation(),
                        icon: Icons.folder_open,
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                ],
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: () => controller.clearBatchStats(),
                    child: Text(
                      'Dismiss',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.secondary,
                      ),
                    ),
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
