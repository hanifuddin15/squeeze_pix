import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:squeeze_pix/controllers/editor_controller.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:image/image.dart' as img;

class EditorHub extends StatelessWidget {
  final File? imageFile;
  const EditorHub({this.imageFile, super.key});

  @override
  Widget build(BuildContext context) {
    // Use Get.put to ensure a unique controller instance for this screen
    final EditorController controller = Get.put(EditorController());
    if (imageFile != null) {
      controller.setImage(imageFile!);
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Image Editor'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: controller.shareImage,
            tooltip: 'Share Image',
          ),
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: controller.saveImage,
            tooltip: 'Save Image',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Column(
          children: [
            // Image Preview Area
            Expanded(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Obx(() {
                    if (controller.editedImage.value == null) {
                      return const Center(
                        child: Text(
                          'No Image Selected',
                          style: TextStyle(color: Colors.white),
                        ),
                      );
                    }
                    // Wrap the image with ColorFiltered for real-time previews
                    return ColorFiltered(
                      colorFilter: controller.activeColorFilter.value,
                      child: Image.file(controller.editedImage.value!),
                    );
                  }),
                ),
              ),
            ),
            // Editing Controls Area
            Obx(() {
              switch (controller.activeTool.value) {
                case EditorTool.none:
                  return _buildMainToolbar(controller);
                default:
                  return _buildToolPanel(controller);
              }
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildMainToolbar(EditorController controller) {
    return Container(
      height: 100,
      color: Colors.black.withOpacity(0.3),
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8.0),
        children: <Widget>[
          _EditorToolButton(
            icon: Icons.crop_rotate,
            label: 'Crop',
            onTap: controller.cropImage,
          ),
          _EditorToolButton(
            icon: Icons.aspect_ratio,
            label: 'Resize',
            onTap: () => controller.setActiveTool(EditorTool.resize),
          ),
          _EditorToolButton(
            icon: Icons.compress,
            label: 'Compress',
            onTap: () => controller.setActiveTool(EditorTool.compress),
          ),
          _EditorToolButton(
            icon: Icons.transform,
            label: 'Convert',
            onTap: () => controller.setActiveTool(EditorTool.convert),
          ),
          _EditorToolButton(
            icon: Icons.filter_vintage,
            label: 'Effects',
            onTap: () => controller.setActiveTool(EditorTool.effects),
          ),
        ],
      ),
    );
  }

  Widget _buildToolPanel(EditorController controller) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      color: Colors.black.withOpacity(0.5),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Obx(
            () => _buildActiveToolControls(
              controller,
              controller.activeTool.value,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                icon: const Icon(Icons.close, color: Colors.red, size: 30),
                onPressed: () => controller.setActiveTool(EditorTool.none),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildActiveToolControls(
    EditorController controller,
    EditorTool tool,
  ) {
    switch (tool) {
      case EditorTool.resize:
        return _ResizeControls(controller: controller);
      case EditorTool.compress:
        return _CompressControls(controller: controller);
      case EditorTool.convert:
        return _ConvertControls(controller: controller);
      case EditorTool.effects:
        return _EffectsControls();
      default:
        return const SizedBox.shrink();
    }
  }
}

class _ResizeControls extends StatefulWidget {
  final EditorController controller;
  const _ResizeControls({required this.controller});

  @override
  State<_ResizeControls> createState() => _ResizeControlsState();
}

class _ResizeControlsState extends State<_ResizeControls> {
  late TextEditingController _widthController;
  late TextEditingController _heightController;
  bool _keepAspectRatio = true;
  double _aspectRatio = 1.0;

  @override
  void initState() {
    super.initState();
    _widthController = TextEditingController();
    _heightController = TextEditingController();

    widget.controller.editedImage.value?.readAsBytes().then((bytes) {
      final image = img.decodeImage(bytes);
      if (image != null && mounted) {
        setState(() {
          _aspectRatio = image.width / image.height;
          _widthController.text = image.width.toString();
          _heightController.text = image.height.toString();
        });
      }
    });

    _widthController.addListener(_onWidthChanged);
    _heightController.addListener(_onHeightChanged);
  }

  void _onWidthChanged() {
    if (!_keepAspectRatio || !_heightController.hasListeners) return;
    final width = int.tryParse(_widthController.text);
    if (width != null) {
      _heightController.removeListener(_onHeightChanged);
      _heightController.text = (width / _aspectRatio).round().toString();
      _heightController.addListener(_onHeightChanged);
    }
  }

  void _onHeightChanged() {
    if (!_keepAspectRatio || !_widthController.hasListeners) return;
    final height = int.tryParse(_heightController.text);
    if (height != null) {
      _widthController.removeListener(_onWidthChanged);
      _widthController.text = (height * _aspectRatio).round().toString();
      _widthController.addListener(_onWidthChanged);
    }
  }

  @override
  void dispose() {
    _widthController.dispose();
    _heightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Expanded(child: _buildTextField(_widthController, 'Width')),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 8.0),
              child: Icon(Icons.close, color: Colors.white),
            ),
            Expanded(child: _buildTextField(_heightController, 'Height')),
          ],
        ),
        SwitchListTile.adaptive(
          title: const Text(
            'Keep Aspect Ratio',
            style: TextStyle(color: Colors.white),
          ),
          value: _keepAspectRatio,
          onChanged: (val) => setState(() => _keepAspectRatio = val),
          activeColor: Get.theme.colorScheme.primary,
        ),
        ElevatedButton(
          onPressed: () {
            final w = int.tryParse(_widthController.text);
            final h = int.tryParse(_heightController.text);
            if (w != null && h != null) {
              widget.controller.applyResize(w, h);
            }
          },
          child: const Text('Apply Resize'),
        ),
      ],
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.white.withOpacity(0.7)),
        enabledBorder: const UnderlineInputBorder(
          borderSide: BorderSide(color: Colors.white54),
        ),
        focusedBorder: UnderlineInputBorder(
          borderSide: BorderSide(color: Get.theme.colorScheme.primary),
        ),
      ),
    );
  }
}

