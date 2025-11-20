import 'dart:io';
import 'dart:math';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import 'package:image/image.dart' as img;

enum EditorTool { none, crop, resize, compress, convert, effects }

class EditorController extends GetxController {
  final Rxn<File> originalImage = Rxn<File>();
  final Rxn<File> editedImage = Rxn<File>();

  // UI State
  final Rx<EditorTool> activeTool = EditorTool.none.obs;

  // --- Tool-specific states ---
  // Compress
  final RxDouble compressionQuality = 85.0.obs;
  final RxInt compressionMode = 0.obs; // 0 for Quality, 1 for Target Size
  final Rxn<int> targetSizeKB = Rxn<int>(100);
  // Effects
  final RxDouble brightness = 0.0.obs; // -100 to 100
  final RxDouble contrast = 1.0.obs; // 0 to 2
  final RxDouble saturation = 1.0.obs; // 0 to 2
  final RxDouble hue = 0.0.obs; // -180 to 180
  final Rx<ColorFilter> activeColorFilter = const ColorFilter.mode(
    Colors.transparent,
    BlendMode.color,
  ).obs;

  @override
  void onInit() {
    super.onInit();
    // Listen to all effect sliders to update the UI in real-time
    everAll([
      brightness,
      contrast,
      saturation,
      hue,
    ], (_) => _updateColorFilter());
  }

  // This will be called when the EditorHub is opened
  void setImage(File image) {
    originalImage.value = image;
    editedImage.value = image; // Initially, edited is same as original
    resetTools();
    resetEffects();
  }

  void resetEffects() {
    brightness.value = 0.0;
    contrast.value = 1.0;
    saturation.value = 1.0;
    hue.value = 0.0;
    // This will be updated by the everAll listener
    activeColorFilter.value = const ColorFilter.mode(
      Colors.transparent,
      BlendMode.color,
    );
  }

  void setActiveTool(EditorTool tool) {
    if (activeTool.value == tool) {
      activeTool.value = EditorTool.none; // Toggle off to close the panel
    } else {
      activeTool.value = tool;
    }
  }

  void resetTools() {
    activeTool.value = EditorTool.none;
  }

