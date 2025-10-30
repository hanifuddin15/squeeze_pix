import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/widgets/batch_options_dialog.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/bottom_action_bar.dart';
import 'package:squeeze_pix/widgets/custom_appbar.dart';
import 'package:squeeze_pix/widgets/empty_state.dart';
import 'package:squeeze_pix/widgets/image_grid.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';
import 'package:squeeze_pix/widgets/compression_slider.dart';
import 'package:squeeze_pix/widgets/savings_card.dart';
import 'package:squeeze_pix/widgets/unity_ads.dart';

class HomePage extends GetView<CompressorController> {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(kToolbarHeight),
        child: Obx(() {
          if (controller.isSelectionMode.value) {
            return AppBar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              leading: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => controller.toggleSelectionMode(false),
              ),
              title: Text('${controller.batchSelection.length} selected'),
              actions: [
                IconButton(
                  icon: const Icon(Icons.delete_outline),
                  tooltip: 'Delete Selected',
                  onPressed: () {
                    Get.dialog(
                      AlertDialog(
                        title: const Text('Delete Images?'),
                        content: Text(
                          'Are you sure you want to delete ${controller.batchSelection.length} selected image(s)? This cannot be undone.',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.of(context).pop(),
                            child: const Text('Cancel'),
                          ),
                          FilledButton(
                            onPressed: () {
                              controller.deleteBatchSelection();
                              Navigator.of(context).pop();
                            },
                            child: const Text('Delete'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                IconButton(
                  icon: const Icon(Icons.select_all),
                  tooltip: 'Select All',
                  onPressed: () => controller.selectAllForBatch(),
                ),
              ],
            );
          } else {
            return CustomAppBar(
              title: 'Squeeze Pix',
              images: controller.images,
              onClearAll: controller.showClearConfirmation,
            );
          }
        }),
      ),
      body: Obx(() {
        // This ensures the body rebuilds when batchStats changes
        final _ = controller.batchStats;
        return Container(
          // Main container for the body
          decoration: BoxDecoration(gradient: AppTheme.gradient),
          child: Obx(() {
            if (controller.images.isEmpty) {
              return const EmptyState();
            }

            return CustomScrollView(
              slivers: [
                SliverToBoxAdapter(
                  child: SizedBox(
                    height: Get.mediaQuery.padding.top + kToolbarHeight,
                  ),
                ),
                const SliverToBoxAdapter(child: SavingsCard()),
                Obx(() {
                  // This Obx ensures the grid and its children rebuild
                  // when the batch selection list changes.
                  final _ = controller.batchSelection.length;
                  return const ImageGrid();
                }),
                // 👇 Moved this batch card section inside scroll view
                SliverPadding(
                  padding: const EdgeInsets.all(12),
                  sliver: SliverToBoxAdapter(
                    child: Card(
                      child: Container(
                        decoration: BoxDecoration(
                          gradient: AppTheme.gradient.scale(0.8),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Column(
                            children: [
                              Text(
                                'Batch Quality: ${controller.batchQuality.value}%',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      color: Theme.of(
                                        context,
                                      ).colorScheme.onPrimary,
                                      fontWeight: FontWeight.bold,
                                    ),
                              ),
                              const SizedBox(height: 12),
                              CompressionSlider(
                                value: controller.batchQuality.value.toDouble(),
                                onChanged: controller.isCompressing.value
                                    ? null
                                    : (v) => controller.batchQuality.value = v
                                          .round(),
                              ),
                              const SizedBox(height: 8),
                              SwitchListTile(
                                title: Text(
                                  'Strip Image Metadata (EXIF)',
                                  style: TextStyle(
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.onPrimary,
                                  ),
                                ),
                                value: controller.stripExif.value,
                                onChanged: (val) =>
                                    controller.stripExif.value = val,
                                activeThumbColor: Theme.of(
                                  context,
                                ).colorScheme.secondary,
                                dense: true,
                              ),
                              const SizedBox(height: 16),

                              const UnitBannerAdsWidget(),
                              const SizedBox(height: 16),
                              Obx(() {
                                final count = controller.isSelectionMode.value
                                    ? controller.batchSelection.length
                                    : controller.images.length;
                                return PrimaryButton(
                                  label: controller.isCompressing.value
                                      ? 'Compressing...'
                                      : 'Compress ($count)',
                                  onPressed: controller.isCompressing.value
                                      ? () {}
                                      : () => Get.dialog(
                                          const BatchOptionsDialog(),
                                        ),
                                  icon: Icons.compress,
                                );
                              }),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            );
          }),
        );
      }), // Closing for the main Container and outer Obx
      bottomNavigationBar: const BottomActionBar(),
    );
  }
}
