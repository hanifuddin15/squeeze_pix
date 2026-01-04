// lib/controllers/home_controller.dart
import 'dart:io';
import 'dart:ui';
import 'package:file_saver/file_saver.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/controllers/unity_ads_controller.dart';
import 'package:squeeze_pix/models/app_images_model.dart';
import 'package:squeeze_pix/pages/editor_hub.dart';
import 'package:squeeze_pix/services/compressor_service.dart';
import 'package:archive/archive_io.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:path_provider/path_provider.dart';
// ignore: depend_on_referenced_packages
import 'package:image/image.dart' as img;
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import 'package:open_filex/open_filex.dart';
import 'package:gal/gal.dart';

/// A data class to pass parameters to the isolate for batch compression.
class _BatchCompressParams {
  final List<File> imagesToCompress;
  final int batchCompressionMode;
  final int? batchTargetSizeKB;
  final int batchQuality;
  final bool stripExif;

  _BatchCompressParams({
    required this.imagesToCompress,
    required this.batchCompressionMode,
    this.batchTargetSizeKB,
    required this.batchQuality,
    required this.stripExif,
  });
}

/// This is a top-level function that will run in a separate isolate for heavy lifting.
Future<List<Uint8List>> _compressBatchIsolate(
  _BatchCompressParams params,
) async {
  final List<Uint8List> compressedBytesList = [];

  for (final file in params.imagesToCompress) {
     // Read file bytes
    final imageBytes = await file.readAsBytes();

    // Decode using image package (safe in isolate)
    final decoded = img.decodeImage(imageBytes);
    if (decoded == null) {
      compressedBytesList.add(imageBytes);
      continue;
    }

    Uint8List resultBytes;

    // --------------------------
    // TARGET SIZE MODE
    // --------------------------
    if (params.batchCompressionMode == 1 && params.batchTargetSizeKB != null) {
      int quality = 95;

      resultBytes = Uint8List.fromList(
        img.encodeJpg(
          decoded,
          quality: quality,
        ),
      );

      // Reduce quality until target KB is achieved
      while (resultBytes.lengthInBytes / 1024 > params.batchTargetSizeKB! &&
          quality > 10) {
        quality -= 5;

        resultBytes = Uint8List.fromList(
          img.encodeJpg(
            decoded,
            quality: quality,
          ),
        );
      }
    }
    // --------------------------
    // QUALITY MODE
    // --------------------------
    else {
      resultBytes = Uint8List.fromList(
        img.encodeJpg(
          decoded,
          quality: params.batchQuality,
        ),
      );
    }

    compressedBytesList.add(resultBytes);
  }

  return compressedBytesList;
}

class HomeController extends GetxController {
  // ========================================================================
  // STATE VARIABLES
  // ========================================================================
  
  // -- Main Home State --
  final RxList<AppImage> images = <AppImage>[].obs;
  final RxList<AppImage> favorites = <AppImage>[].obs;
  final RxBool isSelectionMode = false.obs;
  final RxList<AppImage> selection = <AppImage>[].obs;
  final RxInt tabIndex = 0.obs;
  final RxBool isPicking = false.obs;
  final GetStorage box = GetStorage();

  final CompressorService compressorService = CompressorService();

  // -- Compressor / Editor State --
  final Rxn<File> selected = Rxn<File>(); // Currently selected for single edit
  
  // 0 for Quality, 1 for Target Size
  final RxInt compressionMode = 0.obs;
  final RxInt quality = 80.obs;
  final RxInt batchQuality = 80.obs;
  final RxString outputFormat = 'jpg'.obs;
  final RxBool isCompressing = false.obs;
  final RxList<String> history = <String>[].obs;
  final Rx<File?> lastCompressed = Rx<File?>(null);
  final Rxn<File> lastZipFile = Rxn<File>();
  final RxMap batchStats = {}.obs;
  final RxInt totalBytesSaved = 0.obs; // Unified savings counter

  final RxString zipFileName = 'squeezepix_batch'.obs;

  // -- Single Image Editor State --
  final Rxn<int> targetSizeKB = Rxn<int>();
  final Rxn<int> resizeWidth = Rxn<int>();
  final Rxn<int> resizeHeight = Rxn<int>();
  final RxBool keepAspectRatio = true.obs;
  final RxBool stripExif = true.obs;

