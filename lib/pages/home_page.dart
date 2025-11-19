import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/models/app_images_model.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/controllers/home_controller.dart';
import 'package:squeeze_pix/controllers/history_screen.dart';
import 'package:squeeze_pix/controllers/pixel_lab_screen.dart';
import 'package:squeeze_pix/utils/formatters.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/controllers/glassmorphic_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    // Ensure CompressorController is initialized for the HistoryScreen
    Get.put(CompressorController());

    final List<Widget> pages = [
      const ImageGridPage(),
      const PixelLabScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Obx(
          () => IndexedStack(
            index: homeController.tabIndex.value,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: GlassBottomNav(), // Using the refactored Nav Bar
    );
  }
}

class ImageGridPage extends StatelessWidget {
  const ImageGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    final compressorController = Get.find<CompressorController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Obx(
          () => Text(
            homeController.isSelectionMode.value
                ? '${homeController.selection.length} selected'
                : 'Squeeze Pix',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        actions: [
          Obx(
            () => homeController.isSelectionMode.value
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.select_all),
                        onPressed: homeController.selectAll,
                        tooltip: 'Select All',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: homeController.clearSelection,
                        tooltip: 'Clear Selection',
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: Obx(() {
              if (homeController.images.isEmpty) {
                return const _EmptyState();
              }
              return GridView.builder(
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 100),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                ),
                itemCount: homeController.images.length,
                itemBuilder: (context, index) {
                  final image = homeController.images[index];
                  return _GridItem(image: image);
                },
              );
            }),
          ),
          _buildBatchActionBar(homeController, compressorController),
        ],
      ),
    );
  }
}

Widget _buildBatchActionBar(
  HomeController homeController,
  CompressorController compressorController,
) {
  return Obx(
    () => AnimatedContainer(
      height: homeController.isSelectionMode.value ? 350 : 0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      transform: Matrix4.translationValues(
        0,
        homeController.isSelectionMode.value
            ? 0
            : 350, // Start off-screen at the bottom
        0,
      ),
      child: _BatchActionBar(
        onCompress: homeController.compressBatch,
        onShare: () {
          // This assumes you have a share method for batch
          compressorController.batchSelection.assignAll(
            homeController.selection.map((e) => e.file).toList(),
          );
          compressorController.shareZipFile();
        },
        onDelete: homeController.deleteSelection,
      ),
    ),
  );
}

class _GridItem extends StatelessWidget {
  final AppImage image;
  const _GridItem({required this.image});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Obx(() {
      final isSelected = homeController.selection.contains(image);
      return GestureDetector(
        onTap: () => homeController.handleImageTap(image),
        onLongPress: () => homeController.toggleSelection(image),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.file(image.file, fit: BoxFit.cover),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  color: isSelected
                      ? Colors.black.withOpacity(0.5)
                      : Colors.transparent,
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.secondary
                        : Colors.transparent,
                    width: 3,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              if (isSelected)
                const Center(
                  child: Icon(
                    Icons.check_circle,
                    color: Colors.white,
                    size: 32,
                  ),
                ),
            ],
          ),
        ),
      );
    });
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.image_search, size: 80, color: Colors.white70),
          const SizedBox(height: 20),
          const Text(
            'No images yet.',
            style: TextStyle(color: Colors.white, fontSize: 24),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the button below to get started.',
            style: TextStyle(color: Colors.white70, fontSize: 16),
          ),
          const SizedBox(height: 30),
          GlassmorphicButton(
            width: 200,
            height: 50,
            onPressed: homeController.isPicking.value
                ? () {}
                : homeController.pickMultiple,
            child: Obx(
              () => Text(
                homeController.isPicking.value ? "Loading..." : "Pick Images",
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return ClipRRect(
      // This is for the main bottom nav, not the action bar
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Obx(
          () => BottomNavigationBar(
            backgroundColor: Colors.white.withValues(alpha: .2),
            selectedItemColor: Colors.cyan,
            unselectedItemColor: Colors.white70,
            currentIndex: homeController.tabIndex.value,
            onTap: (i) => homeController.tabIndex.value = i,
            type:
                BottomNavigationBarType.fixed, // This makes all labels visible
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: "Pixel Lab",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "History",
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BatchActionBar extends StatelessWidget {
  final VoidCallback onCompress;
  final VoidCallback onShare;
  final VoidCallback onDelete;

  const _BatchActionBar({
    required this.onCompress,
    required this.onShare,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final compressorController = Get.find<CompressorController>();
    final homeController = Get.find<HomeController>();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 20, 16, 16),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
            border: Border(
              top: BorderSide(color: Colors.white.withOpacity(0.3), width: 1.5),
            ),
          ),
          child: Obx(
            () => SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Section
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Size: ${formatBytes(homeController.selectionTotalSize, 2)}',
                          style: const TextStyle(color: Colors.white),
                        ),
                        if (compressorController.batchStats['sizeReduction'] !=
                            null)
                          Text(
                            'Saved: ${formatBytes(compressorController.batchStats['sizeReduction'], 2)}',
                            style: const TextStyle(color: Colors.greenAccent),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Compression Mode Toggle
                  ToggleButtons(
                    isSelected: [
                      compressorController.batchCompressionMode.value == 0,
                      compressorController.batchCompressionMode.value == 1,
                    ],
                    onPressed: (index) {
                      compressorController.batchCompressionMode.value = index;
                    },
                    borderRadius: BorderRadius.circular(10),
                    selectedColor: Colors.white,
                    color: Colors.white70,
                    fillColor: Colors.cyan.withOpacity(0.5),
                    renderBorder: false,
                    children: const [
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Quality'),
                      ),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16.0),
                        child: Text('Target Size'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),

                  // Dynamic Controls (Slider or TextField)
                  if (compressorController.batchCompressionMode.value == 0)
                    // Quality Slider
                    Row(
                      children: [
                        const Icon(Icons.photo_filter, color: Colors.white),
                        Expanded(
                          child: Slider(
                            value: compressorController.batchQuality.value
                                .toDouble(),
                            min: 1,
                            max: 100,
                            divisions: 99,
                            label:
                                '${compressorController.batchQuality.value}%',
                            onChanged: (val) =>
                                compressorController.batchQuality.value = val
                                    .round(),
                          ),
                        ),
                        Text(
                          '${compressorController.batchQuality.value}%',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    )
                  else
                    // Target Size Input
                    Row(
                      children: [
                        const Icon(Icons.straighten, color: Colors.white),
                        const SizedBox(width: 15),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              compressorController.batchTargetSizeKB.value =
                                  int.tryParse(value);
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(color: Colors.white),
                            decoration: const InputDecoration(
                              labelText: 'Size per image',
                              labelStyle: TextStyle(color: Colors.white70),
                              suffixText: 'KB',
                              suffixStyle: TextStyle(color: Colors.white70),
                              enabledBorder: UnderlineInputBorder(
                                borderSide: BorderSide(color: Colors.white54),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 20), // Replaced Spacer with SizedBox
                  // Action Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _ActionButton(
                        icon: Icons.folder_open,
                        label: 'Save To',
                        onTap: compressorController.setBatchSavePath,
                      ),
                      _ActionButton(
                        icon: Icons.compress,
                        label: 'Compress',
                        onTap: onCompress,
                      ),
                      _ActionButton(
                        icon: Icons.share,
                        label: 'Share',
                        onTap: onShare,
                      ),
                      _ActionButton(
                        icon: Icons.delete_outline,
                        label: 'Delete',
                        onTap: onDelete,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: Colors.white, size: 28),
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
