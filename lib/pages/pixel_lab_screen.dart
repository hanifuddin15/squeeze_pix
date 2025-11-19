import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class PixelLabScreen extends StatelessWidget {
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
                  // TODO: Navigate to your DP Maker screen
                  Get.snackbar(
                    'Coming Soon',
                    'DP Maker feature is under development.',
                  );
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
                  // TODO: Navigate to your ID Photo screen
                  Get.snackbar(
                    'Coming Soon',
                    'ID Photo feature is under development.',
                  );
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
                  // TODO: Navigate to your Meme Gen screen
                  Get.snackbar(
                    'Coming Soon',
                    'Meme Generator is under development.',
                  );
                },
              ),
              _buildFeatureCard(
                title: 'AI Tools',
                icon: Icons.auto_awesome,
                gradient: const LinearGradient(
                  colors: [Colors.teal, Colors.greenAccent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                onTap: () {
                  // TODO: Navigate to your AI Tools screen
                  Get.snackbar(
                    'Coming Soon',
                    'AI features are under development.',
                  );
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
  }) {
    return Card(
      elevation: 8.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Container(
          decoration: BoxDecoration(gradient: gradient),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 50, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
