import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/utils/snackbar.dart';

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

  void resizeImage() {
    // TODO: Implement resize logic, perhaps with a bottom sheet for input
    showWarningSnackkbar(message: 'Resize feature coming soon!');
  }

  void compressImage() {
    // TODO: Implement compress logic, perhaps with a bottom sheet for quality slider
    showWarningSnackkbar(message: 'Compress feature coming soon!');
  }

  void convertImage() {
    // TODO: Implement convert logic (e.g., to PNG, WEBP)
    showWarningSnackkbar(message: 'Convert feature coming soon!');
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
}
