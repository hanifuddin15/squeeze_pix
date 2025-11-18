import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;

// class CompressorService {
//   Future<File?> compressFile({
//     required File file,
//     required int quality,
//     int? targetWidth,
//     int? targetHeight,
//     required String format,
//     double? targetSizeKB,
//   }) async {
//     final dir = await getTemporaryDirectory();
//     final targetPath = p.join(
//       dir.path,
//       'squeeze_${DateTime.now().millisecondsSinceEpoch}.$format',
//     );

//     try {
//       if (targetSizeKB != null) {
//         return await _compressToTargetSize(
//           file: file,
//           targetPath: targetPath,
//           targetSizeKB: targetSizeKB,
//           format: format,
//           minWidth: targetWidth ?? 1920,
//           minHeight: targetHeight ?? 1080,
//         );
//       }

//       final XFile? result = await FlutterImageCompress.compressAndGetFile(
//         file.absolute.path,
//         targetPath,
//         quality: quality,
//         minWidth: targetWidth ?? 1920,
//         minHeight: targetHeight ?? 1080,
//         keepExif: false,
//         format: format == 'png' ? CompressFormat.png : CompressFormat.jpeg,
//       );

//       debugPrint('Compression result: ${result?.path}');
//       if (result == null) return null;
//       return File(result.path);
//     } catch (e) {
//       debugPrint('Compression failed: $e');
//       return null;
//     }
//   }

//   Future<File?> _compressToTargetSize({
//     required File file,
//     required String targetPath,
//     required double targetSizeKB,
//     required String format,
//     int minWidth = 1920,
//     int minHeight = 1080,
//   }) async {
//     int quality = 80;
//     int step = 10;
//     File? compressedFile;

//     while (quality >= 10) {
//       final XFile? result = await FlutterImageCompress.compressAndGetFile(
//         file.absolute.path,
//         targetPath,
//         quality: quality,
//         minWidth: minWidth,
//         minHeight: minHeight,
//         keepExif: false,
//         format: format == 'png' ? CompressFormat.png : CompressFormat.jpeg,
//       );

//       if (result == null) return null;
//       compressedFile = File(result.path);
//       final sizeKB = compressedFile.lengthSync() / 1024;

//       if (sizeKB <= targetSizeKB || quality <= 10) break;
//       quality -= step;
//     }

//     return compressedFile;
//   }
// }

// lib/services/compressor_service.dart

import 'package:squeeze_pix/services/zip_service.dart';

class CompressorService {
  Future<File?> compressFile({
    required File file,
    required int quality,
    int? targetWidth,
    int? targetHeight,
    required String format,
    double? targetSizeKB,
  }) async {
    final dir = await getTemporaryDirectory();
    final targetPath = p.join(
      dir.path,
      'squeeze_${DateTime.now().millisecondsSinceEpoch}.$format',
    );

    try {
      if (targetSizeKB != null) {
        return await _compressToTargetSize(
          file: file,
          targetPath: targetPath,
          targetSizeKB: targetSizeKB,
          format: format,
          minWidth: targetWidth ?? 1920,
          minHeight: targetHeight ?? 1080,
        );
      }

      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: targetWidth ?? 1920,
        minHeight: targetHeight ?? 1080,
        keepExif: false,
        format: format == 'png' ? CompressFormat.png : CompressFormat.jpeg,
      );

      debugPrint('Compression result: ${result?.path}');
      if (result == null) return null;
      return File(result.path);
    } catch (e) {
      debugPrint('Compression failed: $e');
      return null;
    }
  }

  Future<File?> batchCompress(List<File> files, int quality) async {
    // final dir = await getTemporaryDirectory();
    final compressed = <File>[];
    for (var file in files) {
      final compressedFile = await compress(
        file: file,
        quality: quality,
        format: p.extension(file.path).replaceFirst('.', ''),
      );
      if (compressedFile != null) {
        compressed.add(compressedFile);
      }
    }
    return ZipService().createZip(compressed, 'batch.zip');
  }

  Future<File?> _compressToTargetSize({
    required File file,
    required String targetPath,
    required double targetSizeKB,
    required String format,
    int minWidth = 1920,
    int minHeight = 1080,
  }) async {
    int quality = 80;
    int step = 10;
    File? compressedFile;

    while (quality >= 10) {
      final XFile? result = await FlutterImageCompress.compressAndGetFile(
        file.absolute.path,
        targetPath,
        quality: quality,
        minWidth: minWidth,
        minHeight: minHeight,
        keepExif: false,
        format: format == 'png' ? CompressFormat.png : CompressFormat.jpeg,
      );

      if (result == null) return null;
      compressedFile = File(result.path);
      final sizeKB = compressedFile.lengthSync() / 1024;

      if (sizeKB <= targetSizeKB || quality <= 10) break;
      quality -= step;
    }

    return compressedFile;
  }

  Future<File?> compress({
    required File file,
    required int quality,
    int? targetWidth,
    int? targetHeight,
    required String format,
    double? targetSizeKB,
  }) async {
    return compressFile(
      file: file,
      quality: quality,
      targetWidth: targetWidth,
      targetHeight: targetHeight,
      format: format,
      targetSizeKB: targetSizeKB,
    );
  }
}
