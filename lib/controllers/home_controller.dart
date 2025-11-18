// lib/controllers/home_controller.dart
import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/models/app_images_model.dart';
import 'package:squeeze_pix/pages/editor_hub.dart';
import 'package:squeeze_pix/services/compressor_service.dart';

class HomeController extends GetxController {
  final RxList<AppImage> images = <AppImage>[].obs;
  final RxList<AppImage> favorites = <AppImage>[].obs;
  final RxBool isSelectionMode = false.obs;
  final RxList<AppImage> selection = <AppImage>[].obs;
  final RxInt tabIndex = 0.obs;
  final RxInt totalSavings = 0.obs;
  final RxBool isPicking = false.obs;
  final GetStorage box = GetStorage();

  final CompressorService compressor = CompressorService();

  @override
  void onInit() {
    super.onInit();
    loadImages();
    loadFavorites();
    totalSavings.value = box.read('savings') ?? 0;
  }

  void pickMultiple() async {
    if (isPicking.value) return;
    try {
      isPicking.value = true;
      final picked = await ImagePicker().pickMultiImage();
      if (picked.isNotEmpty) {
        images.addAll(picked.map((x) => AppImage(File(x.path))));
      }
      saveImages();
    } finally {
      isPicking.value = false;
    }
  }

  void toggleFavorite(AppImage image) {
    if (favorites.contains(image)) {
      favorites.remove(image);
    } else {
      favorites.add(image);
    }
    saveFavorites();
  }

  void toggleSelection(AppImage image) {
    if (selection.contains(image)) {
      selection.remove(image);
      if (selection.isEmpty) isSelectionMode.value = false;
    } else {
      selection.add(image);
      isSelectionMode.value = true;
    }
  }

  void deleteSelection() {
    images.removeWhere((img) => selection.contains(img));
    selection.clear();
    isSelectionMode.value = false;
    saveImages();
  }

  void saveImages() => box.write('images', images.map((e) => e.path).toList());
  void loadImages() {
    final imagePaths = box.read<List>('images')?.cast<String>() ?? [];
    images.assignAll(imagePaths.map((p) => AppImage(File(p))));
  }

  void saveFavorites() =>
      box.write('favorites', favorites.map((e) => e.path).toList());
  void loadFavorites() {
    final favoritePaths = box.read<List>('favorites')?.cast<String>() ?? [];
    favorites.assignAll(favoritePaths.map((p) => AppImage(File(p))));
  }

  void compressBatch() {
    if (selection.isNotEmpty) {
      Get.to(() => EditorHub());
    }
  }
}
