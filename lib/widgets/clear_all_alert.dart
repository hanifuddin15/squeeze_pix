import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/home_controller.dart';
import 'package:squeeze_pix/models/app_images_model.dart';

class ClearAllAlertDialog extends GetView<HomeController> {
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
            final List<AppImage> previousImages = List.from(controller.images);
            controller.images.clear();
            controller.selected.value = null;
            controller.saveImages(); // Ensure persistence is cleared
            Get.back();
            Get.snackbar(
              'Images Cleared',
              'All images have been removed.',
              backgroundColor: Theme.of(context).colorScheme.primary,
              colorText: Colors.white,
              snackbarStatus: (status) {
                if (status == SnackbarStatus.CLOSED && previousImages.isNotEmpty) {
                    // Optional: Show undo logic, but avoiding complex nesting which might be buggy with Get.snackbar timing.
                    // For now, simple clear is enough.
                }
              },
              mainButton: TextButton(
                onPressed: () {
                  controller.images.assignAll(previousImages);
                  if (previousImages.isNotEmpty) {
                    controller.selected.value = previousImages.first.file;
                  }
                  controller.saveImages();
                  if (Get.isSnackbarOpen) {
                    Get.back(); // Close snackbar
                  }
                },
                child: const Text('UNDO', style: TextStyle(color: Colors.white)),
              )
            );
          },
          child: const Text('Clear'),
        ),
      ],
    );
  }
}
