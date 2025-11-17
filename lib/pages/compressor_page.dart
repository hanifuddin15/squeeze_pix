import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/before_after_card.dart';
import 'package:squeeze_pix/widgets/controls_card.dart';
import 'package:squeeze_pix/widgets/custom_appbar.dart';
import 'package:squeeze_pix/widgets/result_card.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/widgets/unity_ads.dart';

class CompressorPage extends GetView<CompressorController> {
  const CompressorPage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: const CustomAppBar(
        title: 'Compress & Share',
        isLeadingIcon: true,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Obx(() {
          final selectedFile = controller.selected.value;
          if (selectedFile == null) {
            return const Center(
              child: Text(
                'No image selected.',
                style: TextStyle(color: Colors.white, fontSize: 18),
              ),
            );
          }
          return DefaultTabController(
            length: 2,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
              children: [
                SizedBox(height: Get.mediaQuery.padding.top + kToolbarHeight),
                BeforeAfterCard(
                  before: selectedFile,
                  after: controller.lastCompressed.value,
                ),
                const SizedBox(height: 16),
                _buildInfoCard(context, selectedFile),
                const SizedBox(height: 16),
                _buildCompressionTabs(context),
                const SizedBox(height: 16),
                const UnitBannerAdsWidget(),
                const SizedBox(height: 16),
                _buildFormatCard(context),
                const SizedBox(height: 16),
                _buildResizeCard(context),
                const SizedBox(height: 16),
                _buildWatermarkCard(context),
                const SizedBox(height: 16),
                _buildActionButtons(context),
                const SizedBox(height: 16),
                if (controller.isCompressing.value) ...[
                  const Center(child: CircularProgressIndicator()),
                  const SizedBox(height: 16),
                ],
                ResultCard(
                  originalFile: selectedFile,
                  resultFile: controller.lastCompressed.value,
                ),
                const SizedBox(height: 16),
                const UnitBannerAdsWidget(),
                const SizedBox(height: 16),
              ],
            ),
          );
        }),
      ),
    );
  }

  Widget _buildCompressionTabs(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              TabBar(
                onTap: (index) => controller.compressionMode.value = index,
                labelColor: Theme.of(context).colorScheme.secondary,
                unselectedLabelColor: Theme.of(context).colorScheme.onSurface,
                indicatorColor: Theme.of(context).colorScheme.secondary,

                tabs: const [
                  Tab(text: 'By Quality', icon: Icon(Icons.high_quality)),
                  Tab(text: 'By Target Size', icon: Icon(Icons.straighten)),
                ],
              ),
              SizedBox(
                height: 150, // Give tab content a fixed height
                child: TabBarView(
                  physics: const NeverScrollableScrollPhysics(),
                  children: [
                    // Quality Tab
                    ControlsCard(compressionMode: 0),
                    // Target Size Tab
                    ControlsCard(compressionMode: 1),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Obx(() {
      final isCompressing = controller.isCompressing.value;
      return Row(
        children: [
          Expanded(
            child: PrimaryButton(
              label: isCompressing ? 'Compressing...' : 'Compress',
              onPressed: isCompressing
                  ? () {}
                  : () => controller.compressSelectedWithAd(),
              icon: Icons.compress,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: PrimaryButton(
              label: isCompressing ? 'Working...' : 'Compress & Share',
              onPressed: isCompressing
                  ? () {}
                  : () async {
                      await controller.compressSelectedWithAd();
                      final f = controller.lastCompressed.value;
                      if (f != null) {
                        await SharePlus.instance.share(
                          ShareParams(
                            files: [XFile(f.path)],
                            text: 'Check out this compressed image!',
                          ),
                        );
                        Get.snackbar(
                          'Shared',
                          'Image shared successfully!',
                          backgroundColor: context.theme.colorScheme.primary,
                          colorText: Colors.white,
                        );
                      }
                    },
              icon: Icons.share,
            ),
          ),
        ],
      );
    });
  }

  Widget _buildFormatCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Output Options',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              const ControlsCard(compressionMode: 2), // For format options
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, File file) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Original: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              Obx(
                () => IconButton(
                  icon: Icon(
                    controller.favorites.contains(file.path)
                        ? Icons.star
                        : Icons.star_border,
                    color: Theme.of(context).colorScheme.secondary,
                  ),
                  onPressed: () => controller.toggleFavorite(file.path),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildResizeCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Resize (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: controller.widthController,
                      decoration: InputDecoration(
                        labelText: 'Width (px)',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.error,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ).paddingOnly(right: 8),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: TextField(
                      controller: controller.heightController,
                      decoration: InputDecoration(
                        labelText: 'Height (px)',
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                        errorBorder: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.error,
                          ),
                        ),
                        border: OutlineInputBorder(
                          borderSide: BorderSide(
                            color: context.theme.colorScheme.secondary,
                          ),
                        ),
                      ),
                      keyboardType: TextInputType.number,
                      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    ).paddingOnly(left: 8),
                  ),
                ],
              ),
              Obx(
                () => SwitchListTile(
                  title: Text(
                    'Keep Aspect Ratio',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  value: controller.keepAspectRatio.value,
                  onChanged: (val) => controller.keepAspectRatio.value = val,
                  dense: true,
                ),
              ),
              const SizedBox(height: 16),
              const UnitBannerAdsWidget(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWatermarkCard(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: Theme.of(context).colorScheme.secondary,
            width: 2,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Watermark (Optional)',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => SwitchListTile(
                  title: Text(
                    'Enable Watermark',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                  value: controller.enableWatermark.value,
                  onChanged: (val) => controller.enableWatermark.value = val,
                  dense: true,
                ),
              ),
              Obx(() {
                if (!controller.enableWatermark.value) {
                  return const SizedBox.shrink();
                }
                return TextField(
                  decoration: const InputDecoration(
                    labelText: 'Watermark Text',
                    border: OutlineInputBorder(),
                  ),
                  onChanged: (val) => controller.watermarkText.value = val,
                );
              }),
            ],
          ),
        ),
      ),
    );
  }
}
