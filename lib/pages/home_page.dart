import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:squeeze_pix/controllers/home_controller.dart';
import 'package:squeeze_pix/models/app_images_model.dart';
import 'package:squeeze_pix/controllers/history_controller.dart';
import 'package:squeeze_pix/pages/history_screen.dart';
import 'package:squeeze_pix/pages/pixel_lab_screen.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/utils/formatters.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/widgets/glassmorphic_button.dart';
import 'package:squeeze_pix/widgets/custom_stat_card.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    Get.put(HistoryController());

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
      bottomNavigationBar: const GlassBottomNav(),
    );
  }
}

class ImageGridPage extends StatelessWidget {
  const ImageGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();

    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        title: Obx(
          () => Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: AppTheme.heroCardGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.bolt, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    homeController.isSelectionMode.value
                        ? '${homeController.selection.length} Selected'
                        : 'Squeeze Pix',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                      color: Colors.white,
                    ),
                  ),
                  if (!homeController.isSelectionMode.value)
                    Text(
                      'Batch Image Compressor & Studio',
                      style: TextStyle(
                        fontSize: 11,
                        color: Colors.white.withValues(alpha: 0.6),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        actions: [
          Obx(
            () => homeController.isSelectionMode.value
                ? Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.select_all, color: Colors.cyanAccent),
                        onPressed: homeController.selectAll,
                        tooltip: 'Select All',
                      ),
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white70),
                        onPressed: homeController.clearSelection,
                        tooltip: 'Clear Selection',
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Container(
                        margin: const EdgeInsets.only(right: 4),
                        decoration: BoxDecoration(
                          color: Colors.amber.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.amber.withValues(alpha: 0.4),
                          ),
                        ),
                        child: IconButton(
                          icon: const Icon(Icons.workspace_premium, color: Colors.amber),
                          onPressed: () => Get.to(() => const ProUpgradeScreen()),
                          tooltip: 'Pro Upgrade',
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.add_photo_alternate, color: Colors.cyanAccent),
                        onPressed: homeController.showImageSourceDialog,
                        tooltip: 'Add Images',
                      ),
                    ],
                  ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Top Stats Card Banner
          Obx(() {
            if (homeController.images.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  CustomStatCard(
                    label: "Total Selected",
                    value: "${homeController.images.length} Images",
                    icon: Icons.photo_library,
                    iconColor: Colors.cyanAccent,
                  ),
                  const SizedBox(width: 12),
                  CustomStatCard(
                    label: "Total File Size",
                    value: formatBytes(
                      homeController.images.fold<int>(
                        0,
                        (sum, img) => sum + img.file.lengthSync(),
                      ),
                      1,
                    ),
                    icon: Icons.compress,
                    iconColor: Colors.amber,
                  ),
                ],
              ),
            );
          }),

          // Long-press batch selection hint banner
          Obx(() {
            if (homeController.images.isEmpty || homeController.isSelectionMode.value) {
              return const SizedBox.shrink();
            }
            return _LongPressHintBanner();
          }),

          // Main Grid / Empty State
          Expanded(
            child: Obx(() {
              if (homeController.images.isEmpty) {
                return const _EmptyState();
              }
              return _StaggeredImageGrid(images: homeController.images);
            }),
          ),
          _buildBatchActionBar(homeController),
        ],
      ),
    );
  }
}

/// Animated staggered grid for images
class _StaggeredImageGrid extends StatefulWidget {
  final List<AppImage> images;
  const _StaggeredImageGrid({required this.images});

  @override
  State<_StaggeredImageGrid> createState() => _StaggeredImageGridState();
}

class _StaggeredImageGridState extends State<_StaggeredImageGrid>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    )..forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 120),
      physics: const BouncingScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: widget.images.length,
      itemBuilder: (context, index) {
        final image = widget.images[index];
        // Staggered delay for each item
        final delay = (index * 0.05).clamp(0.0, 0.6);
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, (delay + 0.4).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.3),
              end: Offset.zero,
            ).animate(animation),
            child: _GridItem(image: image),
          ),
        );
      },
    );
  }
}

/// Dismissible hint banner for long-press to batch select
class _LongPressHintBanner extends StatefulWidget {
  @override
  State<_LongPressHintBanner> createState() => _LongPressHintBannerState();
}

