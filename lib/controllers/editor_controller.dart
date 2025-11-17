// lib/controllers/editor_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/pages/dp_maker.dart';
import 'package:squeeze_pix/pages/id_photo_maker.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/services/bg_remover_service.dart';
import 'package:squeeze_pix/services/compressor_service.dart';

class EditorController extends GetxController {
  final Rx<File?> selected = Rxn<File>();
  final RxInt quality = 80.obs;
  final RxInt resizeWidth = 1920.obs;
  final RxInt resizeHeight = 1080.obs;
  final RxBool keepAspect = true.obs;
  final RxBool stripExif = true.obs;
  final RxBool enableWatermark = false.obs;
  final RxString watermarkText = ''.obs;
  final Rx<File?> compressed = Rxn<File>();
  final RxBool isCompressing = false.obs;

  final CompressorService compressor = CompressorService();
  final BgRemoverService bgRemover = BgRemoverService();
  final IAPController iap = Get.find();

  Future<void> compress() async {
    if (selected.value == null) return;
    isCompressing.value = true;
    try {
      compressed.value = await compressor.compress(
        file: selected.value!,
        quality: quality.value,
        targetWidth: resizeWidth.value,
        targetHeight: resizeHeight.value,
        format: 'jpg',
      );
    } finally {
      isCompressing.value = false;
    }
  }

  Future<void> removeBackground() async {
    if (!iap.isUltra.value) {
      Get.to(() => ProUpgradeScreen());
      return;
    }
    isCompressing.value = true;
    try {
      compressed.value = await bgRemover.remove(selected.value!);
    } finally {
      isCompressing.value = false;
    }
  }

  Future<void> makeDP() async {
    Get.to(() => DPMaker(image: selected.value!));
  }

  Future<void> makeIDPhoto() async {
    if (!iap.isPro.value) {
      Get.to(() => ProUpgradeScreen());
      return;
    }
    Get.to(() => IDPhotoMaker(image: selected.value!));
  }

  void toggleWatermark(bool value) => enableWatermark.value = value;
}
