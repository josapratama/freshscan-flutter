import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../core/constants/app_colors.dart';
import '../../data/models/scan_result_model.dart';

/// ListTile custom untuk menampilkan item riwayat scan
class HistoryTile extends StatelessWidget {
  final ScanResultModel scanResult;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const HistoryTile({
    super.key,
    required this.scanResult,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.07),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              children: [
                _buildThumbnail(),
                const SizedBox(width: 12),
                Expanded(child: _buildInfo()),
                const SizedBox(width: 8),
                _buildTrailing(context),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ── Thumbnail ──────────────────────────────────────────────────────────────

  Widget _buildThumbnail() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        width: 64,
        height: 64,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.file(
              File(scanResult.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.softGreen,
                child: const Icon(
                  Icons.eco_rounded,
                  color: AppColors.primaryGreen,
                  size: 28,
                ),
              ),
            ),
            // Kategori badge mini di pojok
            Positioned(
              bottom: 3,
              right: 3,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: BoxDecoration(
                  color:
                      (scanResult.isBuah
                              ? AppColors.fruitBadge
                              : AppColors.vegBadge)
                          .withOpacity(0.9),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  scanResult.isBuah ? '🍎' : '🥦',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Info ───────────────────────────────────────────────────────────────────

  Widget _buildInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Nama buah/sayuran
        Text(
          scanResult.namaIndonesia,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 2),

        // Kategori + Confidence
        Row(
          children: [
            _buildKategoriChip(),
            const SizedBox(width: 6),
            _buildConfidenceBadge(),
          ],
        ),

        const SizedBox(height: 4),

        // Tanggal & waktu
        Row(
          children: [
            const Icon(
              Icons.access_time_rounded,
              size: 11,
              color: AppColors.textGrey,
            ),
            const SizedBox(width: 3),
            Text(
              _formatDateTime(scanResult.scannedAt),
              style: const TextStyle(fontSize: 11, color: AppColors.textGrey),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildKategoriChip() {
    final isBuah = scanResult.isBuah;
    final color = isBuah ? AppColors.fruitBadge : AppColors.vegBadge;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        isBuah ? 'Buah' : 'Sayuran',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  Widget _buildConfidenceBadge() {
    final color = _getConfidenceColor(scanResult.confidence);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        '${scanResult.confidencePercent}%',
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: color,
        ),
      ),
    );
  }

  // ── Trailing ───────────────────────────────────────────────────────────────

  Widget _buildTrailing(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(
          Icons.chevron_right_rounded,
          color: AppColors.textGrey,
          size: 22,
        ),
      ],
    );
  }

  // ── Helpers ────────────────────────────────────────────────────────────────

  Color _getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return AppColors.confidenceHigh;
    if (confidence >= 0.5) return AppColors.confidenceMed;
    return AppColors.confidenceLow;
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    if (diff.inDays == 1) return 'Kemarin, ${DateFormat('HH:mm').format(dt)}';
    if (diff.inDays < 7) return '${diff.inDays} hari lalu';
    return DateFormat('d MMM yyyy, HH:mm', 'id_ID').format(dt);
  }
}
