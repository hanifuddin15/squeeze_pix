import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:gal/gal.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/utils/formatters.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

/// Shows a full-screen result preview after any image operation.
/// Displays before/after with file size stats, save & share actions.
Future<void> showResultPreview({
  required File originalFile,
  required File resultFile,
  String? operationLabel,
}) async {
  await Get.dialog(
    ResultPreviewDialog(
      originalFile: originalFile,
      resultFile: resultFile,
      operationLabel: operationLabel ?? 'Done',
    ),
    barrierColor: Colors.black.withValues(alpha: 0.85),
    useSafeArea: false,
  );
}

class ResultPreviewDialog extends StatefulWidget {
  final File originalFile;
  final File resultFile;
  final String operationLabel;

  const ResultPreviewDialog({
    super.key,
    required this.originalFile,
    required this.resultFile,
    required this.operationLabel,
  });

  @override
  State<ResultPreviewDialog> createState() => _ResultPreviewDialogState();
}

class _ResultPreviewDialogState extends State<ResultPreviewDialog>
    with TickerProviderStateMixin {
  bool _showOriginal = false;
  bool _isSaving = false;

  late final AnimationController _slideController;
  late final AnimationController _scaleController;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 480),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 380),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.85, end: 1.0).animate(
      CurvedAnimation(parent: _scaleController, curve: Curves.easeOutBack),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _slideController, curve: Curves.easeIn),
    );

    _slideController.forward();
    _scaleController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  int get _originalSize => widget.originalFile.existsSync()
      ? widget.originalFile.lengthSync()
      : 0;
  int get _resultSize =>
      widget.resultFile.existsSync() ? widget.resultFile.lengthSync() : 0;
  double get _savings =>
      _originalSize > 0 ? (_originalSize - _resultSize) / _originalSize * 100 : 0;
  bool get _isSmaller => _resultSize < _originalSize;

  Future<void> _saveToGallery() async {
    setState(() => _isSaving = true);
    try {
      await Gal.putImage(widget.resultFile.path, album: 'Squeeze Pix');
      showSuccessSnackkbar(message: 'Saved to Gallery (Album: Squeeze Pix) ✓');
    } catch (e) {
      showErrorSnackkbar(message: 'Failed to save: $e');
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _share() {
    SharePlus.instance.share(
      ShareParams(files: [XFile(widget.resultFile.path)]),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Container(
            decoration: BoxDecoration(gradient: AppTheme.gradient),
            child: SafeArea(
              child: Column(
                children: [
                  _buildHeader(),
                  Expanded(child: _buildImagePreview()),
                  _buildStats(),
                  _buildActions(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 8, 8),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: AppTheme.heroCardGradient,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.auto_awesome, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Result Preview',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
              Text(
                widget.operationLabel,
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const Spacer(),
          IconButton(
            icon: const Icon(Icons.close, color: Colors.white70),
            onPressed: () => Get.back(),
          ),
        ],
      ),
    );
  }

  Widget _buildImagePreview() {
    return ScaleTransition(
      scale: _scaleAnimation,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        child: Column(
          children: [
            // Toggle row
            Container(
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.08),
                borderRadius: BorderRadius.circular(30),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _toggleBtn('Result', !_showOriginal, () {
                    setState(() => _showOriginal = false);
                  }),
                  _toggleBtn('Original', _showOriginal, () {
                    setState(() => _showOriginal = true);
                  }),
                ],
              ),
            ),
            // Image
            Expanded(
              child: GestureDetector(
                onTapDown: (_) => setState(() => _showOriginal = true),
                onTapUp: (_) => setState(() => _showOriginal = false),
                onTapCancel: () => setState(() => _showOriginal = false),
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 250),
                  child: ClipRRect(
                    key: ValueKey(_showOriginal),
                    borderRadius: BorderRadius.circular(20),
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // Checkerboard bg for transparency
                        _CheckerboardBackground(),
                        Image.file(
                          _showOriginal ? widget.originalFile : widget.resultFile,
                          fit: BoxFit.contain,
                        ),
                        // Hold-to-compare hint
                        Positioned(
                          bottom: 12,
                          left: 0,
                          right: 0,
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                _showOriginal ? 'Original' : 'Hold to compare',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _toggleBtn(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        decoration: BoxDecoration(
          color: active ? AppTheme.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(28),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : Colors.white54,
            fontWeight: active ? FontWeight.bold : FontWeight.normal,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  Widget _buildStats() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(18),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  'Original',
                  formatBytes(_originalSize, 1),
                  Colors.white70,
                ),
                _arrowIndicator(),
                _statItem(
                  'Result',
                  formatBytes(_resultSize, 1),
                  _isSmaller ? Colors.greenAccent : Colors.orangeAccent,
                ),
                _statItem(
                  _isSmaller ? 'Saved' : 'Increased',
                  '${_savings.abs().toStringAsFixed(1)}%',
                  _isSmaller ? Colors.cyanAccent : Colors.orangeAccent,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _statItem(String label, String value, Color valueColor) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontWeight: FontWeight.bold,
            fontSize: 15,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.5),
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _arrowIndicator() {
    return Icon(
      _isSmaller ? Icons.arrow_forward_rounded : Icons.arrow_forward_rounded,
      color: _isSmaller ? Colors.cyanAccent : Colors.orangeAccent,
      size: 20,
    );
  }

  Widget _buildActions() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: _ActionButton(
              label: _isSaving ? 'Saving...' : 'Save to Gallery',
              icon: _isSaving ? Icons.hourglass_empty : Icons.download_rounded,
              gradient: const LinearGradient(
                colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
              ),
              onTap: _isSaving ? null : _saveToGallery,
            ),
          ),
          const SizedBox(width: 12),
          _ActionButton(
            label: 'Share',
            icon: Icons.share_rounded,
            gradient: const LinearGradient(
              colors: [Color(0xFF8B5CF6), Color(0xFF6D28D9)],
            ),
            onTap: _share,
          ),
          const SizedBox(width: 12),
          _ActionButton(
            label: 'Done',
            icon: Icons.check_rounded,
            gradient: LinearGradient(
              colors: [
                Colors.white.withValues(alpha: 0.15),
                Colors.white.withValues(alpha: 0.05),
              ],
            ),
            onTap: () => Get.back(),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatefulWidget {
  final String label;
  final IconData icon;
  final Gradient gradient;
  final VoidCallback? onTap;

  const _ActionButton({
    required this.label,
    required this.icon,
    required this.gradient,
    required this.onTap,
  });

  @override
  State<_ActionButton> createState() => _ActionButtonState();
}

class _ActionButtonState extends State<_ActionButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scale;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 120),
      vsync: this,
    );
    _scale = Tween<double>(begin: 1.0, end: 0.92).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _controller.forward(),
      onTapUp: (_) {
        _controller.reverse();
        widget.onTap?.call();
      },
      onTapCancel: () => _controller.reverse(),
      child: ScaleTransition(
        scale: _scale,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          decoration: BoxDecoration(
            gradient: widget.gradient,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withValues(alpha: 0.15)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(widget.icon, color: Colors.white, size: 22),
              const SizedBox(height: 4),
              Text(
                widget.label,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Simple checkerboard background for transparent image preview.
class _CheckerboardBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _CheckerboardPainter(),
      child: const SizedBox.expand(),
    );
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 16.0;
    final paint1 = Paint()..color = const Color(0xFF2D2D2D);
    final paint2 = Paint()..color = const Color(0xFF3D3D3D);

    for (double x = 0; x < size.width; x += squareSize) {
      for (double y = 0; y < size.height; y += squareSize) {
        final isEven = ((x / squareSize) + (y / squareSize)).round().isEven;
        canvas.drawRect(
          Rect.fromLTWH(x, y, squareSize, squareSize),
          isEven ? paint1 : paint2,
        );
      }
    }
  }

  @override
  bool shouldRepaint(_CheckerboardPainter oldDelegate) => false;
}
