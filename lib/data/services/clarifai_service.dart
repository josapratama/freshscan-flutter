import 'dart:convert';
import 'dart:io';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/scan_result_model.dart';
import '../../core/utils/nutrisi_helper.dart';

/// Service untuk komunikasi dengan Clarifai Food Recognition API
class ClarifaiService {
  // ── Konfigurasi API ────────────────────────────────────────────────────────
  /// API Key dibaca dari file .env
  static String get _apiKey =>
      dotenv.env['CLARIFAI_API_KEY'] ?? 'YOUR_CLARIFAI_API_KEY';

  /// URL endpoint Clarifai Food Item Recognition Model
  static const String _apiUrl =
      'https://api.clarifai.com/v2/models/food-item-recognition/versions/1d5fd481e0cf4826aa72ec3ff049e044/outputs';

  /// Timeout untuk request (dalam detik)
  static const int _timeoutSeconds = 30;

  // ── Tabel Terjemahan Inggris → Indonesia ──────────────────────────────────
  static const Map<String, String> _translationMap = {
    'apple': 'apel',
    'banana': 'pisang',
    'orange': 'jeruk',
    'mango': 'mangga',
    'watermelon': 'semangka',
    'grape': 'anggur',
    'grapes': 'anggur',
    'strawberry': 'stroberi',
    'strawberries': 'stroberi',
    'papaya': 'pepaya',
    'pineapple': 'nanas',
    'avocado': 'alpukat',
    'tomato': 'tomat',
    'carrot': 'wortel',
    'broccoli': 'brokoli',
    'spinach': 'bayam',
    'water spinach': 'kangkung',
    'morning glory': 'kangkung',
    'cucumber': 'timun',
    'chili': 'cabai',
    'chili pepper': 'cabai',
    'red chili': 'cabai merah',
    'green chili': 'cabai hijau',
    'eggplant': 'terong',
    'aubergine': 'terong',
    'pumpkin': 'labu',
    'squash': 'labu',
    'corn': 'jagung',
    'maize': 'jagung',
    'durian': 'durian',
    'rambutan': 'rambutan',
    'lychee': 'leci',
    'longan': 'kelengkeng',
    'guava': 'jambu biji',
    'star fruit': 'belimbing',
    'dragon fruit': 'buah naga',
    'passion fruit': 'markisa',
    'jackfruit': 'nangka',
    'breadfruit': 'sukun',
    'salak': 'salak',
    'snake fruit': 'salak',
    'lime': 'jeruk nipis',
    'lemon': 'lemon',
    'mandarin': 'jeruk mandarin',
    'grapefruit': 'jeruk bali',
    'peach': 'persik',
    'plum': 'plum',
    'pear': 'pir',
    'cherry': 'ceri',
    'kiwi': 'kiwi',
    'fig': 'ara',
    'date': 'kurma',
    'coconut': 'kelapa',
    'pomegranate': 'delima',
    'blueberry': 'blueberry',
    'raspberry': 'raspberry',
    'blackberry': 'blackberry',
    'melon': 'melon',
    'cantaloupe': 'melon',
    'honeydew': 'melon hijau',
    'sweet potato': 'ubi jalar',
    'potato': 'kentang',
    'onion': 'bawang',
    'garlic': 'bawang putih',
    'ginger': 'jahe',
    'turmeric': 'kunyit',
    'galangal': 'lengkuas',
    'lemongrass': 'serai',
    'shallot': 'bawang merah',
    'cabbage': 'kubis',
    'lettuce': 'selada',
    'celery': 'seledri',
    'asparagus': 'asparagus',
    'mushroom': 'jamur',
    'bean sprouts': 'tauge',
    'long bean': 'kacang panjang',
    'green bean': 'buncis',
    'pea': 'kacang polong',
    'edamame': 'edamame',
    'bitter melon': 'pare',
    'bottle gourd': 'labu botol',
    'zucchini': 'zukini',
    'bell pepper': 'paprika',
    'capsicum': 'paprika',
    'leek': 'daun bawang',
    'scallion': 'daun bawang',
    'green onion': 'daun bawang',
    'choy sum': 'caisim',
    'bok choy': 'bok choy',
    'kale': 'kale',
    'cauliflower': 'kembang kol',
    'brussels sprout': 'kubis brussel',
    'artichoke': 'artichoke',
    'beet': 'bit',
    'beetroot': 'bit',
    'radish': 'lobak',
    'turnip': 'turnip',
    'okra': 'okra',
    'food': 'makanan',
    'fruit': 'buah',
    'vegetable': 'sayuran',
    'produce': 'produk segar',
    'fresh': 'segar',
  };

