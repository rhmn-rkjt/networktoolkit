import 'dart:io';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_file/open_file.dart';

class PDFUtils {
  /// Open PDF file from assets
  static Future<void> openPDF(String pdfFileName) async {
    try {
      // Load PDF from assets
      final byteData = await rootBundle.load('assets/pdf/$pdfFileName');
      
      // Get temporary directory
      final tempDir = await getTemporaryDirectory();
      final file = File('${tempDir.path}/$pdfFileName');
      
      // Write PDF to temporary directory
      await file.writeAsBytes(byteData.buffer.asUint8List());
      
      // Open PDF with default PDF reader
      await OpenFile.open(file.path);
    } catch (e) {
      print('Error opening PDF: $e');
    }
  }

  /// Open Hitung Panduan PDF
  static Future<void> openHitungPDF() async {
    await openPDF('Hitung_Panduan.pdf');
  }

  /// Open Konversi Panduan PDF
  static Future<void> openKonversiPDF() async {
    await openPDF('Konversi_Panduan.pdf');
  }

  /// Open Subnet Panduan PDF
  static Future<void> openSubnetPDF() async {
    await openPDF('Subnet_Panduan.pdf');
  }
}
