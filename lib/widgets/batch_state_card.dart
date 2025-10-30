import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';
import 'package:path/path.dart' as p;

class BatchStatsCard extends GetView<CompressorController> {
  const BatchStatsCard({super.key});

  String _formatBytes(int bytes) {
    if (bytes < 1024) {
      return '$bytes B';
    } else if (bytes < 1024 * 1024) {
      return '${(bytes / 1024).toStringAsFixed(1)} KB';
    } else if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(2)} MB';
    } else {
      return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
    }
  }

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
                  'Original Size: ${_formatBytes(controller.batchStats['totalOriginalSize'] ?? 0)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Compressed Size: ${_formatBytes(controller.batchStats['totalCompressedSize'] ?? 0)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Total Size Reduced: ${_formatBytes(controller.batchStats['sizeReduction'] ?? 0)}',
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(context).colorScheme.onPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Theme.of(
                      context, // This was missing a comma
                    ).colorScheme.surface.withValues(alpha: .5),
                    borderRadius: BorderRadius.circular(12),
                  ),

                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      children: [
                        const Text(
                          'Save Location',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Obx(
                          () => Text(
                            controller.batchSavePath.value != null
                                ? '.../${p.basename(controller.batchSavePath.value!)}'
                                : 'Default (Downloads)',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 12,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 52,
                          width: double.infinity,
                          child: PrimaryButton(
                            label: 'Change',
                            onPressed: () => controller.setBatchSavePath(),
                            icon: Icons.folder_open,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
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
                        label: 'Extract Here',
                        onPressed: () => controller.extractZipFile(),
                        icon: Icons.unarchive,
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
