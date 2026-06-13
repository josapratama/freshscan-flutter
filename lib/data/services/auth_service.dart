import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Service untuk autentikasi menggunakan Firebase Auth
class AuthService extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ── Getters ────────────────────────────────────────────────────────────────

  /// User yang sedang login (null jika belum login)
  User? get currentUser => _auth.currentUser;

  /// Apakah user sudah login
  bool get isLoggedIn => _auth.currentUser != null;

  /// Stream perubahan status auth
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Nama tampilan user
  String get displayName =>
      _auth.currentUser?.displayName ??
      _auth.currentUser?.email?.split('@').first ??
      'Pengguna';

  /// Email user
  String get email => _auth.currentUser?.email ?? '';

  // ── Register ───────────────────────────────────────────────────────────────

  /// Daftar akun baru dengan email dan password
  /// Returns null jika berhasil, pesan error jika gagal
  Future<String?> register({
    required String nama,
    required String email,
    required String password,
  }) async {
    try {
      // Buat akun baru
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      // Update nama tampilan
      await credential.user?.updateDisplayName(nama.trim());
      await credential.user?.reload();

      notifyListeners();
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ── Login ──────────────────────────────────────────────────────────────────

  /// Login dengan email dan password
  /// Returns null jika berhasil, pesan error jika gagal
  Future<String?> login({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      notifyListeners();
      return null; // Sukses
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ── Logout ─────────────────────────────────────────────────────────────────

  /// Keluar dari akun
  Future<void> logout() async {
    await _auth.signOut();
    notifyListeners();
  }

  // ── Reset Password ─────────────────────────────────────────────────────────

  /// Kirim email reset password
  /// Returns null jika berhasil, pesan error jika gagal
  Future<String?> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
      return null;
    } on FirebaseAuthException catch (e) {
      return _getErrorMessage(e.code);
    } catch (e) {
      return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  // ── Private Helper ─────────────────────────────────────────────────────────

  /// Konversi kode error Firebase ke pesan Bahasa Indonesia
  String _getErrorMessage(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email sudah digunakan. Gunakan email lain atau login.';
      case 'invalid-email':
        return 'Format email tidak valid.';
      case 'weak-password':
        return 'Password terlalu lemah. Minimal 6 karakter.';
      case 'user-not-found':
        return 'Akun tidak ditemukan. Periksa email atau daftar terlebih dahulu.';
      case 'wrong-password':
        return 'Password salah. Silakan coba lagi.';
      case 'invalid-credential':
        return 'Email atau password salah.';
      case 'user-disabled':
        return 'Akun ini telah dinonaktifkan.';
      case 'too-many-requests':
        return 'Terlalu banyak percobaan login. Coba lagi nanti.';
      case 'network-request-failed':
        return 'Tidak ada koneksi internet. Periksa jaringan Anda.';
      default:
        return 'Terjadi kesalahan ($code). Silakan coba lagi.';
    }
  }
}
