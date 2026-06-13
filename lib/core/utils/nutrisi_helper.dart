/// Helper class yang menyediakan data nutrisi buah dan sayuran umum.
/// Data per 100 gram bahan segar.
class NutrisiHelper {
  NutrisiHelper._();

  /// Database nutrisi: key = nama lowercase (bisa bahasa Indonesia atau Inggris)
  static const Map<String, Map<String, dynamic>> _database = {
    // ═══════════════════════════════════════════════════════════════════════
    // BUAH-BUAHAN
    // ═══════════════════════════════════════════════════════════════════════
    'apel': {
      'nama_indonesia': 'Apel',
      'nama_inggris': 'Apple',
      'kategori': 'buah',
      'kalori': 52.0,
      'karbohidrat': 13.8,
      'protein': 0.3,
      'lemak': 0.2,
      'serat': 2.4,
      'vitaminC': 4.6,
      'deskripsi':
          'Apel adalah buah yang berasal dari pohon apel (Malus domestica). '
          'Buah ini kaya akan antioksidan, serat, dan berbagai vitamin. '
          'Tersedia dalam berbagai varietas seperti Fuji, Granny Smith, dan Red Delicious.',
      'manfaat': [
        'Menjaga kesehatan jantung dan mengurangi risiko penyakit kardiovaskular',
        'Membantu menurunkan kadar kolesterol jahat (LDL)',
        'Kaya antioksidan quercetin yang melindungi sel dari kerusakan',
        'Membantu mengontrol kadar gula darah',
        'Baik untuk kesehatan pencernaan berkat kandungan serat pektin',
      ],
      'tips_penyimpanan':
          'Simpan apel di lemari es pada suhu 0–4°C untuk menjaga kesegaran hingga 1–2 bulan. '
          'Jauhkan dari buah lain karena apel mengeluarkan gas etilen yang mempercepat pematangan.',
    },

    'pisang': {
      'nama_indonesia': 'Pisang',
      'nama_inggris': 'Banana',
      'kategori': 'buah',
      'kalori': 89.0,
      'karbohidrat': 23.0,
      'protein': 1.1,
      'lemak': 0.3,
      'serat': 2.6,
      'vitaminC': 8.7,
      'deskripsi':
          'Pisang adalah buah tropis dari genus Musa yang kaya energi dan nutrisi. '
          'Merupakan sumber kalium yang sangat baik dan mengandung berbagai vitamin B. '
          'Pisang matang memiliki rasa manis alami dan tekstur lembut.',
      'manfaat': [
        'Sumber energi cepat yang ideal untuk aktivitas fisik',
        'Tinggi kalium yang mendukung fungsi jantung dan tekanan darah normal',
        'Mengandung triptofan yang membantu produksi serotonin (hormon bahagia)',
        'Membantu pemulihan otot setelah olahraga',
        'Kaya vitamin B6 yang penting untuk metabolisme protein',
      ],
      'tips_penyimpanan':
          'Simpan pisang pada suhu ruangan, jangan masukkan ke kulkas sebelum matang. '
          'Pisang matang bisa disimpan di kulkas (kulit akan menghitam tapi isi tetap segar). '
          'Pisang bisa dibekukan untuk smoothie.',
    },

    'jeruk': {
      'nama_indonesia': 'Jeruk',
      'nama_inggris': 'Orange',
      'kategori': 'buah',
      'kalori': 47.0,
      'karbohidrat': 11.8,
      'protein': 0.9,
      'lemak': 0.1,
      'serat': 2.4,
      'vitaminC': 53.2,
      'deskripsi':
          'Jeruk adalah buah citrus yang kaya vitamin C dan antioksidan. '
          'Berasal dari Asia Tenggara, kini dibudidayakan di seluruh dunia. '
          'Tersedia dalam berbagai varietas seperti jeruk navel, Valencia, dan mandarin.',
      'manfaat': [
        'Sumber vitamin C terbaik untuk meningkatkan imunitas tubuh',
        'Kaya flavonoid yang bersifat anti-inflamasi',
        'Membantu penyerapan zat besi dari makanan',
        'Mendukung kesehatan kulit dan produksi kolagen',
        'Membantu menurunkan tekanan darah',
      ],
      'tips_penyimpanan':
          'Jeruk bisa disimpan di suhu ruang selama 1 minggu atau di kulkas hingga 1 bulan. '
          'Simpan dalam kantong berlubang agar ada sirkulasi udara. '
          'Jangan cuci sebelum disimpan.',
    },

    'mangga': {
      'nama_indonesia': 'Mangga',
      'nama_inggris': 'Mango',
      'kategori': 'buah',
      'kalori': 60.0,
      'karbohidrat': 15.0,
      'protein': 0.8,
      'lemak': 0.4,
      'serat': 1.6,
      'vitaminC': 36.4,
      'deskripsi':
          'Mangga adalah "raja buah tropis" dari Asia Selatan. '
          'Dikenal karena rasanya yang manis dan aromanya yang harum. '
          'Indonesia memiliki banyak varietas mangga seperti Harum Manis, Gedong, dan Manalagi.',
      'manfaat': [
        'Kaya beta-karoten yang diubah menjadi vitamin A untuk kesehatan mata',
        'Mengandung enzim pencernaan amilase dan lipase',
        'Tinggi vitamin C untuk kekebalan tubuh',
        'Mengandung polifenol mangiferin yang bersifat antioksidan kuat',
        'Membantu menjaga kesehatan kulit dan rambut',
      ],
      'tips_penyimpanan':
          'Mangga belum matang simpan di suhu ruang. '
          'Setelah matang, simpan di kulkas hingga 5 hari. '
          'Mangga yang sudah dipotong simpan dalam wadah tertutup di kulkas.',
    },

    'semangka': {
      'nama_indonesia': 'Semangka',
      'nama_inggris': 'Watermelon',
      'kategori': 'buah',
      'kalori': 30.0,
      'karbohidrat': 7.6,
      'protein': 0.6,
      'lemak': 0.2,
      'serat': 0.4,
      'vitaminC': 8.1,
      'deskripsi':
          'Semangka adalah buah musim panas yang terdiri dari 92% air. '
          'Berasal dari Afrika, kini dibudidayakan di daerah tropis dan subtropis. '
          'Daging buahnya berwarna merah atau kuning, manis dan menyegarkan.',
      'manfaat': [
        'Kandungan air tinggi membantu hidrasi tubuh',
        'Kaya likopen yang merupakan antioksidan pelindung sel',
        'Mengandung citrulline yang meningkatkan aliran darah',
        'Rendah kalori, cocok untuk program penurunan berat badan',
        'Membantu mengurangi nyeri otot setelah olahraga',
      ],
      'tips_penyimpanan':
          'Semangka utuh bisa disimpan di suhu ruang 1–2 minggu. '
          'Setelah dipotong, bungkus dengan plastik dan simpan di kulkas maksimal 5 hari. '
          'Hindari membekukan semangka karena akan mengubah teksturnya.',
    },

    'anggur': {
      'nama_indonesia': 'Anggur',
      'nama_inggris': 'Grape',
      'kategori': 'buah',
      'kalori': 69.0,
      'karbohidrat': 18.1,
      'protein': 0.7,
      'lemak': 0.2,
      'serat': 0.9,
      'vitaminC': 3.2,
      'deskripsi':
          'Anggur adalah buah kecil berbentuk bulat yang tumbuh dalam tandan. '
          'Tersedia dalam warna hijau, merah, ungu, dan hitam. '
          'Kaya resveratrol, senyawa yang bermanfaat untuk kesehatan jantung.',
      'manfaat': [
        'Mengandung resveratrol yang melindungi jantung dan pembuluh darah',
        'Kaya antioksidan yang melawan radikal bebas',
        'Membantu menjaga kesehatan otak dan mencegah pikun',
        'Memiliki sifat anti-inflamasi',
        'Mendukung kesehatan tulang berkat kandungan vitamin K',
      ],
      'tips_penyimpanan':
          'Simpan anggur di kulkas dalam kantong plastik berlubang. '
          'Jangan cuci sebelum disimpan. '
          'Anggur segar bisa bertahan 1–2 minggu di kulkas. '
          'Bisa dibekukan untuk camilan sehat.',
    },

    'stroberi': {
      'nama_indonesia': 'Stroberi',
      'nama_inggris': 'Strawberry',
      'kategori': 'buah',
      'kalori': 32.0,
      'karbohidrat': 7.7,
      'protein': 0.7,
      'lemak': 0.3,
      'serat': 2.0,
      'vitaminC': 58.8,
      'deskripsi':
          'Stroberi adalah buah merah berbentuk hati dengan biji kecil di permukaan. '
          'Salah satu buah dengan kandungan vitamin C tertinggi. '
          'Rasanya manis-asam yang khas menjadikannya populer untuk berbagai olahan.',
      'manfaat': [
        'Kandungan vitamin C sangat tinggi untuk imunitas dan kolagen',
        'Kaya asam ellagik yang memiliki sifat anti-kanker',
        'Membantu mengontrol kadar gula darah',
        'Mendukung kesehatan jantung dengan mengurangi kolesterol',
        'Baik untuk kesehatan mata karena mengandung lutein',
      ],
      'tips_penyimpanan':
          'Simpan stroberi di kulkas tanpa dicuci dalam wadah berventilasi. '
          'Cuci hanya saat akan dikonsumsi. '
          'Stroberi segar bertahan 3–7 hari di kulkas. '
          'Bisa dibekukan dalam kondisi kering untuk penggunaan jangka panjang.',
    },

    'pepaya': {
      'nama_indonesia': 'Pepaya',
      'nama_inggris': 'Papaya',
      'kategori': 'buah',
      'kalori': 43.0,
      'karbohidrat': 11.0,
      'protein': 0.5,
      'lemak': 0.3,
      'serat': 1.7,
      'vitaminC': 61.8,
      'deskripsi':
          'Pepaya adalah buah tropis yang tumbuh di kawasan Asia Tenggara dan Amerika Selatan. '
          'Mengandung enzim papain yang membantu pencernaan protein. '
          'Daging buahnya yang oranye kaya beta-karoten dan vitamin C.',
      'manfaat': [
        'Enzim papain membantu pencernaan dan mengatasi sembelit',
        'Kaya beta-karoten dan vitamin C sebagai antioksidan kuat',
        'Membantu mengurangi peradangan dalam tubuh',
        'Mendukung kesehatan kulit dan mencegah penuaan dini',
        'Membantu meningkatkan sistem imun tubuh',
      ],
      'tips_penyimpanan':
          'Pepaya belum matang simpan di suhu ruang hingga matang. '
          'Pepaya matang simpan di kulkas hingga 3–4 hari. '
          'Pepaya yang sudah dipotong harus segera dikonsumsi atau simpan tertutup di kulkas.',
    },

    'nanas': {
      'nama_indonesia': 'Nanas',
      'nama_inggris': 'Pineapple',
      'kategori': 'buah',
      'kalori': 50.0,
      'karbohidrat': 13.1,
      'protein': 0.5,
      'lemak': 0.1,
      'serat': 1.4,
      'vitaminC': 47.8,
      'deskripsi':
          'Nanas adalah buah tropis dengan rasa manis-asam yang menyegarkan. '
          'Mengandung bromelain, enzim protease unik yang memiliki banyak manfaat kesehatan. '
          'Buah asli Amerika Selatan yang kini dibudidayakan di seluruh daerah tropis.',
      'manfaat': [
        'Bromelain membantu pencernaan dan mengurangi peradangan',
        'Kaya mangan untuk kesehatan tulang dan metabolisme energi',
        'Membantu mempercepat pemulihan setelah operasi atau cedera',
        'Kandungan vitamin C tinggi untuk kekebalan tubuh',
        'Memiliki sifat antibakteri alami',
      ],
      'tips_penyimpanan':
          'Nanas utuh yang belum matang simpan di suhu ruang. '
          'Nanas matang simpan di kulkas hingga 5 hari. '
          'Nanas yang sudah dipotong simpan dalam wadah tertutup di kulkas maksimal 3–4 hari.',
    },

    'alpukat': {
      'nama_indonesia': 'Alpukat',
      'nama_inggris': 'Avocado',
      'kategori': 'buah',
      'kalori': 160.0,
      'karbohidrat': 8.5,
      'protein': 2.0,
      'lemak': 14.7,
      'serat': 6.7,
      'vitaminC': 10.0,
      'deskripsi':
          'Alpukat adalah buah unik yang tinggi lemak sehat (lemak tak jenuh tunggal). '
          'Berasal dari Amerika Tengah dan Selatan. '
          'Teksturnya yang creamy menjadikannya populer untuk berbagai hidangan.',
      'manfaat': [
        'Tinggi lemak tak jenuh tunggal yang baik untuk jantung',
        'Kaya kalium bahkan lebih tinggi dari pisang',
        'Mengandung lutein dan zeaxanthin untuk kesehatan mata',
        'Serat tinggi mendukung kesehatan pencernaan',
        'Membantu penyerapan nutrisi larut lemak dari makanan lain',
      ],
      'tips_penyimpanan':
          'Alpukat belum matang simpan di suhu ruang. '
          'Alpukat matang simpan di kulkas hingga 3–5 hari. '
          'Alpukat yang sudah dipotong olesi lemon/jeruk nipis dan simpan di kulkas untuk mencegah oksidasi.',
    },

    // ═══════════════════════════════════════════════════════════════════════
    // SAYURAN
    // ═══════════════════════════════════════════════════════════════════════
    'tomat': {
      'nama_indonesia': 'Tomat',
      'nama_inggris': 'Tomato',
      'kategori': 'sayuran',
      'kalori': 18.0,
      'karbohidrat': 3.9,
      'protein': 0.9,
      'lemak': 0.2,
      'serat': 1.2,
      'vitaminC': 13.7,
      'deskripsi':
          'Tomat adalah buah yang secara kuliner diperlakukan sebagai sayuran. '
          'Kaya likopen, antioksidan kuat yang memberi warna merah khas. '
          'Digunakan dalam berbagai masakan di seluruh dunia.',
      'manfaat': [
        'Likopen melindungi dari kanker prostat dan kanker lainnya',
        'Baik untuk kesehatan jantung dan pembuluh darah',
        'Mendukung kesehatan kulit dengan melindungi dari sinar UV',
        'Rendah kalori cocok untuk diet penurunan berat badan',
        'Mengandung vitamin K untuk kesehatan tulang',
      ],
      'tips_penyimpanan':
          'Tomat segar simpan di suhu ruang, jauh dari sinar matahari langsung. '
          'Hindari menyimpan tomat di kulkas karena merusak rasa dan tekstur. '
          'Tomat yang sudah dipotong bisa disimpan di kulkas dalam wadah tertutup.',
    },

    'wortel': {
      'nama_indonesia': 'Wortel',
      'nama_inggris': 'Carrot',
      'kategori': 'sayuran',
      'kalori': 41.0,
      'karbohidrat': 9.6,
      'protein': 0.9,
      'lemak': 0.2,
      'serat': 2.8,
      'vitaminC': 5.9,
      'deskripsi':
          'Wortel adalah umbi akar berwarna oranye yang sangat kaya beta-karoten. '
          'Digunakan dalam masakan, jus, dan snack sehat. '
          'Salah satu sumber vitamin A terbaik dari sayuran.',
      'manfaat': [
        'Beta-karoten tinggi sangat baik untuk kesehatan mata',
        'Membantu menurunkan risiko penyakit jantung',
        'Kandungan serat membantu pencernaan dan kontrol gula darah',
        'Mendukung kesehatan kulit dan sistem imun',
        'Mengandung falkarinol yang memiliki sifat anti-kanker',
      ],
      'tips_penyimpanan':
          'Simpan wortel di kulkas dalam kantong plastik berlubang. '
          'Pisahkan dari buah-buahan yang mengeluarkan etilen. '
          'Wortel segar bertahan 3–4 minggu di kulkas. '
          'Potong daun wortel sebelum disimpan agar tidak menyedot nutrisi.',
    },

    'brokoli': {
      'nama_indonesia': 'Brokoli',
      'nama_inggris': 'Broccoli',
      'kategori': 'sayuran',
      'kalori': 34.0,
      'karbohidrat': 6.6,
      'protein': 2.8,
      'lemak': 0.4,
      'serat': 2.6,
      'vitaminC': 89.2,
      'deskripsi':
          'Brokoli adalah sayuran cruciferous yang terkenal sebagai "superfood". '
          'Kaya vitamin C, vitamin K, dan berbagai senyawa anti-kanker. '
          'Berasal dari Italia dan kini menjadi salah satu sayuran paling populer.',
      'manfaat': [
        'Sulforafan dalam brokoli memiliki sifat anti-kanker yang kuat',
        'Vitamin C sangat tinggi untuk sistem kekebalan tubuh',
        'Kaya vitamin K untuk pembekuan darah dan kesehatan tulang',
        'Mengandung folat penting untuk ibu hamil',
        'Serat tinggi mendukung kesehatan usus',
      ],
      'tips_penyimpanan':
          'Simpan brokoli di kulkas dalam kantong plastik terbuka. '
          'Jangan cuci sebelum disimpan. '
          'Brokoli segar bertahan 3–5 hari di kulkas. '
          'Blanching dan pembekuan mempertahankan nutrisi lebih lama.',
    },

    'bayam': {
      'nama_indonesia': 'Bayam',
      'nama_inggris': 'Spinach',
      'kategori': 'sayuran',
      'kalori': 23.0,
      'karbohidrat': 3.6,
      'protein': 2.9,
      'lemak': 0.4,
      'serat': 2.2,
      'vitaminC': 28.1,
      'deskripsi':
          'Bayam adalah sayuran hijau berdaun yang sangat kaya nutrisi. '
          'Sumber zat besi, kalsium, dan berbagai vitamin yang luar biasa. '
          'Bisa dimakan segar sebagai salad atau dimasak dalam berbagai hidangan.',
      'manfaat': [
        'Kaya zat besi yang membantu mencegah anemia',
        'Tinggi vitamin K dan kalsium untuk kesehatan tulang',
        'Lutein dan zeaxanthin melindungi kesehatan mata',
        'Antioksidan kuat melindungi dari stres oksidatif',
        'Folat mendukung kesehatan sel dan DNA',
      ],
      'tips_penyimpanan':
          'Simpan bayam di kulkas dalam wadah kedap udara atau kantong plastik. '
          'Jangan cuci sebelum disimpan. '
          'Bayam segar bertahan 3–5 hari di kulkas. '
          'Bayam yang sudah dimasak simpan di wadah tertutup maksimal 3 hari.',
    },

    'kangkung': {
      'nama_indonesia': 'Kangkung',
      'nama_inggris': 'Water Spinach',
      'kategori': 'sayuran',
      'kalori': 19.0,
      'karbohidrat': 3.1,
      'protein': 2.6,
      'lemak': 0.2,
      'serat': 2.1,
      'vitaminC': 55.0,
      'deskripsi':
          'Kangkung adalah sayuran hijau tropis yang sangat populer di Asia Tenggara. '
          'Tumbuh di air atau daratan, kaya nutrisi dan mudah diolah. '
          'Salah satu sayuran paling umum dalam masakan Indonesia.',
      'manfaat': [
        'Kaya vitamin C dan antioksidan untuk kekebalan tubuh',
        'Mengandung zat besi yang mencegah anemia',
        'Serat tinggi mendukung pencernaan yang sehat',
        'Rendah kalori sangat baik untuk diet',
        'Mengandung vitamin A untuk kesehatan mata dan kulit',
      ],
      'tips_penyimpanan':
          'Simpan kangkung segar dengan batangnya direndam dalam air atau bungkus kertas basah. '
          'Kangkung segar bertahan 2–3 hari di suhu ruang atau 4–5 hari di kulkas. '
          'Sebaiknya segera dimasak setelah dibeli.',
    },

    'timun': {
      'nama_indonesia': 'Timun',
      'nama_inggris': 'Cucumber',
      'kategori': 'sayuran',
      'kalori': 16.0,
      'karbohidrat': 3.6,
      'protein': 0.7,
      'lemak': 0.1,
      'serat': 0.5,
      'vitaminC': 2.8,
      'deskripsi':
          'Timun adalah sayuran dengan kandungan air yang sangat tinggi (95%). '
          'Menyegarkan dan rendah kalori, cocok untuk diet. '
          'Sering digunakan sebagai lalapan, acar, atau dalam salad.',
      'manfaat': [
        'Kandungan air tinggi membantu hidrasi tubuh',
        'Rendah kalori ideal untuk program diet',
        'Mengandung cucurbitacin yang bersifat anti-inflamasi',
        'Membantu menurunkan gula darah pada penderita diabetes',
        'Kulit timun mengandung antioksidan dan vitamin K',
      ],
      'tips_penyimpanan':
          'Simpan timun di kulkas dalam kantong plastik. '
          'Timun sensitif terhadap suhu terlalu dingin; simpan di bagian sayur kulkas. '
          'Timun segar bertahan 3–7 hari di kulkas. '
          'Timun yang sudah dipotong bungkus dengan plastik wrap.',
    },

    'cabai': {
      'nama_indonesia': 'Cabai',
      'nama_inggris': 'Chili Pepper',
      'kategori': 'sayuran',
      'kalori': 40.0,
      'karbohidrat': 8.8,
      'protein': 1.9,
      'lemak': 0.4,
      'serat': 1.5,
      'vitaminC': 143.7,
      'deskripsi':
          'Cabai adalah buah dari genus Capsicum yang memberikan rasa pedas. '
          'Mengandung capsaicin, senyawa yang bertanggung jawab atas rasa pedas dan manfaat kesehatannya. '
          'Sangat kaya vitamin C, bahkan lebih tinggi dari jeruk.',
      'manfaat': [
        'Capsaicin meningkatkan metabolisme dan membantu pembakaran lemak',
        'Vitamin C sangat tinggi untuk kekebalan tubuh',
        'Memiliki sifat analgesik alami yang mengurangi rasa sakit',
        'Membantu melancarkan sirkulasi darah',
        'Kaya antioksidan yang melindungi sel dari kerusakan',
      ],
      'tips_penyimpanan':
          'Cabai segar simpan di kulkas dalam kantong kertas atau plastik berlubang. '
          'Cabai segar bertahan 1–2 minggu di kulkas. '
          'Bisa dikeringkan atau dibekukan untuk penyimpanan jangka panjang.',
    },

    'terong': {
      'nama_indonesia': 'Terong',
      'nama_inggris': 'Eggplant',
      'kategori': 'sayuran',
      'kalori': 25.0,
      'karbohidrat': 5.9,
      'protein': 1.0,
      'lemak': 0.2,
      'serat': 3.0,
      'vitaminC': 2.2,
      'deskripsi':
          'Terong adalah sayuran berwarna ungu tua dengan daging putih. '
          'Sangat populer dalam masakan Asia dan Mediterania. '
          'Kaya antosianin, pigmen ungu yang memiliki sifat antioksidan kuat.',
      'manfaat': [
        'Antosianin melindungi jantung dan pembuluh darah',
        'Serat tinggi mendukung pencernaan dan kontrol berat badan',
        'Mengandung nasunin, antioksidan yang melindungi sel otak',
        'Membantu mengontrol kadar gula darah',
        'Rendah kalori cocok untuk diet',
      ],
      'tips_penyimpanan':
          'Simpan terong di suhu ruang jika akan digunakan dalam 1–2 hari. '
          'Untuk penyimpanan lebih lama, simpan di kulkas dalam kantong plastik. '
          'Terong sensitif terhadap suhu dingin; jangan simpan terlalu lama di kulkas.',
    },

    'labu': {
      'nama_indonesia': 'Labu',
      'nama_inggris': 'Pumpkin',
      'kategori': 'sayuran',
      'kalori': 26.0,
      'karbohidrat': 6.5,
      'protein': 1.0,
      'lemak': 0.1,
      'serat': 0.5,
      'vitaminC': 9.0,
      'deskripsi':
          'Labu adalah sayuran dari keluarga Cucurbitaceae yang sangat bergizi. '
          'Daging labu yang oranye kaya beta-karoten dan antioksidan. '
          'Tersedia dalam berbagai ukuran dan varietas.',
      'manfaat': [
        'Beta-karoten tinggi sangat baik untuk kesehatan mata',
        'Kaya vitamin A untuk sistem imun dan kesehatan kulit',
        'Rendah kalori dan kaya serat untuk diet sehat',
        'Mengandung zinc untuk mendukung sistem kekebalan',
        'Potassium membantu menjaga tekanan darah normal',
      ],
      'tips_penyimpanan':
          'Labu utuh bisa disimpan di tempat sejuk dan kering hingga 3 bulan. '
          'Labu yang sudah dipotong bungkus dengan plastik wrap dan simpan di kulkas. '
          'Labu yang sudah dimasak bisa dibekukan hingga 3 bulan.',
    },

    'jagung': {
      'nama_indonesia': 'Jagung',
      'nama_inggris': 'Corn',
      'kategori': 'sayuran',
      'kalori': 86.0,
      'karbohidrat': 19.0,
      'protein': 3.2,
      'lemak': 1.2,
      'serat': 2.7,
      'vitaminC': 6.8,
      'deskripsi':
          'Jagung adalah sereal yang juga dikonsumsi sebagai sayuran. '
          'Merupakan tanaman pangan penting di dunia dan sumber energi yang baik. '
          'Kaya lutein dan zeaxanthin yang bermanfaat untuk kesehatan mata.',
      'manfaat': [
        'Sumber energi yang baik dari karbohidrat kompleks',
        'Lutein dan zeaxanthin melindungi kesehatan mata',
        'Serat mendukung kesehatan pencernaan',
        'Mengandung thiamin (B1) penting untuk fungsi saraf',
        'Antioksidan yang melindungi dari penyakit kronis',
      ],
      'tips_penyimpanan':
          'Jagung segar paling baik dimakan segera setelah dipetik. '
          'Simpan jagung dengan kelobot di kulkas hingga 3 hari. '
          'Jagung yang sudah dipisahkan dari tongkolnya simpan di wadah tertutup di kulkas.',
    },
  };

