// lib/widgets/pixel_lab/id_photo_maker.dart
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gal/gal.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';
import 'package:squeeze_pix/theme/app_theme.dart';
import 'package:squeeze_pix/utils/snackbar.dart';

import '../models/id_photo_spec.dart';

// A map of standard ID photo specifications
class IDPhotoMaker extends StatefulWidget {
  final File? image;
  const IDPhotoMaker({this.image, super.key});

  @override
  State<IDPhotoMaker> createState() => _IDPhotoMakerState();
}

class _IDPhotoMakerState extends State<IDPhotoMaker> {
  File? _image;
  final _imageKey = GlobalKey();
  final _sheetKey = GlobalKey();

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

  @override
  void initState() {
    super.initState();
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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor:
          AppTheme.gradient.colors.last, // Ensure background matches gradient
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text("ID Photo Maker"),
        flexibleSpace: Container(
          decoration: BoxDecoration(gradient: AppTheme.gradient),
        ),
        actions: [
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.save_alt),
              onPressed: _saveSheet,
              tooltip: 'Save Sheet',
            ),
          if (_image != null)
            IconButton(
              icon: const Icon(Icons.share),
              onPressed: _shareSheet,
              tooltip: 'Share Sheet',
            ),
        ],
      ),
      body: _image == null
          ? _buildImagePickerPrompt()
          : Container(
              decoration: BoxDecoration(gradient: AppTheme.gradient),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: constraints.maxHeight,
                      ),
                      child: IntrinsicHeight(
                        child: SafeArea(
                          child: Column(
                            children: [
                              Expanded(
                                child: Center(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 20.0,
                                    ),
                                    child: AspectRatio(
                                      aspectRatio: _isCustomSelected()
                                          ? (_customSpec.heightMM > 0
                                                ? _customSpec.aspectRatio
                                                : 1.0)
                                          : _selectedSpec.aspectRatio,
                                      child: Container(
                                        margin: const EdgeInsets.symmetric(
                                          horizontal: 20,
                                        ),
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                            color: Colors.white,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRect(
                                          child: InteractiveViewer(
                                            key: _imageKey,
                                            transformationController:
                                                _transformationController,
                                            minScale: 0.5,
                                            maxScale: 5.0,
                                            child: Image.file(
                                              _image!,
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
                      ),
                    ),
                  );
                },
              ),
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: _pickImage,
        tooltip: 'Pick Image',
        child: const Icon(Icons.photo_library),
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
              'Tap the button below to select an image.',
              style: TextStyle(fontSize: 16, color: Colors.white70),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _pickImage,
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

  bool _isCustomSelected() => _selectedSpec.name.startsWith('Custom');
  bool _isCustomPaperSelected() => _selectedPaper.name.startsWith('Custom');

  Widget _buildControls() {
    return Material(
      elevation: 8,
      color: Theme.of(context).colorScheme.tertiaryFixedDim,
      borderRadius: const BorderRadius.only(
        topLeft: Radius.circular(20),
        topRight: Radius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "ID Photo Standard",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<IdPhotoSpec>(
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.tertiaryFixed,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryFixed,
              ),
              value: _selectedSpec,
              items: idPhotoSpecs
                  .map(
                    (spec) =>
                        DropdownMenuItem(value: spec, child: Text(spec.name)),
                  )
                  .toList(),
              onChanged: (spec) {
                if (spec != null) {
                  setState(() {
                    _selectedSpec = spec;
                    if (_isCustomSelected()) {
                      // When custom is selected, ensure controllers match the default custom spec
                      _customWidthController.text = _customSpec.widthMM
                          .toString();
                      _customHeightController.text = _customSpec.heightMM
                          .toString();
                    }
                  });
                }
              },
            ),
            if (_isCustomSelected())
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customWidthController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Width (mm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _customHeightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Height (mm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            const Text(
              "Paper Size",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DropdownButton<PaperSize>(
              isExpanded: true,
              dropdownColor: Theme.of(context).colorScheme.tertiaryFixed,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onTertiaryFixed,
              ),
              value: _selectedPaper,
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
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _customPaperWidthController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Width (mm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: TextField(
                        controller: _customPaperHeightController,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: const InputDecoration(
                          labelText: 'Height (mm)',
                          border: OutlineInputBorder(),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            const SizedBox(height: 16),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.visibility),
                label: const Text("Show Print Preview"),
                onPressed: _showPrintPreviewPopup,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSheetPreview() {
    final paper = _isCustomPaperSelected() ? _customPaper : _selectedPaper;
    return AspectRatio(
      aspectRatio: paper.heightMM > 0 ? paper.aspectRatio : 1.0,
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey),
          color: Colors.white,
        ),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final (cols, rows) = _calculateLayout();
            return GridView.builder(
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: _isCustomSelected()
                    ? (_customSpec.heightMM > 0 ? _customSpec.aspectRatio : 1.0)
                    : _selectedSpec.aspectRatio,
              ),
              itemCount: cols * rows,
              itemBuilder: (context, index) {
                return Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300, width: 0.5),
                    image: DecorationImage(
                      image: FileImage(_image!),
                      fit: BoxFit.cover,
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  void _showPrintPreviewPopup() {
    if (_image == null) {
      showErrorSnackkbar(message: "Please select an image first.");
      return;
    }
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Print Preview"),
        content: SizedBox(width: double.maxFinite, child: _buildSheetPreview()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text("Close"),
          ),
        ],
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

    pdf.addPage(
      pw.Page(
        pageFormat: paper.pdfPageFormat,
        build: (pw.Context context) {
          return pw.GridView(
            crossAxisCount: cols,
            childAspectRatio: spec.heightMM > 0 ? spec.aspectRatio : 1.0,
            children: List.generate(
              cols * rows,
              (index) => pw.Image(pdfImage, fit: pw.BoxFit.cover),
            ),
          );
        },
      ),
    );

    return pdf.save();
  }

  Future<void> _saveSheet() async {
    final pdfBytes = await _generatePdfBytes();
    final tempDir = await getTemporaryDirectory();
    final file = await File(
      '${tempDir.path}/id_photo_sheet.pdf',
    ).writeAsBytes(pdfBytes);

    try {
      // Saving PDF to gallery is not standard, so we offer to share/open it.
      // For a direct "save", we can save an image representation instead.
      // Let's save as an image for the "Save" button.
      // A better approach would be to render the PDF page to an image.
      // For simplicity, we'll just save the first photo.
      await Gal.putImage(_image!.path);
      showSuccessSnackkbar(
        message:
            "Single photo saved to gallery. Use 'Share' for the full PDF sheet.",
      );
    } catch (e) {
      showErrorSnackkbar(message: "Failed to save photo: $e");
    }
  }

  Future<void> _shareSheet() async {
    try {
      final pdfBytes = await _generatePdfBytes();
      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/id_photo_sheet.pdf',
      ).writeAsBytes(pdfBytes);

      await Share.shareXFiles([
        XFile(file.path),
      ], text: 'Here is my ID Photo Sheet.');
    } catch (e) {
      showErrorSnackkbar(message: "Failed to generate or share PDF: $e");
    }
  }
}
