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
      appBar: _buildAppBar(homeController),
      body: Column(
        children: [
          // Stats row
          Obx(() {
            if (homeController.images.isEmpty) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
              child: Row(
                children: [
                  CustomStatCard(
                    label: "Total Images",
                    value: "${homeController.images.length}",
                    icon: Icons.photo_library,
                    iconColor: Colors.cyanAccent,
                  ),
                  const SizedBox(width: 12),
                  CustomStatCard(
                    label: "Total Size",
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

          // Long-press hint banner
          Obx(() {
            if (homeController.images.isEmpty ||
                homeController.isSelectionMode.value) {
              return const SizedBox.shrink();
            }
            return const _LongPressHintBanner();
          }),

          // Main content
          Expanded(
            child: Obx(() {
              if (homeController.images.isEmpty) {
                return const _EmptyState();
              }
              return _StaggeredImageGrid(images: homeController.images);
            }),
          ),

          // Animated batch action panel
          _AnimatedBatchPanel(homeController: homeController),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(HomeController homeController) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: false,
      title: Obx(() => AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween<Offset>(
                  begin: const Offset(0, -0.3),
                  end: Offset.zero,
                ).animate(animation),
                child: child,
              ),
            ),
            child: homeController.isSelectionMode.value
                ? _SelectionTitle(key: const ValueKey('selection'))
                : _DefaultTitle(key: const ValueKey('default')),
          )),
      actions: [
        Obx(() => homeController.isSelectionMode.value
            ? Row(
                children: [
                  _AppBarIconBtn(
                    icon: Icons.select_all,
                    color: Colors.cyanAccent,
                    onTap: homeController.selectAll,
                    tooltip: 'Select All',
                  ),
                  _AppBarIconBtn(
                    icon: Icons.close,
                    color: Colors.white70,
                    onTap: homeController.clearSelection,
                    tooltip: 'Clear',
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
                          color: Colors.amber.withValues(alpha: 0.4)),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.workspace_premium,
                          color: Colors.amber),
                      onPressed: () => Get.to(
                        () => const ProUpgradeScreen(),
                        transition: Transition.downToUp,
                      ),
                      tooltip: 'Pro Upgrade',
                    ),
                  ),
                  _AppBarIconBtn(
                    icon: Icons.add_photo_alternate,
                    color: Colors.cyanAccent,
                    onTap: homeController.showImageSourceDialog,
                    tooltip: 'Add Images',
                  ),
                ],
              )),
      ],
    );
  }
}

class _SelectionTitle extends StatelessWidget {
  const _SelectionTitle({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<HomeController>();
    return Obx(() => Row(
          children: [
            Container(
              padding: const EdgeInsets.all(7),
              decoration: BoxDecoration(
                color: Colors.cyanAccent.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.4)),
              ),
              child: const Icon(Icons.check_circle_outline,
                  color: Colors.cyanAccent, size: 18),
            ),
            const SizedBox(width: 10),
            Text(
              '${c.selection.length} Selected',
              style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 20),
            ),
          ],
        ));
  }
}

class _DefaultTitle extends StatelessWidget {
  const _DefaultTitle({super.key});
  @override
  Widget build(BuildContext context) {
    return Row(
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
            const Text(
              'Squeeze Pix',
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
            Text(
              'Batch Compressor & Studio',
              style: TextStyle(
                  fontSize: 11, color: Colors.white.withValues(alpha: 0.6)),
            ),
          ],
        ),
      ],
    );
  }
}

class _AppBarIconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _AppBarIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_AppBarIconBtn> createState() => _AppBarIconBtnState();
}

class _AppBarIconBtnState extends State<_AppBarIconBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 110), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.82)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _ctrl.forward(),
      onTapUp: (_) {
        _ctrl.reverse();
        HapticFeedback.lightImpact();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Tooltip(
          message: widget.tooltip,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Icon(widget.icon, color: widget.color, size: 24),
          ),
        ),
      ),
    );
  }
}