  // ── Daftar Buah ───────────────────────────────────────────────────────────
  static const Set<String> _daftarBuah = {
    'apple',
    'banana',
    'orange',
    'mango',
    'watermelon',
    'grape',
    'grapes',
    'strawberry',
    'strawberries',
    'papaya',
    'pineapple',
    'avocado',
    'durian',
    'rambutan',
    'lychee',
    'longan',
    'guava',
    'star fruit',
    'dragon fruit',
    'passion fruit',
    'jackfruit',
    'salak',
    'snake fruit',
    'lime',
    'lemon',
    'mandarin',
    'grapefruit',
    'peach',
    'plum',
    'pear',
    'cherry',
    'kiwi',
    'fig',
    'date',
    'coconut',
    'pomegranate',
    'blueberry',
    'raspberry',
    'blackberry',
    'melon',
    'cantaloupe',
    'honeydew',
    'breadfruit',
  };

  // ── Daftar Sayuran ────────────────────────────────────────────────────────
  static const Set<String> _daftarSayuran = {
    'tomato',
    'carrot',
    'broccoli',
    'spinach',
    'water spinach',
    'morning glory',
    'cucumber',
    'chili',
    'chili pepper',
    'eggplant',
    'aubergine',
    'pumpkin',
    'squash',
    'corn',
    'maize',
    'sweet potato',
    'potato',
    'onion',
    'garlic',
    'ginger',
    'cabbage',
    'lettuce',
    'celery',
    'asparagus',
    'mushroom',
    'bean sprouts',
    'long bean',
    'green bean',
    'pea',
    'edamame',
    'bitter melon',
    'zucchini',
    'bell pepper',
    'capsicum',
    'leek',
    'scallion',
    'green onion',
    'kale',
    'cauliflower',
    'okra',
    'beet',
    'beetroot',
    'radish',
  };

  /// Identifikasi gambar menggunakan Clarifai API
  /// [imagePath] - path file gambar lokal
  /// Returns [ScanResultModel] dengan hasil identifikasi
  Future<ScanResultModel> identifyImage(String imagePath) async {
    // Validasi API key
    if (_apiKey == 'YOUR_CLARIFAI_API_KEY') {
      throw ClarifaiException(
        'API Key belum dikonfigurasi. '
        'Buka lib/data/services/clarifai_service.dart dan ganti YOUR_CLARIFAI_API_KEY '
        'dengan Personal Access Token dari https://clarifai.com/settings/security',
        code: ClarifaiErrorCode.invalidApiKey,
      );
    }

    // Baca file gambar
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw ClarifaiException(
        'File gambar tidak ditemukan: $imagePath',
        code: ClarifaiErrorCode.fileNotFound,
      );
    }

    // Encode gambar ke base64
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // Buat request body
    final requestBody = jsonEncode({
      'inputs': [
        {
          'data': {
            'image': {'base64': base64Image},
          },
        },
      ],
    });

