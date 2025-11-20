import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/editor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class EditorHub extends StatelessWidget {
  final File? imageFile;
  const EditorHub({this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put to ensure a unique controller instance for this screen
    final controller = Get.put(EditorController());
    if (imageFile != null) {
      controller.setImage(imageFile!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareImage,
            tooltip: 'Share Image',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: controller.saveImage,
            tooltip: 'Save Image',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Column(
          children: [
            // Image Preview Area
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(
                    () => controller.editedImage.value != null
                        ? Image.file(controller.editedImage.value!)
                        : const Center(
                            child: Text(
                              'No Image Selected',
                              style: TextStyle(color: Colors.white),
                            ),
                          ),
                  ),
                ),
              ),
            ),
            // Editing Toolbar
            _buildEditingToolbar(controller),
          ],
        ),
      ),
    );
  }

  Widget _buildEditingToolbar(EditorController controller) {
    return Container(
      height: 100,
      color: Colors.black.withOpacity(0.3),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: [
          _EditorToolButton(
            icon: Icons.crop_rotate,
            label: 'Crop',
            onTap: controller.cropImage,
          ),
          _EditorToolButton(
            icon: Icons.aspect_ratio,
            label: 'Resize',
            onTap: controller.resizeImage,
          ),
          _EditorToolButton(
            icon: Icons.compress,
            label: 'Compress',
            onTap: controller.compressImage,
          ),
          _EditorToolButton(
            icon: Icons.transform,
            label: 'Convert',
            onTap: controller.convertImage,
          ),
          _EditorToolButton(
            icon: Icons.filter_vintage,
            label: 'Effects',
            onTap: () {
              Get.snackbar('Coming Soon', 'Effects are under development.');
            },
          ),
        ],
      ),
    );
  }
}

class _EditorToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EditorToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
