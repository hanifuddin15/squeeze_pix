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
      appBar: AppBar(
        title: const Text('Compress & Save'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            c.lastCompressed.value = null; // Clear result on back
            Get.back();
          },
        ),
      ),
      body: Obx(() {
        final selectedFile = c.selected.value;
        if (selectedFile == null) {
          return const Center(child: Text('No image selected.'));
        }
        return ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _OriginalImageCard(file: selectedFile),
            const SizedBox(height: 16),
            _ControlsCard(),
            const SizedBox(height: 16),
            _ResultCard(),
          ],
        );
      }),
    );
  }
}

class _OriginalImageCard extends StatelessWidget {
  final File file;
  const _OriginalImageCard({required this.file});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          SizedBox(
            height: Get.height * 0.3,
            child: Hero(
              tag: file.path,
              child: Image.file(file, fit: BoxFit.contain),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Text(
              'Original: ${(file.lengthSync() / 1024).toStringAsFixed(1)} KB',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
        ],
      ),
    );
  }
}

class _ControlsCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();

    return Obx(() {
      final bool isCompressing = c.isCompressing.value;
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                'Quality: ${c.quality.value}%',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              CompressionSlider(
                value: c.quality.value.toDouble(),
                onChanged: isCompressing
                    ? null
                    : (v) => c.quality.value = v.round(),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: PrimaryButton(
                      label: isCompressing ? 'Compressing...' : 'Compress',
                      onPressed: isCompressing
                          ? () {}
                          : () => c.compressSelected(),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: PrimaryButton(
                      label: isCompressing ? 'Working...' : 'Compress & Share',
                      onPressed: isCompressing
                          ? () {}
                          : () async {
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
              if (isCompressing) ...[
                const SizedBox(height: 16),
                const LinearProgressIndicator(),
              ],
            ],
          ),
        ),
      );
    });
  }
}

class _ResultCard extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final c = Get.find<CompressorController>();
    final resultFile = c.lastCompressed.value;

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 500),
      transitionBuilder: (child, animation) {
        return FadeTransition(opacity: animation, child: child);
      },
      child: resultFile == null
          ? const SizedBox.shrink()
          : Card(
              key: ValueKey(resultFile.path),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.file(
                        resultFile,
                        width: 80,
                        height: 80,
                        fit: BoxFit.cover,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Success!',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'New size: ${(resultFile.lengthSync() / 1024).toStringAsFixed(1)} KB',
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                          const SizedBox(height: 8),
                          PrimaryButton(
                            label: 'Open File',
                            onPressed: () => c.openLastCompressedLocation(),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
