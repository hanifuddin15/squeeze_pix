import 'dart:io';
import 'package:flutter/material.dart';

class ImageTile extends StatelessWidget {
  final File file;
  final bool selected;
  const ImageTile({required this.file, this.selected = false, super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned.fill(child: Image.file(file, fit: BoxFit.cover)),
        if (selected)
          Positioned(
            top: 6,
            right: 6,
            child: Icon(Icons.check_circle, color: Colors.greenAccent),
          ),
      ],
    );
  }
}
