// lib/widgets/pixel_lab/id_photo_maker.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';
import '../../controllers/history_controller.dart';
import '../../controllers/unity_ads_controller.dart';

import '../../models/id_photo_spec.dart';

// A map of standard ID photo specifications
class IDPhotoMaker extends StatefulWidget {
  final File? image;
  const IDPhotoMaker({this.image, super.key});

  @override
  State<IDPhotoMaker> createState() => _IDPhotoMakerState();
}

class _IDPhotoMakerState extends State<IDPhotoMaker>
    with SingleTickerProviderStateMixin {
  File? _image;
  final _imageKey = GlobalKey();

  // --- State ---
  final TransformationController _transformationController =
      TransformationController();
  IdPhotoSpec _selectedSpec = idPhotoSpecs.first;
  PaperSize _selectedPaper = paperSizes.first;
  IdPhotoSpec _customSpec = idPhotoSpecs.firstWhere(
    (spec) => spec.name.startsWith('Custom'),
  );
  late TextEditingController _customWidthController;
  late TextEditingController _customHeightController;
  PaperSize _customPaper = paperSizes.firstWhere(
    (p) => p.name.startsWith('Custom'),
  );
  late TextEditingController _customPaperWidthController;
  late TextEditingController _customPaperHeightController;

  // New Controller for Quantity
  final TextEditingController _quantityController = TextEditingController();

  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _image = widget.image;
    if (_image == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _pickImage());
    }
    _customWidthController = TextEditingController(
      text: _customSpec.widthMM.toString(),
    );
    _customHeightController = TextEditingController(
      text: _customSpec.heightMM.toString(),
    );

    _customWidthController.addListener(_updateCustomSpec);
    _customHeightController.addListener(_updateCustomSpec);

    _customPaperWidthController = TextEditingController(
      text: _customPaper.widthMM.toString(),
    );
    _customPaperHeightController = TextEditingController(
      text: _customPaper.heightMM.toString(),
    );

    _customPaperWidthController.addListener(_updateCustomPaperSpec);
    _customPaperHeightController.addListener(_updateCustomPaperSpec);

    // Listen to quantity changes to refresh UI
    _quantityController.addListener(() {
      setState(() {});
    });
  }

  void _updateCustomSpec() {
    final width = double.tryParse(_customWidthController.text) ?? 0;
    final height = double.tryParse(_customHeightController.text) ?? 0;
    setState(() {
      _customSpec = IdPhotoSpec(
        name: 'Custom',
        widthMM: width,
        heightMM: height,
      );
    });
  }

  void _updateCustomPaperSpec() {
    final width = double.tryParse(_customPaperWidthController.text) ?? 0;
    final height = double.tryParse(_customPaperHeightController.text) ?? 0;
    setState(() {
      _customPaper = PaperSize(
        name: 'Custom',
        widthMM: width,
        heightMM: height,
        pdfPageFormat: PdfPageFormat(
          width * PdfPageFormat.mm,
          height * PdfPageFormat.mm,
        ),
      );
    });
  }

  @override
  void dispose() {
    _transformationController.dispose();
    _customWidthController.dispose();
    _customHeightController.dispose();
    _customPaperWidthController.dispose();
    _customPaperHeightController.dispose();
    _quantityController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("ID Photo Maker"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.photo_library, color: Colors.white),
            onPressed: _pickImage,
            tooltip: 'Change Image',
          ),
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.save_alt, color: Colors.amberAccent),
              onPressed: _saveSheet,
              tooltip: 'Save Sheet',
            ),
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: _shareSheet,
              tooltip: 'Share Sheet',
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(gradient: AppTheme.gradient),
        child: _image == null
            ? _buildImagePickerPrompt()
            : Column(
                children: [
                  // 1. Preview Area (Expanded)
                  Expanded(
                    child: Center(
                      child: Padding(
                        padding: const EdgeInsets.only(
                          top: 80,
                          bottom: 20,
                          left: 20,
                          right: 20,
                        ),
                        child: _tabController.index == 2
                            ? _buildSheetPreview() // Show full sheet preview in Layout tab
                            : _buildSinglePhotoPreview(), // Show single photo cropping in other tabs
                      ),
                    ),
                  ),

                  // 2. Controls Area (Bottom Panel)
                  _buildBottomPanel(),
                ],
              ),
      ),
    );
  }

  Widget _buildSinglePhotoPreview() {
    return AspectRatio(
      aspectRatio: _isCustomSelected()
          ? (_customSpec.heightMM > 0 ? _customSpec.aspectRatio : 1.0)
          : _selectedSpec.aspectRatio,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRect(
          child: InteractiveViewer(
            key: _imageKey,
            transformationController: _transformationController,
            minScale: 0.5,
            maxScale: 5.0,
            child: Image.file(_image!, fit: BoxFit.cover),
          ),
        ),
      ),
    );
  }

  Widget _buildBottomPanel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.85),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
        ),
      ),
      child: SafeArea(
        // Ensure it respects bottom safe area
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TabBar(
              controller: _tabController,
              indicatorColor: Colors.amber,
              labelColor: Colors.amber,
              unselectedLabelColor: Colors.white54,
              onTap: (_) => setState(() {}), // Rebuild to toggle preview mode
              tabs: const [
                Tab(icon: Icon(Icons.aspect_ratio), text: "Size"),
                Tab(icon: Icon(Icons.description), text: "Paper"),
                Tab(icon: Icon(Icons.grid_view), text: "Layout"),
              ],
            ),
            SizedBox(
              height: 220, // Fixed height for controls
              child: TabBarView(
                controller: _tabController,
                physics:
                    const NeverScrollableScrollPhysics(), // Prevent swiping to avoid conflict with sliders
                children: [
                  _buildSizeControls(),
                  _buildPaperControls(),
                  _buildLayoutControls(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSizeControls() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<IdPhotoSpec>(
          decoration: InputDecoration(
            labelText: "Select Standard",
            labelStyle: const TextStyle(color: Colors.amber),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
          ),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          initialValue: _selectedSpec,
          items: idPhotoSpecs
              .map(
                (spec) => DropdownMenuItem(
                  value: spec,
                  child: Text(
                    spec.name,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
              .toList(),
          onChanged: (spec) {
            if (spec != null) {
              setState(() {
                _selectedSpec = spec;
                if (_isCustomSelected()) {
                  _customWidthController.text = _customSpec.widthMM.toString();
                  _customHeightController.text = _customSpec.heightMM
                      .toString();
                }
              });
            }
          },
        ),
        if (_isCustomSelected())
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildDarkTextField(
                    controller: _customWidthController,
                    label: "Width (mm)",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDarkTextField(
                    controller: _customHeightController,
                    label: "Height (mm)",
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildPaperControls() {
    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DropdownButtonFormField<PaperSize>(
          decoration: InputDecoration(
            labelText: "Paper Size",
            labelStyle: const TextStyle(color: Colors.amber),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha: 0.3),
              ),
            ),
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white.withValues(alpha: 0.05),
          ),
          dropdownColor: Colors.grey[900],
          style: const TextStyle(color: Colors.white),
          initialValue: _selectedPaper,
          items: paperSizes
              .map(
                (paper) =>
                    DropdownMenuItem(value: paper, child: Text(paper.name)),
              )
              .toList(),
          onChanged: (paper) {
            if (paper != null) setState(() => _selectedPaper = paper);
          },
        ),
        if (_isCustomPaperSelected())
          Padding(
            padding: const EdgeInsets.only(top: 16.0),
            child: Row(
              children: [
                Expanded(
                  child: _buildDarkTextField(
                    controller: _customPaperWidthController,
                    label: "Width (mm)",
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildDarkTextField(
                    controller: _customPaperHeightController,
                    label: "Height (mm)",
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildLayoutControls() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          _buildDarkTextField(
            controller: _quantityController,
            label: "Quantity (Leave empty to fill page)",
            icon: Icons.grid_on,
          ),
          const SizedBox(height: 20),
          const Text(
            "Preview above showing how photos fit on the page.",
            style: TextStyle(color: Colors.white54, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildDarkTextField({
    required TextEditingController controller,
    required String label,
    IconData? icon,
  }) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white70),
        prefixIcon: icon != null ? Icon(icon, color: Colors.white54) : null,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.3)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Colors.amber),
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.05),
      ),
    );
  }

  Future<void> _pickImage() async {
    final picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (picked != null) {
      setState(() {
        _image = File(picked.path);
        _transformationController.value = Matrix4.identity();
      });
    }
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
            onPressed: () => _pickImage,
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

  bool _isCustomSelected() => _selectedSpec.name.startsWith('Custom');
  bool _isCustomPaperSelected() => _selectedPaper.name.startsWith('Custom');

  Widget _buildSheetPreview() {
    final paper = _isCustomPaperSelected() ? _customPaper : _selectedPaper;
    return AspectRatio(
      aspectRatio: paper.heightMM > 0 ? paper.aspectRatio : 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 15,
            ),
          ],
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final (cols, rows) = _calculateLayout();
            final maxItems = cols * rows;
            // Parse quantity
            int reqCount = int.tryParse(_quantityController.text) ?? 0;
            if (reqCount <= 0 || reqCount > maxItems) {
              reqCount = maxItems;
            }

            return Padding(
              padding: const EdgeInsets.all(8), // UI margin preview
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  childAspectRatio: _isCustomSelected()
                      ? (_customSpec.heightMM > 0
                            ? _customSpec.aspectRatio
                            : 1.0)
                      : _selectedSpec.aspectRatio,
                ),
                itemCount: reqCount,
                itemBuilder: (context, index) {
                  return Container(
                    margin: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: Colors.grey.shade300,
                        width: 0.5,
                      ),
                      image: DecorationImage(
                        image: FileImage(_image!),
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  (int, int) _calculateLayout() {
    final spec = _isCustomSelected() ? _customSpec : _selectedSpec;
    final paper = _isCustomPaperSelected() ? _customPaper : _selectedPaper;
    final paperWidth = paper.widthMM;
    final paperHeight = paper.heightMM;
    final photoWidth = spec.widthMM > 0 ? spec.widthMM : 1.0;
    final photoHeight = spec.heightMM > 0 ? spec.heightMM : 1.0;

    final cols = (paperWidth / photoWidth).floor();
    final rows = (paperHeight / photoHeight).floor();

    return (cols, rows);
  }

  Future<Uint8List> _generatePdfBytes() async {
    final pdf = pw.Document();
    final imageBytes = await _image!.readAsBytes();
    final pdfImage = pw.MemoryImage(imageBytes);
    final spec = _isCustomSelected() ? _customSpec : _selectedSpec;
    final paper = _isCustomPaperSelected() ? _customPaper : _selectedPaper;

    final (cols, rows) = _calculateLayout();
    final maxItems = cols * rows;

    // Parse quantity logic for PDF
    int reqCount = int.tryParse(_quantityController.text) ?? 0;
    if (reqCount <= 0 || reqCount > maxItems) {
      reqCount = maxItems;
    }

    pdf.addPage(
      pw.Page(
        pageFormat: paper.pdfPageFormat,
        build: (pw.Context context) {
          return pw.GridView(
            crossAxisCount: cols,
            childAspectRatio: spec.heightMM > 0 ? spec.aspectRatio : 1.0,
            children: List.generate(
              reqCount,
              (index) => pw.Image(pdfImage, fit: pw.BoxFit.cover),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _saveSheet() async {
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      final pdfBytes = await _generatePdfBytes();
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/id_photo_sheet.pdf',
      ).writeAsBytes(pdfBytes);

      try {
        await Gal.putImage(_image!.path);
        showSuccessSnackkbar(
          message: "Single photo saved. Use 'Share' for full PDF.",
        );
        // Add to history
        Get.find<HistoryController>().addHistoryItem(file, HistoryType.id);
      } catch (e) {
        showErrorSnackkbar(message: "Failed to save photo: $e");
      }
    });
  }

  Future<void> _shareSheet() async {
    final adsController = Get.find<UnityAdsController>();
    adsController.performAction(() async {
      try {
        final pdfBytes = await _generatePdfBytes();
        final tempDir = await getTemporaryDirectory();
        final file = await File(
          '${tempDir.path}/id_photo_sheet.pdf',
        ).writeAsBytes(pdfBytes);

        await SharePlus.instance.share(
          ShareParams(
            files: [XFile(file.path)],
            text: 'Here is my ID Photo Sheet.',
          ),
        );
      } catch (e) {
        showErrorSnackkbar(message: "Failed to generate or share PDF: $e");
      }
    });
  }
}
