import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';

class ClearAllAlertDialog extends GetView<CompressorController> {
  const ClearAllAlertDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: Theme.of(context).colorScheme.surface,
      title: Text(
        'Clear All Images?',
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
          color: Theme.of(context).colorScheme.error,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'This will remove all picked images. Are you sure?',
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      actions: [
        TextButton(
          onPressed: () => Get.back(),
          child: Text(
            'Cancel',
            style: TextStyle(color: Theme.of(context).colorScheme.secondary),
          ),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
          onPressed: () {
            final List<File> previousImages = List.from(controller.images);
            controller.images.clear();
            controller.selected.value = null;
            Get.back();
            Get.snackbar(
              'Images Cleared',
              'All images have been removed.',
              backgroundColor: Theme.of(context).colorScheme.primary,
              colorText: Colors.white,
              snackbarStatus: (status) {
                if (status == SnackbarStatus.CLOSED) {
                  Get.snackbar(
                    'Undo',
                    'Restore cleared images?',
                    backgroundColor: Theme.of(context).colorScheme.secondary,
                    colorText: Colors.black,
                    mainButton: TextButton(
                      onPressed: () {
                        controller.images.assignAll(previousImages);
                        if (previousImages.isNotEmpty) {
                          controller.selected.value = previousImages.first;
                        }
                        Get.back();
                      },
                      child: const Text(
                        'Undo',
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                }
              },
            );
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
