import 'dart:ui';
import 'package:flutter/material.dart';

class GlassmorphicButton extends StatelessWidget {
  final VoidCallback onPressed;
  final Widget child;
  final double width;
  final double height;
  final double borderRadius;
  final Color splashColor;

  const GlassmorphicButton({
    Key? key,
    required this.onPressed,
    required this.child,
    this.width = 200,
    this.height = 60,
    this.borderRadius = 15.0,
    this.splashColor = Colors.white30,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(borderRadius),
            border: Border.all(
              color: Colors.white.withOpacity(0.2),
              width: 1.5,
            ),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: splashColor,
              onTap: onPressed,
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}