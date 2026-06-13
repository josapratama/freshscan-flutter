import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../core/constants/app_colors.dart';
import '../../data/services/auth_service.dart';
import '../../data/services/firestore_history_service.dart';
import 'login_page.dart';

/// Halaman profil user
/// Menampilkan info akun, statistik scan, dan opsi pengaturan
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  static const String routeName = '/profile';

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  bool _isEditingName = false;
  final _nameController = TextEditingController();
  bool _isSavingName = false;

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authService = context.watch<AuthService>();
    final historyService = context.watch<FirestoreHistoryService>();

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: AppColors.primaryGreen,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),
            _buildAvatarCard(authService),
            const SizedBox(height: 20),
            _buildStatsCard(historyService),
            const SizedBox(height: 20),
            _buildAccountSection(authService),
            const SizedBox(height: 20),
            _buildLogoutButton(authService),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  // ── Avatar & Nama ──────────────────────────────────────────────────────────

  Widget _buildAvatarCard(AuthService authService) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: AppColors.greenGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Avatar circle dengan inisial
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.25),
              shape: BoxShape.circle,
              border:
                  Border.all(color: Colors.white.withOpacity(0.5), width: 2),
            ),
            child: Center(
              child: Text(
                _getInitial(authService.displayName),
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Nama — bisa diedit
          if (_isEditingName)
            _buildNameEditField(authService)
          else
            _buildNameDisplay(authService),

          const SizedBox(height: 4),

          // Email
          Text(
            authService.email,
            style: TextStyle(
              fontSize: 13,
              color: Colors.white.withOpacity(0.8),
            ),
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 400.ms)
        .slideY(begin: -0.1, end: 0, duration: 400.ms);
  }

  Widget _buildNameDisplay(AuthService authService) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          authService.displayName,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 8),
        GestureDetector(
          onTap: () {
            _nameController.text = authService.displayName;
            setState(() => _isEditingName = true);
          },
          child: const Icon(
            Icons.edit_outlined,
            color: Colors.white70,
            size: 18,
          ),
        ),
      ],
    );
  }

  Widget _buildNameEditField(AuthService authService) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          width: 180,
          child: TextField(
            controller: _nameController,
            autofocus: true,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
            decoration: InputDecoration(
              isDense: true,
              contentPadding:
                  const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: BorderSide(color: Colors.white.withOpacity(0.5)),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: Colors.white),
              ),
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Tombol simpan
        _isSavingName
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2),
              )
            : GestureDetector(
                onTap: () => _saveName(authService),
                child: const Icon(Icons.check_circle,
                    color: Colors.white, size: 24),
              ),
        const SizedBox(width: 4),
        // Tombol batal
        GestureDetector(
          onTap: () => setState(() => _isEditingName = false),
          child: const Icon(Icons.cancel, color: Colors.white70, size: 24),
        ),
      ],
    );
  }

  Future<void> _saveName(AuthService authService) async {
    final newName = _nameController.text.trim();
    if (newName.isEmpty || newName == authService.displayName) {
      setState(() => _isEditingName = false);
      return;
    }

    setState(() => _isSavingName = true);
    try {
      await authService.currentUser?.updateDisplayName(newName);
      await authService.currentUser?.reload();
      authService.notifyListeners();
      if (mounted) {
        setState(() {
          _isEditingName = false;
          _isSavingName = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Nama berhasil diperbarui'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppColors.primaryGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isSavingName = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memperbarui nama: $e'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ── Statistik ──────────────────────────────────────────────────────────────

  Widget _buildStatsCard(FirestoreHistoryService historyService) {
    final buahCount = historyService.filterKategori('buah').length;
    final sayuranCount = historyService.filterKategori('sayuran').length;
    final totalScan = historyService.jumlahScan;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.bar_chart_rounded,
                  color: AppColors.primaryGreen, size: 20),
              SizedBox(width: 8),
              Text(
                'Statistik Scan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Divider(height: 1),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  icon: '📊',
                  label: 'Total Scan',
                  value: totalScan.toString(),
                  color: AppColors.primaryGreen,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🍎',
                  label: 'Buah',
                  value: buahCount.toString(),
                  color: AppColors.fruitBadge,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  icon: '🥦',
                  label: 'Sayuran',
                  value: sayuranCount.toString(),
                  color: AppColors.vegBadge,
                ),
              ),
            ],
          ),
          if (totalScan > 0) ...[
            const SizedBox(height: 16),
            _buildScanDistributionBar(buahCount, sayuranCount, totalScan),
          ],
        ],
      ),
    )
        .animate()
        .fadeIn(delay: 100.ms, duration: 400.ms)
        .slideY(begin: 0.1, end: 0, delay: 100.ms, duration: 400.ms);
  }

  Widget _buildStatItem({
    required String icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Column(
      children: [
        Text(icon, style: const TextStyle(fontSize: 28)),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w800,
            color: color,
          ),
        ),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
      ],
    );
  }

  Widget _buildScanDistributionBar(int buah, int sayuran, int total) {
    final buahRatio = total > 0 ? buah / total : 0.0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Distribusi Scan',
          style: TextStyle(fontSize: 12, color: AppColors.textGrey),
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: SizedBox(
            height: 12,
            child: Row(
              children: [
                Flexible(
                  flex: (buahRatio * 100).round(),
                  child: Container(color: AppColors.fruitBadge),
                ),
                Flexible(
                  flex: ((1 - buahRatio) * 100).round(),
                  child: Container(color: AppColors.vegBadge),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            _buildLegendDot(AppColors.fruitBadge),
            const SizedBox(width: 4),
            const Text('Buah',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
            const SizedBox(width: 12),
            _buildLegendDot(AppColors.vegBadge),
            const SizedBox(width: 4),
            const Text('Sayuran',
                style: TextStyle(fontSize: 11, color: AppColors.textGrey)),
          ],
        ),
      ],
    );
  }

  Widget _buildLegendDot(Color color) {
    return Container(
      width: 8,
      height: 8,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }

  // ── Account Section ────────────────────────────────────────────────────────

  Widget _buildAccountSection(AuthService authService) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardWhite,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryGreen.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          _buildMenuTile(
            icon: Icons.lock_outline_rounded,
            title: 'Ganti Password',
            subtitle: 'Kirim email reset password',
            onTap: () => _sendResetPassword(authService),
          ),
          const Divider(height: 1, indent: 56),
          _buildMenuTile(
            icon: Icons.email_outlined,
            title: 'Email Akun',
            subtitle: authService.email,
            onTap: null,
            showArrow: false,
          ),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildMenuTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback? onTap,
    bool showArrow = true,
  }) {
    return ListTile(
      leading: Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, size: 20, color: AppColors.primaryGreen),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(fontSize: 12, color: AppColors.textGrey),
      ),
      trailing: showArrow
          ? const Icon(Icons.chevron_right_rounded, color: AppColors.textGrey)
          : null,
      onTap: onTap,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }

  Future<void> _sendResetPassword(AuthService authService) async {
    final email = authService.email;
    if (email.isEmpty) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Reset Password'),
        content: Text('Email reset password akan dikirim ke:\n$email'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryGreen,
              foregroundColor: Colors.white,
            ),
            child: const Text('Kirim'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      final error = await authService.resetPassword(email);
      if (mounted) {
        if (error == null) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Email reset password dikirim ke $email'),
              backgroundColor: AppColors.primaryGreen,
              behavior: SnackBarBehavior.floating,
            ),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(error),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  // ── Logout Button ──────────────────────────────────────────────────────────

  Widget _buildLogoutButton(AuthService authService) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: OutlinedButton.icon(
        onPressed: () => _confirmLogout(authService),
        icon: const Icon(Icons.logout_rounded, color: Colors.red),
        label: const Text(
          'Keluar dari Akun',
          style: TextStyle(
            color: Colors.red,
            fontWeight: FontWeight.w600,
            fontSize: 15,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: const BorderSide(color: Colors.red, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    ).animate().fadeIn(delay: 300.ms, duration: 400.ms);
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

  // ── Helper ─────────────────────────────────────────────────────────────────

  String _getInitial(String name) {
    if (name.isEmpty) return '?';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name[0].toUpperCase();
  }
}
