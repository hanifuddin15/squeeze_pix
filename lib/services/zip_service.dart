import 'dart:io';
import 'package:archive/archive.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

class ZipService {
  Future<File> createZip(List<File> files, String zipName) async {
    final docDir = await getApplicationDocumentsDirectory();
    final outDir = Directory(p.join(docDir.path, 'SqueezePix'));
    if (!await outDir.exists()) await outDir.create(recursive: true);

    final zipPath = p.join(outDir.path, zipName);
    final archive = Archive();

    for (var file in files) {
      final bytes = await file.readAsBytes();
      archive.addFile(ArchiveFile(p.basename(file.path), bytes.length, bytes));
    }

    final zipEncoder = ZipEncoder();
    final zipBytes = zipEncoder.encode(archive);

    final zipFile = File(zipPath);
    await zipFile.writeAsBytes(zipBytes);

    return zipFile;
  }
}
