import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:gal/gal.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import 'package:image/image.dart' as img;

class EditorController extends GetxController {
  final Rxn<File> originalImage = Rxn<File>();
  final Rxn<File> editedImage = Rxn<File>();

  // This will be called when the EditorHub is opened
  void setImage(File image) {
    originalImage.value = image;
    editedImage.value = image; // Initially, edited is same as original
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
      editedImage.value = File(croppedFile.path);
      showSuccessSnackkbar(message: 'Image cropped successfully.');
    }
  }

  Future<void> resizeImage() async {
    if (editedImage.value == null) return;

    final img.Image? image = img.decodeImage(
      await editedImage.value!.readAsBytes(),
    );
    if (image == null) return;

    final widthController = TextEditingController(text: image.width.toString());
    final heightController = TextEditingController(
      text: image.height.toString(),
    );
    final RxBool keepAspectRatio = true.obs;
    final double aspectRatio = image.width / image.height;

    await Get.dialog(
      AlertDialog(
        title: const Text('Resize Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: widthController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Width'),
              onChanged: (value) {
                if (keepAspectRatio.value) {
                  final width = int.tryParse(value);
                  if (width != null) {
                    heightController.text = (width / aspectRatio)
                        .round()
                        .toString();
                  }
                }
              },
            ),
            TextField(
              controller: heightController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(labelText: 'Height'),
              onChanged: (value) {
                if (keepAspectRatio.value) {
                  final height = int.tryParse(value);
                  if (height != null) {
                    widthController.text = (height * aspectRatio)
                        .round()
                        .toString();
                  }
                }
              },
            ),
            Obx(
              () => CheckboxListTile(
                title: const Text('Keep aspect ratio'),
                value: keepAspectRatio.value,
                onChanged: (value) => keepAspectRatio.value = value ?? true,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final newWidth = int.tryParse(widthController.text);
              final newHeight = int.tryParse(heightController.text);

              if (newWidth != null && newHeight != null) {
                final resizedImage = img.copyResize(
                  image,
                  width: newWidth,
                  height: newHeight,
                );
                await _updateEditedImage(img.encodeJpg(resizedImage));
                await _updateEditedImage(
                  Uint8List.fromList(img.encodeJpg(resizedImage)),
                );
                showSuccessSnackkbar(message: 'Image resized.');
              }
              Get.back();
            },
            child: const Text('Resize'),
          ),
        ],
      ),
    );
  }

  Future<void> compressImage() async {
    if (editedImage.value == null) return;

    final RxDouble quality = 85.0.obs;

    await Get.dialog(
      AlertDialog(
        title: const Text('Compress Image'),
        content: Obx(
          () => Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Quality: ${quality.value.toInt()}'),
              Slider(
                value: quality.value,
                min: 1,
                max: 100,
                divisions: 99,
                label: quality.value.round().toString(),
                onChanged: (value) => quality.value = value,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: Get.back, child: const Text('Cancel')),
          TextButton(
            onPressed: () async {
              final imageBytes = await editedImage.value!.readAsBytes();
              final image = img.decodeImage(imageBytes);
              if (image != null) {
                await _updateEditedImage(
                  img.encodeJpg(image, quality: quality.value.toInt()),
                );
                showSuccessSnackkbar(message: 'Image compressed.');
              }
              Get.back();
            },
            child: const Text('Compress'),
          ),
        ],
      ),
    );
  }

  Future<void> convertImage() async {
    if (editedImage.value == null) return;

    await Get.dialog(
      AlertDialog(
        title: const Text('Convert Image'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('to PNG'),
              onTap: () => _performConversion(img.encodePng, 'PNG'),
            ),
            ListTile(
              title: const Text('to JPG'),
              onTap: () => _performConversion(img.encodeJpg, 'JPG'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _performConversion(
    List<int> Function(img.Image) encoder,
    String format,
  ) async {
    Get.back(); // Close dialog
    final imageBytes = await editedImage.value!.readAsBytes();
    final image = img.decodeImage(imageBytes);
    if (image != null) {
      await _updateEditedImage(
        Uint8List.fromList(encoder(image)),
        newExtension: '.${format.toLowerCase()}',
      );
      showSuccessSnackkbar(message: 'Image converted to $format.');
    }
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