  /// Mendapatkan data nutrisi berdasarkan nama (Indonesia atau Inggris)
  static Map<String, dynamic>? getNutrisi(String nama) {
    final key = nama.toLowerCase().trim();

    // Coba langsung dengan key
    if (_database.containsKey(key)) {
      return _database[key];
    }

    // Coba cari berdasarkan nama_indonesia atau nama_inggris
    for (final entry in _database.entries) {
      final data = entry.value;
      final namaIndo = (data['nama_indonesia'] as String).toLowerCase();
      final namaEng = (data['nama_inggris'] as String).toLowerCase();

      if (namaIndo == key || namaEng == key) {
        return data;
      }
    }

    // Coba partial match
    for (final entry in _database.entries) {
      final data = entry.value;
      final namaIndo = (data['nama_indonesia'] as String).toLowerCase();
      final namaEng = (data['nama_inggris'] as String).toLowerCase();

      if (namaIndo.contains(key) ||
          key.contains(namaIndo) ||
          namaEng.contains(key) ||
          key.contains(namaEng)) {
        return data;
      }
    }

    return null;
  }

  /// Mendapatkan daftar semua nama yang tersedia
  static List<String> getDaftarNama() {
    return _database.keys.toList();
  }

  /// Mendapatkan semua buah
  static Map<String, Map<String, dynamic>> getBuah() {
    return Map.fromEntries(
      _database.entries.where((e) => e.value['kategori'] == 'buah'),
    );
  }

  /// Mendapatkan semua sayuran
  static Map<String, Map<String, dynamic>> getSayuran() {
    return Map.fromEntries(
      _database.entries.where((e) => e.value['kategori'] == 'sayuran'),
    );
  }
}
