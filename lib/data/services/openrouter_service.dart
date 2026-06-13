import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import '../models/scan_result_model.dart';
import '../../core/utils/nutrisi_helper.dart';

/// Service untuk komunikasi dengan OpenRouter API (alternatif Gemini)
///
/// Cara mendapatkan API Key (GRATIS, mudah):
///   1. Buka https://openrouter.ai
///   2. Klik "Sign In" → Sign in dengan Google/GitHub/Email
///   3. Setelah login, klik profil → "Keys"
///   4. Klik "Create Key" → beri nama "FreshScan" → Copy key
///   5. Paste di bawah
///
/// Free tier: Model gratis tersedia tanpa batas (google/gemini-flash-1.5-8b-exp:free)
class OpenRouterService {
  // ── Konfigurasi API ────────────────────────────────────────────────────────

  /// API Key dibaca dari file .env
  static String get _apiKey =>
      dotenv.env['OPENROUTER_API_KEY'] ?? 'YOUR_OPENROUTER_API_KEY';

  /// Model yang digunakan (gratis, support vision)
  static const String _model = 'nvidia/nemotron-nano-12b-v2-vl:free';

  /// Base URL OpenRouter API
  static const String _baseUrl =
      'https://openrouter.ai/api/v1/chat/completions';

  /// Timeout request dalam detik
  static const int _timeoutSeconds = 30;

  // ── Prompt Template ────────────────────────────────────────────────────────

  static const String _systemPrompt = '''
Kamu adalah AI untuk identifikasi buah dan sayuran. Analisis gambar dan jawab dengan format JSON berikut:

{
  "terdeteksi": true,
  "nama_inggris": "nama lowercase",
  "nama_indonesia": "terjemahan indonesia",
  "kategori": "buah atau sayuran",
  "confidence": 0.95,
  "alternatif": [
    {"nama_inggris": "apple", "nama_indonesia": "apel", "confidence": 0.60}
  ]
}

Aturan:
- confidence: 0.0 - 1.0
- Jika bukan buah/sayuran: terdeteksi=false
- Maksimal 2 alternatif
- Hanya JSON, tidak ada teks lain
''';

  // ── Tabel Terjemahan ───────────────────────────────────────────────────────

  static const Map<String, String> _translationMap = {
    'apple': 'apel',
    'banana': 'pisang',
    'orange': 'jeruk',
    'mango': 'mangga',
    'watermelon': 'semangka',
    'grape': 'anggur',
    'strawberry': 'stroberi',
    'papaya': 'pepaya',
    'pineapple': 'nanas',
    'avocado': 'alpukat',
    'tomato': 'tomat',
    'carrot': 'wortel',
    'broccoli': 'brokoli',
    'spinach': 'bayam',
    'cucumber': 'timun',
    'chili': 'cabai',
    'eggplant': 'terong',
    'pumpkin': 'labu',
    'corn': 'jagung',
    'potato': 'kentang',
    'onion': 'bawang',
    'garlic': 'bawang putih',
    'ginger': 'jahe',
    'cabbage': 'kubis',
    'lettuce': 'selada',
    'mushroom': 'jamur',
    'bell pepper': 'paprika',
    'cauliflower': 'kembang kol',
  };

  // ── Public Method ──────────────────────────────────────────────────────────

