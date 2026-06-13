import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/models/scan_result_model.dart';
import 'scan_page.dart';

/// Halaman hasil identifikasi scan buah/sayuran
/// Menampilkan detail lengkap: nama, confidence, nutrisi, manfaat, tips
class ResultPage extends StatelessWidget {
  final ScanResultModel scanResult;

  const ResultPage({super.key, required this.scanResult});

  static const String routeName = '/result';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: CustomScrollView(
        slivers: [
          _buildSliverAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 16),
                  _buildMainResultCard(context),
                  const SizedBox(height: 20),
                  if (scanResult.nutrisi != null) ...[
                    _buildNutrisiSection(context),
                    const SizedBox(height: 20),
                    _buildDeskripsiSection(context),
                    const SizedBox(height: 20),
                    _buildManfaatSection(context),
                    const SizedBox(height: 20),
                    _buildTipsSection(context),
                    const SizedBox(height: 20),
                  ] else
                    _buildNoNutrisiCard(context),
                  if (scanResult.alternatif.isNotEmpty) ...[
                    _buildAlternatifSection(context),
                    const SizedBox(height: 20),
                  ],
                  _buildActionButtons(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SliverAppBar dengan gambar ─────────────────────────────────────────────

  Widget _buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 280,
      pinned: true,
      backgroundColor: AppColors.primaryGreen,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: const Text(
        AppStrings.resultTitle,
        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.share_rounded, color: Colors.white),
          tooltip: AppStrings.share,
          onPressed: () => _shareResult(context),
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar hasil scan
            Image.file(
              File(scanResult.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.softGreen,
                child: const Icon(
                  Icons.eco_rounded,
                  size: 80,
                  color: AppColors.primaryGreen,
                ),
              ),
            ),
            // Gradient overlay
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.3),
                    Colors.transparent,
                    Colors.black.withOpacity(0.5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Kartu Hasil Utama ──────────────────────────────────────────────────────

  Widget _buildMainResultCard(BuildContext context) {
    final confidenceColor = _getConfidenceColor(scanResult.confidence);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama + Badge Kategori
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      scanResult.namaIndonesia,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      scanResult.namaItem,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGrey,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              _buildKategoriBadge(),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),

          // Confidence
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                AppStrings.resultConfidence,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              Text(
                '${scanResult.confidencePercent}%',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: confidenceColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: scanResult.confidence,
              backgroundColor: AppColors.softGreen,
              valueColor: AlwaysStoppedAnimation<Color>(confidenceColor),
              minHeight: 10,
            ),
          ),

          // Label level keyakinan
          const SizedBox(height: 6),
          Text(
            _getConfidenceLabel(scanResult.confidence),
            style: TextStyle(
              fontSize: 12,
              color: confidenceColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.3, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 400.ms);
  }

  Widget _buildKategoriBadge() {
    final isBuah = scanResult.isBuah;
    final color = isBuah ? AppColors.fruitBadge : AppColors.vegBadge;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withOpacity(0.4)),
      ),
      child: Text(
        scanResult.labelKategori,
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.confidenceHigh;
    if (confidence >= 0.5) return AppColors.confidenceMed;
    return AppColors.confidenceLow;
  }

  String _getConfidenceLabel(double confidence) {
    if (confidence >= 0.9) return '✓ Sangat yakin';
    if (confidence >= 0.75) return '✓ Yakin';
    if (confidence >= 0.5) return '⚠ Cukup yakin';
    return '⚠ Kurang yakin - coba foto ulang';
  }

  // ── Informasi Nutrisi ──────────────────────────────────────────────────────

  Widget _buildNutrisiSection(BuildContext context) {
    final nutrisi = scanResult.nutrisi!;

    return _buildSection(
      title: AppStrings.nutrisiTitle,
      subtitle: AppStrings.nutrisiPer100g,
      icon: Icons.local_dining_rounded,
      delay: 100,
      child: GridView.count(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        children: [
          _buildNutrisiCard(
            emoji: '🔥',
            label: AppStrings.nutrisiKalori,
            value: nutrisi['kalori']?.toStringAsFixed(0) ?? '-',
            unit: AppStrings.nutrisiKkal,
          ),
          _buildNutrisiCard(
            emoji: '🍞',
            label: AppStrings.nutrisiKarbohidrat,
            value: nutrisi['karbohidrat']?.toStringAsFixed(1) ?? '-',
            unit: AppStrings.nutrisiGram,
          ),
          _buildNutrisiCard(
            emoji: '💪',
            label: AppStrings.nutrisiProtein,
            value: nutrisi['protein']?.toStringAsFixed(1) ?? '-',
            unit: AppStrings.nutrisiGram,
          ),
          _buildNutrisiCard(
            emoji: '🫒',
            label: AppStrings.nutrisiLemak,
            value: nutrisi['lemak']?.toStringAsFixed(1) ?? '-',
            unit: AppStrings.nutrisiGram,
          ),
          _buildNutrisiCard(
            emoji: '🌿',
            label: AppStrings.nutrisiSerat,
            value: nutrisi['serat']?.toStringAsFixed(1) ?? '-',
            unit: AppStrings.nutrisiGram,
          ),
          _buildNutrisiCard(
            emoji: '🍊',
            label: AppStrings.nutrisiVitaminC,
            value: nutrisi['vitaminC']?.toStringAsFixed(1) ?? '-',
            unit: AppStrings.nutrisiMg,
          ),
        ],
      ),
    );
  }