class _LongPressHintBannerState extends State<_LongPressHintBanner>
    with SingleTickerProviderStateMixin {
  final _box = GetStorage();
  bool _dismissed = false;
  late final AnimationController _shimmerController;

  @override
  void initState() {
    super.initState();
    _dismissed = _box.read('hintDismissed') ?? false;
    _shimmerController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();
  }

  @override
  void dispose() {
    _shimmerController.dispose();
    super.dispose();
  }

  void _dismiss() {
    _box.write('hintDismissed', true);
    setState(() => _dismissed = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 400),
      opacity: _dismissed ? 0 : 1,
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              Colors.cyanAccent.withValues(alpha: 0.15),
              Colors.blue.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
            color: Colors.cyanAccent.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _shimmerController,
              builder: (context, child) {
                return Transform.scale(
                  scale: 1.0 + 0.15 * (_shimmerController.value > 0.5
                      ? 1.0 - _shimmerController.value
                      : _shimmerController.value) * 2,
                  child: child,
                );
              },
              child: const Icon(
                Icons.touch_app_rounded,
                color: Colors.cyanAccent,
                size: 20,
              ),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '💡 Long-press any image to select multiple for batch compression',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  height: 1.4,
                ),
              ),
            ),
            GestureDetector(
              onTap: _dismiss,
              child: const Icon(Icons.close, color: Colors.white38, size: 16),
            ),
          ],
        ),
      ),
    );
  }
}

Widget _buildBatchActionBar(HomeController homeController) {
  return Obx(
    () => AnimatedContainer(
      height: homeController.isSelectionMode.value ? 360 : 0,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
      clipBehavior: Clip.hardEdge,
      decoration: const BoxDecoration(),
      child: _BatchActionBar(
        onCompress: homeController.compressAll,
        onShare: () => homeController.shareZipFile(),
        onDelete: homeController.deleteSelection,
      ),
    ),
  );
}

class _GridItem extends StatefulWidget {
  final AppImage image;
  const _GridItem({required this.image});

  @override
  State<_GridItem> createState() => _GridItemState();
}

class _GridItemState extends State<_GridItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController;
  late final Animation<double> _pressScale;

  @override
  void initState() {
    super.initState();
    _pressController = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.93).animate(
      CurvedAnimation(parent: _pressController, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _pressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Obx(() {
      final isSelected = homeController.selection.contains(widget.image);
      final fileSizeString = formatBytes(widget.image.file.lengthSync(), 1);

      return GestureDetector(
        onTapDown: (_) => _pressController.forward(),
        onTapUp: (_) {
          _pressController.reverse();
          HapticFeedback.selectionClick();
          homeController.handleImageTap(widget.image);
        },
        onTapCancel: () => _pressController.reverse(),
        onLongPress: () {
          HapticFeedback.mediumImpact();
          homeController.toggleSelection(widget.image);
        },
        child: ScaleTransition(
          scale: _pressScale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.cyanAccent
                    : Colors.white.withValues(alpha: 0.15),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.3),
                        blurRadius: 10,
                        spreadRadius: 1,
                      ),
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(widget.image.file, fit: BoxFit.cover),

                  // Bottom size badge
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 4, horizontal: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.black.withValues(alpha: 0.2),
                          ],
                          begin: Alignment.bottomCenter,
                          end: Alignment.topCenter,
                        ),
                      ),
                      child: Text(
                        fileSizeString,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),

                  // Selection overlay
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: isSelected
                        ? Colors.cyanAccent.withValues(alpha: 0.25)
                        : Colors.transparent,
                  ),

                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 200),
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.cyanAccent,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.check,
                            color: Colors.black,
                            size: 16,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

class _EmptyState extends StatefulWidget {
  const _EmptyState();

  @override
  State<_EmptyState> createState() => _EmptyStateState();
}

