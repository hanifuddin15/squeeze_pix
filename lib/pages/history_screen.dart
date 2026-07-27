import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:squeeze_pix/controllers/history_controller.dart';
import 'package:squeeze_pix/widgets/glass_card.dart';
import 'package:squeeze_pix/utils/formatters.dart';

class HistoryScreen extends GetView<HistoryController> {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final Map<HistoryType, String> tabTitles = {
      HistoryType.compression: 'Compressed',
      HistoryType.editor: 'Edited',
      HistoryType.dp: 'DP Maker',
      HistoryType.id: 'ID Photos',
      HistoryType.meme: 'Memes',
    };

    return Obx(() {
      final availableHistoryTypes = controller.history
          .map((e) => e.type)
          .toSet()
          .toList();
      availableHistoryTypes.sort((a, b) => a.index.compareTo(b.index));

      if (availableHistoryTypes.isEmpty) {
        return Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Creation History', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
          ),
          body: const _EmptyHistoryState(),
        );
      }

      return DefaultTabController(
        length: availableHistoryTypes.length,
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Creation History', style: TextStyle(fontWeight: FontWeight.bold)),
            backgroundColor: Colors.transparent,
            elevation: 0,
            centerTitle: true,
            bottom: TabBar(
              isScrollable: true,
              indicatorColor: Colors.cyanAccent,
              labelColor: Colors.cyanAccent,
              unselectedLabelColor: Colors.white60,
              labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
              tabs: availableHistoryTypes
                  .map((type) => Tab(text: tabTitles[type]))
                  .toList(),
            ),
          ),
          body: TabBarView(
            children: availableHistoryTypes.map((type) {
              final itemsForType = controller.history
                  .where((item) => item.type == type)
                  .toList();
              return _HistoryList(items: itemsForType);
            }).toList(),
          ),
        ),
      );
    });
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryItem> items;
  const _HistoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return Center(
        child: Text(
          'No items in this category yet.',
          style: TextStyle(color: Colors.white.withValues(alpha: 0.6)),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 120),
      physics: const BouncingScrollPhysics(),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final file = File(item.path);
        final fileName = file.path.split(Platform.pathSeparator).last;
        final exists = file.existsSync();
        final fileSize = exists ? formatBytes(file.lengthSync(), 1) : 'Unavailable';

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            padding: const EdgeInsets.all(12),
            onTap: exists ? () => OpenFilex.open(item.path) : null,
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: exists
                      ? Image.file(
                          file,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (c, o, s) => Container(
                            width: 60,
                            height: 60,
                            color: Colors.white.withValues(alpha: 0.1),
                            child: const Icon(Icons.broken_image, color: Colors.white54),
                          ),
                        )
                      : Container(
                          width: 60,
                          height: 60,
                          color: Colors.white.withValues(alpha: 0.1),
                          child: const Icon(Icons.description, color: Colors.white54),
                        ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        fileName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.cyanAccent.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              fileSize,
                              style: const TextStyle(
                                color: Colors.cyanAccent,
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tap to view',
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.open_in_new, color: Colors.white70, size: 20),
                  onPressed: exists ? () => OpenFilex.open(item.path) : null,
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _EmptyHistoryState extends StatelessWidget {
  const _EmptyHistoryState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.white.withValues(alpha: 0.08),
            ),
            child: const Icon(Icons.history_toggle_off_rounded, size: 64, color: Colors.white60),
          ),
          const SizedBox(height: 20),
          const Text(
            'No History Yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            'Your compressed and edited images will appear here.',
            style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 14),
          ),
        ],
      ),
    );
  }
}
