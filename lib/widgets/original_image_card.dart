import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';

class OriginalImageCard extends GetView<CompressorController> {
  final File file;
  const OriginalImageCard({super.key, required this.file});

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
