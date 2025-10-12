import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  final IconData? icon;
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    this.icon,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    final child = Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(label),
    );

    return icon != null
        ? FilledButton.icon(
            onPressed: onPressed,
            icon: Icon(icon),
            label: child,
          )
        : FilledButton(onPressed: onPressed, child: child);
  }
}
