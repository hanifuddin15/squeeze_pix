import 'dart:io';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/editor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:image/image.dart' as img;

class EditorHub extends StatelessWidget {
  final File? imageFile;
  const EditorHub({this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    final EditorController controller = Get.put(EditorController());
    if (imageFile != null) {
      controller.setImage(imageFile!);
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Image Editor',
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          _AnimatedIconBtn(
            icon: Icons.share_rounded,
            color: Colors.amber,
            onTap: controller.shareImage,
            tooltip: 'Share',
          ),
          _AnimatedIconBtn(
            icon: Icons.download_rounded,
            color: Colors.cyanAccent,
            onTap: controller.saveImage,
            tooltip: 'Save',
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: Column(
            children: [
              // Image Preview Area
              Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Obx(() {
                      if (controller.editedImage.value == null) {
                        return const Center(
                          child: Text(
                            'No Image Selected',
                            style: TextStyle(color: Colors.white70),
                          ),
                        );
                      }
                      return Hero(
                        tag: 'editor_image',
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: ColorFiltered(
                            colorFilter: controller.activeColorFilter.value,
                            child: Image.file(
                              controller.editedImage.value!,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
              ),
              // Tool Panels & Toolbar
              Obx(() => _buildToolUI(context, controller)),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildToolUI(BuildContext context, EditorController controller) {
    if (controller.activeTool.value == EditorTool.none) {
      return _buildMainToolbar(context, controller);
    }
    return _buildToolPanel(context, controller);
  }

  Widget _buildMainToolbar(BuildContext context, EditorController controller) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A).withValues(alpha: 0.92),
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(
              top: BorderSide(
                color: Colors.white.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag handle
              Container(
                width: 36,
                height: 4,
                margin: const EdgeInsets.only(bottom: 12),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.25),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _ToolPill(
                      icon: Icons.crop_rotate_rounded,
                      label: 'Crop',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF00B4DB), Color(0xFF0083B0)]),
                      onTap: controller.cropImage,
                    ),
                    _ToolPill(
                      icon: Icons.aspect_ratio_rounded,
                      label: 'Resize',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF7F7FD5), Color(0xFF91EAE4)]),
                      onTap: () =>
                          controller.setActiveTool(EditorTool.resize),
                    ),
                    _ToolPill(
                      icon: Icons.compress_rounded,
                      label: 'Compress',
                      gradient: const LinearGradient(
                          colors: [Color(0xFFFF512F), Color(0xFFDD2476)]),
                      onTap: () =>
                          controller.setActiveTool(EditorTool.compress),
                    ),
                    _ToolPill(
                      icon: Icons.transform_rounded,
                      label: 'Convert',
                      gradient: const LinearGradient(
                          colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
                      onTap: () =>
                          controller.setActiveTool(EditorTool.convert),
                    ),
                    _ToolPill(
                      icon: Icons.auto_awesome_rounded,
                      label: 'Effects',
                      gradient: const LinearGradient(
                          colors: [Color(0xFFF093FB), Color(0xFFF5576C)]),
                      onTap: () =>
                          controller.setActiveTool(EditorTool.effects),
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

  Widget _buildToolPanel(BuildContext context, EditorController controller) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 320),
      transitionBuilder: (child, animation) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(
            CurvedAnimation(parent: animation, curve: Curves.easeOutCubic),
          ),
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      child: ClipRRect(
        key: ValueKey(controller.activeTool.value),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
            decoration: BoxDecoration(
              color: const Color(0xFF0D1B2A).withValues(alpha: 0.95),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(28)),
              border: Border(
                top: BorderSide(
                  color: Colors.cyanAccent.withValues(alpha: 0.25),
                  width: 1.5,
                ),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag handle + title
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Row(
                  children: [
                    Obx(() => Text(
                          _toolTitle(controller.activeTool.value),
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        )),
                    const Spacer(),
                    GestureDetector(
                      onTap: () =>
                          controller.setActiveTool(EditorTool.none),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close,
                            color: Colors.white70, size: 16),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Obx(() => _buildActiveToolControls(
                      context,
                      controller,
                      controller.activeTool.value,
                    )),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _toolTitle(EditorTool tool) {
    switch (tool) {
      case EditorTool.resize:
        return '📐 Resize Image';
      case EditorTool.compress:
        return '🗜️ Compress Image';
      case EditorTool.convert:
        return '🔄 Convert Format';
      case EditorTool.effects:
        return '✨ Image Effects';
      default:
        return 'Edit';
    }
  }

  Widget _buildActiveToolControls(
    BuildContext context,
    EditorController controller,
    EditorTool tool,
  ) {
    switch (tool) {
      case EditorTool.resize:
        return _ResizeControls(controller: controller);
      case EditorTool.compress:
        return _CompressControls(controller: controller);
      case EditorTool.convert:
        return _ConvertControls(controller: controller);
      case EditorTool.effects:
        return _EffectsControls();
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Animated icon button for appbar
class _AnimatedIconBtn extends StatefulWidget {
  final IconData icon;
  final Color color;
  final VoidCallback onTap;
  final String tooltip;

  const _AnimatedIconBtn({
    required this.icon,
    required this.color,
    required this.onTap,
    required this.tooltip,
  });

  @override
  State<_AnimatedIconBtn> createState() => _AnimatedIconBtnState();
}

class _AnimatedIconBtnState extends State<_AnimatedIconBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
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
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
            child: Icon(widget.icon, color: widget.color, size: 24),
          ),
        ),
      ),
    );
  }
}

/// Tool pill button for the main toolbar
class _ToolPill extends StatefulWidget {
  final IconData icon;
  final String label;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ToolPill({
    required this.icon,
    required this.label,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ToolPill> createState() => _ToolPillState();
}

class _ToolPillState extends State<_ToolPill>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.88)
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
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(right: 12),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(50),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Resize Controls ────────────────────────────────────────────────────────

class _ResizeControls extends StatefulWidget {
  final EditorController controller;
  const _ResizeControls({required this.controller});

  @override
  State<_ResizeControls> createState() => _ResizeControlsState();
}

class _ResizeControlsState extends State<_ResizeControls> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  bool _keepAspectRatio = true;
  double _aspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController();
    _heightController = TextEditingController();

    widget.controller.editedImage.value?.readAsBytes().then((bytes) {
      final image = img.decodeImage(bytes);
      if (image != null && mounted) {
        setState(() {
          _aspectRatio = image.width / image.height;
          _widthController.text = image.width.toString();
          _heightController.text = image.height.toString();
        });
      }
    });

    _widthController.addListener(_onWidthChanged);
    _heightController.addListener(_onHeightChanged);
  }

  void _onWidthChanged() {
    // ignore: invalid_use_of_protected_member
    if (!_keepAspectRatio || !_heightController.hasListeners) return;
    final width = int.tryParse(_widthController.text);
    if (width != null) {
      _heightController.removeListener(_onHeightChanged);
      _heightController.text = (width / _aspectRatio).round().toString();
      _heightController.addListener(_onHeightChanged);
    }
  }

  void _onHeightChanged() {
    // ignore: invalid_use_of_protected_member
    if (!_keepAspectRatio || !_widthController.hasListeners) return;
    final height = int.tryParse(_heightController.text);
    if (height != null) {
      _widthController.removeListener(_onWidthChanged);
      _widthController.text = (height * _aspectRatio).round().toString();
      _widthController.addListener(_onWidthChanged);
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(_widthController, 'Width (px)')),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 12),
              child: Icon(Icons.close, color: Colors.white38, size: 16),
            ),
            Expanded(child: _buildTextField(_heightController, 'Height (px)')),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => setState(() => _keepAspectRatio = !_keepAspectRatio),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: _keepAspectRatio
                  ? Colors.cyanAccent.withValues(alpha: 0.15)
                  : Colors.white.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: _keepAspectRatio
                    ? Colors.cyanAccent.withValues(alpha: 0.5)
                    : Colors.white.withValues(alpha: 0.1),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _keepAspectRatio ? Icons.lock_rounded : Icons.lock_open_rounded,
                  color: _keepAspectRatio ? Colors.cyanAccent : Colors.white38,
                  size: 18,
                ),
                const SizedBox(width: 8),
                Text(
                  'Keep Aspect Ratio',
                  style: TextStyle(
                    color:
                        _keepAspectRatio ? Colors.cyanAccent : Colors.white54,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () {
              final w = int.tryParse(_widthController.text);
              final h = int.tryParse(_heightController.text);
              if (w != null && h != null) {
                widget.controller.applyResize(w, h);
              }
            },
            icon: const Icon(Icons.check_rounded, size: 18),
            label: const Text('Apply Resize',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.cyanAccent,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [FilteringTextInputFormatter.digitsOnly],
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withValues(alpha: 0.5), fontSize: 12),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.15)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.cyanAccent),
        ),
      ),
    );
  }
}

