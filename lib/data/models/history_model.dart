import 'scan_result_model.dart';

/// Model untuk menyimpan riwayat scan
class HistoryModel {
  final List<ScanResultModel> items;
  final DateTime lastUpdated;

  const HistoryModel({required this.items, required this.lastUpdated});

  /// Buat HistoryModel kosong
  factory HistoryModel.empty() {
    return HistoryModel(items: const [], lastUpdated: DateTime.now());
  }

  /// Jumlah item dalam riwayat
  int get jumlah => items.length;

  /// Apakah riwayat kosong
  bool get isEmpty => items.isEmpty;

  /// Apakah riwayat tidak kosong
  bool get isNotEmpty => items.isNotEmpty;

  /// Ambil item terbaru (urutkan berdasarkan waktu scan, terbaru dulu)
  List<ScanResultModel> get itemsTerbaru {
    final sorted = List<ScanResultModel>.from(items);
    sorted.sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return sorted;
  }

  /// Ambil N item terbaru
  List<ScanResultModel> getTerbaru(int n) {
    return itemsTerbaru.take(n).toList();
  }

  /// Tambah item baru, item terbaru di posisi pertama
  HistoryModel tambahItem(ScanResultModel item) {
    final newItems = [item, ...items];
    return HistoryModel(items: newItems, lastUpdated: DateTime.now());
  }

  /// Hapus item berdasarkan id
  HistoryModel hapusItem(String id) {
    final newItems = items.where((item) => item.id != id).toList();
    return HistoryModel(items: newItems, lastUpdated: DateTime.now());
  }

  /// Hapus semua item
  HistoryModel hapusSemua() {
    return HistoryModel(items: const [], lastUpdated: DateTime.now());
  }

  /// Filter berdasarkan kategori
  List<ScanResultModel> filterKategori(String kategori) {
    return items
        .where((item) => item.kategori.toLowerCase() == kategori.toLowerCase())
        .toList();
  }

  /// Serialize ke JSON
  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'lastUpdated': lastUpdated.toIso8601String(),
    };
  }

  /// Deserialize dari JSON
  factory HistoryModel.fromJson(Map<String, dynamic> json) {
    final itemsList = json['items'] as List<dynamic>? ?? [];
    return HistoryModel(
      items: itemsList
          .map((item) => ScanResultModel.fromJson(item as Map<String, dynamic>))
          .toList(),
      lastUpdated: json['lastUpdated'] != null
          ? DateTime.parse(json['lastUpdated'] as String)
          : DateTime.now(),
    );
  }

  /// Buat salinan dengan field yang diubah
  HistoryModel copyWith({List<ScanResultModel>? items, DateTime? lastUpdated}) {
    return HistoryModel(
      items: items ?? this.items,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  String toString() {
    return 'HistoryModel(jumlah: $jumlah, lastUpdated: $lastUpdated)';
  }
}
