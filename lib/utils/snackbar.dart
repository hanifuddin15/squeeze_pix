import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

enum SnackType { success, error, warning, info }

/// 🎨 Premium glassmorphic snackbar system
void showSuccessSnackkbar({String? title, required String message}) {
  _showPremiumSnackbar(
    title: title ?? 'Success',
    message: message,
    type: SnackType.success,
  );
}

void showErrorSnackkbar({String? title, required String message}) {
  _showPremiumSnackbar(
    title: title ?? 'Error',
    message: message,
    type: SnackType.error,
  );
}

void showWarningSnackkbar({String? title, required String message}) {
  _showPremiumSnackbar(
    title: title ?? 'Notice',
    message: message,
    type: SnackType.warning,
  );
}

void showSnackkbar({required String title, required String message}) {
  _showPremiumSnackbar(
    title: title,
    message: message,
    type: SnackType.info,
  );
}

void _showPremiumSnackbar({
  required String title,
  required String message,
  required SnackType type,
}) {
  // Dismiss any existing snackbar
  if (Get.isSnackbarOpen) Get.closeCurrentSnackbar();

  final config = _snackConfig(type);

  Get.snackbar(
    '',
    '',
    titleText: const SizedBox.shrink(),
    messageText: _SnackbarWidget(
      title: title,
      message: message,
      config: config,
    ),
    snackPosition: SnackPosition.TOP,
    margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
    borderRadius: 18,
    duration: const Duration(seconds: 3),
    animationDuration: const Duration(milliseconds: 400),
    forwardAnimationCurve: Curves.easeOutCubic,
    reverseAnimationCurve: Curves.easeInCubic,
    backgroundColor: Colors.transparent,
    padding: EdgeInsets.zero,
    boxShadows: [
      BoxShadow(
        color: config.glowColor.withValues(alpha: 0.25),
        blurRadius: 20,
        spreadRadius: 0,
        offset: const Offset(0, 6),
      ),
    ],
    snackStyle: SnackStyle.FLOATING,
    overlayBlur: 0,
    overlayColor: Colors.transparent,
    userInputForm: null,
    mainButton: null,
    icon: null,
    shouldIconPulse: false,
    barBlur: 0,
  );
}

class _SnackConfig {
  final Color accentColor;
  final Color glowColor;
  final IconData icon;
  final List<Color> gradientColors;

  const _SnackConfig({
    required this.accentColor,
    required this.glowColor,
    required this.icon,
    required this.gradientColors,
  });
}

_SnackConfig _snackConfig(SnackType type) {
  switch (type) {
    case SnackType.success:
      return const _SnackConfig(
        accentColor: Color(0xFF00F5A0),
        glowColor: Color(0xFF00F5A0),
        icon: Icons.check_circle_rounded,
        gradientColors: [Color(0xFF00F5A0), Color(0xFF00D9F5)],
      );
    case SnackType.error:
      return const _SnackConfig(
        accentColor: Color(0xFFFF4D6D),
        glowColor: Color(0xFFFF4D6D),
        icon: Icons.cancel_rounded,
        gradientColors: [Color(0xFFFF4D6D), Color(0xFFFF8500)],
      );
    case SnackType.warning:
      return const _SnackConfig(
        accentColor: Color(0xFFFFD60A),
        glowColor: Color(0xFFFFD60A),
        icon: Icons.warning_amber_rounded,
        gradientColors: [Color(0xFFFFD60A), Color(0xFFFF9500)],
      );
    case SnackType.info:
      return const _SnackConfig(
        accentColor: Color(0xFF6C9FFF),
        glowColor: Color(0xFF6C9FFF),
        icon: Icons.info_rounded,
        gradientColors: [Color(0xFF6C9FFF), Color(0xFFB06CFF)],
      );
  }
}

class _SnackbarWidget extends StatelessWidget {
  final String title;
  final String message;
  final _SnackConfig config;

  const _SnackbarWidget({
    required this.title,
    required this.message,
    required this.config,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
        child: Container(
          padding: const EdgeInsets.fromLTRB(0, 0, 14, 0),
          decoration: BoxDecoration(
            color: const Color(0xFF0D1B2A).withValues(alpha: 0.92),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: config.accentColor.withValues(alpha: 0.3),
              width: 1,
            ),
          ),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Left accent bar with gradient
                Container(
                  width: 5,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: config.gradientColors,
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(18),
                      bottomLeft: Radius.circular(18),
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                // Icon circle
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: config.gradientColors
                            .map((c) => c.withValues(alpha: 0.2))
                            .toList(),
                      ),
                      border: Border.all(
                        color: config.accentColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Icon(
                      config.icon,
                      color: config.accentColor,
                      size: 22,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Text content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => LinearGradient(
                            colors: config.gradientColors,
                          ).createShader(bounds),
                          child: Text(
                            title,
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 13,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          message,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.75),
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ],
                    ),
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