// ─── Compress Controls ───────────────────────────────────────────────────────

class _CompressControls extends StatelessWidget {
  final EditorController controller;
  const _CompressControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Mode Toggle
        Obx(() => Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                children: [
                  _modeToggleBtn(
                    'Quality Mode',
                    Icons.tune_rounded,
                    controller.compressionMode.value == 0,
                    () => controller.compressionMode.value = 0,
                  ),
                  _modeToggleBtn(
                    'Target Size',
                    Icons.straighten_rounded,
                    controller.compressionMode.value == 1,
                    () => controller.compressionMode.value = 1,
                  ),
                ],
              ),
            )),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.compressionMode.value == 0) {
            return _buildQualitySlider(controller);
          } else {
            return _buildTargetSizeInput(controller);
          }
        }),
        const SizedBox(height: 16),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: controller.applyCompression,
            icon: const Icon(Icons.compress_rounded, size: 18),
            label: const Text('Apply Compression',
                style: TextStyle(fontWeight: FontWeight.bold)),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFDD2476),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _modeToggleBtn(
      String label, IconData icon, bool active, VoidCallback onTap) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 9),
          decoration: BoxDecoration(
            color: active ? AppTheme.primaryColor : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white, size: 15),
              const SizedBox(width: 6),
              Text(
                label,
                style: TextStyle(
                  color: active ? Colors.white : Colors.white54,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQualitySlider(EditorController controller) {
    return Obx(() => Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Quality',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.cyanAccent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${controller.compressionQuality.value.toInt()}%',
                    style: const TextStyle(
                      color: Colors.cyanAccent,
                      fontWeight: FontWeight.bold,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
            SliderTheme(
              data: SliderTheme.of(Get.context!).copyWith(
                activeTrackColor: Colors.cyanAccent,
                inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                thumbColor: Colors.white,
                overlayColor: Colors.cyanAccent.withValues(alpha: 0.2),
              ),
              child: Slider(
                value: controller.compressionQuality.value,
                min: 1,
                max: 100,
                divisions: 99,
                onChanged: (value) =>
                    controller.compressionQuality.value = value,
              ),
            ),
          ],
        ));
  }

  Widget _buildTargetSizeInput(EditorController controller) {
    final textController = TextEditingController(
      text: controller.targetSizeKB.value?.toString() ?? '',
    );
    return Row(
      children: [
        const Icon(Icons.straighten_rounded,
            color: Colors.cyanAccent, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: const TextStyle(color: Colors.white, fontSize: 14),
            decoration: InputDecoration(
              hintText: 'Target size in KB (e.g. 200)',
              hintStyle:
                  TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 13),
              suffixText: 'KB',
              suffixStyle: const TextStyle(
                color: Colors.cyanAccent,
                fontWeight: FontWeight.bold,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              filled: true,
              fillColor: Colors.white.withValues(alpha: 0.06),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
            onChanged: (value) {
              controller.targetSizeKB.value = int.tryParse(value);
            },
          ),
        ),
      ],
    );
  }
}

