// import 'package:flutter/material.dart';
// import 'package:squeeze_pix/theme/app_theme.dart';

// class PrimaryButton extends StatelessWidget {
//   final String label;
//   final TextStyle? labelStyle;
//   final VoidCallback onPressed;
//   final IconData? icon;
//   const PrimaryButton({
//     required this.label,
//     required this.onPressed,
//     this.icon,
//     super.key,
//     this.labelStyle,
//   });

//   @override
//   Widget build(BuildContext context) {
//     return Container(
//       decoration: BoxDecoration(
//         gradient: AppTheme.gradient,
//         borderRadius: BorderRadius.circular(12),
//         border: Border.all(
//           color: Theme.of(context).colorScheme.secondary,
//           width: 2,
//         ),
//         boxShadow: [
//           BoxShadow(
//             color: Colors.black.withValues(alpha: .2),
//             blurRadius: 8,
//             offset: const Offset(0, 4),
//           ),
//         ],
//       ),
//       child: FilledButton(
//         style: FilledButton.styleFrom(
//           backgroundColor: Colors.transparent,
//           padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
//           shape: RoundedRectangleBorder(
//             borderRadius: BorderRadius.circular(12),
//           ),
//         ),
//         onPressed: onPressed,
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             if (icon != null) ...[
//               Icon(icon, size: 12),
//               const SizedBox(width: 8),
//             ],
//             Text(
//               label,
//               style:
//                   labelStyle ??
//                   Theme.of(context).textTheme.bodySmall?.copyWith(
//                     color: Theme.of(context).colorScheme.onPrimary,
//                     fontWeight: FontWeight.bold,
//                   ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
