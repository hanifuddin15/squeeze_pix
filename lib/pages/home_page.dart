import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/compressor_controller.dart';
import '../widgets/primary_button.dart';
import '../widgets/image_tile.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    return Scaffold(
      appBar: AppBar(title: const Text('SqueezePix'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: PrimaryButton(
                    label: 'Pick Images',
                    onPressed: () => c.pickImages(),
                  ),
                ),
                const SizedBox(width: 12),
                IconButton(
                  onPressed: () => c.pickSingleFromCamera(),
                  icon: const Icon(Icons.camera_alt_outlined),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Obx(() {
              if (c.images.isEmpty) {
                return const Expanded(
                  child: Center(
                    child: Text(
                      'No images selected.\nTap "Pick Images" to begin.',
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
              }
              return Expanded(
                child: GridView.builder(
                  itemCount: c.images.length,
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemBuilder: (_, i) {
                    final file = c.images[i];
                    final selected = c.selected.value?.path == file.path;
                    return GestureDetector(
                      onTap: () {
                        c.selectImage(file);
                        Get.toNamed('/compress');
                      },
                      child: ImageTile(file: file, selected: selected),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 8),
            Obx(
              () => c.history.isEmpty
                  ? const SizedBox.shrink()
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'History',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                        SizedBox(
                          height: 90,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemBuilder: (_, i) => Image.file(
                              File(c.history[i]),
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                            ),
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 8),
                            itemCount: c.history.length,
                          ),
                        ),
                      ],
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
