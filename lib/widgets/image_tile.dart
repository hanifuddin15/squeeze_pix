import 'dart:io';
import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final File file;
  final bool selected;
  const ImageTile({required this.file, this.selected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: file.path,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),
            if (selected) ...[
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: Theme.of(context).colorScheme.primary,
                      width: 3,
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              const Positioned(
                top: 6,
                right: 6,
                child: Icon(Icons.check_circle, color: Colors.white, size: 20),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
