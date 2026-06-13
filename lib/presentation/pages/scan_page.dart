import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/services/openrouter_service.dart';
import '../../data/services/firestore_history_service.dart';
import '../../data/models/scan_result_model.dart';
import 'result_page.dart';

/// Halaman loading/proses analisis gambar
/// Menampilkan progress scan dan memanggil OpenRouterService
class ScanPage extends StatefulWidget {
  final String imagePath;

  const ScanPage({super.key, required this.imagePath});

  static const String routeName = '/scan';

  @override
  State<ScanPage> createState() => _ScanPageState();
}

class _ScanPageState extends State<ScanPage> with TickerProviderStateMixin {
  final OpenRouterService _openRouterService = OpenRouterService();

  // Progress steps
  int _currentStep = 0;
  bool _hasError = false;
  String _errorMessage = '';

  // Animasi loading dots
  late AnimationController _dotsController;
  late AnimationController _pulseController;

  final List<String> _steps = [
    '✓ Gambar diterima',
    '⟳ Mengunggah ke server AI...',
    '⟳ Model AI mengidentifikasi...',
    '⟳ Menyiapkan hasil...',
  ];

  @override
  void initState() {
    super.initState();

    _dotsController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..repeat(reverse: true);

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    // Mulai proses analisis setelah frame pertama render
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _startAnalysis();
    });
  }

  @override
  void dispose() {
    _dotsController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  // ── Analysis Process ───────────────────────────────────────────────────────

  Future<void> _startAnalysis() async {
    // Step 1: Gambar diterima
    _updateStep(0);
    await Future.delayed(const Duration(milliseconds: 600));

    // Step 2: Mengunggah
    _updateStep(1);
    await Future.delayed(const Duration(milliseconds: 800));

    // Step 3: AI mengidentifikasi
    _updateStep(2);

    try {
      // Panggil OpenRouter API
      final ScanResultModel result = await _openRouterService.identifyImage(
        widget.imagePath,
      );

      // Step 4: Menyiapkan hasil
      _updateStep(3);
      await Future.delayed(const Duration(milliseconds: 600));

      // Simpan ke Firestore
      if (mounted) {
        await context.read<FirestoreHistoryService>().tambahScan(result);
      }

      // Navigasi ke halaman hasil
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => ResultPage(scanResult: result)),
        );
      }
    } on OpenRouterException catch (e) {
      _showError(e.userMessage);
    } catch (e) {
      _showError(AppStrings.scanErrorGeneric);
    }
  }

  void _updateStep(int step) {
    if (mounted) {
      setState(() => _currentStep = step);
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    setState(() {
      _hasError = true;
      _errorMessage = message;
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
        action: SnackBarAction(
          label: AppStrings.back,
          textColor: Colors.white,
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text(AppStrings.scanTitle),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),
            _buildImagePreview(),
            const SizedBox(height: 32),
            if (!_hasError) _buildLoadingSection(),
            if (_hasError) _buildErrorSection(),
          ],
        ),
      ),
    );
  }

  // ── Image Preview ──────────────────────────────────────────────────────────

  Widget _buildImagePreview() {
    return Container(
      width: double.infinity,
      height: 260,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Gambar yang dipilih
            Image.file(
              File(widget.imagePath),
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.softGreen,
                child: const Icon(
                  Icons.broken_image_rounded,
                  size: 60,
                  color: AppColors.textGrey,
                ),
              ),
            ),
            // Overlay gelap di bagian bawah
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 80,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Colors.transparent, Colors.black.withOpacity(0.5)],
                  ),
                ),
              ),
            ),
            // Animasi scan line
            if (!_hasError)
              AnimatedBuilder(
                animation: _pulseController,
                builder: (_, __) {
                  return Positioned(
                    top: _pulseController.value * 220,
                    left: 0,
                    right: 0,
                    child: Container(
                      height: 2,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            Colors.transparent,
                            AppColors.lightGreen.withOpacity(0.8),
                            AppColors.lightGreen,
                            AppColors.lightGreen.withOpacity(0.8),
                            Colors.transparent,
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
          ],
        ),
      ),
    ).animate().scale(
          begin: const Offset(0.9, 0.9),
          end: const Offset(1.0, 1.0),
          duration: 400.ms,
          curve: Curves.easeOut,
        );
  }

  // ── Loading Section ────────────────────────────────────────────────────────

  Widget _buildLoadingSection() {
    return Column(
      children: [
        // Judul
        const Text(
          AppStrings.scanAnalyzing,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          AppStrings.scanAiProcessing,
          style: TextStyle(fontSize: 14, color: AppColors.textGrey),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 32),

        // Indikator loading
        SizedBox(
          width: 56,
          height: 56,
          child: CircularProgressIndicator(
            strokeWidth: 4,
            backgroundColor: AppColors.softGreen,
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppColors.primaryGreen,
            ),
          ),
        ),

        const SizedBox(height: 32),

        // Progress steps
        Container(
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
            children: List.generate(
              _steps.length,
              (index) => _buildStepItem(index),
            ),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildStepItem(int index) {
    final isDone = index < _currentStep;
    final isActive = index == _currentStep;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          // Status icon
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isDone
                  ? AppColors.primaryGreen
                  : isActive
                      ? AppColors.softGreen
                      : Colors.grey[100],
            ),
            child: Center(
              child: isDone
                  ? const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    )
                  : isActive
                      ? SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primaryGreen,
                            ),
                          ),
                        )
                      : Text(
                          '${index + 1}',
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.textGrey,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
            ),
          ),
          const SizedBox(width: 12),
          // Step text
          Expanded(
            child: Text(
              _steps[index],
              style: TextStyle(
                fontSize: 13,
                fontWeight: isActive ? FontWeight.w600 : FontWeight.w400,
                color: isDone
                    ? AppColors.primaryGreen
                    : isActive
                        ? AppColors.textDark
                        : AppColors.textGrey,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── Error Section ──────────────────────────────────────────────────────────

  Widget _buildErrorSection() {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.red[50],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.red[200]!),
          ),
          child: Column(
            children: [
              Icon(
                Icons.error_outline_rounded,
                size: 48,
                color: Colors.red[400],
              ),
              const SizedBox(height: 12),
              Text(
                AppStrings.scanError,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Colors.red[700],
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage,
                style: TextStyle(fontSize: 13, color: Colors.red[600]),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: () => Navigator.of(context).pop(),
            icon: const Icon(Icons.arrow_back_rounded),
            label: const Text(AppStrings.back),
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }
}