class _EmptyStateState extends State<_EmptyState>
    with SingleTickerProviderStateMixin {
  late final AnimationController _floatController;
  late final Animation<double> _floatAnimation;

  @override
  void initState() {
    super.initState();
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnimation = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _floatController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _floatController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _floatAnimation,
              builder: (context, child) {
                return Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                );
              },
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.heroCardGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.primaryColor.withValues(alpha: 0.4),
                      blurRadius: 24,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.add_photo_alternate_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Compress & Optimize Photos',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Select images from gallery or camera to shrink file size up to 90% without losing quality.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            // Pro tip
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.2),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.touch_app_rounded,
                      color: Colors.cyanAccent, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'Long-press images to batch select',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.7),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 28),
            Obx(
              () => homeController.isPicking.value
                  ? const CircularProgressIndicator(color: Colors.cyanAccent)
                  : Column(
                      children: [
                        GlassmorphicButton(
                          width: 240,
                          height: 52,
                          borderRadius: 16,
                          color: AppTheme.primaryColor.withValues(alpha: 0.4),
                          borderColor: Colors.cyanAccent.withValues(alpha: 0.5),
                          onPressed: homeController.pickMultiple,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.photo_library_outlined,
                                  color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "Pick from Gallery",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 15,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        GlassmorphicButton(
                          width: 240,
                          height: 50,
                          borderRadius: 16,
                          onPressed: homeController.pickFromCamera,
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.camera_alt_outlined,
                                  color: Colors.white),
                              SizedBox(width: 10),
                              Text(
                                "Use Camera",
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E).withValues(alpha: 0.8),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.15),
                width: 1,
              ),
            ),
            child: Obx(
              () => BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.cyanAccent,
                unselectedItemColor: Colors.white.withValues(alpha: 0.5),
                selectedLabelStyle:
                    const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                currentIndex: homeController.tabIndex.value,
                onTap: (i) {
                  HapticFeedback.selectionClick();
                  homeController.tabIndex.value = i;
                },
                type: BottomNavigationBarType.fixed,
                items: const [
                  BottomNavigationBarItem(
                    icon: Icon(Icons.compress_rounded),
                    activeIcon: Icon(Icons.compress_rounded,
                        color: Colors.cyanAccent),
                    label: "Squeeze",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.auto_awesome_outlined),
                    activeIcon: Icon(Icons.auto_awesome, color: Colors.cyanAccent),
                    label: "Pixel Lab",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(Icons.history_toggle_off_rounded),
                    activeIcon: Icon(Icons.history_rounded,
                        color: Colors.cyanAccent),
                    label: "History",
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
    final homeController = Get.find<HomeController>();

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.95),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.cyanAccent.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
          ),
          child: Obx(
            () => SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Info Banner
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.check_circle_outline,
                              color: Colors.cyanAccent, size: 18),
                          const SizedBox(width: 8),
                          Text(
                            '${homeController.selection.length} Selected',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 15,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Total: ${formatBytes(homeController.selectionTotalSize, 2)}',
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.8),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Mode Toggle (Quality vs Target KB)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                homeController.batchCompressionMode.value = 0,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    homeController.batchCompressionMode.value ==
                                            0
                                        ? AppTheme.primaryColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Quality %',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () =>
                                homeController.batchCompressionMode.value = 1,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              padding:
                                  const EdgeInsets.symmetric(vertical: 8),
                              decoration: BoxDecoration(
                                color:
                                    homeController.batchCompressionMode.value ==
                                            1
                                        ? AppTheme.primaryColor
                                        : Colors.transparent,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Text(
                                'Target KB',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Mode Controls
                  if (homeController.batchCompressionMode.value == 0)
                    Row(
                      children: [
                        const Icon(Icons.tune,
                            color: Colors.cyanAccent, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: SliderTheme(
                            data: SliderTheme.of(context).copyWith(
                              activeTrackColor: Colors.cyanAccent,
                              inactiveTrackColor:
                                  Colors.white.withValues(alpha: 0.1),
                              thumbColor: Colors.white,
                            ),
                            child: Slider(
                              value: homeController.batchQuality.value
                                  .toDouble(),
                              min: 1,
                              max: 100,
                              divisions: 99,
                              label: '${homeController.batchQuality.value}%',
                              onChanged: (val) =>
                                  homeController.batchQuality.value =
                                      val.round(),
                            ),
                          ),
                        ),
                        Text(
                          '${homeController.batchQuality.value}%',
                          style: const TextStyle(
                            color: Colors.cyanAccent,
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    )
                  else
                    Row(
                      children: [
                        const Icon(Icons.straighten,
                            color: Colors.cyanAccent, size: 20),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            onChanged: (value) {
                              homeController.batchTargetSizeKB.value =
                                  int.tryParse(value);
                            },
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                            ],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 14),
                            decoration: InputDecoration(
                              hintText: 'Target max size (e.g. 200)',
                              hintStyle: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.4)),
                              suffixText: 'KB',
                              suffixStyle: const TextStyle(
                                  color: Colors.cyanAccent,
                                  fontWeight: FontWeight.bold),
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 10),
                              filled: true,
                              fillColor: Colors.white.withValues(alpha: 0.08),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(12),
                                borderSide: BorderSide.none,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),

                  const SizedBox(height: 16),

                  // Action Buttons Row
                  Row(
                    children: [
                      Expanded(
                        flex: 2,
                        child: ElevatedButton.icon(
                          onPressed: onCompress,
                          icon: const Icon(Icons.compress,
                              color: Colors.black, size: 20),
                          label: const Text('Compress Now',
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.cyanAccent,
                            padding:
                                const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: homeController.compressAndShare,
                        icon: const Icon(Icons.share,
                            color: Colors.white, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.white.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(12),
                        ),
                      ),
                      const SizedBox(width: 4),
                      IconButton.filledTonal(
                        onPressed: onDelete,
                        icon: const Icon(Icons.delete_outline,
                            color: Colors.redAccent, size: 20),
                        style: IconButton.styleFrom(
                          backgroundColor:
                              Colors.redAccent.withValues(alpha: 0.15),
                          padding: const EdgeInsets.all(12),
                        ),
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
