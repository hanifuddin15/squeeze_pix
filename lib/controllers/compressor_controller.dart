import 'dart:io';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../services/compressor_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as p;
import 'package:get_storage/get_storage.dart';

class CompressorController extends GetxController {
  final CompressorService _service = CompressorService();

  final RxList<File> images = <File>[].obs;
  final Rxn<File> selected = Rxn<File>();
  final RxInt quality = 80.obs; // default quality
  final Rxn<File> lastCompressed = Rxn<File>();
  final RxBool isCompressing = false.obs;
  final storage = GetStorage();

  // history small list of paths
  final RxList<String> history = <String>[].obs;

  Future<void> pickImages() async {
    final ImagePicker picker = ImagePicker();
    final picked = await picker.pickMultiImage();
    if (picked != null && picked.isNotEmpty) {
      images.addAll(picked.map((x) => File(x.path)));
      selected.value ??= images.first;
    }
  }

  Future<void> pickSingleFromCamera() async {
    final ImagePicker picker = ImagePicker();
    final XFile? shot = await picker.pickImage(source: ImageSource.camera);
    if (shot != null) {
      final f = File(shot.path);
      images.add(f);
      selected.value = f;
    }
  }

  void selectImage(File f) => selected.value = f;

  Future<void> compressSelected({int? targetWidth, int? targetHeight}) async {
    final file = selected.value;
    if (file == null) return;
    isCompressing.value = true;
    try {
      final int q = quality.value;
      final compressed = await _service.compressFile(
        file: file,
        quality: q,
        targetWidth: targetWidth,
        targetHeight: targetHeight,
      );
      if (compressed != null) {
        lastCompressed.value = await moveToDownloads(compressed);
        addToHistory(lastCompressed.value!.path);
      }
    } finally {
      isCompressing.value = false;
    }
  }

  Future<File> moveToDownloads(File tempFile) async {
    final docDir = await getApplicationDocumentsDirectory();
    final outDir = Directory(p.join(docDir.path, 'SqueezePix'));
    if (!await outDir.exists()) await outDir.create(recursive: true);
    final newPath = p.join(outDir.path, p.basename(tempFile.path));
    final newFile = await tempFile.copy(newPath);
    return newFile;
  }

  void addToHistory(String path) {
    history.insert(0, path);
    if (history.length > 50) history.removeLast();
    storage.write('history', history);
  }

  @override
  void onInit() {
    super.onInit();
    final saved = storage.read<List>('history') ?? [];
    history.assignAll(saved.cast<String>());
  }
}
