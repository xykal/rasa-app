import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/config/app_config.dart';
import '../models/post_model.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: AppConfig.geminiKey);
});

/// AI Teman — dibungkus biar aman:
/// - API key kosong / offline / error -> otomatis pakai balasan bawaan.
/// - Jadi app TIDAK PERNAH crash gara-gara AI.
class GeminiService {
  final String apiKey;
  final _rnd = Random();
  GeminiService({required this.apiKey});

  bool get ready => apiKey.isNotEmpty;

  String _canned() => kCannedAiReplies[_rnd.nextInt(kCannedAiReplies.length)];

  /// Respons empati otomatis untuk cerita baru (maksimal 3 kalimat pendek).
  Future<String> empathyReply({
    required String postText,
    required String moodLabel,
  }) async {
    if (!ready) {
      await Future.delayed(const Duration(seconds: 1)); // efek "AI mengetik..."
      return _canned();
    }
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Kamu RASA AI, teman bercerita yang hangat, empatik, dan tidak menghakimi. '
          'Selalu gunakan Bahasa Indonesia yang natural dan sopan (sapaan kamu/saya). '
          'Maksimal 3 kalimat pendek. Jangan gunakan emoji. '
          'Jangan memberikan diagnosa medis. Kalau ada indikasi self-harm, '
          'arahkan dengan lembut untuk menghubungi orang terdekat atau tenaga profesional.',
        ),
      );
      final res = await model.generateContent([
        Content.text(
            'Mood pengguna: $moodLabel.\nCerita: "$postText"\n\nBerikan respons empati:'),
      ]);
      final t = res.text?.trim();
      if (t == null || t.isEmpty) return _canned();
      return t;
    } catch (_) {
      return _canned();
    }
  }

  /// Chat bebas 1-on-1 dengan AI Teman.
  Future<String> chatReply(List<ChatMsg> history, String userMsg) async {
    if (!ready) {
      await Future.delayed(const Duration(milliseconds: 900));
      return _cannedChat(userMsg);
    }
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Kamu RASA AI, teman mengobrol yang hangat dalam Bahasa Indonesia. '
          'Sopan, suportif, maksimal 3 kalimat per balasan, tanpa emoji. '
          'Ajukan pertanyaan balik agar percakapan berjalan.',
        ),
      );
      final chat = model.startChat(history: [
        for (final m in history.take(12))
          Content(m.mine ? 'user' : 'model', [TextPart(m.text)]),
      ]);
      final res = await chat.sendMessage(Content.text(userMsg));
      return res.text?.trim() ?? _cannedChat(userMsg);
    } catch (_) {
      return _cannedChat(userMsg);
    }
  }

  String _cannedChat(String userMsg) {
    final lower = userMsg.toLowerCase();
    if (lower.contains('capek') || lower.contains('lelah')) {
      return 'Terdengar melelahkan. Bagian mana yang paling menguras hari ini? Ceritakan, saya mendengarkan.';
    }
    if (lower.contains('sedih') ||
        lower.contains('nangis') ||
        lower.contains('menangis')) {
      return 'Tidak apa-apa merasa sedih, tidak perlu ditahan. Mau bercerita apa yang membuatmu merasa begitu?';
    }
    if (lower.contains('seneng') ||
        lower.contains('senang') ||
        lower.contains('bahagia') ||
        lower.contains('menyenangkan')) {
      return 'Ikut senang mendengarnya. Ceritakan kabar baiknya, semoga kebahagiaannya menular.';
    }
    if (lower.contains('semangat')) {
      return 'Kamu sudah melakukan yang terbaik hari ini, dan itu cukup. Satu langkah kecil tetaplah kemajuan. Besok kita lanjutkan lagi.';
    }
    if (lower.contains('overthinking') || lower.contains('cemas')) {
      return 'Overthinking memang melelahkan. Coba tulis satu kekhawatiran terbesarmu saat ini, lalu kita uraikan bersama-sama.';
    }
    if (lower.contains('makasih') ||
        lower.contains('terima kasih') ||
        lower.contains('thanks')) {
      return 'Sama-sama. Saya selalu di sini jika kamu butuh teman bercerita lagi. Jaga dirimu baik-baik.';
    }
    const fallback = [
      'Menarik. Bagaimana perasaanmu tentang hal itu?',
      'Saya mendengarkan. Silakan lanjut bercerita, tidak perlu terburu-buru.',
      'Terbayang itu tidak mudah. Jika kamu bisa mengubah satu hal dari situasi itu, apa yang ingin kamu ubah?',
      'Terima kasih sudah bercerita sejujur itu. Apakah kamu merasa sedikit lega setelah menuliskannya?',
    ];
    return fallback[_rnd.nextInt(fallback.length)];
  }
}