// ─── Staggered Grid ─────────────────────────────────────────────────────────

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
      duration: const Duration(milliseconds: 700),
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
        final delay = (index * 0.04).clamp(0.0, 0.5);
        final animation = CurvedAnimation(
          parent: _controller,
          curve: Interval(delay, (delay + 0.45).clamp(0.0, 1.0),
              curve: Curves.easeOutCubic),
        );
        return FadeTransition(
          opacity: animation,
          child: SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(0, 0.25),
              end: Offset.zero,
            ).animate(animation),
            child: _GridItem(image: image),
          ),
        );
      },
    );
  }
}

// ─── Grid Item ───────────────────────────────────────────────────────────────

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
      duration: const Duration(milliseconds: 110),
      vsync: this,
    );
    _pressScale = Tween<double>(begin: 1.0, end: 0.92).animate(
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
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeOutCubic,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? Colors.cyanAccent
                    : Colors.white.withValues(alpha: 0.12),
                width: isSelected ? 2.5 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.35),
                        blurRadius: 12,
                        spreadRadius: 2,
                      )
                    ]
                  : [],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(14),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.file(widget.image.file, fit: BoxFit.cover),

                  // Gradient label at bottom
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          vertical: 5, horizontal: 6),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.black.withValues(alpha: 0.85),
                            Colors.transparent,
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

                  // Selection tint overlay
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    color: isSelected
                        ? Colors.cyanAccent.withValues(alpha: 0.22)
                        : Colors.transparent,
                  ),

                  // Selection checkmark
                  if (isSelected)
                    Positioned(
                      top: 6,
                      right: 6,
                      child: TweenAnimationBuilder<double>(
                        tween: Tween(begin: 0.0, end: 1.0),
                        duration: const Duration(milliseconds: 220),
                        curve: Curves.elasticOut,
                        builder: (ctx, v, child) =>
                            Transform.scale(scale: v, child: child),
                        child: Container(
                          padding: const EdgeInsets.all(3),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Colors.cyanAccent, Color(0xFF00C6FF)],
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.cyanAccent.withValues(alpha: 0.5),
                                blurRadius: 8,
                              )
                            ],
                          ),
                          child: const Icon(Icons.check,
                              color: Colors.black, size: 14),
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

// ─── Long Press Hint Banner ──────────────────────────────────────────────────

class _LongPressHintBanner extends StatefulWidget {
  const _LongPressHintBanner();

  @override
  State<_LongPressHintBanner> createState() => _LongPressHintBannerState();
}

