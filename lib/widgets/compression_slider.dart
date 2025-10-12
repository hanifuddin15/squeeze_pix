import 'package:flutter/material.dart';

class CompressionSlider extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  const CompressionSlider({
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Slider(
      min: 10,
      max: 100,
      divisions: 18,
      label: value.round().toString(),
      value: value,
      onChanged: onChanged,
    );
  }
}
