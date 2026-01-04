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
        return const CircleBorder(
          side: BorderSide(width: 4, color: Colors.white),
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
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),
        ),
        actions: [
          if (_selectedImage != null)
            IconButton(
              icon: const Icon(Icons.check, color: Colors.amber,),
              onPressed: _saveDP,
              tooltip: 'Save DP',
            ),
          IconButton(
            icon: const Icon(Icons.share, color: Colors.amber,),
            onPressed: _shareDP,
            tooltip: 'Share DP',
          ),
        ],
      ),
      body: _selectedImage == null
          ? _buildImagePickerPrompt()
          : Container(
              decoration: BoxDecoration(gradient: AppTheme.gradient),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: RepaintBoundary(
                        key: _repaintBoundaryKey,
                        child: Container(
                          margin: const EdgeInsets.all(20),
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
                  _buildControls(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.photo_library),
      ),
    );
  }

  Widget _buildImagePickerPrompt() {
    return Center(
      child: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo, size: 80, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'No Image Selected',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below to select an image.',
              style: TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickImage,
              icon: const Icon(Icons.add_a_photo),
              label: const Text('Select Image'),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
                textStyle: const TextStyle(fontSize: 16),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControls() {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface.withValues(alpha: .7),
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildShapeSelector(),
            const SizedBox(height: 16),
            _buildSliderRow(
              icon: Icons.rotate_right,
              label: 'Rotate',
              value: _rotation,
              min: -3.14,
              max: 3.14,
              onChanged: (val) => setState(() => _rotation = val),
            ),
            _buildSliderRow(
              icon: Icons.border_style_outlined,
              label: 'Border',
              value: _borderWidth,
              min: 0,
              max: 20,
              onChanged: (val) => setState(() => _borderWidth = val),
              onTapIcon: _pickBorderColor,
            ),
            if (_showRadiusSlider)
              _buildSliderRow(
                icon: Icons.rounded_corner,
                label: 'Radius',
                value: _borderRadius,
                min: 0,
                max: 150,
                onChanged: (val) => setState(() => _borderRadius = val),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildShapeSelector() {
    return CupertinoSlidingSegmentedControl<DPShape>(
      children: const {
        DPShape.circle: Icon(Icons.circle_outlined),
        DPShape.square: Icon(Icons.square_outlined),
        DPShape.rounded: Icon(Icons.rounded_corner),
      },
      groupValue: _selectedShape,
      onValueChanged: (value) {
        if (value != null) {
          setState(() {
            _selectedShape = value;

            // Default radius for shapes
            if (value == DPShape.square && _borderRadius == 30) {
              _borderRadius = 0;
            }
            if (value == DPShape.rounded) _borderRadius = 30;
          });
        }
      },
    );
  }

  Widget _buildSliderRow({
    required IconData icon,
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
    VoidCallback? onTapIcon,
  }) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          InkWell(
            onTap: onTapIcon,
            child: Icon(icon, color: onTapIcon != null ? _borderColor : null),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Slider(
              activeColor: Theme.of(context).colorScheme.inverseSurface,
              inactiveColor: Theme.of(
                context,
              ).colorScheme.onSurface.withValues(alpha: .24),
              value: value,
              min: min,
              max: max,
              label: value.toStringAsFixed(1),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }

  void _pickBorderColor() {
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

      await SharePlus.instance.share(ShareParams(files: [XFile(file.path)], text: 'Check out my new DP!'));
    });
  }
}