class _LongPressHintBannerState extends State<_LongPressHintBanner>
    with SingleTickerProviderStateMixin {
  final _box = GetStorage();
  bool _dismissed = false;
  late final AnimationController _pulseCtrl;

  @override
  void initState() {
    super.initState();
    _dismissed = _box.read('batchHintDismissed') ?? false;
    _pulseCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_dismissed) return const SizedBox.shrink();

    return AnimatedOpacity(
      opacity: _dismissed ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 4, 16, 8),
        padding: const EdgeInsets.fromLTRB(12, 10, 10, 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          gradient: LinearGradient(
            colors: [
              Colors.cyanAccent.withValues(alpha: 0.12),
              Colors.indigo.withValues(alpha: 0.1),
            ],
          ),
          border: Border.all(
              color: Colors.cyanAccent.withValues(alpha: 0.28)),
        ),
        child: Row(
          children: [
            AnimatedBuilder(
              animation: _pulseCtrl,
              builder: (_, child) => Transform.scale(
                scale: 1.0 + 0.18 * _pulseCtrl.value,
                child: child,
              ),
              child: const Icon(Icons.touch_app_rounded,
                  color: Colors.cyanAccent, size: 22),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Text(
                '💡 Long-press any image to select multiple for batch compression',
                style: TextStyle(color: Colors.white, fontSize: 12, height: 1.4),
              ),
            ),
            GestureDetector(
              onTap: () {
                _box.write('batchHintDismissed', true);
                setState(() => _dismissed = true);
              },
              child: const Padding(
                padding: EdgeInsets.all(4),
                child: Icon(Icons.close, color: Colors.white38, size: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Animated Batch Panel ────────────────────────────────────────────────────

class _AnimatedBatchPanel extends StatelessWidget {
  final HomeController homeController;
  const _AnimatedBatchPanel({required this.homeController});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final isVisible = homeController.isSelectionMode.value;
      return AnimatedSlide(
        offset: isVisible ? Offset.zero : const Offset(0, 1),
        duration: const Duration(milliseconds: 420),
        curve: isVisible ? Curves.easeOutCubic : Curves.easeInCubic,
        child: AnimatedOpacity(
          opacity: isVisible ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: isVisible
              ? _BatchActionSheet(homeController: homeController)
              : const SizedBox.shrink(),
        ),
      );
    });
  }
}

// ─── Batch Action Sheet ──────────────────────────────────────────────────────

class _BatchActionSheet extends StatefulWidget {
  final HomeController homeController;
  const _BatchActionSheet({required this.homeController});

  @override
  State<_BatchActionSheet> createState() => _BatchActionSheetState();
}

class _BatchActionSheetState extends State<_BatchActionSheet>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressCtrl;
  late final Animation<double> _progressAnim;
  double _estimatedSavingsPercent = 0;

  HomeController get ctrl => widget.homeController;

  @override
  void initState() {
    super.initState();
    _progressCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressCtrl,
      curve: Curves.easeOutCubic,
    );
  }

  @override
  void dispose() {
    _progressCtrl.dispose();
    super.dispose();
  }

  void _updateEstimatedSavings(int quality) {
    // Rough estimate: 80% quality ≈ 40% savings, 50% quality ≈ 65% savings
    final savings = ((100 - quality) * 0.8).clamp(5.0, 90.0);
    setState(() => _estimatedSavingsPercent = savings);
    _progressCtrl.animateTo(savings / 100,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeOutCubic);
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFF08101E).withValues(alpha: 0.97),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.cyanAccent.withValues(alpha: 0.35),
                width: 1.5,
              ),
            ),
          ),
          child: Obx(() {
            final quality = ctrl.batchQuality.value;
            final isQualityMode = ctrl.batchCompressionMode.value == 0;
            final currentSavings = isQualityMode ? ((100 - quality) * 0.8).clamp(5.0, 90.0) : 15.0;

            // Trigger progress bar animation without calling setState:
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (_progressCtrl.isAnimating == false) {
                _progressCtrl.animateTo(currentSavings / 100,
                    duration: const Duration(milliseconds: 400),
                    curve: Curves.easeOutCubic);
              }
            });

            return Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(top: 12, bottom: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),

                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      _buildHeader(),
                      const SizedBox(height: 16),

                      // Mode toggle
                      _buildModeToggle(),
                      const SizedBox(height: 14),

                      // Controls
                      if (ctrl.batchCompressionMode.value == 0)
                        _buildQualitySection()
                      else
                        _buildTargetSizeSection(),

                      const SizedBox(height: 18),

                      // Action buttons
                      _buildActionButtons(),
                    ],
                  ),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Obx(() {
      final count = ctrl.selection.length;
      final totalSize = ctrl.selectionTotalSize;
      return Row(
        children: [
          // Glowing icon
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.cyanAccent.withValues(alpha: 0.3),
                  blurRadius: 12,
                )
              ],
            ),
            child: const Icon(Icons.compress_rounded,
                color: Colors.white, size: 20),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Batch Compress  ·  $count ${count == 1 ? "image" : "images"}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Total: ${formatBytes(totalSize, 1)}  →  Est. save ~${_estimatedSavingsPercent.toStringAsFixed(0)}%',
                  style: TextStyle(
                    color: Colors.cyanAccent.withValues(alpha: 0.85),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          // Animated savings badge
          AnimatedBuilder(
            animation: _progressAnim,
            builder: (_, __) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Colors.cyanAccent.withValues(alpha: 0.2),
                    Colors.blue.withValues(alpha: 0.1),
                  ],
                ),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: Colors.cyanAccent.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                '~${(_progressAnim.value * 100).toStringAsFixed(0)}% off',
                style: const TextStyle(
                  color: Colors.cyanAccent,
                  fontWeight: FontWeight.bold,
                  fontSize: 11,
                ),
              ),
            ),
          ),
        ],
      );
    });
  }

  Widget _buildModeToggle() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.06),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        children: [
          _modeTab('Quality Mode', Icons.tune_rounded, 0),
          _modeTab('Target Size', Icons.straighten_rounded, 1),
        ],
      ),
    );
  }

  Widget _modeTab(String label, IconData icon, int modeIndex) {
    return Obx(() {
      final isActive = ctrl.batchCompressionMode.value == modeIndex;
      return Expanded(
        child: GestureDetector(
          onTap: () {
            HapticFeedback.selectionClick();
            ctrl.batchCompressionMode.value = modeIndex;
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            padding: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              gradient: isActive
                  ? const LinearGradient(
                      colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                    )
                  : null,
              borderRadius: BorderRadius.circular(10),
              boxShadow: isActive
                  ? [
                      BoxShadow(
                        color: Colors.cyanAccent.withValues(alpha: 0.25),
                        blurRadius: 8,
                      )
                    ]
                  : [],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(icon,
                    color: isActive ? Colors.white : Colors.white38, size: 16),
                const SizedBox(width: 6),
                Text(
                  label,
                  style: TextStyle(
                    color: isActive ? Colors.white : Colors.white38,
                    fontWeight:
                        isActive ? FontWeight.bold : FontWeight.normal,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    });
  }

  Widget _buildQualitySection() {
    return Obx(() {
      final quality = ctrl.batchQuality.value;
      final color = quality > 70
          ? Colors.cyanAccent
          : quality > 40
              ? Colors.amberAccent
              : Colors.redAccent;

      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Quality',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              _QualityBadge(quality: quality, color: color),
            ],
          ),
          const SizedBox(height: 10),
          // Custom quality slider
          SliderTheme(
            data: SliderThemeData(
              activeTrackColor: color,
              inactiveTrackColor: Colors.white.withValues(alpha: 0.08),
              thumbColor: Colors.white,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
              trackHeight: 5,
              overlayColor: color.withValues(alpha: 0.2),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 18),
            ),
            child: Slider(
              value: quality.toDouble(),
              min: 1,
              max: 100,
              divisions: 99,
              onChanged: (val) {
                ctrl.batchQuality.value = val.round();
                _updateEstimatedSavings(val.round());
              },
            ),
          ),
          // Quality label row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text('Small file',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 10)),
              Text('Best quality',
                  style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.35),
                      fontSize: 10)),
            ],
          ),
        ],
      );
    });
  }

  Widget _buildTargetSizeSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Max file size per image',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.7),
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: TextField(
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold),
                textAlign: TextAlign.center,
                decoration: InputDecoration(
                  hintText: '200',
                  hintStyle: TextStyle(
                      color: Colors.white.withValues(alpha: 0.25),
                      fontSize: 16),
                  suffixText: 'KB',
                  suffixStyle: const TextStyle(
                    color: Colors.cyanAccent,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 14),
                  filled: true,
                  fillColor: Colors.white.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: BorderSide(
                        color: Colors.white.withValues(alpha: 0.1)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(14),
                    borderSide: const BorderSide(color: Colors.cyanAccent),
                  ),
                ),
                onChanged: (v) =>
                    ctrl.batchTargetSizeKB.value = int.tryParse(v),
              ),
            ),
            const SizedBox(width: 12),
            // Preset chips
            Column(
              children: [
                for (final preset in [100, 200, 500])
                  GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      ctrl.batchTargetSizeKB.value = preset;
                    },
                    child: Obx(() {
                      final isSelected =
                          ctrl.batchTargetSizeKB.value == preset;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: isSelected
                              ? Colors.cyanAccent.withValues(alpha: 0.2)
                              : Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: isSelected
                                ? Colors.cyanAccent
                                : Colors.white.withValues(alpha: 0.1),
                          ),
                        ),
                        child: Text(
                          '$preset KB',
                          style: TextStyle(
                            color:
                                isSelected ? Colors.cyanAccent : Colors.white54,
                            fontSize: 11,
                            fontWeight: isSelected
                                ? FontWeight.bold
                                : FontWeight.normal,
                          ),
                        ),
                      );
                    }),
                  ),
              ],
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Obx(() {
      final isCompressing = ctrl.isCompressing.value;
      return Column(
        children: [
          if (isCompressing)
            Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: _CompressionProgressBar(),
            ),
          Row(
            children: [
              // Compress Now — main CTA
              Expanded(
                flex: 3,
                child: _GlowButton(
                  label: isCompressing ? 'Compressing…' : 'Compress Now',
                  icon: isCompressing
                      ? Icons.hourglass_empty
                      : Icons.compress_rounded,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                  ),
                  glowColor: Colors.cyanAccent,
                  onTap: isCompressing ? null : ctrl.compressAll,
                ),
              ),
              const SizedBox(width: 10),
              // Share
              _IconActionBtn(
                icon: Icons.share_rounded,
                color: Colors.amber,
                onTap: isCompressing ? null : ctrl.compressAndShare,
                tooltip: 'Compress & Share',
              ),
              const SizedBox(width: 8),
              // Delete
              _IconActionBtn(
                icon: Icons.delete_outline_rounded,
                color: Colors.redAccent,
                onTap: isCompressing ? null : ctrl.deleteSelection,
                tooltip: 'Delete Selected',
                bgColor: Colors.redAccent.withValues(alpha: 0.12),
              ),
            ],
          ),
        ],
      );
    });
  }
}

