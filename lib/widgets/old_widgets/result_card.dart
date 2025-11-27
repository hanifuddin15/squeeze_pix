// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:squeeze_pix/controllers/compressor_controller.dart';
// import 'package:squeeze_pix/theme/app_theme.dart';
// import 'package:squeeze_pix/widgets/primary_button.dart';

// class ResultCard extends GetView<CompressorController> {
//   final File? originalFile;
//   final File? resultFile;
//   const ResultCard({super.key, this.originalFile, this.resultFile});

//   @override
//   Widget build(BuildContext context) {
//     return AnimatedSwitcher(
//       duration: const Duration(milliseconds: 600),
//       transitionBuilder: (child, animation) {
//         return FadeTransition(opacity: animation, child: child);
//       },
//       child: resultFile == null || resultFile!.path.isEmpty
//           ? const SizedBox.shrink()
//           : Card(
//               key: ValueKey(resultFile!.path),
//               child: Container(
//                 decoration: BoxDecoration(
//                   gradient: AppTheme.gradient,
//                   borderRadius: BorderRadius.circular(12),
//                 ),
//                 child: Padding(
//                   padding: const EdgeInsets.all(16.0),
//                   child: Row(
//                     children: [
//                       ClipRRect(
//                         borderRadius: BorderRadius.circular(12),
//                         child: Image.file(
//                           resultFile!,
//                           width: 90,
//                           height: 90,
//                           fit: BoxFit.cover,
//                         ),
//                       ),
//                       const SizedBox(width: 16),
//                       Expanded(
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             Text(
//                               'Success!',
//                               style: Theme.of(context).textTheme.titleLarge
//                                   ?.copyWith(
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onPrimary,
//                                   ),
//                             ),
//                             const SizedBox(height: 8),
//                             Text(
//                               _buildResultText(),
//                               style: Theme.of(context).textTheme.bodyLarge
//                                   ?.copyWith(
//                                     color: Theme.of(
//                                       context,
//                                     ).colorScheme.onPrimary,
//                                   ),
//                             ),
//                             const SizedBox(height: 12),
//                             PrimaryButton(
//                               label: 'Open File',
//                               onPressed: () =>
//                                   controller.openLastCompressedLocation(),
//                               icon: Icons.folder_open,
//                             ),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),
//                 ),
//               ),
//             ),
//     );
//   }

//   String _buildResultText() {
//     if (resultFile == null || originalFile == null) return '';

//     final originalSize = originalFile!.lengthSync();
//     final newSize = resultFile!.lengthSync();
//     final reduction = originalSize - newSize;
//     final reductionPercent = (reduction / originalSize * 100).toStringAsFixed(
//       1,
//     );

//     final newSizeKB = (newSize / 1024).toStringAsFixed(1);

//     if (reduction > 0) {
//       return 'New size: $newSizeKB KB ($reductionPercent% smaller)';
//     } else {
//       return 'New size: $newSizeKB KB';
//     }
//   }
// }
