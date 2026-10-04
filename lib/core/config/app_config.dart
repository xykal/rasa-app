import 'package:flutter/material.dart';

/// RASA - Satu file config buat semua.
///
/// - Demo tanpa Firebase : langsung `flutter run` (default DEMO_MODE=true)
/// - Production          : flutter build apk --dart-define=DEMO_MODE=false
/// - API key Gemini      : --dart-define=GEMINI_KEY=xxx

class AppConfig {
  AppConfig._();

  static const String appName = 'RASA';
  static const String tagline = 'Ruang aman untuk bercerita secara anonim';
  static const String version = '1.1.0';
  static const String supportEmail = 'halo@rasa.app';

  /// true = jalan TANPA Firebase (data dummy lokal). Cocok buat demo & review buyer.
  static const bool kDemoMode =
      bool.fromEnvironment('DEMO_MODE', defaultValue: true);

  /// API key Gemini (https://aistudio.google.com).
  /// Kalau kosong -> app pakai balasan bawaan (tetap jalan, tanpa AI).
  static const String geminiKey =
      String.fromEnvironment('GEMINI_KEY', defaultValue: '');

  /// OneSignal App ID untuk push notification.
  /// Isi via --dart-define=ONESIGNAL_APP_ID=xxx (lihat SETUP.md bagian 8).
  /// Kalau kosong -> modul push nonaktif sendiri, app tetap jalan normal.
  static const String oneSignalAppId =
      String.fromEnvironment('ONESIGNAL_APP_ID', defaultValue: '');

  /// Batas karakter (disamakan dengan firestore.rules = 500)
  static const int maxPostLength = 280;
  static const int maxReplyLength = 280;
  static const int maxAliasLength = 24;

  /// Durasi Biliar Chat dalam detik.
  static const int biliarDurationSec = 300;
}

/// Model mood — ikon + warna konsisten di seluruh aplikasi.
class RasaMood {
  final String id;
  final IconData icon;
  final String label;
  final Color color;
  const RasaMood(this.id, this.icon, this.label, this.color);
}

const List<RasaMood> kMoods = [
  RasaMood(
      'hancur', Icons.sentiment_very_dissatisfied, 'Hancur', Color(0xFFE5484D)),
  RasaMood(
      'sedih', Icons.sentiment_dissatisfied, 'Sedih', Color(0xFFF76B15)),
  RasaMood('flat', Icons.sentiment_neutral, 'Biasa', Color(0xFF8E8C99)),
  RasaMood(
      'lumayan', Icons.sentiment_satisfied, 'Lumayan', Color(0xFF46A758)),
  RasaMood(
      'seneng', Icons.sentiment_very_satisfied, 'Senang', Color(0xFF6C4CF1)),
];

RasaMood moodOf(String id) =>
    kMoods.firstWhere((m) => m.id == id, orElse: () => kMoods[2]);

/// Pertanyaan harian biar feed rame terus (diputar per hari).
const List<String> kDailyQuestions = [
  'Hal kecil apa yang membuatmu senang hari ini?',
  'Jika bisa berbicara dengan dirimu satu tahun lalu, apa yang ingin kamu sampaikan?',
  'Lagu apa yang sedang terngiang di kepalamu minggu ini?',
  'Satu hal yang ingin kamu syukuri malam ini, apa?',
  'Ceritakan satu momen minggu ini yang tidak akan kamu lupakan.',
  'Jika besok libur total tanpa gawai, kamu ingin melakukan apa?',
  'Siapa orang yang paling ingin kamu peluk saat ini? Mengapa?',
];

/// Filter kata kasar (lapis 1 di client, lapis 2 di moderasi admin).
const List<String> kBannedWords = [
  'anjing',
  'bangsat',
  'babi',
  'tolol',
  'goblok',
  'goblog',
  'kontol',
  'memek',
  'bajingan',
  'kampret',
  'brengsek',
  'asu',
  'jancuk',
  'bego',
  'idiot',
  'lonte',
  'pantek',
];

/// Saran cepat di AI Chat.
const List<String> kQuickPrompts = [
  'Saya merasa lelah sekali',
  'Berikan saya semangat',
  'Saya sedang overthinking',
  'Hari ini menyenangkan',
];

/// Alasan laporan konten.
const List<String> kReportReasons = [
  'Ujaran kebencian / perundungan',
  'Spam / promosi',
  'Konten dewasa',
  'Berpotensi membahayakan diri sendiri / orang lain',
  'Lainnya',
];

/// Balasan empati bawaan — dipakai kalau GEMINI_KEY kosong / offline.
/// Biar buyer tetap bisa demo fitur "AI reply" tanpa keluar modal.
const List<String> kCannedAiReplies = [
  'Terima kasih sudah berani bercerita di sini. Apa yang kamu rasakan saat ini valid dan wajar. Jika berkenan, ceritakan lebih lanjut, saya akan mendengarkan.',
  'Terdengar seperti hari yang berat. Tidak apa-apa merasa lelah, istirahat juga bagian dari proses. Pelan-pelan saja, kamu tidak sendirian.',
  'Apresiasi untuk kejujuranmu. Kadang menuliskan perasaan saja sudah sedikit melegakan. Bagian mana yang paling mengganggumu? Mungkin bisa kita uraikan bersama.',
  'Saya tidak bisa merasakan persisnya, tetapi saya di sini untuk menemanimu. Kamu sudah kuat melewati hari ini. Mari hadapi esok hari satu langkah demi satu langkah.',
  'Bercerita seperti ini membutuhkan keberanian, dan kamu sudah melakukannya. Coba tarik napas dalam tiga kali, lalu ingat: hari yang berat bukan berarti hidup yang berat.',
];

/// Nama samaran acak biar anonim tapi tetap hangat.
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
