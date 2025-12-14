// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:squeeze_pix/controllers/iap_controller.dart';
// import 'package:squeeze_pix/controllers/unity_ads_controller.dart';
// import 'package:unity_ads_plugin/unity_ads_plugin.dart';

// class BannerAdWidget extends StatelessWidget {
//   const BannerAdWidget({super.key});

//   @override
//   Widget build(BuildContext context) {
//     try {
//       final iapController = Get.find<IAPController>();
//       final adsController = Get.find<UnityAdsController>();

//       return Obx(() {
//         // Hide banner if user is Gold or Platinum
//         if (iapController.isGold) {
//           return const SizedBox.shrink();
//         }

//         return Container(
//           alignment: Alignment.center,
//           width: double.infinity,
//           height: 60, // Enforce a height safely
//           color: Colors.transparent,
//           child: UnityBannerAd(
//             placementId: adsController.bannerPlacementId,
//             onLoad: (placementId) =>
//                 debugPrint('Banner Ad Loaded: $placementId'),
//             onFailed: (placementId, error, message) => debugPrint(
//                 'Banner Ad Failed: $placementId, $error, $message'),
//           ),
//         );
//       });
//     } catch (e) {
//       debugPrint('BannerAdWidget Error: $e');
//       return const SizedBox.shrink();
//     }
//   }
// }