// ─── Convert Controls ────────────────────────────────────────────────────────

class _ConvertControls extends StatelessWidget {
  final EditorController controller;
  const _ConvertControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          'Choose output format',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            _ConvertBtn(
              label: 'to JPG',
              icon: Icons.image_rounded,
              gradient: const LinearGradient(
                  colors: [Color(0xFF43E97B), Color(0xFF38F9D7)]),
              onTap: () => controller.applyConversion('JPG'),
            ),
            const SizedBox(width: 10),
            _ConvertBtn(
              label: 'to PNG',
              icon: Icons.image_outlined,
              gradient: const LinearGradient(
                  colors: [Color(0xFF667EEA), Color(0xFF764BA2)]),
              onTap: () => controller.applyConversion('PNG'),
            ),
            const SizedBox(width: 10),
            _ConvertBtn(
              label: 'to PDF',
              icon: Icons.picture_as_pdf_rounded,
              gradient: const LinearGradient(
                  colors: [Color(0xFFFF512F), Color(0xFFDD2476)]),
              onTap: () => controller.applyConversion('PDF'),
            ),
          ],
        ),
      ],
    );
  }
}

class _ConvertBtn extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback onTap;

  const _ConvertBtn({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ConvertBtn> createState() => _ConvertBtnState();
}

class _ConvertBtnState extends State<_ConvertBtn>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTapDown: (_) => _ctrl.forward(),
        onTapUp: (_) {
          _ctrl.reverse();
          HapticFeedback.selectionClick();
          widget.onTap();
        },
        onTapCancel: () => _ctrl.reverse(),
        child: ScaleTransition(
          scale: _scale,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              gradient: widget.gradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              children: [
                Icon(widget.icon, color: Colors.white, size: 24),
                const SizedBox(height: 4),
                Text(
                  widget.label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
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

// ─── Effects Controls ────────────────────────────────────────────────────────

class _EffectsControls extends GetView<EditorController> {
  const _EffectsControls();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // One-tap effects
        Text(
          'One-tap Filters',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 10),
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            children: [
              _EffectButton(
                label: 'Grayscale',
                imageFile: controller.editedImage.value,
                effect: img.grayscale,
                onTap: () => controller.applyOneTapEffect(img.grayscale),
              ),
              _EffectButton(
                label: 'Sepia',
                imageFile: controller.editedImage.value,
                effect: (i) => img.sepia(i),
                onTap: () =>
                    controller.applyOneTapEffect((i) => img.sepia(i)),
              ),
              _EffectButton(
                label: 'Invert',
                imageFile: controller.editedImage.value,
                effect: img.invert,
                onTap: () => controller.applyOneTapEffect(img.invert),
              ),
              _EffectButton(
                label: 'Sketch',
                imageFile: controller.editedImage.value,
                effect: (i) => img.sketch(i),
                onTap: () =>
                    controller.applyOneTapEffect((i) => img.sketch(i)),
              ),
              _EffectButton(
                label: 'Vignette',
                imageFile: controller.editedImage.value,
                effect: (i) => img.vignette(i),
                onTap: () =>
                    controller.applyOneTapEffect((i) => img.vignette(i)),
              ),
              _EffectButton(
                label: 'Mono',
                imageFile: controller.editedImage.value,
                effect: (i) => img.monochrome(i),
                onTap: () =>
                    controller.applyOneTapEffect((i) => img.monochrome(i)),
              ),
              _EffectButton(
                label: 'Solarize',
                imageFile: controller.editedImage.value,
                effect: (i) => img.solarize(
                  threshold: (128 * (1 + Random().nextDouble())).toInt(),
                  i,
                ),
                onTap: () => controller.applyOneTapEffect(
                  (i) => img.solarize(
                    threshold: (128 * (1 + Random().nextDouble())).toInt(),
                    i,
                  ),
                ),
              ),
              _EffectButton(
                label: 'Smooth',
                imageFile: controller.editedImage.value,
                effect: (i) =>
                    img.smooth(weight: (2 + Random().nextInt(5)).toDouble(), i),
                onTap: () => controller.applyOneTapEffect(
                  (i) =>
                      img.smooth(weight: (2 + Random().nextInt(5)).toDouble(), i),
                ),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white12, height: 20),
        // Adjustable sliders
        Text(
          'Adjustments',
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        _buildEffectSlider('Brightness', controller.brightness, -100, 100),
        _buildEffectSlider('Contrast', controller.contrast, 0.0, 2.0),
        _buildEffectSlider('Saturation', controller.saturation, 0.0, 2.0),
        _buildEffectSlider('Hue', controller.hue, -180, 180),
        const SizedBox(height: 10),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: controller.resetEffects,
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.white70,
                  side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Reset'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              flex: 2,
              child: ElevatedButton(
                onPressed: controller.applyAdjustments,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF5576C),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text('Apply',
                    style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildEffectSlider(
    String label,
    RxDouble value,
    double min,
    double max,
  ) {
    return Obx(() => Row(
          children: [
            SizedBox(
              width: 70,
              child: Text(
                label,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.7),
                  fontSize: 11,
                ),
                textAlign: TextAlign.right,
              ),
            ),
            Expanded(
              child: SliderTheme(
                data: SliderTheme.of(Get.context!).copyWith(
                  activeTrackColor: Colors.pinkAccent,
                  inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
                  thumbColor: Colors.white,
                  trackHeight: 3,
                  overlayShape: SliderComponentShape.noOverlay,
                ),
                child: Slider(
                  value: value.value,
                  min: min,
                  max: max,
                  onChanged: (val) => value.value = val,
                ),
              ),
            ),
          ],
        ));
  }
}

class _EffectButton extends StatefulWidget {
  final String label;
  final VoidCallback onTap;
  final File? imageFile;
  final img.Image Function(img.Image) effect;

  const _EffectButton({
    required this.label,
    required this.onTap,
    this.imageFile,
    required this.effect,
  });

  @override
  State<_EffectButton> createState() => _EffectButtonState();
}

class _EffectButtonState extends State<_EffectButton>
    with SingleTickerProviderStateMixin {
  img.Image? _thumbnail;
  late final AnimationController _ctrl;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
        duration: const Duration(milliseconds: 120), vsync: this);
    _scale = Tween<double>(begin: 1.0, end: 0.9)
        .animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeIn));
    _generateThumbnail();
  }

  Future<void> _generateThumbnail() async {
    if (widget.imageFile == null) return;
    try {
      final imageBytes = await widget.imageFile!.readAsBytes();
      final originalImage = img.decodeImage(imageBytes);
      if (originalImage != null) {
        final thumbnail = img.copyResize(originalImage, width: 60);
        final effectedThumbnail = widget.effect(thumbnail);
        if (mounted) setState(() => _thumbnail = effectedThumbnail);
      }
    } catch (e) {
      debugPrint('Error generating thumbnail: $e');
    }
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
        HapticFeedback.selectionClick();
        widget.onTap();
      },
      onTapCancel: () => _ctrl.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          margin: const EdgeInsets.only(right: 10),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 54,
                height: 54,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1A1A2E), Color(0xFF16213E)],
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha: 0.2),
                  ),
                ),
                child: _thumbnail != null
                    ? ClipOval(
                        child: Image.memory(
                          img.encodePng(_thumbnail!),
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(Icons.auto_awesome_rounded,
                        color: Colors.white54, size: 22),
              ),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: const TextStyle(color: Colors.white70, fontSize: 10),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
