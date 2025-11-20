import 'dart:io';
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
  final RxDouble contrast = 1.0.obs; // 0 to 4

  // This will be called when the EditorHub is opened
  void setImage(File image) {
    originalImage.value = image;
    editedImage.value = image; // Initially, edited is same as original
    resetTools();
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

  Future<void> applyEffect(img.Image Function(img.Image) effect) async {
    if (editedImage.value == null) return;
    final imageBytes = await editedImage.value!.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image == null) return;

    img.Image newImage;
    // Handle simple effects
    if (effect == img.grayscale ||
        effect == img.sepia ||
        effect == img.invert) {
      newImage = effect(image);
    } else {
      // Handle effects that need parameters (brightness, contrast)
      newImage = image; // Start with the original
      if (brightness.value != 0) {
        newImage = img.adjustColor(
          newImage,
          brightness: brightness.value / 100,
        );
      }
      if (contrast.value != 1) {
        newImage = img.contrast(newImage, contrast: contrast.value * 100);
      }
    }

    await _updateEditedImage(Uint8List.fromList(img.encodeJpg(newImage)));
    showSuccessSnackkbar(message: 'Effect applied.');
    activeTool.value = EditorTool.none;
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
