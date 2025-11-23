// lib/widgets/pixel_lab/meme_generator.dart
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart' as ui;
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:get/get_core/src/get_main.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';

class MemeText {
  int id;
  String text;
  Offset position;
  double scale;
  double rotation;
  TextStyle style;
  Color strokeColor;
  double strokeWidth;

  MemeText({
    required this.id,
    required this.text,
    required this.position,
    this.scale = 1.0,
    this.rotation = 0.0,
    required this.style,
    this.strokeColor = Colors.black,
    this.strokeWidth = 3.0,
  });
}

class Frame {
  File? image;
  final TransformationController controller = TransformationController();

  Frame({this.image});
}

enum FrameLayout { single, twoVertical, twoHorizontal }

const Map<String, String> memeTemplates = {
  'Doge': 'assets/templates/doge.jpg',
  'Distracted Boyfriend': 'assets/templates/distracted.jpg',
  'Drake': 'assets/templates/drake.jpg',
  'Two Buttons': 'assets/templates/two_buttons.png',
  'Expanding Brain': 'assets/templates/expanded_brain.png',
  'Change My Mind': 'assets/templates/change_my_mind.png',
  'Surprised Pikachu': 'assets/templates/surprised_pikachu.png',
  'Success Kid': 'assets/templates/success_kid.jpg',
  'Laughing Leo': 'assets/templates/leo_debunk.png',
  'Angry Women Yelling at Cat': 'assets/templates/women_yelling_at_cat.png',
  'Hide The pain Harold': 'assets/templates/hide_the_pain.png',
  'Happy/Shock': 'assets/templates/happy_shock.jpg',
  'Leo Cheers': 'assets/templates/leo_cheers.png',
  'Success Kid Vertical': 'assets/templates/success_kid.jpg',
  'Leo Pointing': 'assets/templates/leo_pointing.png',
  'Sad Pablo': 'assets/templates/sad_pablo.png',
  'Three Dragons': 'assets/templates/three_dragon.png',
};

final Map<String, TextStyle> appFonts = {
  'Anton': GoogleFonts.anton(),
  'Oswald': GoogleFonts.oswald(),
  'BebasNeue': GoogleFonts.bebasNeue(),
  'Bangers': GoogleFonts.bangers(),
  'LuckiestGuy': GoogleFonts.luckiestGuy(),
  'FjallaOne': GoogleFonts.fjallaOne(),
  'ArchivoBlack': GoogleFonts.archivoBlack(),
  'BlackOpsOne': GoogleFonts.blackOpsOne(),
  'Teko': GoogleFonts.teko(),
  'ChangaOne': GoogleFonts.changaOne(),
  'PatuaOne': GoogleFonts.patuaOne(),
  // fallback
  'ImpactLike': GoogleFonts.poppins(fontWeight: FontWeight.w900),
};

class MemeGenerator extends StatefulWidget {
  const MemeGenerator({super.key});

  @override
  State<MemeGenerator> createState() => _MemeGeneratorState();
}

class _MemeGeneratorState extends State<MemeGenerator> {
  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final List<MemeText> _texts = [];
  int? _selectedTextIndex;
  int _nextTextId = 0;

  List<Frame> _frames = [Frame()];
  FrameLayout _layout = FrameLayout.single;

  // For gesture handling
  double _gestureStartScale = 1.0;
  double _gestureStartRotation = 0.0;
  late TextEditingController _textEditingController;

  @override
  void dispose() {
    for (var f in _frames) {
      f.controller.dispose();
    }
    super.dispose();
    _textEditingController.dispose();
  }

  @override
  void initState() {
    super.initState();
    _textEditingController = TextEditingController();
    _textEditingController.addListener(() {
      _onScreenTextEdit();
    });
  }

