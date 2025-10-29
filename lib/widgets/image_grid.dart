import 'package:flutter/material.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/widgets/batch_state_card.dart';
import 'package:squeeze_pix/widgets/history.dart';
import 'package:squeeze_pix/widgets/image_tile.dart';

class ImageGrid extends GetView<CompressorController> {
  const ImageGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final sortedImages = controller.getSortedImages();

      return SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(
          delegate: SliverChildListDelegate([
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: sortedImages.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemBuilder: (context, i) {
                final file = sortedImages[i];
                final selected = controller.selected.value?.path == file.path;
                return AnimationConfiguration.staggeredGrid(
                  position: i,
                  duration: const Duration(milliseconds: 400),
                  columnCount: 3,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: Obx(() {
                        final isSelectedInBatch = controller.batchSelection
                            .contains(file);
                        return GestureDetector(
                          onTap: () {
                            if (controller.isSelectionMode.value) {
                              controller.toggleBatchSelection(file);
                            } else {
                              controller.selectImage(file);
                              Get.toNamed('/compress');
                            }
                          },
                          onLongPress: () =>
                              controller.toggleBatchSelection(file),
                          child: ImageTile(
                            file: file,
                            selected: selected,
                            isSelectionMode: controller.isSelectionMode.value,
                            isSelectedInBatch: isSelectedInBatch,
                          ),
                        );
                      }),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            const BatchStatsCard(),
            const SizedBox(height: 8),
            const History(),
          ]),
        ),
      );
    });
  }
}
