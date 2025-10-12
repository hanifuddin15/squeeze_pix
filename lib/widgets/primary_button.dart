import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onPressed;
  const PrimaryButton({
    required this.label,
    required this.onPressed,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return FilledButton(
      onPressed: onPressed,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12),
        child: Text(label),
      ),
    );
  }
}
