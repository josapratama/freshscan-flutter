import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/scan_result_model.dart';
import '../../core/utils/nutrisi_helper.dart';

/// Service untuk komunikasi dengan Google Gemini Vision API
///
/// Alternatif dari ClarifaiService - interface identik sehingga mudah diganti.
/// Cara mendapatkan API Key (GRATIS):
///   1. Buka https://aistudio.google.com
///   2. Login dengan akun Google
///   3. Klik "Get API Key" → "Create API key"
///   4. Copy key dan paste di bawah
///
/// Free tier: 15 request/menit, 1500 request/hari
class GeminiService {
  // ── Konfigurasi API ────────────────────────────────────────────────────────

  /// API Key dibaca dari file .env
  static String get _apiKey =>
      dotenv.env['GEMINI_API_KEY'] ?? 'YOUR_GEMINI_API_KEY';

  /// Model Gemini yang digunakan
  static const String _model = 'gemini-2.0-flash-lite';

  /// Base URL Gemini API
  static const String _baseUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/$_model:generateContent';

  /// Timeout request dalam detik
  static const int _timeoutSeconds = 30;

  // ── Prompt Template ────────────────────────────────────────────────────────

  /// Prompt instruksi untuk Gemini agar mengenali buah/sayuran
  static const String _prompt = '''
Analisis gambar ini dan identifikasi buah atau sayuran yang ada.

Jawab HANYA dengan format JSON berikut, tanpa teks tambahan apapun:
{
  "terdeteksi": true,
  "nama_inggris": "nama dalam bahasa inggris lowercase",
  "nama_indonesia": "nama dalam bahasa indonesia",
  "kategori": "buah atau sayuran",
  "confidence": 0.95,
  "alternatif": [
    {"nama_inggris": "nama2", "nama_indonesia": "terjemahan2", "confidence": 0.60},
    {"nama_inggris": "nama3", "nama_indonesia": "terjemahan3", "confidence": 0.40}
  ]
}

Aturan:
- confidence adalah nilai 0.0 sampai 1.0
- Jika bukan buah atau sayuran, isi "terdeteksi": false dan nama kosong
- Berikan maksimal 3 alternatif (bisa kosong jika tidak ada)
- kategori harus "buah" atau "sayuran"
''';

