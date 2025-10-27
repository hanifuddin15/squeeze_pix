import 'package:flutter/material.dart';

class CompressionSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double>? onChanged;
  const CompressionSlider({required this.value, this.onChanged, super.key});

  @override
  Widget build(BuildContext context) {
    return SliderTheme(
      data: SliderTheme.of(context).copyWith(
        trackHeight: 6,
        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 12),
        overlayShape: const RoundSliderOverlayShape(overlayRadius: 24),
        activeTrackColor: Theme.of(context).colorScheme.primary,
        inactiveTrackColor: Theme.of(
          context,
        ).colorScheme.primary.withValues(alpha: .3),
        thumbColor: Theme.of(context).colorScheme.secondary,
      ),
      child: Slider(
        min: 10,
        max: 100,
        divisions: 18,
        label: value.round().toString(),
        value: value,
        onChanged: onChanged,
      ),
    );
  }
}
