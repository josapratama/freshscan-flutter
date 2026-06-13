import 'dart:io';
import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_result_model.dart';

/// Widget card untuk menampilkan satu hasil identifikasi
class ResultCard extends StatelessWidget {
  final ScanResultModel scanResult;
  final VoidCallback? onTap;
  final bool showImage;

  const ResultCard({
    super.key,
    required this.scanResult,
    this.onTap,
    this.showImage = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [if (showImage) _buildImage(), _buildContent()],
        ),
      ),
    );
  }

  Widget _buildImage() {
    return SizedBox(
      width: double.infinity,
      height: 140,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Thumbnail gambar
          Image.file(
            File(scanResult.imagePath),
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) => Container(
              color: AppColors.softGreen,
              child: const Icon(
                Icons.eco_rounded,
                size: 50,
                color: AppColors.primaryGreen,
              ),
            ),
          ),
          // Gradient overlay
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 60,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                ),
              ),
            ),
          ),
          // Badge kategori di pojok kanan atas
          Positioned(top: 8, right: 8, child: _buildKategoriBadge()),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Nama
          Text(
            scanResult.namaIndonesia,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            scanResult.namaItem,
            style: const TextStyle(
              fontSize: 11,
              color: AppColors.textGrey,
              fontStyle: FontStyle.italic,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 8),

          // Confidence bar
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: LinearProgressIndicator(
                    value: scanResult.confidence,
                    backgroundColor: AppColors.softGreen,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      _getConfidenceColor(scanResult.confidence),
                    ),
                    minHeight: 6,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '${scanResult.confidencePercent}%',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: _getConfidenceColor(scanResult.confidence),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildKategoriBadge() {
    final isBuah = scanResult.isBuah;
    final color = isBuah ? AppColors.fruitBadge : AppColors.vegBadge;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        scanResult.labelKategori,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
    );
  }

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.confidenceHigh;
    if (confidence >= 0.5) return AppColors.confidenceMed;
    return AppColors.confidenceLow;
  }
}