  // ── Tabel Terjemahan Fallback ──────────────────────────────────────────────
  // Digunakan jika Gemini tidak memberikan nama Indonesia

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
    'zucchini': 'zukini',
    'bell pepper': 'paprika',
    'capsicum': 'paprika',
    'leek': 'daun bawang',
    'scallion': 'daun bawang',
    'green onion': 'daun bawang',
    'kale': 'kale',
    'cauliflower': 'kembang kol',
    'okra': 'okra',
    'radish': 'lobak',
  };

  // ── Public Method ──────────────────────────────────────────────────────────

  /// Identifikasi gambar menggunakan Gemini Vision API
  /// [imagePath] - path file gambar lokal
  /// Returns [ScanResultModel] dengan hasil identifikasi
  ///
  /// Throws [GeminiException] jika terjadi error
  Future<ScanResultModel> identifyImage(String imagePath) async {
    // Validasi API key
    if (_apiKey == 'YOUR_GEMINI_API_KEY') {
      throw GeminiException(
        'API Key belum dikonfigurasi. '
        'Buka lib/data/services/gemini_service.dart dan ganti YOUR_GEMINI_API_KEY. '
        'Dapatkan API Key gratis di https://aistudio.google.com/app/apikey',
        code: GeminiErrorCode.invalidApiKey,
      );
    }

    // Validasi file gambar
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw GeminiException(
        'File gambar tidak ditemukan: $imagePath',
        code: GeminiErrorCode.fileNotFound,
      );
    }

    // Baca dan encode gambar ke base64
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);

    // Deteksi MIME type dari ekstensi file
    final mimeType = _getMimeType(imagePath);

    // Buat request body Gemini
    final requestBody = jsonEncode({
      'contents': [
        {
          'parts': [
            {'text': _prompt},
            {
              'inline_data': {
                'mime_type': mimeType,
                'data': base64Image,
              },
            },
          ],
        },
      ],
      'generationConfig': {
        'temperature': 0.1, // Rendah = lebih konsisten/akurat
        'topK': 1,
        'topP': 1,
        'maxOutputTokens': 512,
      },
    });

    // Kirim request ke Gemini API
    late http.Response response;
    try {
      response = await http
          .post(
            Uri.parse('$_baseUrl?key=$_apiKey'),
            headers: {'Content-Type': 'application/json'},
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw GeminiException(
              'Request timeout setelah $_timeoutSeconds detik',
              code: GeminiErrorCode.timeout,
            ),
          );
    } on SocketException {
      throw GeminiException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        code: GeminiErrorCode.networkError,
      );
    }

    // Debug: log status dan response body
    debugPrint('[GeminiService] HTTP ${response.statusCode}');
    debugPrint(
        '[GeminiService] Response: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

    // Handle HTTP error codes
    if (response.statusCode == 400) {
      throw GeminiException(
        'Request tidak valid (400): ${response.body.substring(0, response.body.length.clamp(0, 200))}',
        code: GeminiErrorCode.invalidRequest,
      );
    } else if (response.statusCode == 404) {
      throw GeminiException(
        'Model tidak ditemukan. Coba perbarui aplikasi.',
        code: GeminiErrorCode.serverError,
      );
    } else if (response.statusCode == 401 || response.statusCode == 403) {
      throw GeminiException(
        'API Key tidak valid atau tidak memiliki akses',
        code: GeminiErrorCode.invalidApiKey,
      );
    } else if (response.statusCode == 429) {
      throw GeminiException(
        'Batas request API tercapai. Coba lagi beberapa saat.',
        code: GeminiErrorCode.rateLimited,
      );
    } else if (response.statusCode != 200) {
      throw GeminiException(
        'Server error: HTTP ${response.statusCode}',
        code: GeminiErrorCode.serverError,
      );
    }

    // Parse response JSON dari Gemini
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // Ekstrak teks hasil dari Gemini
    final candidates = responseData['candidates'] as List<dynamic>?;
    if (candidates == null || candidates.isEmpty) {
      throw GeminiException(
        'Tidak ada hasil dari API',
        code: GeminiErrorCode.noResults,
      );
    }

    final content = candidates[0]['content'];
    final parts = content['parts'] as List<dynamic>?;
    if (parts == null || parts.isEmpty) {
      throw GeminiException(
        'Response API tidak valid',
        code: GeminiErrorCode.noResults,
      );
    }

    final rawText = parts[0]['text'] as String? ?? '';

    // Parse JSON dari teks respons Gemini
    final Map<String, dynamic> parsedResult = _parseGeminiResponse(rawText);

    // Validasi apakah gambar terdeteksi sebagai buah/sayuran
    final terdeteksi = parsedResult['terdeteksi'] as bool? ?? false;
    if (!terdeteksi) {
      throw GeminiException(
        'Gambar tidak dikenali sebagai buah atau sayuran. '
        'Coba foto ulang dengan pencahayaan lebih baik.',
        code: GeminiErrorCode.notFoodItem,
      );
    }

    // Ambil data hasil utama
    final namaInggris =
        (parsedResult['nama_inggris'] as String? ?? '').toLowerCase().trim();
    final namaIndonesiaRaw =
        (parsedResult['nama_indonesia'] as String? ?? '').trim();
    final kategori =
        (parsedResult['kategori'] as String? ?? 'lainnya').toLowerCase();
    final confidence = (parsedResult['confidence'] as num?)?.toDouble() ?? 0.5;

    // Gunakan nama Indonesia dari Gemini, fallback ke tabel translasi
    final namaIndonesia = namaIndonesiaRaw.isNotEmpty
        ? namaIndonesiaRaw
        : _translateToIndonesia(namaInggris);

    // Parse alternatif hasil
    final alternatifRaw = parsedResult['alternatif'] as List<dynamic>? ?? [];
    final alternatif = alternatifRaw.map((item) {
      final itemMap = item as Map<String, dynamic>;
      final altNamaEn =
          (itemMap['nama_inggris'] as String? ?? '').toLowerCase();
      final altNamaId = (itemMap['nama_indonesia'] as String? ?? '').isNotEmpty
          ? itemMap['nama_indonesia'] as String
          : _translateToIndonesia(altNamaEn);
      final altConf = (itemMap['confidence'] as num?)?.toDouble() ?? 0.0;
      return AlternatifHasil(
        nama: _capitalizeFirst(altNamaId),
        namaAsli: altNamaEn,
        confidence: altConf,
      );
    }).toList();

    // Lookup data nutrisi dari database lokal
    final nutrisi = NutrisiHelper.getNutrisi(namaIndonesia) ??
        NutrisiHelper.getNutrisi(namaInggris);

    // Buat dan return ScanResultModel
    return ScanResultModel(
      id: _generateId(),
      namaItem: namaInggris.isNotEmpty ? namaInggris : namaIndonesia,
      namaIndonesia: _capitalizeFirst(namaIndonesia),
      confidence: confidence,
      imagePath: imagePath,
      scannedAt: DateTime.now(),
      nutrisi: nutrisi,
      kategori: kategori,
      alternatif: alternatif,
    );
  }

  // ── Private Methods ────────────────────────────────────────────────────────

  /// Parse teks respons Gemini menjadi Map JSON
  /// Gemini kadang menambahkan markdown code block, perlu dibersihkan
  Map<String, dynamic> _parseGeminiResponse(String rawText) {
    try {
      // Bersihkan markdown code block jika ada (```json ... ```)
      String cleaned = rawText.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceAll(RegExp(r'^```(?:json)?\s*'), '');
        cleaned = cleaned.replaceAll(RegExp(r'\s*```$'), '');
        cleaned = cleaned.trim();
      }

      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      // Coba ekstrak JSON dari teks jika parsing gagal
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
      if (jsonMatch != null) {
        try {
          return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        } catch (_) {}
      }

      throw GeminiException(
        'AI tidak dapat mengidentifikasi gambar ini dengan benar. '
        'Coba dengan foto yang lebih jelas.',
        code: GeminiErrorCode.parseError,
      );
    }
  }

  /// Terjemahkan nama Inggris ke Indonesia menggunakan tabel fallback
  String _translateToIndonesia(String englishName) {
    final lower = englishName.toLowerCase().trim();
    if (_translationMap.containsKey(lower)) return _translationMap[lower]!;

    // Partial match
    for (final entry in _translationMap.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }
    return englishName; // Kembalikan nama asli jika tidak ada terjemahan
  }

  /// Capitalize huruf pertama string
  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

  /// Deteksi MIME type dari ekstensi file gambar
  String _getMimeType(String filePath) {
    final ext = filePath.toLowerCase().split('.').last;
    switch (ext) {
      case 'jpg':
      case 'jpeg':
        return 'image/jpeg';
      case 'png':
        return 'image/png';
      case 'webp':
        return 'image/webp';
      case 'heic':
        return 'image/heic';
      case 'heif':
        return 'image/heif';
      default:
        return 'image/jpeg'; // Default ke JPEG
    }
  }

  /// Generate ID unik berdasarkan timestamp
  String _generateId() {
    return 'scan_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ── Exception Classes ──────────────────────────────────────────────────────

/// Kode error untuk GeminiException
enum GeminiErrorCode {
  invalidApiKey,
  fileNotFound,
  networkError,
  timeout,
  rateLimited,
  serverError,
  invalidRequest,
  noResults,
  notFoodItem,
  parseError,
  unknown,
}

/// Exception khusus untuk error Gemini API
class GeminiException implements Exception {
  final String message;
  final GeminiErrorCode code;

  const GeminiException(
    this.message, {
    this.code = GeminiErrorCode.unknown,
  });

  /// Pesan error yang ramah untuk user (Bahasa Indonesia)
  String get userMessage {
    switch (code) {
      case GeminiErrorCode.invalidApiKey:
        return 'API Key tidak valid. Periksa konfigurasi di gemini_service.dart.';
      case GeminiErrorCode.fileNotFound:
        return 'File gambar tidak ditemukan.';
      case GeminiErrorCode.networkError:
        return 'Tidak dapat terhubung ke internet. Periksa koneksi Anda.';
      case GeminiErrorCode.timeout:
        return 'Koneksi timeout. Coba lagi.';
      case GeminiErrorCode.rateLimited:
        return 'Batas penggunaan API tercapai. Coba lagi beberapa saat.';
      case GeminiErrorCode.serverError:
        return 'Terjadi kesalahan pada server. Coba lagi.';
      case GeminiErrorCode.invalidRequest:
        return 'Format gambar tidak didukung. Gunakan JPG atau PNG.';
      case GeminiErrorCode.noResults:
        return 'AI tidak dapat memproses gambar ini.';
      case GeminiErrorCode.notFoodItem:
        return 'Gambar tidak dikenali sebagai buah atau sayuran. Coba foto ulang.';
      case GeminiErrorCode.parseError:
        return 'Gagal memproses hasil AI. Coba lagi.';
      case GeminiErrorCode.unknown:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  @override
  String toString() => 'GeminiException[$code]: $message';
}
