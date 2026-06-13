import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/constants/app_colors.dart';
import 'login_page.dart';

/// Halaman onboarding yang ditampilkan saat pertama kali install
/// Terdiri dari 4 slide yang menjelaskan fitur utama FreshScan
class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  static const String routeName = '/onboarding';

  /// Key untuk menyimpan status sudah lihat onboarding
  static const String _prefKey = 'onboarding_done';

  /// Cek apakah onboarding sudah pernah ditampilkan
  static Future<bool> isOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_prefKey) ?? false;
  }

  /// Tandai onboarding sudah selesai
  static Future<void> markOnboardingDone() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_prefKey, true);
  }

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<_OnboardingData> _pages = const [
    _OnboardingData(
      emoji: '🍎',
      title: 'Selamat Datang di FreshScan!',
      description:
          'Identifikasi buah dan sayuran secara instan menggunakan kecerdasan buatan. '
          'Cukup ambil foto dan biarkan AI bekerja untuk Anda.',
      bgColor: Color(0xFF2E7D32),
      accentColor: Color(0xFF81C784),
    ),
    _OnboardingData(
      emoji: '📷',
      title: 'Scan dengan Kamera',
      description:
          'Arahkan kamera ke buah atau sayuran yang ingin Anda kenali. '
          'Bisa juga memilih foto dari galeri ponsel Anda.',
      bgColor: Color(0xFF1565C0),
      accentColor: Color(0xFF64B5F6),
    ),
    _OnboardingData(
      emoji: '📊',
      title: 'Info Nutrisi Lengkap',
      description:
          'Dapatkan informasi nutrisi detail seperti kalori, protein, karbohidrat, '
          'serat, vitamin, dan manfaat kesehatan secara langsung.',
      bgColor: Color(0xFF6A1B9A),
      accentColor: Color(0xFFCE93D8),
    ),
    _OnboardingData(
      emoji: '📝',
      title: 'Simpan Riwayat Scan',
      description: 'Semua hasil scan tersimpan otomatis di akun Anda. '
          'Akses kapan saja dan di mana saja untuk referensi nutrisi harian.',
      bgColor: Color(0xFFBF360C),
      accentColor: Color(0xFFFFAB91),
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _finishOnboarding() async {
    await OnboardingPage.markOnboardingDone();
    if (mounted) {
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginPage()),
        (_) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // PageView utama
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) => setState(() => _currentPage = index),
            itemBuilder: (_, index) => _buildPage(_pages[index], index),
          ),

          // Bottom navigation
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNav(),
          ),
        ],
      ),
    );
  }

  Widget _buildPage(_OnboardingData data, int index) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            data.bgColor,
            data.bgColor.withOpacity(0.85),
            Colors.white,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: TextButton(
                  onPressed: _finishOnboarding,
                  child: Text(
                    'Lewati',
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.8),
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
            ),

            const Spacer(flex: 1),

            // Emoji besar
            Text(
              data.emoji,
              style: const TextStyle(fontSize: 100),
            )
                .animate(key: ValueKey('emoji_$index'))
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  duration: 500.ms,
                  curve: Curves.elasticOut,
                )
                .fadeIn(duration: 400.ms),

            const SizedBox(height: 40),

            // Konten teks
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Column(
                children: [
                  Text(
                    data.title,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(key: ValueKey('title_$index'))
                      .slideY(
                          begin: 0.3, end: 0, duration: 400.ms, delay: 100.ms)
                      .fadeIn(duration: 400.ms, delay: 100.ms),
                  const SizedBox(height: 16),
                  Text(
                    data.description,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textGrey,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  )
                      .animate(key: ValueKey('desc_$index'))
                      .slideY(
                          begin: 0.3, end: 0, duration: 400.ms, delay: 200.ms)
                      .fadeIn(duration: 400.ms, delay: 200.ms),
                ],
              ),
            ),

            const Spacer(flex: 2),

            // Spacer untuk bottom nav
            const SizedBox(height: 120),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNav() {
    final isLastPage = _currentPage == _pages.length - 1;

    return Container(
      padding: const EdgeInsets.fromLTRB(24, 16, 24, 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 10,
            offset: Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Dot indicators
          Row(
            children: List.generate(
              _pages.length,
              (index) => AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.only(right: 6),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index
                      ? AppColors.primaryGreen
                      : AppColors.softGreen,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),

          // Tombol next / mulai
          ElevatedButton(
            onPressed: _nextPage,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 3,
            ),
            child: Text(
              isLastPage ? 'Mulai Sekarang' : 'Selanjutnya',
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Data model untuk setiap slide onboarding
class _OnboardingData {
  final String emoji;
  final String title;
  final String description;
  final Color bgColor;
  final Color accentColor;

  const _OnboardingData({
    required this.emoji,
    required this.title,
    required this.description,
    required this.bgColor,
    required this.accentColor,
  });
}
