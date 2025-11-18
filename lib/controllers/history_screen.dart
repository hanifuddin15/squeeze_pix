import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final CompressorController controller = Get.find();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Compression History'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Obx(() {
        if (controller.history.isEmpty) {
          return Container(
            decoration: BoxDecoration(gradient: AppTheme.gradient),
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.history_toggle_off, size: 80, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    'No History Yet',
                    style: TextStyle(fontSize: 20, color: Colors.grey),
                  ),
                  Text(
                    'Your compressed images will appear here.',
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          itemCount: controller.history.length,
          itemBuilder: (context, index) {
            final path = controller.history[index];
            final file = File(path);
            final fileName = file.path.split('/').last;

            return Container(
              decoration: BoxDecoration(gradient: AppTheme.gradient),

              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: ListTile(
                leading: ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: Image.file(
                    file,
                    width: 56,
                    height: 56,
                    fit: BoxFit.cover,
                    errorBuilder: (c, o, s) =>
                        const Icon(Icons.image_not_supported),
                  ),
                ),
                title: Text(fileName, overflow: TextOverflow.ellipsis),
                subtitle: Text('Tap to open'),
                onTap: () => controller.openHistoryFile(path),
              ),
            );
          },
        );
      }),
    );
  }
}
