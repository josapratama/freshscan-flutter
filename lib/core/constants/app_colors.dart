import 'package:flutter/material.dart';

/// Warna-warna tema FreshScan
class AppColors {
  AppColors._();

  /// Warna hijau utama - identitas FreshScan
  static const Color primaryGreen = Color(0xFF2E7D32);

  /// Hijau muda untuk aksen dan latar
  static const Color lightGreen = Color(0xFF81C784);

  /// Hijau sangat muda untuk surface/background card
  static const Color softGreen = Color(0xFFC8E6C9);

  /// Oranye aksen untuk highlight & badge
  static const Color accentOrange = Color(0xFFFF6F00);

  /// Oranye muda
  static const Color lightOrange = Color(0xFFFFCC80);

  /// Latar belakang utama aplikasi
  static const Color background = Color(0xFFF1F8E9);

  /// Warna card putih bersih
  static const Color cardWhite = Colors.white;

  /// Teks gelap utama
  static const Color textDark = Color(0xFF1B5E20);

  /// Teks abu untuk sub-info
  static const Color textGrey = Color(0xFF757575);

  /// Warna untuk badge buah
  static const Color fruitBadge = Color(0xFFE91E63);

  /// Warna untuk badge sayuran
  static const Color vegBadge = Color(0xFF388E3C);

  /// Warna confidence tinggi (>80%)
  static const Color confidenceHigh = Color(0xFF2E7D32);

  /// Warna confidence sedang (50-80%)
  static const Color confidenceMed = Color(0xFFF57F17);

  /// Warna confidence rendah (<50%)
  static const Color confidenceLow = Color(0xFFC62828);

  /// Gradient header hijau
  static const LinearGradient greenGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF66BB6A)],
  );

  /// Gradient untuk splash screen
  static const LinearGradient splashGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B5E20), Color(0xFF2E7D32), Color(0xFF43A047)],
  );

  /// Gradient tombol scan
  static const LinearGradient scanButtonGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF2E7D32), Color(0xFF1B5E20)],
  );
}
