// lib/widgets/pixel_lab/dp_maker.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import '../../../theme/app_theme.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/unity_ads_controller.dart';

enum DPShape { circle, square, rounded }

enum EditorTool { none, shape, border, rotate }

class DPMaker extends StatefulWidget {
  final File? image;
  const DPMaker({this.image, super.key});

  @override
  State<DPMaker> createState() => _DPMakerState();
}

class _DPMakerState extends State<DPMaker> {
  File? _selectedImage;
  final GlobalKey _repaintBoundaryKey = GlobalKey();

  // DP customization state
  double _rotation = 0.0;
  double _borderWidth = 4.0;
  Color _borderColor = Colors.white;
  double _borderRadius = 30.0;
  DPShape _selectedShape = DPShape.circle;

  // UI State
  EditorTool _activeTool = EditorTool.none;

  final TransformationController _transformationController =
      TransformationController();

  @override
  void initState() {
    super.initState();
    _selectedImage = widget.image;
    if (_selectedImage == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickImage());
    }
  }

  @override
  void dispose() {
    _transformationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _selectedImage = File(picked.path);
        _transformationController.value = Matrix4.identity();
        _rotation = 0.0;
      });
    }
  }

  ShapeBorder get _currentShape {
    switch (_selectedShape) {
      case DPShape.circle:
        return CircleBorder(
          side: BorderSide(width: _borderWidth, color: _borderColor),
        );
      case DPShape.square:
      case DPShape.rounded:
        return RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(_borderRadius),
          side: BorderSide(color: _borderColor, width: _borderWidth),
        );
    }
  }

  bool get _showRadiusSlider =>
      _selectedShape == DPShape.square || _selectedShape == DPShape.rounded;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("DP Maker"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _pickImage,
            tooltip: 'Change Image',
          ),
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.amberAccent),
              onPressed: _saveDP,
              tooltip: 'Save DP',
            ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.white),
            onPressed: _shareDP,
            tooltip: 'Share DP',
          ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: _selectedImage == null
            ? _buildImagePickerPrompt()
            : Stack(
                children: [
                  // Main Editor Area
                  Positioned.fill(
                    bottom: 140, // Leave space for controls
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: Container(
                            decoration: ShapeDecoration(shape: _currentShape),
                            child: ClipPath(
                              clipper: ShapeBorderClipper(shape: _currentShape),
                              child: InteractiveViewer(
                                transformationController:
                                    _transformationController,
                                minScale: 0.5,
                                maxScale: 4.0,
                                panEnabled: true,
                                scaleEnabled: true,
                                child: Transform.rotate(
                                  angle: _rotation,
                                  child: Image.file(
                                    _selectedImage!,
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Bottom Controls Panel
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: _buildBottomControls(),
                  ),
                ],
              ),
      ),
    );
  }

  Widget _buildImagePickerPrompt() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.add_photo_alternate_outlined,
            size: 80,
            color: Colors.white.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 16),
          const Text(
            'Select an Image to Start',
            style: TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _pickImage,
            icon: const Icon(Icons.add),
            label: const Text('Pick Image'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomControls() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.8),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contextual Controls (Sliders, Color Picker, Segmented Control)
            if (_activeTool != EditorTool.none) _buildContextualPanel(),

            // Main Toolbar
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildToolbarItem(
                    icon: Icons.crop_square,
                    label: "Shape",
                    tool: EditorTool.shape,
                  ),
                  _buildToolbarItem(
                    icon: Icons.border_style,
                    label: "Border",
                    tool: EditorTool.border,
                  ),
                  _buildToolbarItem(
                    icon: Icons.rotate_right,
                    label: "Rotate",
                    tool: EditorTool.rotate,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbarItem({
    required IconData icon,
    required String label,
    required EditorTool tool,
  }) {
    final isSelected = _activeTool == tool;
    return InkWell(
      onTap: () {
        setState(() {
          _activeTool = isSelected ? EditorTool.none : tool;
        });
      },
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.amberAccent : Colors.white70,
              size: 28,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.amberAccent : Colors.white70,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContextualPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_activeTool == EditorTool.shape) _buildShapeControls(),
          if (_activeTool == EditorTool.border) _buildBorderControls(),
          if (_activeTool == EditorTool.rotate) _buildRotateControls(),
        ],
      ),
    );
  }

  Widget _buildShapeControls() {
    return Column(
      children: [
        CupertinoSlidingSegmentedControl<DPShape>(
          backgroundColor: Colors.white.withValues(alpha: 0.2),
          thumbColor: Colors.amber,
          children: {
            DPShape.circle: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.circle_outlined, color: Colors.black),
            ),
            DPShape.square: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.crop_square, color: Colors.black),
            ),
            DPShape.rounded: const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8),
              child: Icon(Icons.rounded_corner, color: Colors.black),
            ),
          },
          groupValue: _selectedShape,
          onValueChanged: (value) {
            if (value != null) {
              setState(() {
                _selectedShape = value;
                if (value == DPShape.square && _borderRadius == 30) {
                  _borderRadius = 0;
                }
                if (value == DPShape.rounded) _borderRadius = 30;
              });
            }
          },
        ),
        if (_showRadiusSlider)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Row(
              children: [
                const Icon(
                  Icons.rounded_corner,
                  color: Colors.white70,
                  size: 20,
                ),
                Expanded(
                  child: Slider(
                    value: _borderRadius,
                    min: 0,
                    max: 150,
                    activeColor: Colors.amber,
                    inactiveColor: Colors.white24,
                    onChanged: (val) => setState(() => _borderRadius = val),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBorderControls() {
    return Column(
      children: [
        Row(
          children: [
            const Text("Width", style: TextStyle(color: Colors.white70)),
            const SizedBox(width: 8),
            Expanded(
              child: Slider(
                value: _borderWidth,
                min: 0,
                max: 30,
                activeColor: Colors.amber,
                inactiveColor: Colors.white24,
                onChanged: (val) => setState(() => _borderWidth = val),
              ),
            ),
            Text(
              "${_borderWidth.toInt()}",
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildColorOption(Colors.white),
              _buildColorOption(Colors.black),
              _buildColorOption(Colors.red),
              _buildColorOption(Colors.blue),
              _buildColorOption(Colors.green),
              _buildColorOption(Colors.amber),
              _buildColorOption(Colors.purple),
              _buildColorOption(Colors.cyan),
              GestureDetector(
                onTap: _pickCustomBorderColor,
                child: Container(
                  width: 40,
                  height: 40,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [Colors.red, Colors.green, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: const Icon(
                    Icons.colorize,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildColorOption(Color color) {
    final isSelected = _borderColor == color;
    return GestureDetector(
      onTap: () => setState(() => _borderColor = color),
      child: Container(
        width: 40,
        height: 40,
        margin: const EdgeInsets.only(right: 12),
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          border: isSelected
              ? Border.all(color: Colors.amberAccent, width: 3)
              : Border.all(color: Colors.white24, width: 1),
          boxShadow: [
            if (isSelected)
              BoxShadow(
                color: Colors.amberAccent.withValues(alpha: 0.4),
                blurRadius: 8,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildRotateControls() {
    return Row(
      children: [
        IconButton(
          onPressed: () => setState(() => _rotation -= 0.1),
          icon: const Icon(Icons.rotate_left, color: Colors.white70),
        ),
        Expanded(
          child: Slider(
            value: _rotation,
            min: -3.14,
            max: 3.14,
            activeColor: Colors.amber,
            inactiveColor: Colors.white24,
            onChanged: (val) => setState(() => _rotation = val),
          ),
        ),
        IconButton(
          onPressed: () => setState(() => _rotation += 0.1),
          icon: const Icon(Icons.rotate_right, color: Colors.white70),
        ),
        IconButton(
          onPressed: () => setState(() => _rotation = 0),
          icon: const Icon(Icons.restore, color: Colors.white70),
          tooltip: "Reset Rotation",
        ),
      ],
    );
  }

  void _pickCustomBorderColor() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color!'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: _borderColor,
            onColorChanged: (color) => setState(() => _borderColor = color),
          ),
        ),
        actions: [
          ElevatedButton(
            child: const Text('Got it'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  Future<Uint8List?> _captureWidget() async {
    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
      if (boundary == null) return null;

      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      showErrorSnackkbar(message: "Failed to capture image: $e");
      return null;
    }
  }

  Future<void> _saveDP() async {
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      final imageBytes = await _captureWidget();
      if (imageBytes == null) return;

      try {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/dp_maker_output.png').create();
        await file.writeAsBytes(imageBytes);
        await Gal.putImage(file.path);
        // Add to history
        Get.find<HistoryController>().addHistoryItem(file, HistoryType.dp);
        showSuccessSnackkbar(message: "DP saved to gallery!");
      } catch (e) {
        showErrorSnackkbar(message: "Failed to save DP: $e");
      }
    });
  }

  Future<void> _shareDP() async {
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      final imageBytes = await _captureWidget();
      if (imageBytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/dp_maker_share.png').create();
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(files: [XFile(file.path)], text: 'Check out my new DP!'),
      );
    });
  }
}
