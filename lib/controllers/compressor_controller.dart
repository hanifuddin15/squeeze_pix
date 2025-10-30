import 'dart:io';
import 'package:file_saver/file_saver.dart';
import 'package:file_picker/file_picker.dart';
import 'package:squeeze_pix/controllers/unity_ads_controller.dart';
import 'package:flutter/foundation.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/widgets.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:open_filex/open_filex.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/widgets/clear_all_alert.dart';

class CompressorController extends GetxController {
  final _box = GetStorage();
  final RxList<File> images = <File>[].obs;
  final Rxn<File> selected = Rxn<File>();

  // 0 for Quality, 1 for Target Size
  final RxInt compressionMode = 0.obs;

  final RxInt quality = 80.obs;
  final RxInt batchQuality = 80.obs;
  final RxString outputFormat = 'jpg'.obs;
  final RxBool isCompressing = false.obs;
  final RxBool isPicking = false.obs;
  final RxList<String> history = <String>[].obs;
  final RxList<String> favorites = <String>[].obs;
  final Rx<File?> lastCompressed = Rx<File?>(null);
  final Rxn<File> lastZipFile = Rxn<File>();
  final RxMap batchStats = {}.obs;
  final RxInt totalBytesSaved = 0.obs;

  // For batch selection
  final RxList<File> batchSelection = <File>[].obs;
  final RxBool isSelectionMode = false.obs;
  final RxString zipFileName = 'squeezepix_batch'.obs;
  final RxnString batchSavePath = RxnString(null);

  // New Feature States
  final Rxn<int> targetSizeKB = Rxn<int>();
  final Rxn<int> resizeWidth = Rxn<int>();
  final Rxn<int> resizeHeight = Rxn<int>();
  final RxBool keepAspectRatio = true.obs;
  final RxBool stripExif = true.obs;

  // Watermark states
  final RxBool enableWatermark = false.obs;
  final RxString watermarkText = ''.obs;
  final Rx<Alignment> watermarkAlignment = Alignment.bottomRight.obs;

  // For rewarded ads
  final RxBool batchAccessGranted = false.obs;

  // Controllers for resize text fields
  late TextEditingController widthController;
  late TextEditingController heightController;
  img.Image? _decodedImage;

