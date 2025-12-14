// // lib/screens/pixel_lab_hub.dart
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:squeeze_pix/pages/bg_remover.dart';
// import 'package:squeeze_pix/pages/dp_maker.dart';
// import 'package:squeeze_pix/pages/id_photo_maker.dart';
// import 'package:squeeze_pix/pages/meme_generator.dart';
// import 'package:squeeze_pix/theme/app_theme.dart';
// import 'package:squeeze_pix/widgets/pixel_lab_button.dart';

// class PixelLabHub extends StatelessWidget {
//   const PixelLabHub({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Container(
//         decoration: BoxDecoration(gradient: AppTheme.gradient),
//         child: SafeArea(
//           child: Column(
//             children: [
//               Text(
//                 "Pixel Lab",
//                 style: TextStyle(
//                   fontSize: 32,
//                   color: Colors.white,
//                   fontWeight: FontWeight.bold,
//                 ),
//               ),
//               Expanded(
//                 child: GridView.count(
//                   crossAxisCount: 2,
//                   padding: EdgeInsets.all(20),
//                   children: [
//                     PixelLabButton(
//                       icon: Icons.crop,
//                       label: "DP Maker",
//                       onTap: () => Get.to(() => DPMaker()),
//                     ),
//                     PixelLabButton(
//                       icon: Icons.portrait,
//                       label: "ID Photo",
//                       onTap: () => Get.to(() => IDPhotoMaker()),
//                     ),
//                     PixelLabButton(
//                       icon: Icons.delete_outline,
//                       label: "Remove BG",
//                       onTap: () => Get.to(() => BackgroundRemover()),
//                     ),
//                     PixelLabButton(
//                       icon: Icons.mood,
//                       label: "Meme Gen",
//                       onTap: () => Get.to(() => MemeGenerator()),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }
