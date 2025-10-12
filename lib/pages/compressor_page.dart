import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/compressor_controller.dart';
import '../widgets/compression_slider.dart';
import '../widgets/primary_button.dart';
import 'package:share_plus/share_plus.dart';

class CompressorPage extends StatelessWidget {
  const CompressorPage({super.key});

  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    return Scaffold(
      appBar: AppBar(title: const Text('Compress & Save')),
      body: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Obx(() {
          final sel = c.selected.value;
          if (sel == null) {
            return const Center(child: Text('No image selected.'));
          }
          return Column(
            children: [
              Expanded(
                child: Column(
                  children: [
                    Expanded(child: Image.file(sel, fit: BoxFit.contain)),
                    const SizedBox(height: 8),
                    Text(
                      'Original: ${(sel.lengthSync() / 1024).toStringAsFixed(1)} KB',
                    ),
                    const SizedBox(height: 12),
                    CompressionSlider(
                      value: c.quality.value.toDouble(),
                      onChanged: (v) => c.quality.value = v.round(),
                    ),
                    const SizedBox(height: 8),
                    Obx(() => Text('Quality: ${c.quality.value}%')),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: PrimaryButton(
                            label: 'Compress',
                            onPressed: () => c.compressSelected(),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: PrimaryButton(
                            label: 'Compress & Share',
                            onPressed: () async {
                              await c.compressSelected();
                              final f = c.lastCompressed.value;
                              if (f != null) {
                                await Share.shareXFiles([XFile(f.path)]);
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    if (c.isCompressing.value) const LinearProgressIndicator(),
                    if (c.lastCompressed.value != null) ...[
                      const Divider(),
                      Text('Result:'),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(
                            child: Image.file(
                              File(c.lastCompressed.value!.path),
                              height: 120,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Size: ${(c.lastCompressed.value!.lengthSync() / 1024).toStringAsFixed(1)} KB',
                                ),
                                const SizedBox(height: 8),
                                PrimaryButton(
                                  label: 'Open Folder',
                                  onPressed: () {
                                    // implement open folder with platform-specific code or just show path
                                    Get.snackbar(
                                      'Saved',
                                      c.lastCompressed.value!.path,
                                    );
                                  },
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}