class _QualityBadge extends StatelessWidget {
  final int quality;
  final Color color;
  const _QualityBadge({required this.quality, required this.color});

  String get _label {
    if (quality >= 80) return 'High Quality';
    if (quality >= 50) return 'Balanced';
    return 'Max Savings';
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '$quality%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            _label,
            style: TextStyle(
              color: color.withValues(alpha: 0.8),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _CompressionProgressBar extends StatefulWidget {
  @override
  State<_CompressionProgressBar> createState() =>
      _CompressionProgressBarState();
}

class _CompressionProgressBarState extends State<_CompressionProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.compress_rounded,
                color: Colors.cyanAccent, size: 14),
            const SizedBox(width: 6),
            Text(
              'Compressing images…',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.7),
                fontSize: 12,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        AnimatedBuilder(
          animation: _ctrl,
          builder: (_, __) => ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: null, // indeterminate
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              valueColor: AlwaysStoppedAnimation<Color>(
                Color.lerp(Colors.cyanAccent, Colors.blue, _ctrl.value)!,
              ),
              minHeight: 5,
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Glow Button ─────────────────────────────────────────────────────────────

class _GlowButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final Color glowColor;
  final VoidCallback? onTap;

  const _GlowButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.glowColor,
    required this.onTap,
  });

