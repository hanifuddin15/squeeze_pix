// lib/widgets/reusable/pixel_lab_button.dart
import 'package:flutter/material.dart';
import 'package:squeeze_pix/widgets/glass_card.dart';

class PixelLabButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const PixelLabButton({
    required this.icon,
    required this.label,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: GlassCard(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 48, color: Colors.white),
            SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