  @override
  void onInit() {
    super.onInit();
    final List<dynamic>? storedHistory = _box.read<List>('history');
    final List<dynamic>? storedFavorites = _box.read<List>('favorites');
    final List<dynamic>? storedImages = _box.read<List>('images');
    totalBytesSaved.value = _box.read<int>('totalBytesSaved') ?? 0;
    batchSavePath.value = _box.read<String>('batchSavePath');

    widthController = TextEditingController();
    heightController = TextEditingController();

    if (storedHistory != null) {
      history.assignAll(storedHistory.map((e) => e.toString()).toList());
    }
    if (storedFavorites != null) {
      favorites.assignAll(storedFavorites.map((e) => e.toString()).toList());
    }
    if (storedImages != null) {
      images.assignAll(storedImages.map((e) => File(e.toString())).toList());
      if (images.isNotEmpty) {
        selected.value = images.first;
      }
    }

    // When selected image changes, decode it for aspect ratio calculations
    ever(selected, (File? file) async {
      if (file != null) {
        final bytes = await file.readAsBytes();
        _decodedImage = img.decodeImage(bytes);
      } else {
        _decodedImage = null;
      }
      // Clear resize fields when image changes
      widthController.clear();
      heightController.clear();
      resizeWidth.value = null;
      resizeHeight.value = null;
    });

    widthController.addListener(() {
      if (widthController.text.isEmpty) {
        resizeWidth.value = null;
        return;
      }
      final newWidth = int.tryParse(widthController.text);
      resizeWidth.value = newWidth;
      if (keepAspectRatio.value && newWidth != null && _decodedImage != null) {
        final newHeight =
            (newWidth * _decodedImage!.height / _decodedImage!.width).round();
        heightController.text = newHeight.toString();
        resizeHeight.value = newHeight;
      }
    });

    heightController.addListener(() {
      if (heightController.text.isEmpty) {
        resizeHeight.value = null;
        return;
      }
      final newHeight = int.tryParse(heightController.text);
      resizeHeight.value = newHeight;
      if (keepAspectRatio.value && newHeight != null && _decodedImage != null) {
        final newWidth =
            (newHeight * _decodedImage!.width / _decodedImage!.height).round();
        widthController.text = newWidth.toString();
        resizeWidth.value = newWidth;
      }
    });
  }

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    isPicking.value = true;
    final picked = await picker.pickMultiImage();
    if (picked.isNotEmpty) {
      images.addAll(picked.map((x) => File(x.path)));
      selected.value ??= images.first;
      _box.write('images', images.map((e) => e.path).toList());
    }
    isPicking.value = false;
  }

  Future<void> pickSingleFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? shot = await picker.pickImage(source: ImageSource.camera);
    if (shot != null) {
      final file = File(shot.path);
      images.add(file);
      selected.value = file;
      _box.write('images', images.map((e) => e.path).toList());
    }
  }

  void selectImage(File file) {
    selected.value = file;
    lastCompressed.value = null;
    // Clear resize fields when a new image is selected from the grid
    widthController.clear();
    heightController.clear();
    resizeWidth.value = null;
    resizeHeight.value = null;
  }

  void clearAll() {
    images.clear();
    selected.value = null;
    lastCompressed.value = null;
    _box.remove('images');
  }

  void clearBatchStats() {
    batchStats.clear();
    lastZipFile.value = null;
  }

  void showClearConfirmation() {
    Get.dialog(const ClearAllAlertDialog());
  }

  void toggleFavorite(String path) {
    if (favorites.contains(path)) {
      favorites.remove(path);
    } else {
      favorites.add(path);
    }
    _box.write('favorites', favorites.toList());
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

  Future<File?> _compressFileWithTargetSize(
    File file,
    int targetKB,
    Uint8List imageBytes,
  ) async {
    int currentQuality = 95;
    int minQuality = 10;
    Uint8List? resultBytes;

    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.${outputFormat.value}';

    // Iteratively compress to find the best quality for the target size
    while (currentQuality >= minQuality) {
      resultBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: currentQuality,
        format: outputFormat.value == 'jpg'
            ? CompressFormat.jpeg
            : (outputFormat.value == 'png'
                  ? CompressFormat.png
                  : CompressFormat.webp),
        keepExif: !stripExif.value,
      );

      final resultSizeKB = resultBytes.lengthInBytes / 1024;
      debugPrint(
        'Trying quality $currentQuality, size: ${resultSizeKB.toStringAsFixed(2)} KB',
      );

      if (resultSizeKB <= targetKB) {
        break; // Found a suitable quality
      }

      // Decrease quality for next iteration
      currentQuality -= 5;
    }

    if (resultBytes == null || resultBytes.isEmpty) {
      return null;
    }

    final resultFile = await File(targetPath).writeAsBytes(resultBytes);
    final originalSize = file.lengthSync();
    final newSize = resultFile.lengthSync();
    final saved = originalSize - newSize;
    if (saved > 0) {
      totalBytesSaved.value += saved;
      _box.write('totalBytesSaved', totalBytesSaved.value);
    }
    return resultFile;
  }

  Future<File?> _compressFile(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.${outputFormat.value}';

    Uint8List? fileBytes = await file.readAsBytes();

    // 1. Image manipulation (resize, watermark) using 'image' package
    if (resizeWidth.value != null ||
        resizeHeight.value != null ||
        enableWatermark.value) {
      final image = img.decodeImage(fileBytes);
      if (image != null) {
        img.Image modifiedImage = image;

        // Resizing
        if (resizeWidth.value != null || resizeHeight.value != null) {
          modifiedImage = img.copyResize(
            image,
            width: resizeWidth.value,
            height: resizeHeight.value,
            maintainAspect: keepAspectRatio.value,
          );
        }

        // Watermarking
        if (enableWatermark.value && watermarkText.value.isNotEmpty) {
          // For simplicity, using a basic font. A real app might bundle a .ttf font
          img.drawString(
            modifiedImage,
            watermarkText.value,
            font: img.arial24,
            x: 20,
            y: modifiedImage.height - 40,
          );
        }

        fileBytes = Uint8List.fromList(
          img.encodeJpg(modifiedImage),
        ); // Re-encode before compression
      }
    }

    // If target size is set and mode is correct, use the iterative approach
    if (compressionMode.value == 1 && targetSizeKB.value != null) {
      return await _compressFileWithTargetSize(
        file,
        targetSizeKB.value!,
        fileBytes,
      );
    } else {
      // 2. Standard Compression using 'flutter_image_compress'
      final resultBytes = await FlutterImageCompress.compressWithList(
        fileBytes,
        quality: quality.value,
        format: outputFormat.value == 'jpg'
            ? CompressFormat.jpeg
            : (outputFormat.value == 'png'
                  ? CompressFormat.png
                  : CompressFormat.webp),
        keepExif: !stripExif.value,
      );

      if (resultBytes.isEmpty) {
        return null;
      }

      final resultFile = await File(targetPath).writeAsBytes(resultBytes);

      final originalSize = file.lengthSync();
      final newSize = resultFile.lengthSync();
      final saved = originalSize - newSize;
      if (saved > 0) {
        totalBytesSaved.value += saved;
        _box.write('totalBytesSaved', totalBytesSaved.value);
      }

      return resultFile;
    }
  }

  void resetCompressor() {
    lastCompressed.value = null;
  }

  Future<void> compressSelected() async {
    if (selected.value == null) return;
    isCompressing.value = true;
    try {
      lastCompressed.value = await _compressFile(selected.value!);
      if (lastCompressed.value != null) {
        history.removeWhere((p) => p == lastCompressed.value!.path);
        history.insert(0, lastCompressed.value!.path);
        if (history.length > 10) history.removeLast();
        _box.write('history', history.toList());
      }
    } finally {
      isCompressing.value = false;
    }
  }

  Future<void> compressSelectedWithAd() async {
    final adsController = Get.find<UnityAdsController>();
    adsController.showInterstitialAd(
      onComplete: () async {
        await compressSelected();
      },
    );
  }

  Future<void> compressAll() async {
    final imagesToCompress = isSelectionMode.value ? batchSelection : images;

    if (imagesToCompress.isEmpty) {
      Get.snackbar('No Images Selected', 'Please select images to compress.');
      return;
    }

    if (imagesToCompress.length > 3 && !batchAccessGranted.value) {
      final adsController = Get.find<UnityAdsController>();
      adsController.showRewardedAd();
      return;
    }

    isCompressing.value = true;
    try {
      String? outputDirectory = batchSavePath.value;
      if (outputDirectory == null) {
        final downloadsDir = await getDownloadsDirectory();
        outputDirectory = downloadsDir?.path;
        if (outputDirectory == null) {
          Get.snackbar('Error', 'Could not determine downloads directory.');
          return;
        }
      }
      // Show interstitial for batch compression as well if you want
      // final adsController = Get.find<UnityAdsController>();
      // adsController.showInterstitialAd(onComplete: () async {
      final tempDir = await getTemporaryDirectory();
      final archive = Archive();
      int count = 0;
      int totalReduction = 0;
      int totalOriginalSize = 0;
      int totalCompressedSize = 0;

      for (final file in imagesToCompress) {
        final compressedFile = await _compressFile(file);
        if (compressedFile != null) {
          final archiveFile = ArchiveFile(
            '${DateTime.now().millisecondsSinceEpoch}_${count++}.jpg',
            compressedFile.lengthSync(),
            await compressedFile.readAsBytes(),
          );
          archive.addFile(archiveFile);
          final originalSize = file.lengthSync();
          final newSize = compressedFile.lengthSync();
          totalOriginalSize += originalSize;
          totalCompressedSize += newSize;
          totalReduction += originalSize - newSize;
        }
      }

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      String? savedPath = await FileSaver.instance.saveFile(
        name: zipFileName.value,
        bytes: Uint8List.fromList(zipData),
        fileExtension: 'zip',
        mimeType: MimeType.zip,
      );
      lastZipFile.value = File(savedPath);
      batchStats.value = {
        'count': count,
        'sizeReduction': totalReduction,
        'totalOriginalSize': totalOriginalSize,
        'totalCompressedSize': totalCompressedSize,
      };
    } finally {
      isCompressing.value = false;
      batchAccessGranted.value = false; // Reset access after use
      toggleSelectionMode(false); // Exit selection mode
    }
    // });
  }

  Future<void> setBatchSavePath() async {
    // Use flutter_document_picker to get a writable content URI for a directory
    String? selectedDirectory = await FilePicker.platform.getDirectoryPath();

    if (selectedDirectory != null) {
      try {
        batchSavePath.value = selectedDirectory;
        _box.write('batchSavePath', selectedDirectory);
        Get.snackbar('Success', 'Batch save location updated.');
        debugPrint('Selected save path: $selectedDirectory');
      } catch (e) {
        debugPrint('Failed to set batch save path: $e');
        Get.snackbar('Error', 'Failed to set save location.');
      }
    }
  }

  Future<void> openLastCompressedLocation() async {
    if (lastCompressed.value != null) {
      final adsController = Get.find<UnityAdsController>();
      adsController.showInterstitialAd(
        onComplete: () {
          OpenFilex.open(lastCompressed.value!.path);
        },
      );
    }
  }

  // Future<void> openZipFolderLocation() async {
  //   if (lastZipFile.value != null) {
  //     final adsController = Get.find<UnityAdsController>();
  //     adsController.showInterstitialAd(
  //       onComplete: () {
  //         final path = lastZipFile.value!.parent.path;
  //         OpenFilex.open(path);
  //       },
  //     );
  //   }
  // }

  Future<void> extractZipFile() async {
    if (lastZipFile.value == null) return;

    final adsController = Get.find<UnityAdsController>();
    adsController.showInterstitialAd(
      onComplete: () async {
        // Request storage permission before proceeding
        var status = await Permission.manageExternalStorage.status;
        if (!status.isGranted) {
          status = await Permission.manageExternalStorage.request();
        }

        if (!status.isGranted) {
          Get.snackbar(
            'Permission Denied',
            'Storage permission is required to extract files.',
          );
          return;
        }

        try {
          String? saveDir = batchSavePath.value;
          if (saveDir == null) {
            Get.snackbar(
              'No Save Location',
              'Please set a save location before extracting.',
            );
            await setBatchSavePath();
            saveDir = batchSavePath.value;
            if (saveDir == null) return;
          }

          final inputStream = InputFileStream(lastZipFile.value!.path);
          final archive = ZipDecoder().decodeStream(inputStream);

          Get.snackbar('Extracting...', 'Extracting files, please wait.');

          for (final file in archive.files) {
            final filename = file.name;
            if (file.isFile) {
              final data = file.content as List<int>;
              final path = '$saveDir/$filename';
              final outFile = File(path);
              await outFile.create(recursive: true);
              await outFile.writeAsBytes(data);
            }
          }
          Get.snackbar('Success', 'Files extracted to your selected folder.');
        } catch (e) {
          Get.snackbar('Error', 'Failed to extract files: $e');
        }
      },
    );
  }

  void toggleSelectionMode(bool? enable) {
    isSelectionMode.value = enable ?? !isSelectionMode.value;
    if (!isSelectionMode.value) {
      batchSelection.clear();
    }
  }

  void toggleBatchSelection(File file) {
    if (batchSelection.contains(file)) {
      batchSelection.remove(file);
      if (batchSelection.isEmpty) {
        isSelectionMode.value = false;
      }
    } else {
      batchSelection.add(file);
    }
  }

  void selectAllForBatch() {
    batchSelection.assignAll(images);
  }

  Future<void> openHistoryFile(String path) async {
    try {
      final result = await OpenFilex.open(path);
      if (result.type != ResultType.done) {
        Get.snackbar('Error', 'Could not open file: ${result.message}');
      }
    } catch (e) {
      Get.snackbar('Error', 'File not found or could not be opened.');
    }
  }

  Future<void> shareZipFile() async {
    if (lastZipFile.value != null) {
      final adsController = Get.find<UnityAdsController>();
      adsController.showInterstitialAd(
        onComplete: () {
          Share.shareXFiles([XFile(lastZipFile.value!.path)]);
        },
      );
    }
  }

  /// Ensures a callback runs on the main isolate, which is required for UI operations.
  void runOnMainThread(VoidCallback callback) {
    WidgetsBinding.instance.addPostFrameCallback((_) => callback());
  }
}
