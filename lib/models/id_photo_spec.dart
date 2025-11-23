import 'package:pdf/pdf.dart';

class IdPhotoSpec {
  final String name;
  final double widthMM;
  final double heightMM;

  const IdPhotoSpec({
    required this.name,
    required this.widthMM,
    required this.heightMM,
  });

  double get aspectRatio => widthMM / heightMM;
}

class PaperSize {
  final String name;
  final double widthMM;
  final double heightMM;
  final PdfPageFormat pdfPageFormat;

  const PaperSize({
    required this.name,
    required this.widthMM,
    required this.heightMM,
    required this.pdfPageFormat,
  });

  double get aspectRatio => widthMM / heightMM;
}

const List<IdPhotoSpec> idPhotoSpecs = [
  IdPhotoSpec(name: 'US Passport (2x2 in)', widthMM: 51, heightMM: 51),
  IdPhotoSpec(name: 'BD Passport (45x55 mm)', widthMM: 45, heightMM: 55),
  IdPhotoSpec(name: 'BD NID (25x30 mm)', widthMM: 25, heightMM: 30),
  IdPhotoSpec(name: 'BD Official (40x50 mm)', widthMM: 40, heightMM: 50),
  IdPhotoSpec(name: 'BD Stamp Size (20x25 mm)', widthMM: 20, heightMM: 25),
  IdPhotoSpec(name: 'Schengen Visa (35x45 mm)', widthMM: 35, heightMM: 45),
  IdPhotoSpec(name: 'India Passport (2x2 in)', widthMM: 51, heightMM: 51),
  IdPhotoSpec(name: 'China Visa (33x48 mm)', widthMM: 33, heightMM: 48),
  IdPhotoSpec(name: 'Canada Visa (35x45 mm)', widthMM: 35, heightMM: 45),
  IdPhotoSpec(name: 'Custom (30x40 mm)', widthMM: 30, heightMM: 40),
];

const List<PaperSize> paperSizes = [
  PaperSize(
    name: '4x6 inch',
    widthMM: 101.6,
    heightMM: 152.4,
    pdfPageFormat: PdfPageFormat(
      101.6 * PdfPageFormat.mm,
      152.4 * PdfPageFormat.mm,
    ),
  ),
  PaperSize(
    name: 'A4',
    widthMM: 210,
    heightMM: 297,
    pdfPageFormat: PdfPageFormat.a4,
  ),
  PaperSize(
    name: 'A5',
    widthMM: 148,
    heightMM: 210,
    pdfPageFormat: PdfPageFormat.a5,
  ),
  PaperSize(
    name: 'Letter',
    widthMM: 215.9,
    heightMM: 279.4,
    pdfPageFormat: PdfPageFormat.letter,
  ),
  PaperSize(
    name: 'Legal',
    widthMM: 215.9,
    heightMM: 355.6,
    pdfPageFormat: PdfPageFormat.legal,
  ),
  // A placeholder for the custom option in the UI
  PaperSize(
    name: 'Custom',
    widthMM: 100,
    heightMM: 150,
    pdfPageFormat: PdfPageFormat.undefined,
  ),
];
