import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

class CompressorService {
  /// Compress single file and return compressed File
  Future<File?> compressFile({
    required File file,
    required int quality, // 1-100
    int? targetWidth,
    int? targetHeight,
  }) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'squeeze_${DateTime.now().millisecondsSinceEpoch}.jpg',
    );

    try {
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: targetWidth ?? 1920,
        minHeight: targetHeight ?? 1080,
        keepExif: false,
      );

      debugPrint('Compression result: ${result?.path}');
      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('Compression failed: $e');
      return null;
    }
  }
}
