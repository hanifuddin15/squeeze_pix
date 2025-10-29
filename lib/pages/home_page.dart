import 'package:flutter/material.dart';
import 'package:get/get.dart';
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
      extendBodyBehindAppBar: false,
      appBar: CustomAppBar(
        title: 'SqueezePix',
        images: controller.images,
        onClearAll: controller.showClearConfirmation,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Obx(() {
          if (controller.images.isEmpty) {
            return const EmptyState();
          }

          return CustomScrollView(
            slivers: [
              const SliverToBoxAdapter(child: SavingsCard()),
              const ImageGrid(), // includes grid + stats + history
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
                              activeColor: Theme.of(
                                context,
                              ).colorScheme.secondary,
                              dense: true,
                            ),
                            const SizedBox(height: 16),
                            const UnitBannerAdsWidget(),
                            const SizedBox(height: 16),
                            PrimaryButton(
                              label: controller.isCompressing.value
                                  ? 'Compressing...'
                                  : 'Compress All (${controller.images.length})',
                              onPressed: controller.isCompressing.value
                                  ? () {}
                                  : () => controller.compressAll(),
                              icon: Icons.compress,
                            ),
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
      ),
      bottomNavigationBar: const BottomActionBar(),
    );
  }
}
