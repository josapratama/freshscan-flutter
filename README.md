# 🍎 FreshScan

**Aplikasi scan buah dan sayuran berbasis AI menggunakan Clarifai Food Recognition API**

---

## ✨ Fitur

- 📷 **Scan via Kamera** - Ambil foto langsung dengan kamera
- 🖼️ **Pilih dari Galeri** - Upload foto dari galeri ponsel
- 🤖 **AI Recognition** - Identifikasi buah/sayuran menggunakan Clarifai API
- 📊 **Info Nutrisi** - Kalori, karbohidrat, protein, lemak, serat, vitamin C
- 💚 **Manfaat Kesehatan** - Deskripsi dan manfaat tiap buah/sayuran
- 💡 **Tips Penyimpanan** - Cara menyimpan agar tetap segar
- 📝 **Riwayat Scan** - Simpan dan lihat kembali hasil scan sebelumnya
- 🗑️ **Swipe to Delete** - Hapus riwayat dengan mudah

---

## 🚀 Cara Setup

### 1. Install Dependencies

```bash
cd freshscan
flutter pub get
```

### 2. Konfigurasi API Key Clarifai

Buka file `lib/data/services/clarifai_service.dart` dan ganti:

```dart
static const String _apiKey = 'YOUR_CLARIFAI_API_KEY';
```

dengan Personal Access Token dari [Clarifai Dashboard](https://clarifai.com/settings/security).

**Langkah mendapatkan API Key:**

1. Daftar/login di [clarifai.com](https://clarifai.com)
2. Pergi ke Settings → Security
3. Buat Personal Access Token baru
4. Copy token dan paste ke `_apiKey`

### 3. Jalankan Aplikasi

```bash
flutter run
```

---

## 📁 Struktur Project

```
freshscan/
├── lib/
│   ├── main.dart                    # Entry point
│   ├── core/
│   │   ├── constants/
│   │   │   ├── app_colors.dart      # Definisi warna
│   │   │   ├── app_strings.dart     # Teks UI (Bahasa Indonesia)
│   │   │   └── app_theme.dart       # Tema Material
│   │   └── utils/
│   │       └── nutrisi_helper.dart  # Database nutrisi
│   ├── data/
│   │   ├── models/
│   │   │   ├── scan_result_model.dart
│   │   │   └── history_model.dart
│   │   └── services/
│   │       ├── clarifai_service.dart # API Clarifai
│   │       └── history_service.dart  # Manajemen riwayat
│   └── presentation/
│       ├── pages/
│       │   ├── splash_page.dart
│       │   ├── home_page.dart
│       │   ├── scan_page.dart
│       │   ├── result_page.dart
│       │   └── history_page.dart
│       └── widgets/
│           ├── scan_button.dart
│           ├── result_card.dart
│           └── history_tile.dart
└── assets/
    ├── images/
    └── animations/
```

---

## 🍃 Data Nutrisi yang Tersedia

### Buah-buahan

Apel, Pisang, Jeruk, Mangga, Semangka, Anggur, Stroberi, Pepaya, Nanas, Alpukat

### Sayuran

Tomat, Wortel, Brokoli, Bayam, Kangkung, Timun, Cabai, Terong, Labu, Jagung

---

## 🛠️ Tech Stack

| Komponen         | Library                        |
| ---------------- | ------------------------------ |
| UI Framework     | Flutter                        |
| State Management | Provider                       |
| HTTP Client      | http                           |
| Image Picker     | image_picker                   |
| Local Storage    | shared_preferences             |
| Font             | Google Fonts (Poppins)         |
| Animasi          | flutter_animate                |
| AI API           | Clarifai Food Item Recognition |

---

## 📱 Persyaratan

- Flutter SDK ≥ 3.0.0
- Android SDK ≥ 21 (Android 5.0)
- Koneksi internet untuk analisis AI
- Kamera (opsional, bisa gunakan galeri)

---

## ⚠️ Catatan

- API Key Clarifai **wajib** dikonfigurasi sebelum menggunakan fitur scan
- Data nutrisi tersimpan lokal, tidak memerlukan internet
- Akurasi identifikasi bergantung pada kualitas foto

---

## 📄 Lisensi

MIT License - Bebas digunakan untuk keperluan belajar dan pengembangan.
