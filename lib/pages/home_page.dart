import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/widgets/bottom_action_bar.dart';
import 'package:squeeze_pix/widgets/empty_state.dart';
import 'package:squeeze_pix/widgets/image_grid.dart';
import '../controllers/compressor_controller.dart';

class HomePage extends GetView<CompressorController> {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('SqueezePix'),
        centerTitle: true,
        actions: [
          Obx(
            () => controller.images.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear All',
                    onPressed: () {
                      controller.showClearConfirmation();
                    },
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (controller.images.isEmpty) {
          return const EmptyState();
        }
        return const ImageGrid();
      }),
      bottomNavigationBar: const BottomActionBar(),
    );
  }
}
