import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/services/compressor_service.dart';
import 'package:squeeze_pix/services/zip_service.dart';
import 'package:squeeze_pix/widgets/clear_all_alert.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:get_storage/get_storage.dart';
import 'package:open_filex/open_filex.dart';
import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:unity_ads_plugin/unity_ads_plugin.dart';

class CompressorController extends GetxController {
  final CompressorService _service = CompressorService();
  final ZipService _zipService = ZipService();
  final RxBool isInterstitialReady = false.obs;
  final RxList<File> images = <File>[].obs;
  final Rxn<File> selected = Rxn<File>();
  final RxInt quality = 80.obs;
  final RxInt batchQuality =
      80.obs; // New variable for batch compression quality
  final Rxn<File> lastCompressed = Rxn<File>();
  final RxBool isCompressing = false.obs;
  final RxBool isPicking = false.obs;
  final RxString outputFormat = 'jpg'.obs;
  final RxList<String> favorites = <String>[].obs;
  final RxMap<String, dynamic> batchStats = <String, dynamic>{}.obs;
  final RxList<String> history = <String>[].obs;
  final RxnDouble targetSizeKB = RxnDouble();
  final Rxn<File> lastZipFile = Rxn<File>();
  final storage = GetStorage();

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    isPicking.value = true;
    try {
      final picked = await picker.pickMultiImage();
      if (picked.isNotEmpty) {
        images.addAll(picked.map((x) => File(x.path)));
        selected.value ??= images.first;
      }
    } finally {
      isPicking.value = false;
    }
  }

  Future<void> pickSingleFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? shot = await picker.pickImage(source: ImageSource.camera);
    if (shot != null) {
      final f = File(shot.path);
      images.add(f);
      selected.value = f;
    }
  }

  void selectImage(File f) => selected.value = f;

  Future<void> compressSelected({int? targetWidth, int? targetHeight}) async {
    final file = selected.value;
    if (file == null) return;
    isCompressing.value = true;
    try {
      final int q = quality.value;
      final compressed = await _service.compressFile(
        file: file,
        quality: q,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
        format: outputFormat.value,
        targetSizeKB: targetSizeKB.value,
      );
      if (compressed != null) {
        lastCompressed.value = await moveToDownloads(compressed);
        addToHistory(lastCompressed.value!.path);
        // Show interstitial ad if ready
        if (isInterstitialReady.value) {
          final interstitialPlacementId = Platform.isAndroid
              ? 'Interstitial_Android'
              : 'Interstitial_iOS';
          UnityAds.showVideoAd(
            placementId: interstitialPlacementId,
            onComplete: (placementId) {
              debugPrint('Interstitial completed: $placementId');
              isInterstitialReady.value = false; // Reset for next load
              _loadInterstitial(); // Pre-load next ad
            },
            onFailed: (placementId, error, message) {
              debugPrint('Interstitial failed: $message');
              isInterstitialReady.value = false;
              _loadInterstitial(); // Retry loading
            },
            onStart: (placementId) =>
                debugPrint('Interstitial started: $placementId'),
            onClick: (placementId) =>
                debugPrint('Interstitial clicked: $placementId'),
            onSkipped: (placementId) {
              debugPrint('Interstitial skipped: $placementId');
              isInterstitialReady.value = false;
              _loadInterstitial();
            },
          );
        }
      }
    } catch (e) {
      Get.snackbar(
        'Compression Failed',
        'Unable to compress image: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isCompressing.value = false;
    }
  }

  Future<void> compressAll() async {
    if (images.isEmpty) return;
    isCompressing.value = true;
    int count = 0;
    double totalSizeReduction = 0;
    final List<File> compressedFiles = [];

    try {
      for (var file in images) {
        final originalSize = file.lengthSync() / 1024;
        final compressed = await _service.compressFile(
          file: file,
          quality: batchQuality.value, // Use batchQuality for batch compression
          format: outputFormat.value,
          targetSizeKB: targetSizeKB.value,
        );
        if (compressed != null) {
          final newFile = await moveToDownloads(compressed);
          final newSize = newFile.lengthSync() / 1024;
          compressedFiles.add(newFile);
          totalSizeReduction += originalSize - newSize;
          count++;
          addToHistory(newFile.path);
        }
      }
      batchStats.value = {'count': count, 'sizeReduction': totalSizeReduction};

      if (compressedFiles.isNotEmpty) {
        final zipName =
            'SqueezePix_${DateTime.now().toIso8601String().replaceAll(':', '').substring(0, 15)}.zip';
        lastZipFile.value = await _zipService.createZip(
          compressedFiles,
          zipName,
        );
      }

      Get.snackbar(
        'Batch Compression Complete',
        '$count images compressed, saved ${(totalSizeReduction).toStringAsFixed(1)} KB!',
        backgroundColor: Get.theme.colorScheme.primary,
        colorText: Colors.white,
      );

      // Show interstitial ad if ready
      if (isInterstitialReady.value) {
        final interstitialPlacementId = Platform.isAndroid
            ? 'Interstitial_Android'
            : 'Interstitial_iOS';
        UnityAds.showVideoAd(
          placementId: interstitialPlacementId,
          onComplete: (placementId) {
            debugPrint('Interstitial completed: $placementId');
            isInterstitialReady.value = false; // Reset for next load
            _loadInterstitial(); // Pre-load next ad
          },
          onFailed: (placementId, error, message) {
            debugPrint('Interstitial failed: $message');
            isInterstitialReady.value = false;
            _loadInterstitial(); // Retry loading
          },
          onStart: (placementId) =>
              debugPrint('Interstitial started: $placementId'),
          onClick: (placementId) =>
              debugPrint('Interstitial clicked: $placementId'),
          onSkipped: (placementId) {
            debugPrint('Interstitial skipped: $placementId');
            isInterstitialReady.value = false;
            _loadInterstitial();
          },
        );
      }
    } catch (e) {
      Get.snackbar(
        'Batch Compression Failed',
        'Error: $e',
        backgroundColor: Get.theme.colorScheme.error,
        colorText: Colors.white,
      );
    } finally {
      isCompressing.value = false;
    }
  }

  void _loadInterstitial() {
    final interstitialPlacementId = Platform.isAndroid
        ? 'Interstitial_Android'
        : 'Interstitial_iOS';
    UnityAds.load(
      placementId: interstitialPlacementId,
      onComplete: (placementId) {
        isInterstitialReady.value = true;
        debugPrint('Interstitial loaded: $placementId');
      },
      onFailed: (placementId, error, message) {
        isInterstitialReady.value = false;
        debugPrint('Interstitial load failed: $message');
      },
    );
  }

  void clearBatchStats() {
    batchStats.clear();
    lastZipFile.value = null;
  }

  void toggleFavorite(String path) {
    if (favorites.contains(path)) {
      favorites.remove(path);
    } else {
      favorites.add(path);
    }
    storage.write('favorites', favorites);
  }

  List<File> getSortedImages() {
    final favoriteImages = images
        .where((file) => favorites.contains(file.path))
        .toList();
    final nonFavoriteImages = images
        .where((file) => !favorites.contains(file.path))
        .toList();
    return [...favoriteImages, ...nonFavoriteImages];
  }

  Future<File> moveToDownloads(File tempFile) async {
    final docDir = await getApplicationDocumentsDirectory();
    final outDir = Directory(p.join(docDir.path, 'SqueezePix'));
    try {
      if (!await outDir.exists()) {
        await outDir.create(recursive: true);
        debugPrint('Created directory: ${outDir.path}');
      }
    } catch (e) {
      debugPrint('Failed to create directory: $e');
      rethrow;
    }
    final newPath = p.join(outDir.path, p.basename(tempFile.path));
    final newFile = await tempFile.copy(newPath);
    return newFile;
  }

  void addToHistory(String path) {
    history.insert(0, path);
    if (history.length > 50) history.removeLast();
    storage.write('history', history);
  }

  Future<void> openLastCompressedLocation() async {
    final file = lastCompressed.value;
    if (file == null) return;
    await OpenFilex.open(file.path);
  }

  Future<void> openZipFolderLocation() async {
    final file = lastZipFile.value;
    if (file == null) return;
    final dirPath = p.dirname(file.path);
    await OpenFilex.open(dirPath);
  }

  Future<void> shareZipFile() async {
    final file = lastZipFile.value;
    if (file == null) return;
    await SharePlus.instance.share(
      ShareParams(
        files: [XFile(file.path)],
        text: 'Check out these compressed images!',
      ),
    );
    Get.snackbar(
      'Shared',
      'Zip file shared successfully!',
      backgroundColor: Get.theme.colorScheme.primary,
      colorText: Colors.white,
    );
  }

  Future<void> showClearConfirmation() {
    return Get.dialog(const ClearAllAlertDialog());
  }

  @override
  void onInit() {
    super.onInit();
    final savedHistory = storage.read<List>('history') ?? [];
    history.assignAll(savedHistory.cast<String>());
    final savedFavorites = storage.read<List>('favorites') ?? [];
    favorites.assignAll(savedFavorites.cast<String>());

    // Pre-load interstitial ad
    _loadInterstitial();
  }
}
