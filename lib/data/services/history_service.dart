import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/scan_result_model.dart';
import '../models/history_model.dart';

/// Service untuk mengelola riwayat scan menggunakan SharedPreferences
/// Menggunakan ChangeNotifier agar UI bisa reaktif terhadap perubahan
class HistoryService extends ChangeNotifier {
  static const String _storageKey = 'freshscan_history';

  HistoryModel _historyModel = HistoryModel.empty();
  bool _isLoading = false;
  String? _errorMessage;

  // ── Getters ────────────────────────────────────────────────────────────────

  /// Daftar semua riwayat scan (terbaru dulu)
  List<ScanResultModel> get history => _historyModel.itemsTerbaru;

  /// Model lengkap riwayat
  HistoryModel get historyModel => _historyModel;

  /// Apakah sedang loading
  bool get isLoading => _isLoading;

  /// Pesan error terkini (null jika tidak ada error)
  String? get errorMessage => _errorMessage;

  /// Jumlah total scan
  int get jumlahScan => _historyModel.jumlah;

  /// Apakah riwayat kosong
  bool get isEmpty => _historyModel.isEmpty;

  /// Apakah riwayat tidak kosong
  bool get isNotEmpty => _historyModel.isNotEmpty;

  // ── Load / Init ────────────────────────────────────────────────────────────

  /// Load riwayat dari penyimpanan lokal
  Future<void> loadHistory() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString(_storageKey);

      if (jsonString != null && jsonString.isNotEmpty) {
        final jsonData = jsonDecode(jsonString) as Map<String, dynamic>;
        _historyModel = HistoryModel.fromJson(jsonData);
      } else {
        _historyModel = HistoryModel.empty();
      }
    } catch (e) {
      _errorMessage = 'Gagal memuat riwayat: $e';
      _historyModel = HistoryModel.empty();
      debugPrint('HistoryService.loadHistory error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── CRUD Operations ────────────────────────────────────────────────────────

  /// Tambah hasil scan baru ke riwayat
  Future<void> tambahScan(ScanResultModel scanResult) async {
    _historyModel = _historyModel.tambahItem(scanResult);
    notifyListeners();

    // Simpan ke penyimpanan
    await _saveToStorage();
  }

  /// Hapus satu item riwayat berdasarkan ID
  Future<void> hapusScan(String id) async {
    _historyModel = _historyModel.hapusItem(id);
    notifyListeners();

    await _saveToStorage();
  }

  /// Hapus semua riwayat
  Future<void> hapusSemua() async {
    _historyModel = _historyModel.hapusSemua();
    notifyListeners();

    await _saveToStorage();
  }

  // ── Query Methods ──────────────────────────────────────────────────────────

  /// Cari item berdasarkan nama
  List<ScanResultModel> cari(String query) {
    if (query.isEmpty) return history;
    final lower = query.toLowerCase();
    return history
        .where(
          (item) =>
              item.namaIndonesia.toLowerCase().contains(lower) ||
              item.namaItem.toLowerCase().contains(lower),
        )
        .toList();
  }

  /// Filter berdasarkan kategori ('buah' atau 'sayuran')
  List<ScanResultModel> filterKategori(String kategori) {
    return _historyModel.filterKategori(kategori);
  }

  /// Ambil N item terbaru
  List<ScanResultModel> getTerbaru(int n) {
    return _historyModel.getTerbaru(n);
  }

  /// Cek apakah item dengan ID tertentu ada di riwayat
  bool exists(String id) {
    return _historyModel.items.any((item) => item.id == id);
  }

  // ── Private Methods ────────────────────────────────────────────────────────

  /// Simpan data ke SharedPreferences
  Future<void> _saveToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = jsonEncode(_historyModel.toJson());
      await prefs.setString(_storageKey, jsonString);
    } catch (e) {
      _errorMessage = 'Gagal menyimpan riwayat: $e';
      debugPrint('HistoryService._saveToStorage error: $e');
      notifyListeners();
    }
  }
}
