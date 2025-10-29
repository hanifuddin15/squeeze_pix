import 'dart:io';
import 'package:before_after/before_after.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/compressor_controller.dart';

class BeforeAfterCard extends GetView<CompressorController> {
  final File before;
  final File? after;

  const BeforeAfterCard({super.key, required this.before, required this.after});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 500),
        key: ValueKey(after?.path ?? before.path), // Ensures widget rebuilds
        child: after == null || after!.path.isEmpty
            ? Hero(
                tag: before.path,
                child: Image.file(
                  before,
                  height: Get.height * 0.35,
                  fit: BoxFit.contain,
                ),
              )
            : BeforeAfter(
                before: Image.file(before, fit: BoxFit.contain),
                after: Image.file(after!, fit: BoxFit.contain),
                // direction : false,
              ),
      ),
    );
  }
}
