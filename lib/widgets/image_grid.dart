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
      return CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              delegate: SliverChildBuilderDelegate((context, i) {
                final file = sortedImages[i];
                final selected = controller.selected.value?.path == file.path;
                return AnimationConfiguration.staggeredGrid(
                  position: i,
                  duration: const Duration(milliseconds: 400),
                  columnCount: 3,
                  child: ScaleAnimation(
                    child: FadeInAnimation(
                      child: GestureDetector(
                        onTap: () {
                          controller.selectImage(file);
                          Get.toNamed('/compress');
                        },
                        child: ImageTile(file: file, selected: selected),
                      ),
                    ),
                  ),
                );
              }, childCount: sortedImages.length),
            ),
          ),
          const SliverToBoxAdapter(child: BatchStatsCard()),
          SliverToBoxAdapter(child: History()),
        ],
      );
    });
  }
}
