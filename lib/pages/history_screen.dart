import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:open_filex/open_filex.dart';
import 'package:squeeze_pix/controllers/history_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';

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

    // Get all unique history types present in the history list
    final availableHistoryTypes = controller.history
        .map((e) => e.type)
        .toSet()
        .toList();
    availableHistoryTypes.sort((a, b) => a.index.compareTo(b.index));

    return DefaultTabController(
      length: availableHistoryTypes.length,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          title: const Text('Creation History'),
          backgroundColor: Colors.transparent,
          elevation: 0,
          bottom: availableHistoryTypes.isEmpty
              ? null
              : TabBar(
                  isScrollable: true,
                  tabs: availableHistoryTypes
                      .map((type) => Tab(text: tabTitles[type]))
                      .toList(),
                ),
        ),
        body: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),
          child: Obx(() {
            if (controller.history.isEmpty) {
              return const _EmptyHistoryState();
            }

            return TabBarView(
              children: availableHistoryTypes.map((type) {
                final itemsForType = controller.history
                    .where((item) => item.type == type)
                    .toList();
                return _HistoryList(items: itemsForType);
              }).toList(),
            );
          }),
        ),
      ),
    );
  }
}

class _HistoryList extends StatelessWidget {
  final List<HistoryItem> items;
  const _HistoryList({required this.items});

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const Center(
        child: Text(
          'No items in this category yet.',
          style: TextStyle(color: Colors.white70),
        ),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.only(top: kToolbarHeight * 2.2, bottom: 100),
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        final file = File(item.path);
        final fileName = file.path.split(Platform.pathSeparator).last;

        return Card(
          color: Colors.white.withOpacity(0.1),
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: ListTile(
            leading: ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.file(
                file,
                width: 56,
                height: 56,
                fit: BoxFit.cover,
                errorBuilder: (c, o, s) =>
                    const Icon(Icons.image_not_supported, color: Colors.white),
              ),
            ),
            title: Text(
              fileName,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.white),
            ),
            subtitle: Text(
              'Tap to open',
              style: TextStyle(color: Colors.white.withOpacity(0.7)),
            ),
            onTap: () => OpenFilex.open(item.path),
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
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.history_toggle_off, size: 80, color: Colors.white70),
          SizedBox(height: 16),
          Text(
            'No History Yet',
            style: TextStyle(fontSize: 20, color: Colors.white70),
          ),
          Text(
            'Your saved creations will appear here.',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }
}
