// lib/widgets/reusable/shimmer_button.dart
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double borderRadius;
  final EdgeInsets padding;

  const ShimmerButton({
    super.key,
    required this.onPressed,
    required this.child,
    this.borderRadius = 30.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.cyan.shade600,
      highlightColor: Colors.white,
      period: const Duration(milliseconds: 1500),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.cyan.shade600,
          foregroundColor: Colors.white,
          padding: padding,
          elevation: 12,
          shadowColor: Colors.cyan.withOpacity(0.6),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(borderRadius),
          ),
        ),
        child: DefaultTextStyle(
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
          child: child,
        ),
      ),
    );
  }
}
