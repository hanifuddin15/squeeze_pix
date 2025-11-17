// lib/widgets/reusable/glass_card.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsets padding;
  const GlassCard({
    required this.child,
    this.padding = const EdgeInsets.all(16),
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          decoration: BoxDecoration(
            gradient: AppTheme.glassGradient,
            border: Border.all(color: Colors.white.withOpacity(0.2)),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
