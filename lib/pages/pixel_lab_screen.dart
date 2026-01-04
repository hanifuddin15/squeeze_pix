import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/pixel_lab_controller.dart';
import 'package:squeeze_pix/pages/pixel_lab/dp_maker.dart';
import 'package:squeeze_pix/pages/pixel_lab/id_photo_maker.dart';
import 'package:squeeze_pix/pages/pixel_lab/meme_generator.dart';
import 'package:squeeze_pix/pages/pixel_lab/bg_remover.dart';
import 'package:squeeze_pix/pages/pixel_lab/ai_enhancer_screen.dart';
import 'package:squeeze_pix/pages/pixel_lab/ai_headshot_screen.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class PixelLabScreen extends GetView<PixelLabController> {
  const PixelLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Pixel Lab'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: GridView.count(
            crossAxisCount: 2,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            children: [
              _buildFeatureCard(
                title: 'DP Maker',
                icon: Icons.account_circle,
                gradient: const LinearGradient(
                  colors: [Colors.blueAccent, Colors.lightBlueAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Get.to(() => const DPMaker());
                },
              ),
              _buildFeatureCard(
                title: 'ID Photo',
                icon: Icons.badge,
                gradient: const LinearGradient(
                  colors: [Colors.purpleAccent, Colors.deepPurpleAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Get.to(() => const IDPhotoMaker());
                },
              ),
              _buildFeatureCard(
                title: 'Meme Gen',
                icon: Icons.emoji_emotions,
                gradient: const LinearGradient(
                  colors: [Colors.orangeAccent, Colors.deepOrangeAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Get.to(() => const MemeGenerator());
                },
              ),
               _buildFeatureCard(
                title: 'Remove BG',
                 subtitle: 'Ultra', 

                icon: Icons.layers_clear,
                gradient: const LinearGradient(
                  colors: [Colors.redAccent, Colors.pinkAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Get.to(() => const BackgroundRemover());
                },
              ),
               _buildFeatureCard(
                title: 'AI Enhancer',
                icon: Icons.auto_fix_high,
                 subtitle: 'Ultra', 
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Get.to(() => const AIEnhancerScreen());
                },
              ),
               _buildFeatureCard(
                title: 'Headshot Pro',
                icon: Icons.person_add_alt_1,
                subtitle: 'Ultra',
                gradient: const LinearGradient(
                  colors: [Colors.indigo, Colors.blue],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  Get.to(() => const AIHeadshotScreen());
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFeatureCard({
    required String title,
    required IconData icon,
    required Gradient gradient,
    required VoidCallback onTap,
    String? subtitle,
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Stack(
            children: [
               Center(
                 child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(icon, size: 40, color: Colors.white),
                    const SizedBox(height: 8),
                    Text(
                      title,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                               ),
               ),
              if (subtitle != null)
                Positioned(
                  top: 8,
                  right: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: Colors.black26,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      subtitle,
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
