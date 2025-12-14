// // lib/screens/result_screen.dart
// import 'dart:io';

// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:share_plus/share_plus.dart';
// import 'package:squeeze_pix/theme/app_theme.dart';
// import 'package:squeeze_pix/widgets/shimmer_button.dart';

// class ResultScreen extends StatelessWidget {
//   final File? compressed;
//   const ResultScreen({required this.compressed, super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(gradient: AppTheme.gradient),
//         child: compressed == null
//             ? const Center(
//                 child: Text(
//                   "No compressed image found.",
//                   style: TextStyle(color: Colors.white, fontSize: 18),
//                 ),
//               )
//             : Column(
//                 children: [
//                   const Text(
//                     "Compressed!",
//                     style: TextStyle(fontSize: 32, color: Colors.white),
//                   ),
//                   if (compressed != null) Image.file(compressed!),
//                   Row(
//                     mainAxisAlignment: MainAxisAlignment.spaceEvenly,
//                     children: [
//                       ShimmerButton(
//                         onPressed: () => _share(),
//                         child: const Text("Share"),
//                       ),
//                       ShimmerButton(
//                         onPressed: () => _save(),
//                         child: const Text("Save"),
//                       ),
//                     ],
//                   ),
//                 ],
//               ),
//       ),
//     );
//   }

//   void _share() {
//     if (compressed != null) {
//       SharePlus.instance.share(
//         ShareParams(
//           subject: "Compressed Image",
//           files: [XFile(compressed!.path)],
//         ),
//       );
//     }
//   }

//   void _save() {
//     // Save to gallery
//     Get.snackbar("Saved", "Compressed image saved to gallery!");
//   }
// }
