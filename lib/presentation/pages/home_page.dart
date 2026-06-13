import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_history_service.dart';
import '../../data/models/scan_result_model.dart';
import '../widgets/history_tile.dart';
import 'scan_page.dart';
import 'history_page.dart';
import 'result_page.dart';
import 'login_page.dart';

/// Halaman utama FreshScan
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  static const String routeName = '/home';

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    // Load riwayat dari Firestore saat halaman dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<FirestoreHistoryService>().loadHistory();
    });
  }

  // ── Image Picking ──────────────────────────────────────────────────────────

  Future<void> _pickFromCamera() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (image != null && mounted) {
        _navigateToScan(image.path);
      }
    } catch (e) {
      if (mounted) {
        _showError(AppStrings.errorPermissionCamera);
      }
    }
  }

  Future<void> _pickFromGallery() async {
    try {
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1080,
        maxHeight: 1080,
      );
      if (image != null && mounted) {
        _navigateToScan(image.path);
      }
    } catch (e) {
      if (mounted) {
        _showError(AppStrings.errorPermissionGallery);
      }
    }
  }

  void _navigateToScan(String imagePath) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ScanPage(imagePath: imagePath)));
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red[700],
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Build ──────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 100),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeaderCard(),
            const SizedBox(height: 24),
            _buildScanButtons(),
            const SizedBox(height: 28),
            _buildHowToUse(),
            const SizedBox(height: 28),
            _buildRecentHistory(),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  AppBar _buildAppBar() {
    final authService = context.read<AuthService>();
    return AppBar(
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.eco_rounded, size: 22),
          const SizedBox(width: 8),
          const Text(AppStrings.appName),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.history_rounded),
          tooltip: AppStrings.historyTitle,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const HistoryPage()),
            );
          },
        ),
        // Tombol logout
        IconButton(
          icon: const Icon(Icons.logout_rounded),
          tooltip: 'Keluar',
          onPressed: () => _confirmLogout(authService),
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Future<void> _confirmLogout(AuthService authService) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Keluar'),
        content: Text('Yakin ingin keluar dari akun ${authService.email}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      context.read<FirestoreHistoryService>().reset();
      await authService.logout();
      if (mounted) {
        Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (_) => const LoginPage()),
          (_) => false,
        );
      }
    }
  }

  // ── Header Card ────────────────────────────────────────────────────────────

  Widget _buildHeaderCard() {
    final authService = context.watch<AuthService>();
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.35),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  AppStrings.homeGreeting,
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Halo, ${authService.displayName} 👋',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  AppStrings.homeSubtitle,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.85),
                  ),
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '🤖 Didukung AI Vision',
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),
          // Ilustrasi ikon buah-sayuran
          Column(
            children: [
              _emojiIcon('🍎', 30),
              const SizedBox(height: 4),
              Row(
                children: [
                  _emojiIcon('🥦', 26),
                  const SizedBox(width: 4),
                  _emojiIcon('🥕', 26),
                ],
              ),
              const SizedBox(height: 4),
              _emojiIcon('🍊', 28),
            ],
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: -0.2, end: 0, duration: 400.ms, curve: Curves.easeOut)
        .fadeIn(duration: 400.ms);
  }

  Widget _emojiIcon(String emoji, double size) {
    return Text(emoji, style: TextStyle(fontSize: size));
  }

  // ── Scan Buttons ───────────────────────────────────────────────────────────

  Widget _buildScanButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          // Tombol Scan Kamera (Utama)
          SizedBox(
            width: double.infinity,
            height: 58,
            child: ElevatedButton(
              onPressed: _pickFromCamera,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                elevation: 4,
                shadowColor: AppColors.primaryGreen.withOpacity(0.4),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.camera_alt_rounded, size: 22),
                  SizedBox(width: 10),
                  Text(
                    AppStrings.scanButton,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),

          // Tombol Galeri (Sekunder)
          SizedBox(
            width: double.infinity,
            height: 52,
            child: OutlinedButton(
              onPressed: _pickFromGallery,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.primaryGreen,
                side: const BorderSide(
                  color: AppColors.primaryGreen,
                  width: 1.8,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.photo_library_rounded, size: 20),
                  SizedBox(width: 10),
                  Text(
                    AppStrings.galleryButton,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.2, end: 0, delay: 150.ms, duration: 400.ms)
        .fadeIn(delay: 150.ms, duration: 400.ms);
  }

  // ── How To Use ─────────────────────────────────────────────────────────────

  Widget _buildHowToUse() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.howToUseTitle,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _buildStep(
                  icon: Icons.camera_alt_rounded,
                  number: '1',
                  title: AppStrings.step1Title,
                  desc: AppStrings.step1Desc,
                  delay: 200,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStep(
                  icon: Icons.psychology_rounded,
                  number: '2',
                  title: AppStrings.step2Title,
                  desc: AppStrings.step2Desc,
                  delay: 300,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _buildStep(
                  icon: Icons.bar_chart_rounded,
                  number: '3',
                  title: AppStrings.step3Title,
                  desc: AppStrings.step3Desc,
                  delay: 400,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStep({
    required IconData icon,
    required String number,
    required String title,
    required String desc,
    required int delay,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: const BoxDecoration(
              color: AppColors.background,
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 20, color: AppColors.primaryGreen),
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textDark,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 4),
          Text(
            desc,
            style: const TextStyle(fontSize: 10, color: AppColors.textGrey),
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    )
        .animate()
        .slideY(
          begin: 0.3,
          end: 0,
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        )
        .fadeIn(
          delay: Duration(milliseconds: delay),
          duration: 400.ms,
        );
  }

  // ── Recent History ─────────────────────────────────────────────────────────

  Widget _buildRecentHistory() {
    return Consumer<FirestoreHistoryService>(
      builder: (context, historyService, _) {
        final recentItems = historyService.getTerbaru(3);

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    AppStrings.recentHistory,
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textDark,
                    ),
                  ),
                  if (recentItems.isNotEmpty)
                    TextButton(
                      onPressed: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => const HistoryPage(),
                          ),
                        );
                      },
                      child: const Text(AppStrings.lihatSemua),
                    ),
                ],
              ),
              const SizedBox(height: 8),
              if (recentItems.isEmpty)
                _buildEmptyHistory()
              else
                ...recentItems.map(
                  (item) => Padding(
                    padding: const EdgeInsets.only(bottom: 8),
                    child: HistoryTile(
                      scanResult: item,
                      onTap: () => _navigateToResult(item),
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyHistory() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.softGreen, width: 1.5),
      ),
      child: Column(
        children: [
          Icon(Icons.eco_outlined, size: 40, color: AppColors.lightGreen),
          const SizedBox(height: 8),
          const Text(
            AppStrings.belumAdaRiwayat,
            style: TextStyle(color: AppColors.textGrey, fontSize: 14),
          ),
        ],
      ),
    );
  }

  void _navigateToResult(ScanResultModel item) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => ResultPage(scanResult: item)));
  }

  // ── FAB ────────────────────────────────────────────────────────────────────

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: _pickFromCamera,
      backgroundColor: AppColors.primaryGreen,
      foregroundColor: Colors.white,
      elevation: 6,
      icon: const Icon(Icons.camera_alt_rounded),
      label: const Text('Scan', style: TextStyle(fontWeight: FontWeight.w600)),
    );
  }
}
