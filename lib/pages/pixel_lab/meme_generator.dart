// lib/widgets/pixel_lab/meme_generator.dart

import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/unity_ads_controller.dart';

// --- Data Models ---
class MemeText {
  String text;
  TextStyle style;
  Offset position;
  double rotation;
  Color strokeColor;
  double strokeWidth;

  MemeText({
    required this.text,
    required this.style,
    required this.position,
    this.rotation = 0.0,
    this.strokeColor = Colors.black,
    this.strokeWidth = 2.0,
  });
}

class MemeFrame {
  File? image;
  String? assetImage; // For templates
  Rect rect; // Relative rect (0.0 - 1.0)
  MemeFrame({this.image, this.assetImage, required this.rect});
}

// --- Layout Presets ---
enum MemeLayout {
  single, // 1 image full
  topBottom, // 2 images vertical
  sideBySide, // 2 images horizontal
  grid4, // 4 images grid
}

enum TextTool { none, font, color, stroke, size, rotate, keyboard }

class MemeGenerator extends StatefulWidget {
  const MemeGenerator({super.key});

  @override
  State<MemeGenerator> createState() => _MemeGeneratorState();
}

class _MemeGeneratorState extends State<MemeGenerator> {
  // State
  MemeLayout _currentLayout = MemeLayout.single;
  final List<MemeFrame> _frames = [];
  final List<MemeText> _texts = [];
  int? _selectedTextIndex;
  TextTool _activeTextTool = TextTool.none;

  final GlobalKey _repaintBoundaryKey = GlobalKey();
  final TextEditingController _textEditingController = TextEditingController();

  // Canvas size for scaling
  Size _canvasSize = const Size(300, 300);

