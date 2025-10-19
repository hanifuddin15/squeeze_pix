import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/bottom_action_bar.dart';
import 'package:squeeze_pix/widgets/custom_appbar.dart';
import 'package:squeeze_pix/widgets/empty_state.dart';
import 'package:squeeze_pix/widgets/image_grid.dart';
import 'package:squeeze_pix/widgets/primary_button.dart';

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
        child: Column(
          children: [
            Expanded(
              child: Obx(() {
                if (controller.images.isEmpty) {
                  return const EmptyState();
                }
                return const ImageGrid();
              }),
            ),
            Obx(
              () => controller.images.isNotEmpty
                  ? Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: PrimaryButton(
                        label: controller.isCompressing.value
                            ? 'Compressing...'
                            : 'Compress All',
                        onPressed: controller.isCompressing.value
                            ? () {}
                            : () => controller.compressAll(),
                        icon: Icons.compress,
                      ),
                    )
                  : const SizedBox.shrink(),
            ),
            // FutureBuilder<BannerAd>(
            //   future: _loadBannerAd(),
            //   builder: (context, snapshot) {
            //     if (snapshot.connectionState == ConnectionState.done &&
            //         snapshot.data != null) {
            //       return Container(
            //         alignment: Alignment.center,
            //         width: snapshot.data!.size.width.toDouble(),
            //         height: snapshot.data!.size.height.toDouble(),
            //         child: AdWidget(ad: snapshot.data!),
            //       );
            //     }
            //     return const SizedBox.shrink();
            //   },
            // ),
          ],
        ),
      ),
      bottomNavigationBar: const BottomActionBar(),
    );
  }

  // Future<BannerAd> _loadBannerAd() async {
  //   return BannerAd(
  //     adUnitId: 'ca-app-pub-3940256099942544/6300978111', // Test ad unit ID
  //     size: AdSize.banner,
  //     request: const AdRequest(),
  //     listener: BannerAdListener(
  //       onAdFailedToLoad: (ad, error) {
  //         ad.dispose();
  //         debugPrint('Ad failed to load: $error');
  //       },
  //     ),
  //   )..load();
  // }
}
