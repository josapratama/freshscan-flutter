/// Semua string teks UI FreshScan dalam Bahasa Indonesia
class AppStrings {
  AppStrings._();

  // ─── Umum ───────────────────────────────────────────────────────────────────
  static const String appName = 'FreshScan';
  static const String tagline = 'Identifikasi Buah & Sayuran Instan';
  static const String loading = 'Memuat...';
  static const String retry = 'Coba Lagi';
  static const String cancel = 'Batal';
  static const String ok = 'OK';
  static const String delete = 'Hapus';
  static const String back = 'Kembali';
  static const String share = 'Bagikan';
  static const String close = 'Tutup';

  // ─── Splash ─────────────────────────────────────────────────────────────────
  static const String splashLoading = 'Mempersiapkan AI...';

  // ─── Home ───────────────────────────────────────────────────────────────────
  static const String homeGreeting = 'Selamat datang di FreshScan!';
  static const String homeSubtitle =
      'Scan buah & sayuran untuk info nutrisi lengkap';
  static const String scanButton = '📷  Scan dengan Kamera';
  static const String galleryButton = '🖼️  Pilih dari Galeri';
  static const String howToUseTitle = 'Cara Penggunaan';
  static const String step1Title = 'Ambil Foto';
  static const String step1Desc = 'Arahkan kamera ke buah atau sayuran';
  static const String step2Title = 'AI Menganalisis';
  static const String step2Desc = 'Model AI mengidentifikasi jenis produk';
  static const String step3Title = 'Lihat Hasil';
  static const String step3Desc = 'Dapatkan info nutrisi lengkap & manfaat';
  static const String recentHistory = 'Riwayat Terkini';
  static const String lihatSemua = 'Lihat Semua';
  static const String belumAdaRiwayat = 'Belum ada riwayat scan';

  // ─── Scan ────────────────────────────────────────────────────────────────────
  static const String scanTitle = 'Menganalisis Gambar';
  static const String scanAnalyzing = 'Sedang menganalisis...';
  static const String scanAiProcessing =
      'AI sedang mengenali buah/sayuran Anda';
  static const String scanStep1 = '✓ Gambar diterima';
  static const String scanStep2 = '⟳ Mengunggah ke server AI...';
  static const String scanStep3 = '⟳ Model AI mengidentifikasi...';
  static const String scanStep4 = '⟳ Menyiapkan hasil...';
  static const String scanError = 'Gagal menganalisis gambar';
  static const String scanErrorNetwork = 'Periksa koneksi internet Anda';
  static const String scanErrorGeneric =
      'Terjadi kesalahan. Silakan coba lagi.';
  static const String scanErrorNoApiKey =
      'API Key belum dikonfigurasi. Hubungi developer.';

  // ─── Hasil ───────────────────────────────────────────────────────────────────
  static const String resultTitle = 'Hasil Identifikasi';
  static const String resultConfidence = 'Tingkat Keyakinan';
  static const String resultKategori = 'Kategori';
  static const String resultKategoriBuah = '🍎 Buah';
  static const String resultKategoriSayuran = '🥦 Sayuran';
  static const String resultKategoriLainnya = '🌱 Lainnya';

  // ─── Nutrisi ─────────────────────────────────────────────────────────────────
  static const String nutrisiTitle = 'Informasi Nutrisi';
  static const String nutrisiPer100g = 'per 100 gram';
  static const String nutrisiKalori = 'Kalori';
  static const String nutrisiKarbohidrat = 'Karbohidrat';
  static const String nutrisiProtein = 'Protein';
  static const String nutrisiLemak = 'Lemak';
  static const String nutrisiSerat = 'Serat';
  static const String nutrisiVitaminC = 'Vitamin C';
  static const String nutrisiKkal = 'kkal';
  static const String nutrisiGram = 'g';
  static const String nutrisiMg = 'mg';

  // ─── Deskripsi & Manfaat ─────────────────────────────────────────────────────
  static const String deskripsiTitle = 'Deskripsi';
  static const String manfaatTitle = 'Manfaat Kesehatan';
  static const String tipsTitle = 'Tips Penyimpanan';
  static const String alternatifTitle = 'Kemungkinan Lain';

  static const String scanLagi = 'Scan Lagi';
  static const String simpanHasil = 'Simpan Hasil';

  // ─── Riwayat ──────────────────────────────────────────────────────────────────
  static const String historyTitle = 'Riwayat Scan';
  static const String historyEmpty = 'Belum ada riwayat scan';
  static const String historyEmptyDesc =
      'Mulai scan buah atau sayuran untuk melihat riwayat';
  static const String historyDeleteAll = 'Hapus Semua';
  static const String historyDeleteAllConfirm =
      'Hapus semua riwayat scan? Tindakan ini tidak dapat dibatalkan.';
  static const String historyDeleteItem = 'Hapus riwayat ini?';
  static const String historyDeletedMsg = 'Riwayat berhasil dihapus';

  // ─── Error ───────────────────────────────────────────────────────────────────
  static const String errorTitle = 'Terjadi Kesalahan';
  static const String errorNetwork =
      'Tidak dapat terhubung ke server. Periksa koneksi internet.';
  static const String errorTimeout = 'Koneksi timeout. Coba lagi.';
  static const String errorUnknown = 'Kesalahan tidak diketahui.';
  static const String errorPermissionCamera =
      'Izin kamera diperlukan untuk fitur ini';
  static const String errorPermissionGallery =
      'Izin galeri diperlukan untuk fitur ini';
  static const String errorImageNotFound = 'File gambar tidak ditemukan';
  static const String errorApiKey = 'API Key tidak valid. Periksa konfigurasi.';

  // ─── Izin ────────────────────────────────────────────────────────────────────
  static const String permissionCameraTitle = 'Izin Kamera';
  static const String permissionCameraMsg =
      'FreshScan membutuhkan akses kamera untuk mengambil foto buah/sayuran';
  static const String permissionGalleryTitle = 'Izin Galeri';
  static const String permissionGalleryMsg =
      'FreshScan membutuhkan akses galeri untuk memilih foto';
  static const String permissionDenied = 'Izin ditolak';
  static const String openSettings = 'Buka Pengaturan';
}