  /// Identifikasi gambar menggunakan OpenRouter API
  Future<ScanResultModel> identifyImage(String imagePath) async {
    // Validasi API key
    if (_apiKey == 'YOUR_OPENROUTER_API_KEY') {
      throw OpenRouterException(
        'API Key belum dikonfigurasi. '
        'Buka lib/data/services/openrouter_service.dart dan ganti YOUR_OPENROUTER_API_KEY. '
        'Dapatkan API Key gratis di https://openrouter.ai/keys',
        code: OpenRouterErrorCode.invalidApiKey,
      );
    }

    // Validasi file gambar
    final imageFile = File(imagePath);
    if (!await imageFile.exists()) {
      throw OpenRouterException(
        'File gambar tidak ditemukan: $imagePath',
        code: OpenRouterErrorCode.fileNotFound,
      );
    }

    // Baca dan encode gambar ke base64
    final imageBytes = await imageFile.readAsBytes();
    final base64Image = base64Encode(imageBytes);
    final mimeType = _getMimeType(imagePath);

    // Buat request body OpenRouter (format OpenAI-compatible)
    final requestBody = jsonEncode({
      'model': _model,
      'messages': [
        {
          'role': 'system',
          'content': _systemPrompt,
        },
        {
          'role': 'user',
          'content': [
            {
              'type': 'text',
              'text': 'Identifikasi buah atau sayuran dalam gambar ini.',
            },
            {
              'type': 'image_url',
              'image_url': {
                'url': 'data:$mimeType;base64,$base64Image',
              },
            },
          ],
        },
      ],
      'temperature': 0.1,
      'max_tokens': 512,
    });

    // Kirim request ke OpenRouter API
    late http.Response response;
    try {
      response = await http
          .post(
            Uri.parse(_baseUrl),
            headers: {
              'Authorization': 'Bearer $_apiKey',
              'Content-Type': 'application/json',
              'HTTP-Referer': 'https://github.com/freshscan/app',
              'X-Title': 'FreshScan',
            },
            body: requestBody,
          )
          .timeout(
            const Duration(seconds: _timeoutSeconds),
            onTimeout: () => throw OpenRouterException(
              'Request timeout setelah $_timeoutSeconds detik',
              code: OpenRouterErrorCode.timeout,
            ),
          );
    } on SocketException {
      throw OpenRouterException(
        'Tidak dapat terhubung ke server. Periksa koneksi internet Anda.',
        code: OpenRouterErrorCode.networkError,
      );
    }

    // Debug log
    debugPrint('[OpenRouterService] HTTP ${response.statusCode}');
    debugPrint(
        '[OpenRouterService] Response: ${response.body.substring(0, response.body.length.clamp(0, 500))}');

    // Handle HTTP error codes
    if (response.statusCode == 400) {
      final body = jsonDecode(response.body);
      final msg = body['error']?['message'] ?? 'Request tidak valid';
      throw OpenRouterException(
        msg,
        code: OpenRouterErrorCode.invalidRequest,
      );
    } else if (response.statusCode == 401) {
      throw OpenRouterException(
        'API Key tidak valid. Periksa konfigurasi.',
        code: OpenRouterErrorCode.invalidApiKey,
      );
    } else if (response.statusCode == 402) {
      throw OpenRouterException(
        'Kredit habis. Gunakan model gratis atau isi kredit.',
        code: OpenRouterErrorCode.insufficientCredits,
      );
    } else if (response.statusCode == 429) {
      throw OpenRouterException(
        'Terlalu banyak request. Coba lagi sebentar.',
        code: OpenRouterErrorCode.rateLimited,
      );
    } else if (response.statusCode != 200) {
      throw OpenRouterException(
        'Server error: HTTP ${response.statusCode}',
        code: OpenRouterErrorCode.serverError,
      );
    }

    // Parse response JSON
    final Map<String, dynamic> responseData = jsonDecode(response.body);

    // Ekstrak teks dari response
    final choices = responseData['choices'] as List<dynamic>?;
    if (choices == null || choices.isEmpty) {
      throw OpenRouterException(
        'Tidak ada hasil dari API',
        code: OpenRouterErrorCode.noResults,
      );
    }

    final message = choices[0]['message'];
    final rawText = message['content'] as String? ?? '';

    // Parse JSON dari teks respons
    final Map<String, dynamic> parsedResult = _parseResponse(rawText);

    // Validasi apakah gambar terdeteksi sebagai buah/sayuran
    final terdeteksi = parsedResult['terdeteksi'] as bool? ?? false;
    if (!terdeteksi) {
      throw OpenRouterException(
        'Gambar tidak dikenali sebagai buah atau sayuran. Coba foto ulang.',
        code: OpenRouterErrorCode.notFoodItem,
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

    // Gunakan nama Indonesia dari AI, fallback ke tabel translasi
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

  /// Parse teks respons menjadi Map JSON
  Map<String, dynamic> _parseResponse(String rawText) {
    try {
      // Bersihkan markdown code block jika ada
      String cleaned = rawText.trim();
      if (cleaned.startsWith('```')) {
        cleaned = cleaned.replaceAll(RegExp(r'^```(?:json)?\s*'), '');
        cleaned = cleaned.replaceAll(RegExp(r'\s*```$'), '');
        cleaned = cleaned.trim();
      }

      return jsonDecode(cleaned) as Map<String, dynamic>;
    } catch (_) {
      // Coba ekstrak JSON dari teks
      final jsonMatch = RegExp(r'\{[\s\S]*\}').firstMatch(rawText);
      if (jsonMatch != null) {
        try {
          return jsonDecode(jsonMatch.group(0)!) as Map<String, dynamic>;
        } catch (_) {}
      }

      throw OpenRouterException(
        'Gagal memproses hasil AI. Coba lagi.',
        code: OpenRouterErrorCode.parseError,
      );
    }
  }

  String _translateToIndonesia(String englishName) {
    final lower = englishName.toLowerCase().trim();
    if (_translationMap.containsKey(lower)) return _translationMap[lower]!;

    for (final entry in _translationMap.entries) {
      if (lower.contains(entry.key) || entry.key.contains(lower)) {
        return entry.value;
      }
    }
    return englishName;
  }

  String _capitalizeFirst(String text) {
    if (text.isEmpty) return text;
    return text[0].toUpperCase() + text.substring(1);
  }

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
      default:
        return 'image/jpeg';
    }
  }

  String _generateId() {
    return 'scan_${DateTime.now().millisecondsSinceEpoch}';
  }
}

// ── Exception Classes ──────────────────────────────────────────────────────

enum OpenRouterErrorCode {
  invalidApiKey,
  fileNotFound,
  networkError,
  timeout,
  rateLimited,
  insufficientCredits,
  serverError,
  invalidRequest,
  noResults,
  notFoodItem,
  parseError,
  unknown,
}

class OpenRouterException implements Exception {
  final String message;
  final OpenRouterErrorCode code;