    // Kirim request ke Clarifai API
    late http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_apiUrl),
            headers: {
              'Authorization': 'Key $_apiKey',
              'Content-Type': 'application/json',
            },
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw ClarifaiException(
              'Request timeout setelah $_timeoutSeconds detik',
              code: ClarifaiErrorCode.timeout,
            ),
          );
    } on SocketException {
      throw ClarifaiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        code: ClarifaiErrorCode.networkError,
      );
    }

    // Validasi response HTTP
    if (response.statusCode == 401) {
      throw ClarifaiException(
        'API Key tidak valid atau tidak memiliki akses',
        code: ClarifaiErrorCode.invalidApiKey,
      );
    } else if (response.statusCode == 429) {
      throw ClarifaiException(
        'Batas request API tercapai. Coba lagi nanti.',
        code: ClarifaiErrorCode.rateLimited,
      );
    } else if (response.statusCode != 200) {
      throw ClarifaiException(
        'Server error: HTTP ${response.statusCode}',
        code: ClarifaiErrorCode.serverError,
      );
    }

    // Parse response JSON
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // Validasi status Clarifai
    final status = responseData['status'];
    if (status != null && status['code'] != 10000) {
      throw ClarifaiException(
        'Clarifai API error: ${status['description']}',
        code: ClarifaiErrorCode.serverError,
      );
    }

    // Ekstrak konsep (hasil identifikasi)
    final outputs = responseData['outputs'] as List<dynamic>?;
    if (outputs == null || outputs.isEmpty) {
      throw ClarifaiException(
        'Tidak ada hasil dari API',
        code: ClarifaiErrorCode.noResults,
      );
    }

    final concepts = outputs[0]['data']['concepts'] as List<dynamic>?;
    if (concepts == null || concepts.isEmpty) {
      throw ClarifaiException(
        'AI tidak dapat mengidentifikasi gambar ini',
        code: ClarifaiErrorCode.noResults,
      );
    }

    // Ambil hasil teratas
    final topConcept = concepts[0];
    final topNameEn = (topConcept['name'] as String).toLowerCase();
    final topConfidence = (topConcept['value'] as num).toDouble();

    // Terjemahkan ke Bahasa Indonesia
    final namaIndonesia = _translateToIndonesia(topNameEn);
    final kategori = _getKategori(topNameEn);

    // Ambil alternatif hasil (konsep 2-4)
    final alternatif = <AlternatifHasil>[];
    for (int i = 1; i < concepts.length && i <= 3; i++) {
      final concept = concepts[i];
      final nameEn = (concept['name'] as String).toLowerCase();
      final conf = (concept['value'] as num).toDouble();

      // Filter hanya buah/sayuran untuk alternatif
      if (_isFoodItem(nameEn)) {
        alternatif.add(
          AlternatifHasil(
            nama: _translateToIndonesia(nameEn),
            namaAsli: nameEn,
            confidence: conf,
          ),
        );
      }
    }

    // Lookup data nutrisi
    final nutrisi = NutrisiHelper.getNutrisi(namaIndonesia) ??
        NutrisiHelper.getNutrisi(topNameEn);

    // Buat dan return model hasil
    return ScanResultModel(
      id: _generateId(),
      namaItem: topNameEn,
      namaIndonesia: _capitalizeFirst(namaIndonesia),
      confidence: topConfidence,
      imagePath: imagePath,
      scannedAt: DateTime.now(),
      nutrisi: nutrisi,
      kategori: kategori,
      alternatif: alternatif,
    );
  }

  // ── Private Methods ────────────────────────────────────────────────────────

  /// Terjemahkan nama buah/sayuran dari Inggris ke Indonesia
  String _translateToIndonesia(String englishName) {
    final lower = englishName.toLowerCase().trim();

    // Cek tabel terjemahan langsung
    if (_translationMap.containsKey(lower)) {
      return _translationMap[lower]!;
    }

    // Cek partial match
    for (final entry in _translationMap.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }

    // Kembalikan nama asli jika tidak ada terjemahan
    return englishName;
  }

  /// Tentukan kategori (buah / sayuran / lainnya)
  String _getKategori(String namaInggris) {
    final lower = namaInggris.toLowerCase().trim();

    if (_daftarBuah.contains(lower)) return 'buah';
    if (_daftarSayuran.contains(lower)) return 'sayuran';

    // Partial match
    for (final buah in _daftarBuah) {
      if (lower.contains(buah) || buah.contains(lower)) return 'buah';
    }
    for (final sayuran in _daftarSayuran) {
      if (lower.contains(sayuran) || sayuran.contains(lower)) return 'sayuran';
    }

    return 'lainnya';
  }

  /// Cek apakah nama adalah item makanan (buah atau sayuran)
  bool _isFoodItem(String name) {
    final lower = name.toLowerCase().trim();
    return _daftarBuah.contains(lower) ||
        _daftarSayuran.contains(lower) ||
        _translationMap.containsKey(lower);
  }

  /// Capitalize huruf pertama
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Generate ID unik berdasarkan timestamp
  String _generateId() {
    return 'scan_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ── Exception Classes ──────────────────────────────────────────────────────

/// Kode error untuk ClarifaiException
enum ClarifaiErrorCode {
  invalidApiKey,
  fileNotFound,
  networkError,
  timeout,
  rateLimited,
  serverError,
  noResults,
  unknown,
}

/// Exception khusus untuk error Clarifai API
class ClarifaiException implements Exception {
  final String message;
  final ClarifaiErrorCode code;

  const ClarifaiException(
    this.message, {
    this.code = ClarifaiErrorCode.unknown,
  });

  /// Pesan error yang ramah untuk user (Bahasa Indonesia)
  String get userMessage {
    switch (code) {
      case ClarifaiErrorCode.invalidApiKey:
        return 'API Key tidak valid. Hubungi developer.';
      case ClarifaiErrorCode.fileNotFound:
        return 'File gambar tidak ditemukan.';
      case ClarifaiErrorCode.networkError:
        return 'Tidak dapat terhubung ke internet. Periksa koneksi Anda.';
      case ClarifaiErrorCode.timeout:
        return 'Koneksi timeout. Coba lagi.';
      case ClarifaiErrorCode.rateLimited:
        return 'Batas penggunaan API tercapai. Coba lagi nanti.';
      case ClarifaiErrorCode.serverError:
        return 'Terjadi kesalahan pada server. Coba lagi.';
      case ClarifaiErrorCode.noResults:
        return 'AI tidak dapat mengidentifikasi gambar ini. Coba dengan foto yang lebih jelas.';
      case ClarifaiErrorCode.unknown:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  @override
  String toString() => 'ClarifaiException[$code]: $message';
}