  Widget _buildNutrisiCard({
    required String emoji,
    required String label,
    required String value,
    required String unit,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.softGreen, width: 1),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 22)),
          const SizedBox(height: 4),
          Text(
            '$value $unit',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryGreen,
            ),
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  // ── Deskripsi ──────────────────────────────────────────────────────────────

  Widget _buildDeskripsiSection(BuildContext context) {
    final deskripsi = scanResult.nutrisi!['deskripsi'] as String?;
    if (deskripsi == null || deskripsi.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: AppStrings.deskripsiTitle,
      icon: Icons.info_outline_rounded,
      delay: 200,
      child: Text(
        deskripsi,
        style: const TextStyle(
          fontSize: 14,
          height: 1.6,
          color: AppColors.textDark,
        ),
      ),
    );
  }

  // ── Manfaat Kesehatan ──────────────────────────────────────────────────────

  Widget _buildManfaatSection(BuildContext context) {
    final manfaatRaw = scanResult.nutrisi!['manfaat'];
    if (manfaatRaw == null) return const SizedBox.shrink();
    final manfaat = List<String>.from(manfaatRaw as List);

    return _buildSection(
      title: AppStrings.manfaatTitle,
      icon: Icons.favorite_rounded,
      iconColor: Colors.red[400],
      delay: 300,
      child: Column(
        children: manfaat
            .map(
              (item) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      margin: const EdgeInsets.only(top: 5),
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppColors.primaryGreen,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item,
                        style: const TextStyle(
                          fontSize: 13,
                          height: 1.5,
                          color: AppColors.textDark,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            )
            .toList(),
      ),
    );
  }

  // ── Tips Penyimpanan ───────────────────────────────────────────────────────

  Widget _buildTipsSection(BuildContext context) {
    final tips = scanResult.nutrisi!['tips_penyimpanan'] as String?;
    if (tips == null || tips.isEmpty) return const SizedBox.shrink();

    return _buildSection(
      title: AppStrings.tipsTitle,
      icon: Icons.lightbulb_outline_rounded,
      iconColor: Colors.amber[700],
      delay: 400,
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.amber[50],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.amber[200]!),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.lightbulb_rounded, color: Colors.amber[700], size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                tips,
                style: TextStyle(
                  fontSize: 13,
                  height: 1.6,
                  color: Colors.amber[900],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── No Nutrisi Card ────────────────────────────────────────────────────────

  Widget _buildNoNutrisiCard(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.softGreen),
      ),
      child: Column(
        children: [
          const Icon(Icons.info_outline, size: 36, color: AppColors.textGrey),
          const SizedBox(height: 8),
          Text(
            'Data nutrisi untuk "${scanResult.namaIndonesia}" belum tersedia',
            style: const TextStyle(color: AppColors.textGrey, fontSize: 13),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Kemungkinan Alternatif ─────────────────────────────────────────────────

  Widget _buildAlternatifSection(BuildContext context) {
    return _buildSection(
      title: AppStrings.alternatifTitle,
      icon: Icons.list_alt_rounded,
      delay: 500,
      child: Column(
        children: scanResult.alternatif.map((alt) {
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppColors.softGreen),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        alt.nama,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textDark,
                        ),
                      ),
                      Text(
                        alt.namaAsli,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _getConfidenceColor(
                      alt.confidence,
                    ).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${alt.confidencePercent}%',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: _getConfidenceColor(alt.confidence),
                    ),
                  ),
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  // ── Action Buttons ─────────────────────────────────────────────────────────

  Widget _buildActionButtons(BuildContext context) {
    return Column(
      children: [
        // Tombol Scan Lagi
        SizedBox(
          width: double.infinity,
          height: 54,
          child: ElevatedButton.icon(
            onPressed: () => _scanLagi(context),
            icon: const Icon(Icons.camera_alt_rounded),
            label: const Text(
              AppStrings.scanLagi,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
            ),
          ),
        ),
        const SizedBox(height: 12),
        // Tombol Kembali
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text(
              AppStrings.back,
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      ],
    ).animate().slideY(
          begin: 0.3,
          end: 0,
          delay: 600.ms,
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  // ── Helper: Section Container ──────────────────────────────────────────────

  Widget _buildSection({
    required String title,
    String? subtitle,
    required IconData icon,
    Color? iconColor,
    required Widget child,
    int delay = 0,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: (iconColor ?? AppColors.primaryGreen).withOpacity(
                    0.1,
                  ),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 18,
                  color: iconColor ?? AppColors.primaryGreen,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    if (subtitle != null)
                      Text(
                        subtitle,
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.textGrey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          const Divider(height: 1),
          const SizedBox(height: 14),
          child,
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 0.2,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
          curve: Curves.easeOut,
        )
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        );
  }

  // ── Actions ────────────────────────────────────────────────────────────────

  Future<void> _scanLagi(BuildContext context) async {
    final picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.camera,
      imageQuality: 85,
      maxWidth: 1080,
      maxHeight: 1080,
    );
    if (image != null && context.mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => ScanPage(imagePath: image.path)),
      );
    }
  }

  void _shareResult(BuildContext context) {
    // Tampilkan info share (share paket tidak diinclude, bisa ditambah)
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${scanResult.namaIndonesia} - ${scanResult.confidencePercent}% keyakinan',
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
