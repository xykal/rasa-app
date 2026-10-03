import 'dart:math';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

import '../../core/config/app_config.dart';
import '../models/post_model.dart';

final geminiServiceProvider = Provider<GeminiService>((ref) {
  return GeminiService(apiKey: AppConfig.geminiKey);
});

/// AI Teman Healing — dibungkus biar aman:
/// - API key kosong / offline / error -> otomatis pakai balasan bawaan.
/// - Jadi app TIDAK PERNAH crash gara-gara AI.
class GeminiService {
  final String apiKey;
  final _rnd = Random();
  GeminiService({required this.apiKey});

  bool get ready => apiKey.isNotEmpty;

  String _canned() => kCannedAiReplies[_rnd.nextInt(kCannedAiReplies.length)];

  /// Balasan empati otomatis untuk postingan baru (max ~3 kalimat, Bahasa Indonesia).
  Future<String> empathyReply({
    required String postText,
    required String moodLabel,
  }) async {
    if (!ready) {
      await Future.delayed(const Duration(seconds: 1)); // efek "AI ngetik..."
      return _canned();
    }
    try {
      final model = GenerativeModel(
        model: 'gemini-1.5-flash',
        apiKey: apiKey,
        systemInstruction: Content.system(
          'Kamu RASA AI, teman curhat yang hangat, empati, dan tidak menghakimi. '
          'Selalu Bahasa Indonesia santai (sapaan kamu/aku). Maksimal 3 kalimat pendek + 1 emoji. '
          'Jangan kasih diagnosa medis. Kalau ada tanda self-harm, arahkan dengan lembut untuk hubungi orang terdekat / profesional.',
        ),
      );
      final res = await model.generateContent([
        Content.text('Mood user: $moodLabel.\nCurhatan: "$postText"\n\nBalas dengan empati:'),
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
          'Kamu RASA AI, teman ngobrol hangat Bahasa Indonesia. Santai, supportif, '
          'maksimal 3 kalimat per balasan. Tanya balik biar obrolan jalan.',
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
      return 'Kebayang capeknya 😔 Hari ini bagian paling ngurasnya yang mana? Ceritain, aku dengerin.';
    }
    if (lower.contains('sedih') || lower.contains('nangis') || lower.contains('😭')) {
      return 'Boleh kok sedih, nggak usah ditahan-tahan. Mau cerita apa yang bikin kamu ngerasa gitu? 🫂';
    }
    if (lower.contains('seneng') || lower.contains('senang') || lower.contains('bahagia')) {
      return 'Ikut seneng dengernya! 🎉 Ceritain dong kabar baiknya, biar kebahagiaannya nular.';
    }
    if (lower.contains('makasih') || lower.contains('terima kasih') || lower.contains('thanks')) {
      return 'Sama-sama 🤍 Aku selalu di sini kalau kamu butuh temen cerita lagi. Jaga dirimu ya.';
    }
    const fallback = [
      'Hmm, menarik. Terus gimana perasaanmu soal itu? 👀',
      'Aku dengerin kok. Mau lanjut cerita? Nggak usah buru-buru. 🌙',
      'Kebayang sih itu nggak gampang. Kalau kamu bisa ubah satu hal dari situ, apa yang pengen kamu ubah?',
      'Makasih udah cerita sejujur itu. Kamu ngerasa sedikit lega nggak abis nulis ini? 💛',
    ];
    return fallback[_rnd.nextInt(fallback.length)];
  }
}
