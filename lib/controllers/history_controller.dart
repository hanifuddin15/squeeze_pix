import 'dart:io';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

enum HistoryType { compression, dp, id, meme, editor }

class HistoryItem {
  final String path;
  final HistoryType type;
  final DateTime timestamp;

  HistoryItem({
    required this.path,
    required this.type,
    required this.timestamp,
  });

  // For serialization with GetStorage
  Map<String, dynamic> toJson() => {
        'path': path,
        'type': type.name,
        'timestamp': timestamp.toIso8601String(),
      };

  factory HistoryItem.fromJson(Map<String, dynamic> json) {
    return HistoryItem(
      path: json['path'],
      type: HistoryType.values.firstWhere((e) => e.name == json['type'],
          orElse: () => HistoryType.compression),
      timestamp: DateTime.parse(json['timestamp']),
    );
  }
}

class HistoryController extends GetxController {
  final _box = GetStorage();
  final RxList<HistoryItem> history = <HistoryItem>[].obs;

  @override
  void onInit() {
    super.onInit();
    _loadHistory();
  }

  void _loadHistory() {
    final List<dynamic>? storedHistory = _box.read<List>('unified_history');
    if (storedHistory != null) {
      final loadedItems = storedHistory
          .map((item) => HistoryItem.fromJson(item as Map<String, dynamic>))
          .where((item) => File(item.path).existsSync())
          .toList();
      // Sort by date, newest first
      loadedItems.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      history.assignAll(loadedItems);
    }
  }

  void addHistoryItem(File file, HistoryType type) {
    // Avoid duplicates
    history.removeWhere((item) => item.path == file.path);

    final newItem = HistoryItem(
      path: file.path,
      type: type,
      timestamp: DateTime.now(),
    );

    history.insert(0, newItem);

    // Limit history size
    if (history.length > 50) {
      history.removeLast();
    }

    _box.write('unified_history', history.map((e) => e.toJson()).toList());
  }
}