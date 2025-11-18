import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/controllers/home_controller.dart';
import 'package:squeeze_pix/controllers/history_screen.dart';
import 'package:squeeze_pix/controllers/pixel_lab_screen.dart';
import 'package:squeeze_pix/pages/editor_hub.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/controllers/glassmorphic_button.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.put(HomeController());
    // Ensure CompressorController is initialized for the HistoryScreen
    Get.put(CompressorController());

    final List<Widget> pages = [
      const ImageGridPage(),
      const PixelLabScreen(),
      const HistoryScreen(),
    ];

    return Scaffold(
      extendBody: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Obx(
          () => IndexedStack(
            index: homeController.tabIndex.value,
            children: pages,
          ),
        ),
      ),
      bottomNavigationBar: GlassBottomNav(), // Using the refactored Nav Bar
    );
  }
}

class ImageGridPage extends StatelessWidget {
  const ImageGridPage({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.find<HomeController>();
    Get.put(CompressorController()); // Ensure it's available

    return Obx(() {
      if (controller.images.isEmpty) {
        return Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.image_search, size: 80, color: Colors.white70),
              const SizedBox(height: 20),
              const Text(
                'No images yet.',
                style: TextStyle(color: Colors.white, fontSize: 24),
              ),
              const SizedBox(height: 20),
              GlassmorphicButton(
                width: 200,
                height: 50,
                onPressed: controller.isPicking.value
                    ? () {}
                    : () => controller.pickMultiple(),
                child: Text(
                  controller.isPicking.value ? "Loading..." : "Pick Images",
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        );
      }
      return SafeArea(
        child: GridView.builder(
          padding: const EdgeInsets.all(8),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
          ),
          itemCount: controller.images.length,
          itemBuilder: (context, index) {
            final image = controller.images[index];
            return GestureDetector(
              onTap: () => Get.to(() => EditorHub(imageFile: image.file)),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(image.file, fit: BoxFit.cover),
              ),
            );
          },
        ),
      );
    });
  }
}

class GlassBottomNav extends StatelessWidget {
  const GlassBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    final homeController = Get.find<HomeController>();
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Obx(
          () => BottomNavigationBar(
            backgroundColor: Colors.white.withValues(alpha: .2),
            selectedItemColor: Colors.cyan,
            unselectedItemColor: Colors.white70,
            currentIndex: homeController.tabIndex.value,
            onTap: (i) => homeController.tabIndex.value = i,
            type:
                BottomNavigationBarType.fixed, // This makes all labels visible
            items: const [
              BottomNavigationBarItem(
                icon: Icon(Icons.photo_library),
                label: "Home",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.grid_view_rounded),
                label: "Pixel Lab",
              ),
              BottomNavigationBarItem(
                icon: Icon(Icons.history),
                label: "History",
              ),
            ],
          ),
        ),
      ),
    );
  }
}
