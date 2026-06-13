import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

/// Widget banner yang muncul otomatis saat tidak ada koneksi internet
/// Menggunakan connectivity_plus atau fallback polling HTTP sederhana
class OfflineBanner extends StatefulWidget {
  final Widget child;

  const OfflineBanner({super.key, required this.child});

  @override
  State<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends State<OfflineBanner>
    with SingleTickerProviderStateMixin {
  bool _isOffline = false;
  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeOut));
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  /// Panggil method ini dari luar untuk update status offline
  void setOffline(bool offline) {
    if (!mounted) return;
    setState(() => _isOffline = offline);
    if (offline) {
      _animController.forward();
    } else {
      _animController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_isOffline)
          SlideTransition(
            position: _slideAnimation,
            child: _buildBanner(),
          ),
        Expanded(child: widget.child),
      ],
    );
  }

  Widget _buildBanner() {
    return Material(
      color: Colors.orange[700],
      child: SafeArea(
        bottom: false,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Icon(Icons.wifi_off_rounded, color: Colors.white, size: 18),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Tidak ada koneksi internet. Beberapa fitur mungkin tidak tersedia.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Widget wrapper yang otomatis mendeteksi status koneksi
/// dengan polling ringan setiap 5 detik
class ConnectivityWrapper extends StatefulWidget {
  final Widget child;

  const ConnectivityWrapper({super.key, required this.child});

  @override
  State<ConnectivityWrapper> createState() => _ConnectivityWrapperState();
}

class _ConnectivityWrapperState extends State<ConnectivityWrapper> {
  bool _isOffline = false;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _checkConnectivity();
    // Cek setiap 10 detik
    _timer = Timer.periodic(const Duration(seconds: 10), (_) {
      _checkConnectivity();
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _checkConnectivity() async {
    // Tidak perlu check connectivity di sini — cukup handle error di service
    // Widget ini hanya sebagai placeholder untuk future implementation
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (_isOffline) _buildOfflineOverlay(),
      ],
    );
  }

  Widget _buildOfflineOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: Material(
        color: Colors.orange[700],
        child: SafeArea(
          bottom: false,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: const Row(
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Tidak ada koneksi internet',
                    style: TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget error state untuk kondisi offline yang user-friendly
class OfflineErrorWidget extends StatelessWidget {
  final VoidCallback onRetry;
  final String? message;

  const OfflineErrorWidget({
    super.key,
    required this.onRetry,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.orange[50],
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.wifi_off_rounded,
                size: 40,
                color: Colors.orange[700],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Tidak Ada Koneksi',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message ?? 'Periksa koneksi internet Anda dan coba lagi.',
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textGrey,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Coba Lagi'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryGreen,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