  Future<void> cropImage() async {
    if (editedImage.value == null) return;

    final croppedFile = await ImageCropper().cropImage(
      sourcePath: editedImage.value!.path,
      aspectRatio: const CropAspectRatio(
        ratioX: 1,
        ratioY: 1,
      ), // default = square
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: 'Crop Image',
          toolbarColor: Get.theme.colorScheme.primary,
          toolbarWidgetColor: Colors.white,
          lockAspectRatio: false,
        ),
        IOSUiSettings(title: 'Crop Image'),
      ],
    );

    if (croppedFile != null) {
      final bytes = await croppedFile.readAsBytes();
      await _updateEditedImage(bytes);
      showSuccessSnackkbar(message: 'Image cropped.');
    }
  }

  Future<void> applyResize(int newWidth, int newHeight) async {
    if (editedImage.value == null) return;
    final img.Image? image = img.decodeImage(
      await editedImage.value!.readAsBytes(),
    );
    if (image == null) return;
    final resizedImage = img.copyResize(
      image,
      width: newWidth,
      height: newHeight,
    );
    await _updateEditedImage(Uint8List.fromList(img.encodeJpg(resizedImage)));
    showSuccessSnackkbar(message: 'Image resized.');
    activeTool.value = EditorTool.none;
  }

  Future<void> applyCompression() async {
    if (editedImage.value == null) return;
    final imageBytes = await editedImage.value!.readAsBytes();

    Uint8List resultBytes;

    // Target Size Mode
    if (compressionMode.value == 1 && targetSizeKB.value != null) {
      int quality = 95;
      resultBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: quality,
      );
      // Iteratively reduce quality to meet the target size
      while (resultBytes.lengthInBytes / 1024 > targetSizeKB.value! &&
          quality > 10) {
        quality -= 5;
        resultBytes = await FlutterImageCompress.compressWithList(
          imageBytes,
          quality: quality,
        );
      }
    }
    // Quality Mode
    else {
      resultBytes = await FlutterImageCompress.compressWithList(
        imageBytes,
        quality: compressionQuality.value.toInt(),
      );
    }

    if (resultBytes.isEmpty) {
      showErrorSnackkbar(message: 'Compression failed.');
      return;
    }

    final originalSize = imageBytes.lengthInBytes;
    final newSize = resultBytes.lengthInBytes;
    final reduction = ((originalSize - newSize) / originalSize * 100)
        .toStringAsFixed(1);

    await _updateEditedImage(resultBytes);
    showSuccessSnackkbar(message: 'Compressed by $reduction%');
    activeTool.value = EditorTool.none;
  }

  Future<void> applyConversion(String format) async {
    if (editedImage.value == null) return;
    final imageBytes = await editedImage.value!.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return;

    // Handle PDF conversion as a special case: save and exit the tool.
    if (format == 'PDF') {
      final pdf = pw.Document();
      final pdfImage = pw.MemoryImage(imageBytes);
      pdf.addPage(
        pw.Page(
          build: (pw.Context context) {
            return pw.Center(child: pw.Image(pdfImage));
          },
        ),
      );
      final pdfBytes = await pdf.save();

      // Save the PDF to a temporary file to be able to save/share it
      final tempDir = await getTemporaryDirectory();
      final pdfFile = File('${tempDir.path}/converted.pdf');
      await pdfFile.writeAsBytes(pdfBytes);

      try {
        // Use Share sheet for the PDF
        await SharePlus.instance.share(
          ShareParams(files: [XFile(pdfFile.path)]),
        );
        showSuccessSnackkbar(message: 'PDF ready to be shared!');
      } catch (e) {
        showErrorSnackkbar(message: 'Failed to share PDF: $e');
      }

      activeTool.value = EditorTool.none;
      return; // Exit here, do not try to display the PDF
    }

    // --- Handle normal image format conversions (JPG, PNG) ---
    List<int> encoded;
    if (format == 'PNG') {
      encoded = img.encodePng(image, level: 6);
    } else {
      // Default to JPG
      encoded = img.encodeJpg(image);
    }

    await _updateEditedImage(
      Uint8List.fromList(encoded),
      newExtension: '.${format.toLowerCase()}',
    );
    showSuccessSnackkbar(message: 'Image converted to $format.');
    activeTool.value = EditorTool.none;
  }

  Future<void> applyEffect(img.Image Function(img.Image)? effect) async {
    if (editedImage.value == null) return;
    final imageBytes = await editedImage.value!.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return;

    img.Image newImage = image;

    // If a one-tap effect function is provided, apply it first.
    if (effect != null) {
      newImage = effect(image);
    }

    // Then, apply slider adjustments on top.
    if (brightness.value != 0) {
      newImage = img.adjustColor(
        newImage,
        brightness: brightness.value.toInt(),
      );
    }
    if (contrast.value != 1.0) {
      newImage = img.contrast(newImage, contrast: contrast.value * 100);
    }
    if (saturation.value != 1.0 || hue.value != 0.0) {
      newImage = img.adjustColor(
        newImage,
        saturation: saturation.value * 100,
        hue: hue.value,
      );
    }

    await _updateEditedImage(Uint8List.fromList(img.encodeJpg(newImage)));
    showSuccessSnackkbar(message: 'Effect applied.');
    resetEffects(); // Reset sliders and UI filter after applying to bake the changes
  }

  void applyOneTapEffect(img.Image Function(img.Image) effect) {
    resetEffects(); // Reset sliders first
    applyEffect(effect);
  }

  Future<void> applyAdjustments() async {
    if (editedImage.value == null) return;
    final imageBytes = await editedImage.value!.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return;

    // Call applyEffect with null to only apply slider values
    await applyEffect(null);
  }

  // --- Color Filter Calculation for Real-time Preview ---
  void _updateColorFilter() {
    final b = brightness.value;
    final c = contrast.value;
    final s = saturation.value;
    final h = hue.value;

    // This matrix combines brightness, contrast, and saturation
    List<double> matrix = [
      c * s,
      0,
      0,
      0,
      b,
      0,
      c * s,
      0,
      0,
      b,
      0,
      0,
      c * s,
      0,
      b,
      0,
      0,
      0,
      1,
      0,
    ];

    if (h != 0) {
      final hueMatrix = _hueMatrix(h);
      matrix = _multiplyMatrices(matrix, hueMatrix);
    }

    activeColorFilter.value = ColorFilter.matrix(matrix);
  }

  List<double> _hueMatrix(double degrees) {
    final radians = degrees * (pi / 180);
    final cosVal = cos(radians);
    final sinVal = sin(radians);
    final lumR = 0.213, lumG = 0.715, lumB = 0.072;
    return [
      lumR + cosVal * (1 - lumR) - sinVal * lumR,
      lumG - cosVal * lumG - sinVal * lumG,
      lumB - cosVal * lumB + sinVal * (1 - lumB),
      0,
      0,
      lumR - cosVal * lumR + sinVal * 0.143,
      lumG + cosVal * (1 - lumG) + sinVal * 0.140,
      lumB - cosVal * lumB - sinVal * 0.283,
      0,
      0,
      lumR - cosVal * lumR - sinVal * (1 - lumR),
      lumG - cosVal * lumG + sinVal * lumG,
      lumB + cosVal * (1 - lumB) + sinVal * lumB,
      0,
      0,
      0,
      0,
      0,
      1,
      0,
    ];
  }

  List<double> _multiplyMatrices(List<double> a, List<double> b) {
    final result = List<double>.filled(20, 0.0);
    for (int i = 0; i < 4; i++) {
      for (int j = 0; j < 5; j++) {
        double sum = 0;
        for (int k = 0; k < 4; k++) {
          sum += a[i * 5 + k] * b[k * 5 + j];
        }
        result[i * 5 + j] = sum + (j == 4 ? a[i * 5 + 4] : 0);
      }
    }
    return result;
  }

  Future<void> _updateEditedImage(
    Uint8List imageBytes, {
    String? newExtension,
  }) async {
    final tempDir = await getTemporaryDirectory();
    String fileName = editedImage.value!.path.split('/').last;

    if (newExtension != null) {
      fileName = '${fileName.split('.').first}$newExtension';
    }

    final tempFile = File('${tempDir.path}/$fileName');
    await tempFile.writeAsBytes(imageBytes);
    editedImage.value = tempFile;
  }

  void shareImage() {
    if (editedImage.value != null) {
      SharePlus.instance.share(
        ShareParams(files: [XFile(editedImage.value!.path)]),
      );
    } else {
      showErrorSnackkbar(message: 'No image to share.');
    }
  }

  Future<void> saveImage() async {
    if (editedImage.value != null) {
      try {
        await Gal.putImage(editedImage.value!.path);
        showSuccessSnackkbar(message: 'Image saved to gallery!');
      } catch (e) {
        showErrorSnackkbar(message: 'Failed to save image: $e');
      }
    } else {
      showErrorSnackkbar(message: 'No image to save.');
    }
  }
}