  const OpenRouterException(
    this.message, {
    this.code = OpenRouterErrorCode.unknown,
  });

  String get userMessage {
    switch (code) {
      case OpenRouterErrorCode.invalidApiKey:
        return 'API Key tidak valid. Periksa konfigurasi di openrouter_service.dart.';
      case OpenRouterErrorCode.fileNotFound:
        return 'File gambar tidak ditemukan.';
      case OpenRouterErrorCode.networkError:
        return 'Tidak dapat terhubung ke internet. Periksa koneksi Anda.';
      case OpenRouterErrorCode.timeout:
        return 'Koneksi timeout. Coba lagi.';
      case OpenRouterErrorCode.rateLimited:
        return 'Terlalu banyak request. Tunggu sebentar dan coba lagi.';
      case OpenRouterErrorCode.insufficientCredits:
        return 'Kredit habis. Gunakan model gratis atau isi kredit.';
      case OpenRouterErrorCode.serverError:
        return 'Terjadi kesalahan pada server. Coba lagi.';
      case OpenRouterErrorCode.invalidRequest:
        return 'Format gambar tidak didukung. Gunakan JPG atau PNG.';
      case OpenRouterErrorCode.noResults:
        return 'AI tidak dapat memproses gambar ini.';
      case OpenRouterErrorCode.notFoodItem:
        return 'Gambar tidak dikenali sebagai buah atau sayuran. Coba foto ulang.';
      case OpenRouterErrorCode.parseError:
        return 'Gagal memproses hasil AI. Coba lagi.';
      case OpenRouterErrorCode.unknown:
        return 'Terjadi kesalahan. Silakan coba lagi.';
    }
  }

  @override
  String toString() => 'OpenRouterException[$code]: $message';
}
