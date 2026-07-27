import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/pixel_lab_controller.dart';
import 'package:squeeze_pix/pages/pixel_lab/dp_maker.dart';
import 'package:squeeze_pix/pages/pixel_lab/id_photo_maker.dart';
import 'package:squeeze_pix/pages/pixel_lab/meme_generator.dart';
import 'package:squeeze_pix/pages/pixel_lab/bg_remover.dart';
import 'package:squeeze_pix/pages/pixel_lab/ai_enhancer_screen.dart';
import 'package:squeeze_pix/pages/pixel_lab/ai_headshot_screen.dart';
import 'package:squeeze_pix/widgets/glass_card.dart';

class PixelLabScreen extends GetView<PixelLabController> {
  const PixelLabScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: const Text('Pixel Lab & Studio', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 120),
        physics: const BouncingScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 16),
              child: Text(
                'AI & Creative Tools',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white.withValues(alpha: 0.9),
                  letterSpacing: 0.3,
                ),
              ),
            ),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              childAspectRatio: 1.1,
              children: [
                _buildToolCard(
                  title: 'DP Maker',
                  subtitle: 'Profile frames & borders',
                  icon: Icons.account_circle_outlined,
                  accentColor: Colors.blueAccent,
                  badge: 'FREE',
                  badgeColor: Colors.blueAccent,
                  onTap: () => Get.to(() => const DPMaker()),
                ),
                _buildToolCard(
                  title: 'ID Photo',
                  subtitle: 'Passport & Visa sizing',
                  icon: Icons.badge_outlined,
                  accentColor: Colors.purpleAccent,
                  badge: 'FREE',
                  badgeColor: Colors.purpleAccent,
                  onTap: () => Get.to(() => const IDPhotoMaker()),
                ),
                _buildToolCard(
                  title: 'Meme Gen',
                  subtitle: 'Text overlays & templates',
                  icon: Icons.emoji_emotions_outlined,
                  accentColor: Colors.orangeAccent,
                  badge: 'POPULAR',
                  badgeColor: Colors.amber,
                  onTap: () => Get.to(() => const MemeGenerator()),
                ),
                _buildToolCard(
                  title: 'Remove BG',
                  subtitle: '1-tap auto cutout',
                  icon: Icons.layers_clear_outlined,
                  accentColor: Colors.pinkAccent,
                  badge: 'PRO',
                  badgeColor: Colors.pinkAccent,
                  onTap: () => Get.to(() => const BackgroundRemover()),
                ),
                _buildToolCard(
                  title: 'AI Enhancer',
                  subtitle: 'Upscale resolution HD',
                  icon: Icons.auto_fix_high_outlined,
                  accentColor: Colors.tealAccent,
                  badge: 'ULTRA',
                  badgeColor: Colors.cyanAccent,
                  onTap: () => Get.to(() => const AIEnhancerScreen()),
                ),
                _buildToolCard(
                  title: 'Headshot Pro',
                  subtitle: 'AI avatar & professional',
                  icon: Icons.person_add_alt_1_outlined,
                  accentColor: Colors.indigoAccent,
                  badge: 'ULTRA',
                  badgeColor: Colors.indigoAccent,
                  onTap: () => Get.to(() => const AIHeadshotScreen()),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accentColor,
    required String badge,
    required Color badgeColor,
    required VoidCallback onTap,
  }) {
    return GlassCard(
      padding: const EdgeInsets.all(14),
      onTap: onTap,
      child: Stack(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: accentColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                    color: accentColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Icon(icon, size: 26, color: accentColor),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ],
          ),
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: badgeColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: badgeColor.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
              child: Text(
                badge,
                style: TextStyle(
                  color: badgeColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
