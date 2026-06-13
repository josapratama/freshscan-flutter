import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';

/// Utility untuk kompresi gambar sebelum dikirim ke API
/// Mengurangi ukuran file agar hemat bandwidth dan quota API
class ImageCompressor {
  /// Maksimum dimensi gambar (lebar/tinggi)
  static const int maxDimension = 800;

  /// Kualitas kompresi JPEG (0-100)
  static const int jpegQuality = 80;

  /// Maksimum ukuran file dalam bytes (500KB)
  static const int maxFileSizeBytes = 500 * 1024;

  /// Kompres gambar dari XFile (hasil image_picker)
  /// Menggunakan parameter bawaan image_picker untuk resize
  static Future<String> compressFromPicker({
    required ImageSource source,
    required ImagePicker picker,
  }) async {
    final XFile? image = await picker.pickImage(
      source: source,
      imageQuality: jpegQuality,
      maxWidth: maxDimension.toDouble(),
      maxHeight: maxDimension.toDouble(),
    );
    if (image == null) throw Exception('Tidak ada gambar yang dipilih');
    return image.path;
  }

  /// Cek ukuran file dan log info kompresi
  static Future<void> logFileInfo(String imagePath) async {
    final file = File(imagePath);
    if (await file.exists()) {
      final sizeKB = (await file.length()) / 1024;
      debugPrint('[ImageCompressor] File: $imagePath');
      debugPrint('[ImageCompressor] Ukuran: ${sizeKB.toStringAsFixed(1)} KB');
      if (sizeKB > maxFileSizeBytes / 1024) {
        debugPrint(
            '[ImageCompressor] ⚠ File masih besar, mungkin perlu kompresi tambahan');
      }
    }
  }
}
