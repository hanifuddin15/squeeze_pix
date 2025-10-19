import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/controls_card.dart';
import 'package:squeeze_pix/widgets/custom_appbar.dart';
import 'package:squeeze_pix/widgets/original_image_card.dart';
import 'package:squeeze_pix/widgets/result_card.dart';

class CompressorPage extends GetView<CompressorController> {
  const CompressorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: false,
      appBar: CustomAppBar(
        title: 'Compress & Save',
        isLeadingIcon: true,
        onClearAll: controller.showClearConfirmation,
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
          return ListView(
            padding: const EdgeInsets.all(16.0),
            children: [
              OriginalImageCard(file: selectedFile),
              const SizedBox(height: 16),
              ControlsCard(),
              const SizedBox(height: 16),
              ResultCard(
                resultFile: controller.lastCompressed.value ?? File(''),
              ),
              const SizedBox(height: 16),

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
          );
        }),
      ),
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
