// lib/controllers/home_controller.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/controllers/unity_ads_controller.dart';
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
    Get.lazyPut<CompressorController>(() => CompressorController());
    Get.lazyPut<UnityAdsController>(() => UnityAdsController());
    loadImages();
    loadFavorites();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTheme();
    });
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

  void pickFromCamera() async {
    if (isPicking.value) return;
    try {
      isPicking.value = true;
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked != null) {
        images.add(AppImage(File(picked.path)));
        saveImages();
      }
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

  // Calculate total size of selected images
  int get selectionTotalSize {
    if (selection.isEmpty) return 0;
    return selection
        .map((image) => image.file.lengthSync())
        .reduce((a, b) => a + b);
  }

  void handleImageTap(AppImage image) {
    if (isSelectionMode.value) {
      toggleSelection(image);
    } else {
      // Navigate to single image editor
      Get.to(() => EditorHub(imageFile: image.file));
    }
  }

  void selectAll() {
    selection.assignAll(images);
  }

  void clearSelection() {
    selection.clear();
    isSelectionMode.value = false;
  }

  void deleteSelection() {
    images.removeWhere((img) => selection.contains(img));
    clearSelection();
    saveImages();
    Get.snackbar(
      'Deleted',
      'Selected images have been removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  void saveImages() => box.write('images', images.map((e) => e.path).toList());
  void loadImages() {
    final imagePaths = box.read<List>('images')?.cast<String>() ?? [];
    final existingImages = <AppImage>[];
    for (final path in imagePaths) {
      final file = File(path);
      if (file.existsSync()) {
        existingImages.add(AppImage(file));
      }
    }
    images.assignAll(existingImages);
  }

  void saveFavorites() =>
      box.write('favorites', favorites.map((e) => e.path).toList());
  void loadFavorites() {
    final favoritePaths = box.read<List>('favorites')?.cast<String>() ?? [];
    favorites.assignAll(
      favoritePaths
          .where((p) => File(p).existsSync())
          .map((p) => AppImage(File(p))),
    );
  }

  Future<void> compressBatch() async {
    if (selection.isNotEmpty) {
      final compressor = Get.find<CompressorController>();
      // Pass the selected files to the compressor controller
      compressor.batchSelection.assignAll(
        selection.map((appImage) => appImage.file).toList(),
      );
      // Trigger the batch compression process
      await compressor.compressAll();
      // Clear selection after the process is complete
      clearSelection();
    }
  }

  void toggleTheme() {
    final isDark = Get.isDarkMode;
    Get.changeThemeMode(isDark ? ThemeMode.light : ThemeMode.dark);
    box.write('isDarkMode', !isDark);
  }

  void _loadTheme() {
    final isDarkMode = box.read<bool>('isDarkMode') ?? false;
    Get.changeThemeMode(isDarkMode ? ThemeMode.dark : ThemeMode.light);
  }

  void showImageSourceDialog() {
    Get.bottomSheet(
      // Set background to transparent to allow BackdropFilter to show
      ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(25),
              ),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withOpacity(0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: Wrap(
              children: <Widget>[
                ListTile(
                  leading: const Icon(Icons.photo_library, color: Colors.white),
                  title: const Text(
                    'Pick from Gallery',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Get.back();
                    pickMultiple();
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.camera_alt, color: Colors.white),
                  title: const Text(
                    'Use Camera',
                    style: TextStyle(color: Colors.white),
                  ),
                  onTap: () {
                    Get.back();
                    pickFromCamera();
                  },
                ),
              ],
            ),
          ),
        ),
      ),
      backgroundColor: Colors.transparent, // Important for glassmorphic effect
    );
  }
}