class _CompressControls extends StatelessWidget {
  final EditorController controller;
  const _CompressControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Obx(
          () => SegmentedButton<int>(
            segments: const [
              ButtonSegment(value: 0, label: Text('Quality')),
              ButtonSegment(value: 1, label: Text('Target Size')),
            ],
            selected: {controller.compressionMode.value},
            onSelectionChanged: (newSelection) {
              controller.compressionMode.value = newSelection.first;
            },
            style: SegmentedButton.styleFrom(
              foregroundColor: Colors.white,
              selectedForegroundColor: Get.theme.colorScheme.primary,
              backgroundColor: Colors.black26,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Obx(() {
          if (controller.compressionMode.value == 0) {
            return _buildQualitySlider(controller);
          } else {
            return _buildTargetSizeInput(controller);
          }
        }),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: controller.applyCompression,
          child: const Text('Apply Compression'),
        ),
      ],
    );
  }

  Widget _buildQualitySlider(EditorController controller) {
    return Obx(
      () => Column(
        children: [
          Text(
            'Quality: ${controller.compressionQuality.value.toInt()}',
            style: const TextStyle(color: Colors.white),
          ),
          Slider(
            value: controller.compressionQuality.value,
            min: 1,
            max: 100,
            divisions: 99,
            label: controller.compressionQuality.value.round().toString(),
            onChanged: (value) => controller.compressionQuality.value = value,
            activeColor: Get.theme.colorScheme.primary,
            inactiveColor: Colors.white38,
          ),
        ],
      ),
    );
  }

  Widget _buildTargetSizeInput(EditorController controller) {
    final textController = TextEditingController(
      text: controller.targetSizeKB.value.toString(),
    );
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Target Size:', style: TextStyle(color: Colors.white)),
        const SizedBox(width: 16),
        SizedBox(
          width: 80,
          child: TextField(
            controller: textController,
            keyboardType: TextInputType.number,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              isDense: true,
              contentPadding: const EdgeInsets.all(8),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Get.theme.colorScheme.primary),
              ),
            ),
            onChanged: (value) {
              controller.targetSizeKB.value = int.tryParse(value);
            },
          ),
        ),
        const SizedBox(width: 8),
        const Text('KB', style: TextStyle(color: Colors.white)),
      ],
    );
  }
}

class _ConvertControls extends StatelessWidget {
  final EditorController controller;
  const _ConvertControls({required this.controller});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          onPressed: () => controller.applyConversion('PDF'),
          child: const Text('to PDF'),
        ),
        ElevatedButton(
          onPressed: () => controller.applyConversion('JPG'),
          child: const Text('to JPG'),
        ),
        ElevatedButton(
          onPressed: () => controller.applyConversion('PNG'),
          child: const Text('to PNG'),
        ),
      ],
    );
  }
}

class _EffectsControls extends GetView<EditorController> {
  const _EffectsControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // One-tap effects
        SizedBox(
          height: 90,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            children: [
              _EffectButton(
                label: 'Grayscale',
                onTap: () => controller.applyOneTapEffect(img.grayscale),
              ),
              _EffectButton(
                label: 'Sepia',
                onTap: () => controller.applyOneTapEffect((i) => img.sepia(i)),
              ),
              _EffectButton(
                label: 'Invert',
                onTap: () => controller.applyOneTapEffect(img.invert),
              ),
            ],
          ),
        ),
        const Divider(color: Colors.white24, height: 1),
        // Adjustable effects
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            children: [
              _buildEffectSlider(
                label: 'Brightness',
                value: controller.brightness,
                min: -100,
                max: 100,
              ),
              _buildEffectSlider(
                label: 'Contrast',
                value: controller.contrast,
                min: 0.0,
                max: 2.0,
              ),
              _buildEffectSlider(
                label: 'Saturation',
                value: controller.saturation,
                min: 0.0,
                max: 2.0,
              ),
              _buildEffectSlider(
                label: 'Hue',
                value: controller.hue,
                min: -180,
                max: 180,
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: controller.resetEffects,
                    child: const Text('Reset'),
                  ),
                  ElevatedButton(
                    onPressed: controller.applyAdjustments,
                    child: const Text('Apply Adjustments'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEffectSlider({
    required String label,
    required RxDouble value,
    required double min,
    required double max,
  }) {
    return Obx(
      () => Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.right,
            ),
          ),
          Expanded(
            child: Slider(
              value: value.value,
              min: min,
              max: max,
              onChanged: (val) => value.value = val,
              activeColor: Get.theme.colorScheme.primary,
              inactiveColor: Colors.white38,
            ),
          ),
        ],
      ),
    );
  }
}

class _EffectButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _EffectButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onTap,
            style: ElevatedButton.styleFrom(
              shape: const CircleBorder(),
              padding: const EdgeInsets.all(20),
            ),
            child: const Icon(Icons.auto_awesome),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _EditorToolButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _EditorToolButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        width: 80,
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 30),
            const SizedBox(height: 8),
            Text(
              label,
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
