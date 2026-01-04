import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
// import 'package:squeeze_pix/controllers/compressor_controller.dart'; 
import 'package:squeeze_pix/controllers/home_controller.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class UnityAdsController extends GetxController {
  // final CompressorController _compressorController = Get.put(CompressorController());
  final HomeController _homeController = Get.put(HomeController());

  // Game ID from Unity Dashboard
  static const String _androidGameId = '5970117';
  static const String _iosGameId = '5970116';

  // Ad Placement IDs
  static const String _rewardedAndroid = 'Rewarded_Android';
  static const String _rewardedIos = 'Rewarded_iOS';
  static const String _interstitialAndroid = 'Interstitial_Android';
  static const String _interstitialIos = 'Interstitial_iOS';
  static const String _bannerAndroid = 'Banner_Android';
  static const String _bannerIos = 'Banner_iOS';

  String get _gameId => GetPlatform.isAndroid ? _androidGameId : _iosGameId;
  String get _rewardedPlacementId =>
      GetPlatform.isAndroid ? _rewardedAndroid : _rewardedIos;
  String get _interstitialPlacementId =>
      GetPlatform.isAndroid ? _interstitialAndroid : _interstitialIos;
  String get bannerPlacementId =>
      GetPlatform.isAndroid ? _bannerAndroid : _bannerIos;

  // Internal state to track if ads are ready
  final RxBool isInterstitialReady = false.obs;
  final RxBool isRewardedReady = false.obs;

  @override
  void onInit() {
    super.onInit();
    _initAds();
  }

  Future<void> _initAds() async {
    await UnityAds.init(
      gameId: _gameId,
      testMode: false, //todo:::: Set to false for production
      onComplete: () {
        debugPrint('Unity Ads Initialization Complete');
        _loadAllAds(); // Load ads after initialization
      },
      onFailed: (error, message) =>
          debugPrint('Unity Ads Initialization Failed: $error $message'),
    );
  }

  void _loadAllAds() {
    // Pre-load ads to be ready when needed
    _loadInterstitialAd();
    _loadRewardedAd();
  }

  void _loadInterstitialAd() {
    UnityAds.load(
      placementId: _interstitialPlacementId,
      onComplete: (placementId) {
        debugPrint('Load Complete: $placementId');
        isInterstitialReady.value = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint('Load Failed: $placementId, $error, $message');
        isInterstitialReady.value = false;
      },
    );
  }

  void _loadRewardedAd() {
    UnityAds.load(
      placementId: _rewardedPlacementId,
      onComplete: (placementId) {
        debugPrint('Load Complete: $placementId');
        isRewardedReady.value = true;
      },
      onFailed: (placementId, error, message) {
        debugPrint('Load Failed: $placementId, $error, $message');
        isRewardedReady.value = false;
      },
    );
  }

  void showInterstitialAd({VoidCallback? onComplete}) {
    if (isInterstitialReady.value) {
      UnityAds.showVideoAd(
        placementId: _interstitialPlacementId,
        onStart: (placementId) => debugPrint('Video Ad ($placementId) start'),
        onClick: (placementId) => debugPrint('Video Ad ($placementId) click'),
        onSkipped: (placementId) {
          debugPrint('Video Ad ($placementId) skipped');
          isInterstitialReady.value = false;
          _loadInterstitialAd(); // Load next ad
          onComplete?.call();
        },
        onComplete: (placementId) {
          debugPrint('Video Ad ($placementId) complete');
          isInterstitialReady.value = false;
          _loadInterstitialAd(); // Load next ad
          onComplete?.call();
        },
        onFailed: (placementId, error, message) {
          debugPrint('Video Ad ($placementId) failed: $error $message');
          onComplete?.call(); // Still proceed if ad fails
        },
      );
    } else {
      debugPrint('Interstitial ad not ready, skipping.');
      _loadInterstitialAd(); // Try to load for the next time
      onComplete?.call(); // Proceed without showing ad
    }
  }

  void showRewardedAd() {
    if (isRewardedReady.value) {
      UnityAds.showVideoAd(
        placementId: _rewardedPlacementId,
        onComplete: (placementId) {
          debugPrint('Rewarded Ad ($placementId) complete');
          _homeController.batchAccessGranted.value = true;
          _homeController.compressAll();
          isRewardedReady.value = false;
          _loadRewardedAd(); // Load next ad
        },
        onFailed: (placementId, error, message) {
          debugPrint('Rewarded Ad ($placementId) failed: $error $message');
          Get.snackbar('Error', 'Could not load ad. Please try again later.');
        },
        onSkipped: (placementId) {
          debugPrint('Rewarded Ad ($placementId) skipped');
          isRewardedReady.value = false;
          _loadRewardedAd(); // Load next ad
        },
      );
    } else {
      debugPrint('Rewarded ad not ready, granting access and proceeding.');
      // Grant reward and proceed if ad is not ready, so user is not blocked.
      _homeController.batchAccessGranted.value = true;
      _homeController.compressAll();
    }
  }

  //===== Perform Action with Ad Check =====//
  void performAction(VoidCallback action) {
    if (Get.isRegistered<IAPController>()) {
      final iapController = Get.find<IAPController>();
      if (iapController.isPro.value || iapController.isUltra.value) {
        action();
        return;
      }
    }

    // Show Interstitial Ad for free users
    showInterstitialAd(onComplete: action);
  }
}

// lib/controllers/ads_controller.dart

// class AdsController extends GetxController {
//   final RxBool interstitialReady = false.obs;
//   final RxBool rewardedReady = false.obs;

//   @override
//   void onInit() {
//     super.onInit();
//     UnityAds.init(gameId: '5970117', testMode: false, onComplete: _loadAllAds);
//   }

//   void _loadAllAds() {
//     UnityAds.load(
//       placementId: 'Interstitial_Android',
//       onComplete: (id) => interstitialReady.value = true,
//     );
//     UnityAds.load(
//       placementId: 'Rewarded_Android',
//       onComplete: (id) => rewardedReady.value = true,
//     );
//   }

//   void showInterstitial(VoidCallback onComplete) {
//     UnityAds.load(
//       placementId: 'Interstitial_Android',
//       onComplete: (id) {
//         onComplete();
//         _loadAllAds();
//       },
//     );
//   }

//   void showRewarded({required VoidCallback onComplete}) {
//     UnityAds.load(
//       placementId: 'Rewarded_Android',
//       onComplete: (id) {
//         onComplete();
//         _loadAllAds();
//       },
//     );
//   }
// }
