import 'dart:io';

class AppImage {
  final File file;
  final String path;
  final int size;
  AppImage(this.file) : path = file.path, size = file.lengthSync();
}
