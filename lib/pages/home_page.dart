import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../widgets/primary_button.dart';
import '../widgets/image_tile.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../controllers/compressor_controller.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    return Scaffold(
      appBar: AppBar(
        title: const Text('SqueezePix'),
        centerTitle: true,
        actions: [
          Obx(
            () => c.images.isNotEmpty
                ? IconButton(
                    icon: const Icon(Icons.delete_outline),
                    tooltip: 'Clear All',
                    onPressed: () => _showClearConfirmation(context, c),
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Obx(() {
        if (c.images.isEmpty) {
          return const _EmptyState();
        }
        return const _ImageGrid();
      }),
      bottomNavigationBar: const _BottomActionBar(),
    );
  }

  void _showClearConfirmation(BuildContext context, CompressorController c) {
    Get.dialog(
      AlertDialog(
        title: const Text('Clear All?'),
        content: const Text(
          'This will remove all picked images. Are you sure?',
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          FilledButton(
            onPressed: () {
              c.images.clear();
              c.selected.value = null;
              Get.back();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.photo_library_outlined,
            size: 80,
            color: Colors.grey.shade400,
          ),
          const SizedBox(height: 16),
          Text('No Images Yet', style: textTheme.headlineSmall),
          const SizedBox(height: 8),
          Text(
            'Tap "Pick Images" to get started',
            style: textTheme.bodyLarge?.copyWith(color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }
}

class _ImageGrid extends StatelessWidget {
  const _ImageGrid();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    return CustomScrollView(
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.all(12),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 8,
              mainAxisSpacing: 8,
            ),
            delegate: SliverChildBuilderDelegate((context, i) {
              final file = c.images[i];
              final selected = c.selected.value?.path == file.path;
              return AnimationConfiguration.staggeredGrid(
                position: i,
                duration: const Duration(milliseconds: 375),
                columnCount: 3,
                child: ScaleAnimation(
                  child: FadeInAnimation(
                    child: GestureDetector(
                      onTap: () {
                        c.selectImage(file);
                        Get.toNamed('/compress');
                      },
                      child: ImageTile(file: file, selected: selected),
                    ),
                  ),
                ),
              );
            }, childCount: c.images.length),
          ),
        ),
        SliverToBoxAdapter(child: _History()),
      ],
    );
  }
}

class _BottomActionBar extends StatelessWidget {
  const _BottomActionBar();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(
          () => Row(
            children: [
              Expanded(
                child: PrimaryButton(
                  label: c.isPicking.value ? 'Loading...' : 'Pick Images',
                  onPressed: c.isPicking.value ? () {} : () => c.pickImages(),
                  icon: c.isPicking.value
                      ? null // Or a spinner icon
                      : Icons.photo_library_outlined,
                ),
              ),
              if (c.isPicking.value) ...[
                const SizedBox(width: 12),
                const CircularProgressIndicator(),
              ],
              const SizedBox(width: 12),
              IconButton.filled(
                style: IconButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: c.isPicking.value
                    ? null
                    : () => c.pickSingleFromCamera(),
                icon: const Icon(Icons.camera_alt_outlined),
                tooltip: 'Use Camera',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _History extends StatelessWidget {
  const _History();

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    return Obx(() {
      if (c.history.isEmpty) return const SizedBox.shrink();

      return Card(
        margin: const EdgeInsets.all(12),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Recently Compressed',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 90,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemBuilder: (_, i) => ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      File(c.history[i]),
                      width: 90,
                      height: 90,
                      fit: BoxFit.cover,
                    ),
                  ),
                  separatorBuilder: (_, __) => const SizedBox(width: 8),
                  itemCount: c.history.length,
                ),
              ),
            ],
          ),
        ),
      );
    });
  }
}