  // -- Batch Feature States --
  final RxInt batchCompressionMode = 0.obs; // 0 for Quality, 1 for Target Size
  final Rxn<int> batchTargetSizeKB = Rxn<int>();

  // -- Watermark States --
  final RxBool enableWatermark = false.obs;
  final RxString watermarkText = ''.obs;
  final Rx<Alignment> watermarkAlignment = Alignment.bottomRight.obs;

  // -- Ad Related State --
  final RxBool batchAccessGranted = false.obs;

  // -- Text Controllers --
  late TextEditingController widthController;
  late TextEditingController heightController;
  img.Image? _decodedImage;

  // ========================================================================
  // INITIALIZATION
  // ========================================================================

  @override
  void onInit() {
    super.onInit();
    // Initialize Controllers
    widthController = TextEditingController();
    heightController = TextEditingController();
    
    // Dependencies
    Get.lazyPut<UnityAdsController>(() => UnityAdsController());
    
    // Load Persisted Data
    loadImages();
    loadFavorites();
    _loadPersistedCompressorData();
    
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadTheme();
    });

    _setupListeners();
  }
  
  /// Loads persisted data specific to compressor features (history, savings).
  Future<void> _loadPersistedCompressorData() async {
    final List<dynamic>? storedHistory = box.read<List>('history');
    totalBytesSaved.value = box.read<int>('totalBytesSaved') ?? 0; // Use same key as CompressorController used

    if (storedHistory != null) {
      history.assignAll(
        storedHistory
            .map((e) => e.toString())
            .where((p) => File(p).existsSync()),
      );
    }
  }

  /// Sets up listeners for state changes (e.g. resize calculations).
  void _setupListeners() {
    // When selected image changes (for single edit), decode it
    ever(selected, (File? file) async {
      if (file != null) {
         try {
          final bytes = await file.readAsBytes();
          _decodedImage = img.decodeImage(bytes);
        } catch (e) {
          debugPrint('Error decoding image: $e');
          _decodedImage = null;
        }
      } else {
        _decodedImage = null;
      }
      // Clear resize fields
      widthController.clear();
      heightController.clear();
      resizeWidth.value = null;
      resizeHeight.value = null;
    });

    // Resize Logic
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
        if (heightController.text != newHeight.toString()) {
           heightController.text = newHeight.toString();
           resizeHeight.value = newHeight;
        }
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
        if (widthController.text != newWidth.toString()) {
          widthController.text = newWidth.toString();
          resizeWidth.value = newWidth;
        }
      }
    });
  }

  // ========================================================================
  // IMAGE MANAGEMENT (HOME)
  // ========================================================================

  /// Picks multiple images from gallery and adds them to the list.
  void pickMultiple() async {
    if (isPicking.value) return;
    try {
      isPicking.value = true;
      final picked = await ImagePicker().pickMultiImage();
      if (picked.isNotEmpty) {
        images.addAll(picked.map((x) => AppImage(File(x.path))));
        // Also update 'selected' if we want the first one to be ready for editing
        if (selected.value == null && images.isNotEmpty) {
             selected.value = images.first.file;
        }
      }
      saveImages();
    } finally {
      isPicking.value = false;
    }
  }

  /// Picks a single image from camera and adds it to the list.
  void pickFromCamera() async {
    if (isPicking.value) return;
    try {
      isPicking.value = true;
      final picked = await ImagePicker().pickImage(source: ImageSource.camera);
      if (picked != null) {
        final newImage = AppImage(File(picked.path));
        images.add(newImage);
        selected.value = newImage.file; // Auto-select camera shot
        saveImages();
      }
    } finally {
      isPicking.value = false;
    }
  }

  /// Toggles favorite status for an image.
  void toggleFavorite(AppImage image) {
    if (favorites.contains(image)) {
      favorites.remove(image);
    } else {
      favorites.add(image);
    }
    saveFavorites();
  }

  /// Toggles selection mode and adds/removes image from selection.
  void toggleSelection(AppImage image) {
    if (selection.contains(image)) {
      selection.remove(image);
      if (selection.isEmpty) isSelectionMode.value = false;
    } else {
      selection.add(image);
      isSelectionMode.value = true;
    }
  }

  /// Calculates total size of currently selected images.
  int get selectionTotalSize {
    if (selection.isEmpty) return 0;
    return selection
        .map((image) => image.file.lengthSync())
        .reduce((a, b) => a + b);
  }

  /// Handles tap on a grid image.
  void handleImageTap(AppImage image) {
    if (isSelectionMode.value) {
      toggleSelection(image);
    } else {
      // Set for single editor
      selectImage(image.file);
      Get.to(() => EditorHub(imageFile: image.file));
    }
  }

  /// Selects all images in the grid.
  void selectAll() {
    selection.assignAll(images);
    isSelectionMode.value = true;
  }

  /// Clears current selection.
  void clearSelection() {
    selection.clear();
    isSelectionMode.value = false;
  }

  /// Deletes selected images from the main list.
  void deleteSelection() {
    images.removeWhere((img) => selection.contains(img));
    clearSelection();
    saveImages();
      
    // Update 'selected' if it was deleted
    if (selected.value != null) {
      bool exists = images.any((img) => img.file.path == selected.value!.path);
      if (!exists) {
        selected.value = images.isNotEmpty ? images.first.file : null;
      }
    }
    
    Get.snackbar(
      'Deleted',
      'Selected images have been removed.',
      snackPosition: SnackPosition.BOTTOM,
    );
  }

  /// Persist images list.
  void saveImages() => box.write('images', images.map((e) => e.path).toList());

  /// Load images list from storage.
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
    if (images.isNotEmpty && selected.value == null) {
      selected.value = images.first.file;
    }
  }

  /// Persist favorites.
  void saveFavorites() =>
      box.write('favorites', favorites.map((e) => e.path).toList());

  /// Load favorites.
  void loadFavorites() {
    final favoritePaths = box.read<List>('favorites')?.cast<String>() ?? [];
    favorites.assignAll(
      favoritePaths
          .where((p) => File(p).existsSync())
          .map((p) => AppImage(File(p))),
    );
  }

  // ========================================================================
  // COMPRESSION LOGIC (Merged from CompressorController)
  // ========================================================================

  /// Sets the currently selected file for single editing/compression.
  void selectImage(File file) {
    selected.value = file;
    lastCompressed.value = null;
    // Clear resize fields
    widthController.clear();
    heightController.clear();
    resizeWidth.value = null;
    resizeHeight.value = null;
  }

  /// Compresses all selected images (Batch).
  /// If selection mode is active, uses `selection`. Otherwise, uses all `images`.
  Future<void> compressAll() async {
    // FIX: Using the correct source list based on selection mode
    final List<File> imagesToCompress = isSelectionMode.value 
        ? selection.map((e) => e.file).toList() 
        : images.map((e) => e.file).toList();

    if (imagesToCompress.isEmpty) {
      showWarningSnackkbar(
        message: 'No images selected to compress',
        title: 'No Images Selected',
      );
      return;
    }

    // Check for Rewarded Ad condition (> 1 images)
    if (imagesToCompress.length > 1 && !batchAccessGranted.value) {
      final adsController = Get.find<UnityAdsController>();
      adsController.performAction(() async {
        batchAccessGranted.value = true;
        await compressAll(); // Re-run with permission granted
      });
      return;
    }

    isCompressing.value = true;

    try {
      showWarningSnackkbar(
        message:
            'Compressing ${imagesToCompress.length} images. This may take a moment...',
        title: 'Starting Batch Compression',
      );

      // Prepare parameters for the isolate
      final params = _BatchCompressParams(
        imagesToCompress: imagesToCompress,
        batchCompressionMode: batchCompressionMode.value,
        batchTargetSizeKB: batchTargetSizeKB.value,
        batchQuality: batchQuality.value,
        stripExif: stripExif.value,
      );

      // Run heavy compression in a separate isolate
      final List<Uint8List> compressedResults = await compute(
        _compressBatchIsolate,
        params,
      );

      final archive = Archive();
      int count = 0;
      int totalReduction = 0;
      int totalOriginalSize = 0;
      int totalCompressedSize = 0;

      for (int i = 0; i < compressedResults.length; i++) {
        final originalFile = imagesToCompress[i];
        final compressedBytes = compressedResults[i];
        final archiveFile = ArchiveFile(
          '${DateTime.now().millisecondsSinceEpoch}_${count++}.jpg',
          compressedBytes.length,
          compressedBytes,
        );
        archive.addFile(archiveFile);
        totalOriginalSize += originalFile.lengthSync();
        totalCompressedSize += compressedBytes.length;
      }

      final zipEncoder = ZipEncoder();
      final zipData = zipEncoder.encode(archive);

      final zipName =
          '${zipFileName.value.isNotEmpty ? zipFileName.value : 'squeezepix_batch'}';
      
      // Save using FileSaver
      await FileSaver.instance.saveFile(
        name: '$zipName.zip',
        bytes: Uint8List.fromList(zipData),
        mimeType: MimeType.zip,
      );

      // Create a temp copy for 'lastZipFile' (sharing/extracting)
      final tempDir = await getTemporaryDirectory();
      final tempZipPath = '${tempDir.path}/$zipName.zip';
      final zipFile = File(tempZipPath);
      await zipFile.writeAsBytes(zipData);

      lastZipFile.value = zipFile;
      totalReduction = totalOriginalSize - totalCompressedSize;
      
      // Update stats
      batchStats.value = {
        'count': count,
        'sizeReduction': totalReduction,
        'totalOriginalSize': totalOriginalSize,
        'totalCompressedSize': totalCompressedSize,
      };
      
      // Accumulate total savings
      if (totalReduction > 0) {
        totalBytesSaved.value += totalReduction;
        box.write('totalBytesSaved', totalBytesSaved.value);
      }

      showSuccessSnackkbar(
        message: 'Batch compression complete. ZIP file saved.',
      );
    } catch (e) {
      showErrorSnackkbar(
        message: 'An error occurred during batch compression: $e',
      );
      debugPrint(e.toString());
    } finally {
      isCompressing.value = false;
      // Ideally keeping selection active to let user decide next action, 
      // or we can clear it: clearSelection(); 
      // Current behvaior: Keep selection so user can share/extract/delete.
    }
  }

  /// Compresses all selected images and then immediately triggers the share dialog.
  Future<void> compressAndShare() async {
    // First, run the compression logic.
    await compressAll();

    // If compression was successful and a zip file was created, share it.
    if (lastZipFile.value != null) {
      final adsController = Get.find<UnityAdsController>();
      adsController.performAction(() {
        shareZipFile(showAd: true); 
      });
    }
  }

  /// Shares the last created ZIP file.
  Future<void> shareZipFile({bool showAd = true}) async {
    if (lastZipFile.value != null) {
      void shareAction() {
        SharePlus.instance.share(
          ShareParams(files: [XFile(lastZipFile.value!.path)]),
        );
      }

      if (showAd) {
        final adsController = Get.find<UnityAdsController>();
        adsController.showInterstitialAd(onComplete: shareAction);
      } else {
        shareAction();
      }
    } else {
       showWarningSnackkbar(
        title: 'Not Compressed',
        message:
            'Please compress images first to create a ZIP file to share.',
      );
    }
  }

  /// Extracts the last created ZIP file and adds images to the gallery.
  Future<void> extractZipFile() async {
    if (lastZipFile.value == null) return;

    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      try {
        final appDocDir = await getApplicationDocumentsDirectory();
        final saveDir = appDocDir.path;

        final inputStream = InputFileStream(lastZipFile.value!.path);
        final archive = ZipDecoder().decodeStream(inputStream);
        showSuccessSnackkbar(
          message: 'Extracting files, please wait.',
          title: 'Extracting...',
        );
        
        // Check for Gallery Access
        final hasAccess = await Gal.hasAccess();
        if (!hasAccess) {
          await Gal.requestAccess();
        }

        int count = 0;
        for (final file in archive.files) {
          final filename = file.name;
          if (file.isFile) {
            final data = file.content as List<int>;
            final path = '$saveDir/$filename';
            final outFile = File(path);
            await outFile.create(recursive: true);
            await outFile.writeAsBytes(data);
            
            // Save to Gallery via MediaStore
            try {
               await Gal.putImage(path, album: 'Squeeze Pix');
               count++;
            } catch (e) {
               debugPrint('Failed to save $filename to gallery: $e');
            }
            
            // Add to app images list so user can see/access them
            images.add(AppImage(outFile));
          }
        }
        // Save images list update
        saveImages();
        
        showSuccessSnackkbar(
          message: '$count Images extracted and saved to Gallery (Album: Squeeze Pix).',
        );
      } catch (e) {
        showErrorSnackkbar(message: 'Failed to extract files: $e');
        debugPrint('Failed to extract files: $e');
      }
    });
  }

  /// Compresses the SINGLE currently selected image (for Editor Hub).
  Future<void> compressSingleSelected() async {
    if (selected.value == null) return;
    isCompressing.value = true;
    try {
      final result = await _compressFile(selected.value!);
      lastCompressed.value = result;
      if (lastCompressed.value != null) {
        history.removeWhere((p) => p == lastCompressed.value!.path);
        history.insert(0, lastCompressed.value!.path);
        if (history.length > 10) history.removeLast();
        box.write('history', history.toList());
        
        // Automatically save to Gallery
        try {
           // Check permission implicitly handled by Gal or check before
           await Gal.putImage(lastCompressed.value!.path, album: 'Squeeze Pix');
           showSuccessSnackkbar(message: 'Image saved to Gallery (Album: Squeeze Pix)');
        } catch (e) {
           debugPrint('Failed to save to gallery: $e');
        }
      }
    } finally {
      isCompressing.value = false;
    }
  }

    /// Compresses single selected image with an Ad (for Editor Hub).
  Future<void> compressSingleSelectedWithAd() async {
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      await compressSingleSelected();
    });
  }

  /// Core logic for compressing a single file.
  Future<File?> _compressFile(File file) async {
    final dir = await getTemporaryDirectory();
    final targetPath =
        '${dir.path}/${DateTime.now().millisecondsSinceEpoch}.${outputFormat.value}';

    Uint8List? fileBytes = await file.readAsBytes();

    // 1. Image manipulation (resize, watermark)
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
        ); 
      }
    }

    // 2. Targeted Size Compression
    if (compressionMode.value == 1 && targetSizeKB.value != null) {
       // Iterative approach
        int currentQuality = 95;
        int minQuality = 10;
        Uint8List? resultBytes;

        while (currentQuality >= minQuality) {
          resultBytes = await FlutterImageCompress.compressWithList(
            fileBytes,
            quality: currentQuality,
            format: outputFormat.value == 'jpg'
                ? CompressFormat.jpeg
                : (outputFormat.value == 'png'
                      ? CompressFormat.png
                      : CompressFormat.webp),
            keepExif: !stripExif.value,
          );

          if (resultBytes.lengthInBytes / 1024 <= targetSizeKB.value!) {
            break; 
          }
          currentQuality -= 5;
        }
        
        if (resultBytes == null || resultBytes.isEmpty) return null;
        final resultFile = await File(targetPath).writeAsBytes(resultBytes);
        
        // Stats
        final saved = file.lengthSync() - resultFile.lengthSync();
        if (saved > 0) {
           totalBytesSaved.value += saved;
           box.write('totalBytesSaved', totalBytesSaved.value);
        }
        return resultFile;

    } else {
      // 3. Standard Quality Compression
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

      if (resultBytes.isEmpty) return null;

      final resultFile = await File(targetPath).writeAsBytes(resultBytes);

      // Stats
      final saved = file.lengthSync() - resultFile.lengthSync();
      if (saved > 0) {
        totalBytesSaved.value += saved;
        box.write('totalBytesSaved', totalBytesSaved.value);
      }
      return resultFile;
    }
  }

  /// Opens the location of the last compressed file.
  Future<void> openLastCompressedLocation() async {
    if (lastCompressed.value != null) {
      final adsController = Get.find<UnityAdsController>();
      adsController.performAction(() {
        OpenFilex.open(lastCompressed.value!.path);
      });
    }
  }

  // ========================================================================
  // THEME & UI HELPERS
  // ========================================================================

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
      backgroundColor: Colors.transparent,
    );
  }
}
