import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/scan_result_model.dart';

/// Service riwayat scan menggunakan Cloud Firestore
/// Menggantikan HistoryService (SharedPreferences) agar data tersimpan di cloud
/// Data disimpan per user: users/{uid}/history/{scanId}
class FirestoreHistoryService extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  List<ScanResultModel> _history = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────

  List<ScanResultModel> get history => _history;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isEmpty => _history.isEmpty;
  bool get isNotEmpty => _history.isNotEmpty;
  int get jumlahScan => _history.length;

  /// Referensi koleksi history milik user yang sedang login
  CollectionReference<Map<String, dynamic>>? get _historyRef {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return null;
    return _db.collection('users').doc(uid).collection('history');
  }

  // ── Load ───────────────────────────────────────────────────────────────────

  /// Load riwayat dari Firestore (urutkan terbaru dulu)
  Future<void> loadHistory() async {
    if (_historyRef == null) return;

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final snapshot = await _historyRef!
          .orderBy('scannedAt', descending: true)
          .limit(50)
          .get();

      _history = snapshot.docs.map((doc) {
        final data = doc.data();
        return ScanResultModel.fromJson(data);
      }).toList();
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat: $e';
      debugPrint('FirestoreHistoryService.loadHistory error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Tambah ─────────────────────────────────────────────────────────────────

  /// Simpan hasil scan baru ke Firestore dan list lokal
  Future<void> tambahScan(ScanResultModel scanResult) async {
    if (_historyRef == null) return;

    try {
      // Simpan ke Firestore
      await _historyRef!.doc(scanResult.id).set(scanResult.toJson());

      // Update list lokal (tambah di depan)
      _history.insert(0, scanResult);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menyimpan scan: $e';
      debugPrint('FirestoreHistoryService.tambahScan error: $e');
      notifyListeners();
    }
  }

  // ── Hapus ──────────────────────────────────────────────────────────────────

  /// Hapus satu item riwayat
  Future<void> hapusScan(String id) async {
    if (_historyRef == null) return;

    try {
      await _historyRef!.doc(id).delete();
      _history.removeWhere((item) => item.id == id);
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menghapus scan: $e';
      debugPrint('FirestoreHistoryService.hapusScan error: $e');
      notifyListeners();
    }
  }

  /// Hapus semua riwayat user
  Future<void> hapusSemua() async {
    if (_historyRef == null) return;

    try {
      // Hapus semua dokumen dalam batch
      final snapshot = await _historyRef!.get();
      final batch = _db.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();

      _history.clear();
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Gagal menghapus semua riwayat: $e';
      debugPrint('FirestoreHistoryService.hapusSemua error: $e');
      notifyListeners();
    }
  }

  // ── Query ──────────────────────────────────────────────────────────────────

  /// Ambil N item terbaru
  List<ScanResultModel> getTerbaru(int n) {
    return _history.take(n).toList();
  }

  /// Filter berdasarkan kategori
  List<ScanResultModel> filterKategori(String kategori) {
    return _history
        .where((item) => item.kategori.toLowerCase() == kategori.toLowerCase())
        .toList();
  }

  /// Cari berdasarkan nama
  List<ScanResultModel> cari(String query) {
    if (query.isEmpty) return _history;
    final lower = query.toLowerCase();
    return _history
        .where(
          (item) =>
              item.namaIndonesia.toLowerCase().contains(lower) ||
              item.namaItem.toLowerCase().contains(lower),
        )
        .toList();
  }

  /// Reset data lokal (dipanggil saat logout)
  void reset() {
    _history.clear();
    _errorMessage = null;
    notifyListeners();
  }
}
