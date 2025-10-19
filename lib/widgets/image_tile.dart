import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class ImageTile extends GetView<CompressorController> {
  final File file;
  final bool selected;
  const ImageTile({required this.file, this.selected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onLongPress: () {
        Get.to(
          () => Scaffold(
            appBar: AppBar(
              title: const Text('Image Preview'),
              backgroundColor: Colors.transparent,
            ),
            body: InteractiveViewer(
              child: Center(child: Image.file(file, fit: BoxFit.contain)),
            ),
          ),
        );
      },
      child: Hero(
        tag: file.path,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
            gradient: selected ? AppTheme.gradient : null,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              children: [
                Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),
                if (selected) ...[
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Theme.of(context).colorScheme.primary,
                          width: 4,
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                    ),
                  ),
                ],
                Positioned(
                  top: 8,
                  left: 8,
                  child: Obx(
                    () => controller.favorites.contains(file.path)
                        ? Icon(
                            Icons.star,
                            color: Theme.of(context).colorScheme.secondary,
                            size: 24,
                          )
                        : const SizedBox.shrink(),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