  Future<void> _pickImage([int frameIndex = 0]) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      final file = File(picked.path);
      setState(() {
        while (_frames.length <= frameIndex) _frames.add(Frame());
        _frames[frameIndex].image = file;
        // Add default texts only if there are none
        if (_texts.isEmpty &&
            _frames.where((f) => f.image != null).length == 1) {
          _addText(text: "TOP TEXT", position: const Offset(60, 30));
          _addText(text: "BOTTOM TEXT", position: const Offset(60, 300));
        }
      });
    }
  }

  void _addText({
    String text = "NEW TEXT",
    Offset position = const Offset(100, 100),
  }) {
    final baseStyle =
        appFonts['Anton']?.copyWith(color: Colors.white, fontSize: 40) ??
        TextStyle(
          color: Colors.white,
          fontSize: 40,
          fontWeight: FontWeight.bold,
        );
    setState(() {
      _texts.add(
        MemeText(
          id: _nextTextId++,
          text: text,
          position: position,
          style: baseStyle,
        ),
      );
      _selectedTextIndex = _texts.length - 1;
    });
  }

  void _onScreenTextEdit() {
    if (_selectedTextIndex != null && _selectedTextIndex! < _texts.length) {
      final currentText = _texts[_selectedTextIndex!];
      if (currentText.text != _textEditingController.text) {
        setState(() {
          currentText.text = _textEditingController.text;
        });
      }
    }
  }

  Widget _buildFrame(int frameIndex) {
    return GestureDetector(
      onTap: () {
        // Tapping a frame allows picking an image for it
        if (_frames[frameIndex].image == null) {
          _pickImage(frameIndex);
        } else {
          setState(() => _selectedTextIndex = null);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white24, width: 1),
          borderRadius: BorderRadius.circular(6),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: _frames[frameIndex].image == null
              ? Container(
                  color: Colors.black12,
                  child: const Center(
                    child: Icon(
                      Icons.add_a_photo,
                      color: Colors.white54,
                      size: 48,
                    ),
                  ),
                )
              : InteractiveViewer(
                  transformationController: _frames[frameIndex].controller,
                  minScale: 0.5,
                  maxScale: 5.0,
                  child: Image.file(
                    _frames[frameIndex].image!,
                    fit: BoxFit.cover,
                  ),
                ),
        ),
      ),
    );
  }

  Widget _buildFrameLayout() {
    switch (_layout) {
      case FrameLayout.single:
        return _buildFrame(0);
      case FrameLayout.twoVertical:
        return Column(
          children: [
            Expanded(child: _buildFrame(0)),
            const SizedBox(height: 6),
            Expanded(child: _buildFrame(1)),
          ],
        );
      case FrameLayout.twoHorizontal:
        return Row(
          children: [
            Expanded(child: _buildFrame(0)),
            const SizedBox(width: 6),
            Expanded(child: _buildFrame(1)),
          ],
        );
    }
  }

  Widget _buildMemeTextWidget(MemeText memeText, int index) {
    final isSelected = index == _selectedTextIndex;
    return GestureDetector(
      onTap: () {
        setState(() {
          _selectedTextIndex = index;
          _textEditingController.text = memeText.text;
        });
      },
      onScaleStart: (_) {
        setState(() => _selectedTextIndex = index);
        _textEditingController.text = memeText.text;
        _gestureStartScale = memeText.scale;
        _gestureStartRotation = memeText.rotation;
      },
      onScaleUpdate: (details) {
        setState(() {
          // Panning (moving the text)
          memeText.position += details.focalPointDelta;
          // Scaling
          memeText.scale = (_gestureStartScale * details.scale).clamp(
            0.2,
            10.0,
          );
          // Rotation
          memeText.rotation = _gestureStartRotation + details.rotation;
        });
      },
      child: Transform.rotate(
        angle: memeText.rotation,
        child: Transform.scale(
          scale: memeText.scale,
          child: Opacity(
            opacity: isSelected ? 1.0 : 0.95,
            child: Stack(
              children: [
                // stroke (outline)
                Text(
                  memeText.text,
                  textAlign: TextAlign.center,
                  style: memeText.style.copyWith(
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = memeText.strokeWidth
                      ..color = memeText.strokeColor,
                  ),
                ),
                // fill
                Text(
                  memeText.text,
                  textAlign: TextAlign.center,
                  style: memeText.style,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _showFontPicker(MemeText memeText) async {
    final selected = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: appFonts.entries.map((entry) {
            return ListTile(
              title: Text(entry.key, style: entry.value.copyWith(fontSize: 20)),
              onTap: () => Navigator.pop(context, entry.key),
            );
          }).toList(),
        ),
      ),
    );

    if (selected != null && appFonts.containsKey(selected)) {
      setState(() {
        final oldSize = memeText.style.fontSize ?? 40;
        final oldColor = memeText.style.color ?? Colors.white;
        memeText.style = appFonts[selected]!.copyWith(
          fontSize: oldSize,
          color: oldColor,
        );
      });
    }
  }

  void _showLayoutPicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.check_box_outline_blank),
            title: const Text('Single Frame'),
            onTap: () {
              Navigator.pop(context);
              _updateLayout(FrameLayout.single);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_agenda_outlined),
            title: const Text('Two Frames (Vertical)'),
            onTap: () {
              Navigator.pop(context);
              _updateLayout(FrameLayout.twoVertical);
            },
          ),
          ListTile(
            leading: const Icon(Icons.view_column_outlined),
            title: const Text('Two Frames (Horizontal)'),
            onTap: () {
              Navigator.pop(context);
              _updateLayout(FrameLayout.twoHorizontal);
            },
          ),
        ],
      ),
    );
  }

  void _updateLayout(FrameLayout newLayout) {
    setState(() {
      _layout = newLayout;
      int requiredFrames = (newLayout == FrameLayout.single) ? 1 : 2;
      while (_frames.length < requiredFrames) _frames.add(Frame());
      while (_frames.length > requiredFrames) _frames.removeLast();
    });
  }

  void _showTemplatePicker() async {
    final selectedTemplate = await showModalBottomSheet<String>(
      context: context,
      builder: (context) => SafeArea(
        child: ListView(
          shrinkWrap: true,
          children: memeTemplates.entries.map((entry) {
            return ListTile(
              leading: Image.asset(
                entry.value,
                width: 60,
                height: 40,
                fit: BoxFit.cover,
              ),
              title: Text(entry.key),
              onTap: () => Navigator.pop(context, entry.value),
            );
          }).toList(),
        ),
      ),
    );

    if (selectedTemplate != null) {
      final byteData = await DefaultAssetBundle.of(
        context,
      ).load(selectedTemplate);
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/${selectedTemplate.split('/').last}');
      await file.writeAsBytes(byteData.buffer.asUint8List());
      setState(() {
        if (_layout != FrameLayout.single) _updateLayout(FrameLayout.single);
        _frames[0].image = file;
        if (_texts.isEmpty) {
          _addText(text: "TOP TEXT", position: const Offset(60, 30));
          _addText(text: "BOTTOM TEXT", position: const Offset(60, 300));
        }
      });
    }
  }

  Widget _buildMainToolbar() {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 6),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            IconButton(
              icon: const Icon(Icons.add_comment),
              onPressed: _addText,
              tooltip: 'Add Text',
            ),
            IconButton(
              icon: const Icon(Icons.view_quilt),
              onPressed: _showLayoutPicker,
              tooltip: 'Change Layout',
            ),
            IconButton(
              icon: const Icon(Icons.burst_mode),
              onPressed: _showTemplatePicker,
              tooltip: 'Templates',
            ),
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveMeme,
              tooltip: 'Save',
            ),
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareMeme,
              tooltip: 'Share',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextControls() {
    if (_selectedTextIndex == null) return const SizedBox.shrink();
    final memeText = _texts[_selectedTextIndex!];

    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.surface.withOpacity(0.06),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                IconButton(
                  icon: Icon(Icons.font_download, color: Colors.white),
                  onPressed: () => _showFontPicker(memeText),
                  tooltip: 'Change Font',
                ),
                IconButton(
                  icon: Icon(Icons.color_lens, color: memeText.style.color),
                  onPressed: () => _pickColor(memeText, isStroke: false),
                  tooltip: 'Fill Color',
                ),
                IconButton(
                  icon: Icon(
                    Icons.colorize_rounded,
                    color: memeText.strokeColor,
                  ),
                  onPressed: () => _pickColor(memeText, isStroke: true),
                  tooltip: 'Stroke Color',
                ),
                IconButton(
                  icon: Icon(
                    Icons.swap_horiz,
                    color: Get.context?.theme.colorScheme.onPrimary,
                  ),
                  onPressed: () {
                    // toggle fill/stroke color quick swap
                    setState(() {
                      final tmp = memeText.style.color;
                      memeText.style = memeText.style.copyWith(
                        color: memeText.strokeColor,
                      );
                      memeText.strokeColor = tmp ?? Colors.black;
                    });
                  },
                  tooltip: 'Swap Fill/Stroke',
                ),
                const Spacer(),
                IconButton(
                  icon: const Icon(Icons.delete, color: Colors.redAccent),
                  onPressed: () {
                    setState(() {
                      _texts.removeAt(_selectedTextIndex!);
                      _selectedTextIndex = null;
                    });
                  },
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 4.0,
              ),
              child: TextField(
                controller: _textEditingController,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, fontSize: 18),
                decoration: InputDecoration(
                  hintText: 'Edit text here...',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5)),
                  border: const UnderlineInputBorder(
                    borderSide: BorderSide(color: Colors.white54),
                  ),
                ),
              ),
            ),
            _buildSliderRow(
              label: 'Size',
              value: memeText.style.fontSize ?? 40,
              min: 8,
              max: 200,
              onChanged: (v) => setState(
                () => memeText.style = memeText.style.copyWith(fontSize: v),
              ),
            ),
            _buildSliderRow(
              label: 'Stroke',
              value: memeText.strokeWidth,
              min: 0,
              max: 12,
              onChanged: (v) => setState(() => memeText.strokeWidth = v),
            ),
            _buildSliderRow(
              label: 'Rotate',
              value: memeText.rotation,
              min: -3.14,
              max: 3.14,
              onChanged: (v) => setState(() => memeText.rotation = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSliderRow({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Row(
      children: [
        SizedBox(
          width: 64,
          child: Text(
            label,
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
        Expanded(
          child: Slider(
            value: value,
            min: min,
            max: max,
            label: value.toStringAsFixed(1),
            onChanged: onChanged,
          ),
        ),
      ],
    );
  }

  void _pickColor(MemeText memeText, {required bool isStroke}) {
    final initialColor = isStroke
        ? memeText.strokeColor
        : (memeText.style.color ?? Colors.white);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Pick a color'),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: initialColor,
            onColorChanged: (color) {
              setState(() {
                if (isStroke) {
                  memeText.strokeColor = color;
                } else {
                  memeText.style = memeText.style.copyWith(color: color);
                }
              });
            },
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

  Future<Uint8List?> _captureMeme() async {
    // Deselect text to hide controls before capture
    setState(() => _selectedTextIndex = null);
    await Future.delayed(const Duration(milliseconds: 50));

    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as ui.RenderRepaintBoundary?;
      if (boundary == null) return null;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      return byteData?.buffer.asUint8List();
    } catch (e) {
      showErrorSnackkbar(message: "Failed to capture meme: $e");
      return null;
    }
  }

  Future<void> _saveMeme() async {
    final imageBytes = await _captureMeme();
    if (imageBytes == null) return;

    try {
      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/meme_output.png').create();
      await file.writeAsBytes(imageBytes);
      await Gal.putImage(file.path);
      showSuccessSnackkbar(message: "Meme saved to gallery!");
    } catch (e) {
      showErrorSnackkbar(message: "Failed to save meme: $e");
    }
  }

  Future<void> _shareMeme() async {
    final imageBytes = await _captureMeme();
    if (imageBytes == null) return;

    final tempDir = await getTemporaryDirectory();
    final file = await File('${tempDir.path}/meme_share.png').create();
    await file.writeAsBytes(imageBytes);

    await Share.shareXFiles([
      XFile(file.path),
    ], text: 'Check out this meme I made!');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Meme Generator'),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),
        ),
        actions: [
          if (_frames.any((f) => f.image != null))
            IconButton(icon: const Icon(Icons.save_alt), onPressed: _saveMeme),
          if (_frames.any((f) => f.image != null))
            IconButton(icon: const Icon(Icons.share), onPressed: _shareMeme),
        ],
      ),
      body: _frames.every((f) => f.image == null)
          ? _buildImagePickerPrompt()
          : Container(
              decoration: BoxDecoration(gradient: AppTheme.gradient),
              child: Column(
                children: [
                  Expanded(
                    child: SafeArea(
                      child: Center(
                        child: RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: Container(
                            margin: const EdgeInsets.all(12),
                            padding: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: Colors.black,
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Stack(
                              children: [
                                // Frame layout area
                                Positioned.fill(child: _buildFrameLayout()),
                                // Draggable texts
                                ..._texts.asMap().entries.map((entry) {
                                  final index = entry.key;
                                  final t = entry.value;
                                  return Positioned(
                                    left: t.position.dx,
                                    top: t.position.dy,
                                    child: _buildMemeTextWidget(t, index),
                                  );
                                }).toList(),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  if (_selectedTextIndex != null)
                    _buildTextControls()
                  else
                    _buildMainToolbar(),
                ],
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _pickImage(0),
        tooltip: 'Pick Image',
        child: const Icon(Icons.photo_library),
      ),
    );
  }

  Widget _buildImagePickerPrompt() {
    return Container(
      decoration: BoxDecoration(gradient: AppTheme.gradient),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.photo, size: 80, color: Colors.white70),
            const SizedBox(height: 16),
            const Text(
              'No Image Selected',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tap the button below or choose a template.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _pickImage(0),
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
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _showTemplatePicker,
              icon: const Icon(Icons.burst_mode, color: Colors.white),
              label: const Text(
                'Use a Template',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
