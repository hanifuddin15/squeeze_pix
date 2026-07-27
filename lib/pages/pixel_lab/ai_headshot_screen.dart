import 'dart:io';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:squeeze_pix/controllers/iap_controller.dart';
import 'package:squeeze_pix/pages/pro_upgrade_screen.dart';
import 'package:squeeze_pix/services/ai_service.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import 'package:squeeze_pix/widgets/result_preview_dialog.dart';

class AIHeadshotScreen extends StatefulWidget {
  const AIHeadshotScreen({super.key});

  @override
  State<AIHeadshotScreen> createState() => _AIHeadshotScreenState();
}

class _AIHeadshotScreenState extends State<AIHeadshotScreen>
    with TickerProviderStateMixin {
  File? _image;
  bool _isProcessing = false;
  String _selectedStyle = "Suit & Tie";
  final IAPController _iapController = Get.find<IAPController>();

  final List<Map<String, dynamic>> _styles = [
    {"label": "Suit & Tie", "icon": Icons.business_center},
    {"label": "Business Casual", "icon": Icons.checkroom},
    {"label": "Tuxedo", "icon": Icons.star},
    {"label": "Doctor Coat", "icon": Icons.local_hospital},
    {"label": "Cyan Suit", "icon": Icons.palette},
    {"label": "Red Dress", "icon": Icons.favorite},
  ];

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

    // Immediately redirect non-Ultra users to the upgrade screen
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_iapController.isUltraUser) {
        Get.off(() => const ProUpgradeScreen(initialPlanIndex: 2));
      }
    });
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
          'AI Headshot Pro',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: SafeArea(
          child: Column(
            children: [
              _buildTokenInfo(),
              Expanded(
                child: _image == null ? _buildPicker() : _buildEditor(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTokenInfo() {
    return Obx(() {
      final tokensUsed = _iapController.dailyTokensUsed.value;
      final maxTokens = IAPController.maxDailyTokens;
      final progress = tokensUsed / maxTokens;

      return Container(
        margin: const EdgeInsets.fromLTRB(16, 8, 16, 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: const LinearGradient(
            colors: [Color(0xFF1A003D), Color(0xFF0D001F)],
          ),
          border: Border.all(
            color: Colors.indigoAccent.withValues(alpha: 0.4),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.diamond, color: Colors.indigoAccent, size: 18),
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
                    color: Colors.indigoAccent,
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
                  progress > 0.8 ? Colors.redAccent : Colors.indigoAccent,
                ),
                minHeight: 6,
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _buildPicker() {
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
                    colors: [Color(0xFF5C6BC0), Color(0xFF283593)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.5),
                      blurRadius: 30,
                      spreadRadius: 8,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.person_pin_circle_rounded,
                  size: 56,
                  color: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 28),
            const Text(
              'AI Headshot Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Transform your selfie into a professional\nheadshot with AI in seconds.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.6),
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            GestureDetector(
              onTap: _pickImage,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF5C6BC0), Color(0xFF283593)],
                  ),
                  borderRadius: BorderRadius.circular(50),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.indigo.withValues(alpha: 0.4),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.camera_front_rounded, color: Colors.white),
                    SizedBox(width: 10),
                    Text(
                      'Select Selfie',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEditor() {
    return Column(
      children: [
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: Image.file(_image!, fit: BoxFit.contain),
            ),
          ),
        ),
        // Style selector
        Container(
          height: 90,
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _styles.length,
            itemBuilder: (context, index) {
              final style = _styles[index];
              final isSelected = _selectedStyle == style['label'];
              return GestureDetector(
                onTap: () => setState(() => _selectedStyle = style['label']),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 90,
                  margin: const EdgeInsets.only(right: 10),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? Colors.indigoAccent.withValues(alpha: 0.2)
                        : Colors.white.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: isSelected
                          ? Colors.indigoAccent
                          : Colors.white.withValues(alpha: 0.1),
                      width: isSelected ? 2 : 1,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        style['icon'] as IconData,
                        color: isSelected
                            ? Colors.indigoAccent
                            : Colors.white54,
                        size: 22,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        style['label'] as String,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: isSelected ? Colors.white : Colors.white54,
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal,
                          fontSize: 10,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
        if (_isProcessing)
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              children: [
                const SizedBox(
                  width: 56,
                  height: 56,
                  child: CircularProgressIndicator(
                    strokeWidth: 3,
                    valueColor:
                        AlwaysStoppedAnimation<Color>(Colors.indigoAccent),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Generating Headshot... (~15-30s)',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.7),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          )
        else
          _buildBottomActions(),
      ],
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
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border(
              top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
            ),
          ),
          child: Row(
            children: [
              Expanded(
                child: GestureDetector(
                  onTap: () => setState(() => _image = null),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.swap_horiz_rounded,
                            color: Colors.white70, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Change Photo',
                          style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                flex: 2,
                child: GestureDetector(
                  onTap: _processHeadshot,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF5C6BC0), Color(0xFF283593)],
                      ),
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.indigo.withValues(alpha: 0.3),
                          blurRadius: 12,
                        ),
                      ],
                    ),
                    child: const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.auto_awesome, color: Colors.white, size: 18),
                        SizedBox(width: 8),
                        Text(
                          'Generate (1 Token)',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
      });
    }
  }

  Future<void> _processHeadshot() async {
    if (!_iapController.isUltraUser) {
      Get.to(() => const ProUpgradeScreen(initialPlanIndex: 2));
      return;
    }

    if (!_iapController.hasTokens()) {
      showErrorSnackkbar(
        message: 'Daily token limit reached. Please come back tomorrow!',
      );
      return;
    }

    if (_iapController.useToken()) {
      final originalImage = _image!;
      setState(() => _isProcessing = true);

      try {
        final aiService = Get.put(AIService());
        final prompt = "wearing a $_selectedStyle";
        final resultFile = await aiService.generateHeadshot(_image!, prompt);

        if (resultFile != null) {
          setState(() {
            _isProcessing = false;
          });
          await showResultPreview(
            originalFile: originalImage,
            resultFile: resultFile,
            operationLabel: 'Headshot: $_selectedStyle',
          );
          setState(() {
            _image = resultFile;
          });
        } else {
          throw Exception('Result was null');
        }
      } catch (e) {
        setState(() => _isProcessing = false);
        showErrorSnackkbar(message: 'AI Error: $e');
      }
    }
  }
}
