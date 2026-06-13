/// Model hasil scan identifikasi buah/sayuran
class ScanResultModel {
  final String id;
  final String namaItem; // Nama dalam bahasa Inggris (dari API)
  final String namaIndonesia; // Nama dalam bahasa Indonesia
  final double confidence; // Tingkat keyakinan 0.0 - 1.0
  final String imagePath; // Path lokal file gambar
  final DateTime scannedAt; // Waktu scan
  final Map<String, dynamic>? nutrisi; // Data nutrisi dari NutrisiHelper
  final String kategori; // 'buah' atau 'sayuran'
  final List<AlternatifHasil> alternatif; // Top 3 hasil alternatif

  const ScanResultModel({
    required this.id,
    required this.namaItem,
    required this.namaIndonesia,
    required this.confidence,
    required this.imagePath,
    required this.scannedAt,
    this.nutrisi,
    required this.kategori,
    this.alternatif = const [],
  });

  /// Persentase confidence (0-100)
  int get confidencePercent => (confidence * 100).round();

  /// Apakah termasuk kategori buah
  bool get isBuah => kategori.toLowerCase() == 'buah';

  /// Apakah termasuk kategori sayuran
  bool get isSayuran => kategori.toLowerCase() == 'sayuran';

  /// Label kategori dalam Bahasa Indonesia
  String get labelKategori {
    switch (kategori.toLowerCase()) {
      case 'buah':
        return '🍎 Buah';
      case 'sayuran':
        return '🥦 Sayuran';
      default:
        return '🌱 Lainnya';
    }
  }

  /// Serialize ke JSON untuk penyimpanan
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'namaItem': namaItem,
      'namaIndonesia': namaIndonesia,
      'confidence': confidence,
      'imagePath': imagePath,
      'scannedAt': scannedAt.toIso8601String(),
      'nutrisi': nutrisi,
      'kategori': kategori,
      'alternatif': alternatif.map((a) => a.toJson()).toList(),
    };
  }

  /// Deserialize dari JSON
  factory ScanResultModel.fromJson(Map<String, dynamic> json) {
    return ScanResultModel(
      id: json['id'] as String,
      namaItem: json['namaItem'] as String,
      namaIndonesia: json['namaIndonesia'] as String,
      confidence: (json['confidence'] as num).toDouble(),
      imagePath: json['imagePath'] as String,
      scannedAt: DateTime.parse(json['scannedAt'] as String),
      nutrisi: json['nutrisi'] as Map<String, dynamic>?,
      kategori: json['kategori'] as String,
      alternatif:
          (json['alternatif'] as List<dynamic>?)
              ?.map((a) => AlternatifHasil.fromJson(a as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Buat salinan dengan field yang diubah
  ScanResultModel copyWith({
    String? id,
    String? namaItem,
    String? namaIndonesia,
    double? confidence,
    String? imagePath,
    DateTime? scannedAt,
    Map<String, dynamic>? nutrisi,
    String? kategori,
    List<AlternatifHasil>? alternatif,
  }) {
    return ScanResultModel(
      id: id ?? this.id,
      namaItem: namaItem ?? this.namaItem,
      namaIndonesia: namaIndonesia ?? this.namaIndonesia,
      confidence: confidence ?? this.confidence,
      imagePath: imagePath ?? this.imagePath,
      scannedAt: scannedAt ?? this.scannedAt,
      nutrisi: nutrisi ?? this.nutrisi,
      kategori: kategori ?? this.kategori,
      alternatif: alternatif ?? this.alternatif,
    );
  }

  @override
  String toString() {
    return 'ScanResultModel(id: $id, namaIndonesia: $namaIndonesia, '
        'confidence: $confidence, kategori: $kategori)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ScanResultModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// Model untuk hasil identifikasi alternatif (selain hasil utama)
class AlternatifHasil {
  final String nama; // Nama dalam Bahasa Indonesia
  final String namaAsli; // Nama asli dari API (Inggris)
  final double confidence; // Tingkat keyakinan 0.0 - 1.0

  const AlternatifHasil({
    required this.nama,
    required this.namaAsli,
    required this.confidence,
  });

  /// Persentase confidence
  int get confidencePercent => (confidence * 100).round();

  /// Serialize ke JSON
  Map<String, dynamic> toJson() {
    return {'nama': nama, 'namaAsli': namaAsli, 'confidence': confidence};
  }

  /// Deserialize dari JSON
  factory AlternatifHasil.fromJson(Map<String, dynamic> json) {
    return AlternatifHasil(
      nama: json['nama'] as String,
      namaAsli: json['namaAsli'] as String? ?? json['nama'] as String,
      confidence: (json['confidence'] as num).toDouble(),
    );
  }

  @override
  String toString() {
    return 'AlternatifHasil(nama: $nama, confidence: $confidence)';
  }
}
