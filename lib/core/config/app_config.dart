/// RASA - Satu file config buat semua.
///
/// Cara pakai (gampang buat buyer):
/// - Demo tanpa Firebase : langsung `flutter run` (default DEMO_MODE=true)
/// - Production          : flutter build apk --dart-define=DEMO_MODE=false
/// - API key Gemini      : --dart-define=GEMINI_KEY=xxx (atau isi manual di bawah)
library;

class AppConfig {
  AppConfig._();

  static const String appName = 'RASA';
  static const String tagline = 'Curhat anonim, ditemani AI & sesama manusia';

  /// true = jalan TANPA Firebase (data dummy lokal). Cocok buat demo & review buyer.
  static const bool kDemoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: true);

  /// API key Gemini (https://aistudio.google.com).
  /// Kalau kosong -> app pakai balasan empati bawaan (tetap jalan, tanpa AI).
  static const String geminiKey =
      String.fromEnvironment('GEMINI_KEY', defaultValue: '');

  /// Batas karakter curhat (disamakan dengan firestore.rules = 500)
  static const int maxPostLength = 280;
  static const int maxReplyLength = 280;
}

/// Model mood — dipakai di onboarding, feed filter, & create post.
class RasaMood {
  final String id;
  final String emoji;
  final String label;
  const RasaMood(this.id, this.emoji, this.label);
}

const List<RasaMood> kMoods = [
  RasaMood('hancur', '😭', 'Hancur'),
  RasaMood('sedih', '😔', 'Sedih'),
  RasaMood('flat', '😐', 'Flat'),
  RasaMood('lumayan', '🙂', 'Lumayan'),
  RasaMood('seneng', '🤩', 'Seneng'),
];

String moodEmoji(String id) =>
    kMoods.firstWhere((m) => m.id == id, orElse: () => kMoods[2]).emoji;

/// Pertanyaan harian biar feed rame terus (diputar per hari).
const List<String> kDailyQuestions = [
  'Hal kecil apa yang bikin lu seneng hari ini?',
  'Kalau bisa ngomong ke diri sendiri 1 tahun lalu, lu mau bilang apa?',
  'Lagu apa yang lagi on-repeat di kepala lu minggu ini?',
  'Satu hal yang pengen lu syukuri malam ini, apa?',
  'Ceritain satu momen minggu ini yang nggak bakal lu lupain.',
  'Kalau besok libur total tanpa HP, lu mau ngapain?',
  'Siapa orang yang paling pengen lu peluk sekarang? Kenapa?',
];

/// Filter kata kasar sederhana (lapis 1 di client, lapis 2 di moderasi admin).
/// Buyer bisa tambah sendiri. Cek: _containsBannedWord() di providers.
const List<String> kBannedWords = [
  'anjing',
  'bangsat',
  'babi',
  'tolol',
  'goblok',
  'kontol',
  'memek',
  'bajingan',
  'kampret',
  'brengsek',
];

/// Balasan empati bawaan — dipakai kalau GEMINI_KEY kosong / offline.
/// Biar buyer tetap bisa demo fitur "AI reply" tanpa keluar modal.
const List<String> kCannedAiReplies = [
  'Denger ceritamu berasa berat banget ya. Makasih udah berani cerita di sini, itu langkah yang gede lho. Mau cerita lebih lanjut? Aku dengerin. 🫂',
  'Wah, kebayang capeknya jadi kamu hari ini. Perasaan kayak gitu tuh valid banget. Pelan-pelan aja ya, kamu nggak sendirian. 💛',
  'Makasih udah jujur sama perasaanmu. Kadang nulis aja udah bikin lega sedikit kan? Kalau mau, ceritain bagian yang paling ganggu pikiranmu malam ini.',
  'Aku nggak bisa ngerasain persisnya, tapi aku di sini buat nemenin. Kamu udah kuat banget bisa lewatin hari ini. Besok kita hadapin bareng ya. 🌙',
  'Cerita kayak gini butuh keberanian. Kamu hebat. Coba tarik napas 3x… terus inget: hari yang berat bukan berarti hidup yang berat. ✨',
];

/// Nama samaran random biar anonim tapi tetap hangat & lucu.
const List<String> kAnonAliases = [
  'Kucing Galau',
  'Kopi Susu',
  'Senja Mendung',
  'Kupu Pagi',
  'Hujan Rintik',
  'Bulan Sabit',
  'Angin Malam',
  'Daun Gugur',
  'Komet Lewat',
  'Embun Pagi',
  'Langit Sore',
  'Ombak Tenang',
];
