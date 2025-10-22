import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnitBannerAdsWidget extends GetView<CompressorController> {
  const UnitBannerAdsWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return UnityBannerAd(
      placementId: Platform.isAndroid ? 'Banner_Android' : 'Banner_iOS',
      onLoad: (placementId) => debugPrint('Banner loaded: $placementId'),
      onFailed: (placementId, error, message) =>
          debugPrint('Banner failed: $message'),
      onClick: (placementId) => debugPrint('Banner clicked: $placementId'),
      onShown: (placementId) => debugPrint('Banner shown: $placementId'),
      // onHidden: (placementId) => debugPrint('Banner hidden: $placementId'),
    );
  }
}
