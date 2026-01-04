import 'package:get/get.dart';
// import 'package:squeeze_pix/controllers/home_controller.dart'; // Unused

import 'package:squeeze_pix/controllers/unity_ads_controller.dart';
import 'package:squeeze_pix/services/bg_remover_service.dart';

class AppBindings extends Bindings {
  @override
  void dependencies() {
    // Get.lazyPut<CompressorController>(() => CompressorController()); // REMOVED
    Get.put<UnityAdsController>(UnityAdsController(), permanent: true);
    Get.lazyPut<BgRemoverService>(() => BgRemoverService());
  }
}