  @override
  void initState() {
    super.initState();
    _updateLayout(MemeLayout.single);
    _textEditingController.addListener(() {
      if (_selectedTextIndex != null) {
        setState(() {
          _texts[_selectedTextIndex!].text = _textEditingController.text;
        });
      }
    });
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  // --- Logic ---

  void _updateLayout(MemeLayout layout) {
    setState(() {
      _currentLayout = layout;
      _frames.clear();
      switch (layout) {
        case MemeLayout.single:
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0, 0, 1, 1)));
          break;
        case MemeLayout.topBottom:
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0, 0, 1, 0.5)));
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0, 0.5, 1, 0.5)));
          break;
        case MemeLayout.sideBySide:
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0, 0, 0.5, 1)));
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0.5, 0, 0.5, 1)));
          break;
        case MemeLayout.grid4:
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0, 0, 0.5, 0.5)));
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0.5, 0, 0.5, 0.5)));
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0, 0.5, 0.5, 0.5)));
          _frames.add(MemeFrame(rect: const Rect.fromLTWH(0.5, 0.5, 0.5, 0.5)));
          break;
      }
    });
  }

  Future<void> _pickImage(int frameIndex) async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _frames[frameIndex].image = File(picked.path);
        _frames[frameIndex].assetImage = null; // clear template if any
      });
    }
  }

  void _addText() {
    setState(() {
      _texts.add(
        MemeText(
          text: 'TAP TO EDIT',
          style: GoogleFonts.aladin(
            fontSize: 40,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
          position: const Offset(50, 50),
        ),
      );
      _selectedTextIndex = _texts.length - 1;
      _activeTextTool = TextTool.none;
      _textEditingController.text = _texts.last.text;
    });
  }

  // --- UI Components ---

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Meme Generator'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_frames.any((f) => f.image != null || f.assetImage != null))
            IconButton(
              icon: const Icon(Icons.check, color: Colors.amberAccent),
              onPressed: _saveMeme,
              tooltip: "Save",
            ),
          if (_frames.any((f) => f.image != null || f.assetImage != null))
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareMeme,
              tooltip: "Share",
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: Stack(
          children: [
            // 1. Main Canvas Area
            Positioned.fill(
              bottom: 140, // Space for tools
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: AspectRatio(
                    aspectRatio: 1.0, // Square canvas for memes generally
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        // Update canvas size for relative positioning
                        WidgetsBinding.instance.addPostFrameCallback((_) {
                          if (_canvasSize != constraints.biggest) {
                            _canvasSize = constraints.biggest;
                          }
                        });

                        return RepaintBoundary(
                          key: _repaintBoundaryKey,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.5),
                                  blurRadius: 20,
                                ),
                              ],
                            ),
                            child: Stack(
                              children: [
                                ..._frames.asMap().entries.map(
                                  (e) => _buildFrame(
                                    e.key,
                                    e.value,
                                    constraints.biggest,
                                  ),
                                ),
                                ..._texts.asMap().entries.map(
                                  (e) => _buildText(e.key, e.value),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),

            // 2. Bottom Toolbar Area
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: _selectedTextIndex != null
                  ? _buildTextToolbar()
                  : _buildMainToolbar(),
            ),
          ],
        ),
      ),
    );
  }

  ImageProvider? _getFrameImage(MemeFrame frame) {
    if (frame.image != null) {
      return FileImage(frame.image!);
    } else if (frame.assetImage != null) {
      return AssetImage(frame.assetImage!);
    }
    return null;
  }

  Widget _buildFrame(int index, MemeFrame frame, Size size) {
    final imgProvider = _getFrameImage(frame);

    return Positioned(
      left: frame.rect.left * size.width,
      top: frame.rect.top * size.height,
      width: frame.rect.width * size.width,
      height: frame.rect.height * size.height,
      child: GestureDetector(
        onTap: () {
          // Deselect text when tapping background
          setState(() => _selectedTextIndex = null);
          _pickImage(index);
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            border: Border.all(color: Colors.white, width: 0.5),
            image: imgProvider != null
                ? DecorationImage(image: imgProvider, fit: BoxFit.cover)
                : null,
          ),
          child: imgProvider == null
              ? const Center(
                  child: Icon(
                    Icons.add_photo_alternate,
                    color: Colors.white24,
                    size: 40,
                  ),
                )
              : null,
        ),
      ),
    );
  }

  Widget _buildText(int index, MemeText memeText) {
    final isSelected = _selectedTextIndex == index;
    return Positioned(
      left: memeText.position.dx,
      top: memeText.position.dy,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedTextIndex = index;
            _textEditingController.text = memeText.text;
            _activeTextTool = TextTool.none; // Reset tool on select
          });
        },
        onPanUpdate: (details) {
          setState(() {
            _selectedTextIndex = index;
            memeText.position += details.delta;
          });
        },
        child: Container(
          decoration: isSelected
              ? BoxDecoration(border: Border.all(color: Colors.amber, width: 1))
              : null,
          padding: const EdgeInsets.all(4),
          child: Stack(
            children: [
              // Stroke Text (Background)
              Text(
                memeText.text,
                style: memeText.style.copyWith(
                  foreground: Paint()
                    ..style = PaintingStyle.stroke
                    ..strokeWidth = memeText.strokeWidth
                    ..color = memeText.strokeColor,
                ),
              ),
              // Fill Text (Foreground)
              Transform.rotate(
                angle: memeText.rotation,
                child: Text(memeText.text, style: memeText.style),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- Toolbars ---

  Widget _buildMainToolbar() {
    return Container(
      padding: const EdgeInsets.only(bottom: 20, top: 12),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildToolbarBtn(
              Icons.grid_view,
              "Layout",
              () => _showLayoutPicker(),
            ),
            _buildToolbarBtn(Icons.add_box, "Add Text", _addText),
            _buildToolbarBtn(
              Icons.burst_mode,
              "Templates",
              _showTemplatePicker,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextToolbar() {
    final memeText = _texts[_selectedTextIndex!];

    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.9),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Contextual Controls Panel
            if (_activeTextTool != TextTool.none)
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                color: Colors.white.withValues(alpha: 0.05),
                child: _buildActiveToolControls(memeText),
              ),

            // Text Tool Icons
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Row(
                children: [
                  const SizedBox(width: 8),
                  _buildTextToolIcon(
                    Icons.keyboard,
                    "Edit",
                    TextTool.keyboard,
                    isActive: _activeTextTool == TextTool.keyboard,
                  ),
                  _buildTextToolIcon(
                    Icons.font_download,
                    "Font",
                    TextTool.font,
                    isActive: _activeTextTool == TextTool.font,
                  ),
                  _buildTextToolIcon(
                    Icons.format_size,
                    "Size",
                    TextTool.size,
                    isActive: _activeTextTool == TextTool.size,
                  ),
                  _buildTextToolIcon(
                    Icons.color_lens,
                    "Color",
                    TextTool.color,
                    isActive: _activeTextTool == TextTool.color,
                  ),
                  _buildTextToolIcon(
                    Icons.border_color,
                    "Stroke",
                    TextTool.stroke,
                    isActive: _activeTextTool == TextTool.stroke,
                  ),
                  _buildTextToolIcon(
                    Icons.rotate_right,
                    "Rotate",
                    TextTool.rotate,
                    isActive: _activeTextTool == TextTool.rotate,
                  ),
                  Container(
                    height: 30,
                    width: 1,
                    color: Colors.white24,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () => setState(() {
                      _texts.removeAt(_selectedTextIndex!);
                      _selectedTextIndex = null;
                    }),
                  ),
                  IconButton(
                    icon: const Icon(Icons.check, color: Colors.white),
                    onPressed: () => setState(() => _selectedTextIndex = null),
                  ),
                  const SizedBox(width: 16),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActiveToolControls(MemeText memeText) {
    switch (_activeTextTool) {
      case TextTool.keyboard:
        return TextField(
          controller: _textEditingController,
          autofocus: true,
          style: const TextStyle(color: Colors.white),
          decoration: const InputDecoration(
            hintText: "Enter Text",
            hintStyle: TextStyle(color: Colors.white54),
            border: InputBorder.none,
          ),
          onSubmitted: (_) {
            FocusScope.of(context).unfocus();
            setState(() => _activeTextTool = TextTool.none);
          },
        );
      case TextTool.size:
        return Row(
          children: [
            const Text("Size", style: TextStyle(color: Colors.white)),
            Expanded(
              child: Slider(
                value: memeText.style.fontSize ?? 20,
                min: 10,
                max: 100,
                activeColor: Colors.amber,
                onChanged: (v) => setState(
                  () => memeText.style = memeText.style.copyWith(fontSize: v),
                ),
              ),
            ),
            Text(
              (memeText.style.fontSize ?? 20).toInt().toString(),
              style: const TextStyle(color: Colors.white),
            ),
          ],
        );
      case TextTool.rotate:
        return Row(
          children: [
            const Text("Angle", style: TextStyle(color: Colors.white)),
            Expanded(
              child: Slider(
                value: memeText.rotation,
                min: -3.14,
                max: 3.14,
                activeColor: Colors.amber,
                onChanged: (v) => setState(() => memeText.rotation = v),
              ),
            ),
          ],
        );
      case TextTool.stroke:
        return Column(
          children: [
            Row(
              children: [
                const Text("Width", style: TextStyle(color: Colors.white)),
                Expanded(
                  child: Slider(
                    value: memeText.strokeWidth,
                    min: 0,
                    max: 10,
                    activeColor: Colors.amber,
                    onChanged: (v) => setState(() => memeText.strokeWidth = v),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            _buildColorRow((c) => setState(() => memeText.strokeColor = c)),
          ],
        );
      case TextTool.color:
        return _buildColorRow(
          (c) => setState(
            () => memeText.style = memeText.style.copyWith(color: c),
          ),
        );
      case TextTool.font:
        // Simple font switcher for demo
        return SizedBox(
          height: 40,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _buildFontBtn("Inter", GoogleFonts.inter(), memeText),
              _buildFontBtn("Aladin", GoogleFonts.aladin(), memeText),
              _buildFontBtn("Roboto", GoogleFonts.roboto(), memeText),
              _buildFontBtn("Lato", GoogleFonts.lato(), memeText),
              _buildFontBtn("Oswald", GoogleFonts.oswald(), memeText),
            ],
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildFontBtn(String name, TextStyle font, MemeText memeText) {
    final isSelected = memeText.style.fontFamily == font.fontFamily;
    return GestureDetector(
      onTap: () => setState(
        () => memeText.style = font.copyWith(
          fontSize: memeText.style.fontSize,
          color: memeText.style.color,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        margin: const EdgeInsets.only(right: 8),
        decoration: BoxDecoration(
          color: isSelected ? Colors.amber : Colors.white10,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          name,
          style: TextStyle(
            color: isSelected ? Colors.black : Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildColorRow(ValueChanged<Color> onSelect) {
    final colors = [
      Colors.white,
      Colors.black,
      Colors.red,
      Colors.blue,
      Colors.green,
      Colors.yellow,
      Colors.purple,
    ];
    return SizedBox(
      height: 40,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: colors
            .map(
              (c) => GestureDetector(
                onTap: () => onSelect(c),
                child: Container(
                  width: 30,
                  height: 30,
                  margin: const EdgeInsets.only(right: 12),
                  decoration: BoxDecoration(
                    color: c,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white24),
                  ),
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  Widget _buildToolbarBtn(IconData icon, String label, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 28),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(color: Colors.white70, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildTextToolIcon(
    IconData icon,
    String label,
    TextTool tool, {
    bool isActive = false,
  }) {
    return InkWell(
      onTap: () {
        setState(() {
          _activeTextTool = (_activeTextTool == tool) ? TextTool.none : tool;
        });
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isActive ? Colors.amber : Colors.white, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? Colors.amber : Colors.white70,
                fontSize: 10,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Logic Helpers ---

  void _showLayoutPicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.grey[900],
          borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Select Layout",
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildLayoutOption(
                  Icons.crop_square,
                  "Single",
                  MemeLayout.single,
                ),
                _buildLayoutOption(
                  Icons.view_agenda,
                  "Vertical",
                  MemeLayout.topBottom,
                ),
                _buildLayoutOption(
                  Icons.view_column,
                  "Side",
                  MemeLayout.sideBySide,
                ),
                _buildLayoutOption(Icons.grid_view, "Grid", MemeLayout.grid4),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLayoutOption(IconData icon, String label, MemeLayout layout) {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
        _updateLayout(layout);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _currentLayout == layout ? Colors.amber : Colors.white10,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: _currentLayout == layout ? Colors.black : Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: Colors.white70)),
        ],
      ),
    );
  }

  Future<void> _showTemplatePicker() async {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        builder: (_, controller) => Container(
          decoration: BoxDecoration(
            color: Colors.grey[900],
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextField(
                  style: const TextStyle(color: Colors.white),
                  decoration: InputDecoration(
                    hintText: "Search templates...",
                    hintStyle: const TextStyle(color: Colors.white54),
                    prefixIcon: const Icon(Icons.search, color: Colors.white54),
                    filled: true,
                    fillColor: Colors.white.withValues(alpha: 0.1),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  onChanged: (val) {
                    // Implement filtering would require state inside the modal or parent.
                    // Leaving as placeholder for simplicity unless requested.
                  },
                ),
              ),
              Expanded(
                child: FutureBuilder<List<String>>(
                  future: _loadTemplateAssets(),
                  builder: (context, snapshot) {
                    if (!snapshot.hasData) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final templates = snapshot.data!;
                    if (templates.isEmpty) {
                      return Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.broken_image,
                            color: Colors.white54,
                            size: 48,
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            "No templates found.",
                            style: TextStyle(color: Colors.white54),
                          ),
                          const SizedBox(height: 8),
                          const Padding(
                            padding: EdgeInsets.symmetric(horizontal: 32),
                            child: Text(
                              "Ensure you have restarted the app after adding assets.",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.white24,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      );
                    }

                    return GridView.builder(
                      controller: controller,
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            crossAxisSpacing: 8,
                            mainAxisSpacing: 8,
                          ),
                      itemCount: templates.length,
                      itemBuilder: (context, index) {
                        return GestureDetector(
                          onTap: () {
                            // Use this template
                            Navigator.pop(context);
                            setState(() {
                              // Reset to single layout
                              _updateLayout(MemeLayout.single);
                              _frames[0].assetImage = templates[index];
                              _frames[0].image = null;
                            });
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.asset(
                              templates[index],
                              fit: BoxFit.cover,
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<List<String>> _loadTemplateAssets() async {
    try {
      final manifest = await AssetManifest.loadFromAssetBundle(rootBundle);
      final templatePaths = manifest
          .listAssets()
          .where((String key) => key.contains('assets/templates/'))
          .toList();

      return templatePaths;
    } catch (e) {
      print("Error loading templates: $e");
      return [];
    }
  }

  Future<Uint8List?> _captureMeme() async {
    // Deselect for capture
    setState(() => _selectedTextIndex = null);
    await Future.delayed(const Duration(milliseconds: 100)); // Wait for rebuild

    try {
      final boundary =
          _repaintBoundaryKey.currentContext?.findRenderObject()
              as RenderRepaintBoundary?;
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
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      final imageBytes = await _captureMeme();
      if (imageBytes == null) return;

      try {
        final tempDir = await getTemporaryDirectory();
        final file = await File('${tempDir.path}/meme_output.png').create();
        await file.writeAsBytes(imageBytes);
        await Gal.putImage(file.path);
        // Add to history
        Get.find<HistoryController>().addHistoryItem(file, HistoryType.meme);
        showSuccessSnackkbar(message: "Meme saved to gallery!");
      } catch (e) {
        showErrorSnackkbar(message: "Failed to save meme: $e");
      }
    });
  }

  Future<void> _shareMeme() async {
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      final imageBytes = await _captureMeme();
      if (imageBytes == null) return;

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/meme_share.png').create();
      await file.writeAsBytes(imageBytes);

      await SharePlus.instance.share(
        ShareParams(
          files: [XFile(file.path)],
          text: 'Check out this meme I made!',
        ),
      );
    });
  }
}
