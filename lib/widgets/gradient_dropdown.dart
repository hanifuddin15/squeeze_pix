import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class GradientDropdown extends StatelessWidget {
  final RxString selectedValue;
  final List<String> items;
  final bool isDisabled;
  final void Function(String) onChanged;

  const GradientDropdown({
    super.key,
    required this.selectedValue,
    required this.items,
    required this.onChanged,
    this.isDisabled = false,
  });

  @override
  Widget build(BuildContext context) {
    return Obx(
      () => Container(
        decoration: BoxDecoration(
          gradient: AppTheme.gradient,
          borderRadius: BorderRadius.circular(12),
          // boxShadow: [
          //   BoxShadow(
          //     color: Colors.black.withOpacity(0.1),
          //     blurRadius: 6,
          //     offset: const Offset(0, 3),
          //   ),
          // ],
        ),
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DropdownButtonHideUnderline(
          child: DropdownButton<String>(
            value: selectedValue.value,
            onChanged: isDisabled
                ? null
                : (String? newValue) {
                    if (newValue != null) onChanged(newValue);
                  },
            items: items.map((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(
                  value.toUpperCase(),
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              );
            }).toList(),
            iconEnabledColor: Colors.white,
            dropdownColor: Colors.cyan, // allow gradient to show
            isExpanded: true,
            hint: Text(
              'Select Format',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(color: Colors.white70),
            ),
          ),
        ),
      ),
    );
  }
}