  @override
  State<_GlowButton> createState() => _GlowButtonState();
}

class _GlowButtonState extends State<_GlowButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 110), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.94)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _ctrl.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _ctrl.reverse();
              HapticFeedback.heavyImpact();
              widget.onTap!();
            },
      onTapCancel: isDisabled ? null : () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: AnimatedOpacity(
          opacity: isDisabled ? 0.55 : 1.0,
          duration: const Duration(milliseconds: 200),
          child: Container(
            padding:
                const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: widget.glowColor.withValues(alpha: 0.4),
                  blurRadius: 16,
                  spreadRadius: 0,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(widget.icon, color: Colors.white, size: 20),
                const SizedBox(width: 8),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
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

class _IconActionBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;
  final String tooltip;
  final Color? bgColor;

  const _IconActionBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
    this.bgColor,
  });

  @override
  State<_IconActionBtn> createState() => _IconActionBtnState();
}

class _IconActionBtnState extends State<_IconActionBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 110), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.85)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDisabled = widget.onTap == null;
    return GestureDetector(
      onTapDown: isDisabled ? null : (_) => _ctrl.forward(),
      onTapUp: isDisabled
          ? null
          : (_) {
              _ctrl.reverse();
              HapticFeedback.mediumImpact();
              widget.onTap!();
            },
      onTapCancel: isDisabled ? null : () => _ctrl.reverse(),
      child: Tooltip(
        message: widget.tooltip,
        child: ScaleTransition(
          scale: _scale,
          child: AnimatedOpacity(
            opacity: isDisabled ? 0.4 : 1.0,
            duration: const Duration(milliseconds: 200),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: widget.bgColor ??
                    Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: widget.color.withValues(alpha: 0.3),
                ),
              ),
              child: Icon(widget.icon, color: widget.color, size: 22),
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Empty State ──────────────────────────────────────────────────────────────

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
    _floatAnimation = Tween<double>(begin: -10, end: 10).animate(
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
        child: FadeTransition(
          opacity: Tween<double>(begin: 0.0, end: 1.0).animate(
            CurvedAnimation(parent: _floatController, curve: const Interval(0.0, 0.5)),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedBuilder(
                animation: _floatAnimation,
                builder: (context, child) => Transform.translate(
                  offset: Offset(0, _floatAnimation.value),
                  child: child,
                ),
                child: Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: AppTheme.heroCardGradient,
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withValues(alpha: 0.45),
                        blurRadius: 28,
                        spreadRadius: 4,
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
              const SizedBox(height: 28),
              const Text(
                'Compress & Optimize Photos',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Select images from gallery or camera.\nBatch-compress up to 90% with zero loss.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.65),
                  fontSize: 14,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              // Pro tip chip
              Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.cyanAccent.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: Colors.cyanAccent.withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.touch_app_rounded,
                        color: Colors.cyanAccent, size: 15),
                    const SizedBox(width: 6),
                    Text(
                      'Long-press to batch select',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.65),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              Obx(
                () => homeController.isPicking.value
                    ? const CircularProgressIndicator(
                        color: Colors.cyanAccent)
                    : Column(
                        children: [
                          GlassmorphicButton(
                            width: 240,
                            height: 52,
                            borderRadius: 16,
                            color: AppTheme.primaryColor
                                .withValues(alpha: 0.4),
                            borderColor:
                                Colors.cyanAccent.withValues(alpha: 0.5),
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
      ),
    );
  }
}

// ─── Glass Bottom Nav ────────────────────────────────────────────────────────

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
            padding: const EdgeInsets.symmetric(vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF131B2E).withValues(alpha: 0.85),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: Obx(
              () => BottomNavigationBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: Colors.cyanAccent,
                unselectedItemColor: Colors.white.withValues(alpha: 0.45),
                selectedLabelStyle: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 12),
                unselectedLabelStyle: const TextStyle(fontSize: 11),
                currentIndex: homeController.tabIndex.value,
                onTap: (i) {
                  HapticFeedback.selectionClick();
                  homeController.tabIndex.value = i;
                },
                type: BottomNavigationBarType.fixed,
                items: [
                  BottomNavigationBarItem(
                    icon: Icon(homeController.tabIndex.value == 0
                        ? Icons.compress_rounded
                        : Icons.compress_outlined),
                    label: "Squeeze",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(homeController.tabIndex.value == 1
                        ? Icons.auto_awesome
                        : Icons.auto_awesome_outlined),
                    label: "Pixel Lab",
                  ),
                  BottomNavigationBarItem(
                    icon: Icon(homeController.tabIndex.value == 2
                        ? Icons.history_rounded
                        : Icons.history_toggle_off_rounded),
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
