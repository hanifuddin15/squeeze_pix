// lib/pages/pixel_lab/bg_remover.dart
import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/services/ai_service.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import 'package:squeeze_pix/widgets/result_preview_dialog.dart';

class BackgroundRemover extends StatefulWidget {
  const BackgroundRemover({super.key});

  @override
  State<BackgroundRemover> createState() => _BackgroundRemoverState();
}

class _BackgroundRemoverState extends State<BackgroundRemover>
    with TickerProviderStateMixin {
  File? _image;
  File? _result;
  final IAPController _iapController = Get.find<IAPController>();
  bool _isLoading = false;
  bool _showResult = false;

  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Remove Background',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTokenBanner(),
              Expanded(
                child: _image == null ? _buildEmptyState() : _buildEditorView(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenBanner() {
    return Obx(() {
      final isUltra = _iapController.isUltraUser;
      final tokensUsed = _iapController.dailyTokensUsed.value;
      final maxTokens = IAPController.maxDailyTokens;
      final progress = isUltra ? tokensUsed / maxTokens : 0.0;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: isUltra
              ? const LinearGradient(
                  colors: [Color(0xFF1A1060), Color(0xFF0D1B4B)],
                )
              : const LinearGradient(
                  colors: [Color(0xFF0A1E3F), Color(0xFF07142A)],
                ),
          border: Border.all(
            color: isUltra
                ? Colors.cyanAccent.withValues(alpha: 0.4)
                : Colors.cyanAccent.withValues(alpha: 0.3),
          ),
        ),
        child: isUltra
            ? Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(
                        Icons.bolt,
                        color: Colors.cyanAccent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$tokensUsed / $maxTokens Tokens Used Today',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${_iapController.remainingTokens} left',
                        style: const TextStyle(
                          color: Colors.cyanAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress > 0.8 ? Colors.redAccent : Colors.cyanAccent,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              )
            : Row(
                children: [
                  const Icon(Icons.lock_outline, color: Colors.cyanAccent, size: 18),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text(
                      'Platinum Ultra Plan',
                      style: TextStyle(
                        color: Colors.cyanAccent,
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Get.to(
                      () => const ProUpgradeScreen(initialPlanIndex: 2),
                      transition: Transition.rightToLeft,
                    ),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF00C6FF), Color(0xFF0072FF)],
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const Text(
                        'Upgrade',
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
      );
    });
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnimation,
              child: Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: const LinearGradient(
                    colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.purple.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.layers_clear_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'AI Background Remover',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Upload any photo and our AI will\ninstantly remove the background.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            _buildPickButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildPickButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
          ),
          borderRadius: BorderRadius.circular(50),
          boxShadow: [
            BoxShadow(
              color: Colors.purple.withValues(alpha: 0.4),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.add_photo_alternate_rounded, color: Colors.white),
            SizedBox(width: 10),
            Text(
              'Choose Photo',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditorView() {
    return Column(
      children: [
        // Image Preview with checkerboard for transparency
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Checkerboard background
                  CustomPaint(painter: _CheckerboardPainter()),
                  if (_showResult && _result != null)
                    Image.file(_result!, fit: BoxFit.contain)
                  else if (_image != null)
                    Image.file(_image!, fit: BoxFit.contain),
                  if (_isLoading) _buildProcessingOverlay(),
                  // Result/Original toggle
                  if (_result != null)
                    Positioned(
                      top: 12,
                      right: 12,
                      child: GestureDetector(
                        onTap: () => setState(() => _showResult = !_showResult),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: BackdropFilter(
                            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 14,
                                vertical: 8,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withValues(alpha: 0.5),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Colors.white.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Text(
                                _showResult ? 'Original' : 'No BG',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
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
        _buildBottomActions(),
      ],
    );
  }

  Widget _buildProcessingOverlay() {
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 60,
            height: 60,
            child: CircularProgressIndicator(
              strokeWidth: 3,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.cyanAccent),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'AI Removing Background...',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'This may take 5-15 seconds',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions() {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          decoration: BoxDecoration(
            color: const Color(0xFF0F172A).withValues(alpha: 0.9),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: _buildActionBtn(
                      label: 'Change Photo',
                      icon: Icons.swap_horiz_rounded,
                      color: Colors.white.withValues(alpha: 0.15),
                      onTap: _pickImage,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: _buildActionBtn(
                      label: _isLoading
                          ? 'Processing...'
                          : 'Remove BG (1 Token)',
                      icon: _isLoading
                          ? Icons.hourglass_empty
                          : Icons.layers_clear_rounded,
                      color: Colors.purple.withValues(alpha: 0.8),
                      gradient: const LinearGradient(
                        colors: [Color(0xFFE040FB), Color(0xFF7C4DFF)],
                      ),
                      onTap: _isLoading ? null : _removeBG,
                    ),
                  ),
                ],
              ),
              if (_result != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildActionBtn(
                        label: 'Save to Gallery',
                        icon: Icons.download_rounded,
                        color: Colors.greenAccent.withValues(alpha: 0.15),
                        borderColor: Colors.greenAccent.withValues(alpha: 0.4),
                        onTap: () async {
                          await showResultPreview(
                            originalFile: _image!,
                            resultFile: _result!,
                            operationLabel: 'Background Removed',
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildActionBtn({
    required String label,
    required IconData icon,
    required Color color,
    Gradient? gradient,
    Color? borderColor,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: gradient == null ? color : null,
          gradient: gradient,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: borderColor ?? Colors.transparent),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _result = null;
        _showResult = false;
      });
    }
  }

  void _removeBG() async {
    if (!_iapController.isUltraUser) {
      Get.to(
        () => const ProUpgradeScreen(initialPlanIndex: 2),
        transition: Transition.rightToLeft,
      );
      return;
    }

    if (!_iapController.hasTokens()) {
      showErrorSnackkbar(
        message: 'Daily token limit reached (20/20). Resets tomorrow.',
      );
      return;
    }

    if (_iapController.useToken()) {
      setState(() => _isLoading = true);
      try {
        final aiService = Get.put(AIService());
        final resultFile = await aiService.removeBackground(_image!);

        if (resultFile != null) {
          setState(() {
            _result = resultFile;
            _showResult = true;
            _isLoading = false;
          });
          showSuccessSnackkbar(
            message:
                'Background removed! Tokens remaining: ${_iapController.remainingTokens}',
          );
        } else {
          throw Exception('Result was null');
        }
      } catch (e) {
        setState(() => _isLoading = false);
        showErrorSnackkbar(message: 'Error processing image: $e');
      }
    }
  }
}

class _CheckerboardPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const squareSize = 20.0;
    final paint1 = Paint()..color = const Color(0xFF1E1E2E);
    final paint2 = Paint()..color = const Color(0xFF2A2A3E);

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
