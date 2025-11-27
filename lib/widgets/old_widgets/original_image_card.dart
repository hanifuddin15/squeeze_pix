// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:squeeze_pix/controllers/compressor_controller.dart';
// import 'package:squeeze_pix/theme/app_theme.dart';

// class OriginalImageCard extends GetView<CompressorController> {
//   final File file;
//   const OriginalImageCard({super.key, required this.file});

//   @override
//   Widget build(BuildContext context) {
//     return Card(
//       clipBehavior: Clip.antiAlias,
//       child: Container(
//         decoration: BoxDecoration(
//           gradient: AppTheme.gradient,
//           borderRadius: BorderRadius.circular(12),
//         ),
//         child: Column(
//           children: [
//             SizedBox(
//               height: Get.height * 0.35,
//               child: Hero(
//                 tag: file.path,
//                 child: Image.file(file, fit: BoxFit.contain),
//               ),
//             ),
//             Padding(
//               padding: const EdgeInsets.all(16.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                 children: [
//                   Text(
//                     'Original: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
//                     style: Theme.of(context).textTheme.titleMedium?.copyWith(
//                       color: Theme.of(context).colorScheme.onPrimary,
//                       fontWeight: FontWeight.bold,
//                     ),
//                   ),
//                   Obx(
//                     () => IconButton(
//                       icon: Icon(
//                         controller.favorites.contains(file.path)
//                             ? Icons.star
//                             : Icons.star_border,
//                         color: Theme.of(context).colorScheme.secondary,
//                       ),
//                       onPressed: () => controller.toggleFavorite(file.path),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
