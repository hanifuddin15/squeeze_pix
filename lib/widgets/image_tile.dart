import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class ImageTile extends GetView<CompressorController> {
  final File file;
  final bool selected;
  final bool isSelectionMode;
  final bool isSelectedInBatch;
  const ImageTile({
    required this.file,
    this.selected = false,
    this.isSelectionMode = false,
    this.isSelectedInBatch = false,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (isSelectionMode) {
          controller.toggleBatchSelection(file);
        } else {
          // Select the image first, then navigate.
          controller.selectImage(file);
          Get.toNamed('/compress');
        }
      },
      onLongPress: () {
        // Enable selection mode and select the long-pressed item.
        controller.toggleSelectionMode(true);
        controller.toggleBatchSelection(file);
      },
      child: Hero(
        tag: file.path,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: .1),
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
                if (selected && !isSelectionMode) ...[
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
                if (isSelectionMode)
                  Positioned.fill(
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      decoration: BoxDecoration(
                        color: isSelectedInBatch
                            ? Theme.of(
                                context,
                              ).colorScheme.primary.withOpacity(0.6)
                            : Colors.black.withOpacity(0.2),
                      ),
                    ),
                  ),
                if (isSelectedInBatch)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.check_circle,
                      color: Theme.of(context).colorScheme.onPrimary,
                      size: 24,
                      shadows: const [
                        Shadow(color: Colors.black38, blurRadius: 4),
                      ],
                    ),
                  ),
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
