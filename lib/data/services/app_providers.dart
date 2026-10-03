import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../core/config/app_config.dart';
import '../dummy_data.dart';
import '../models/post_model.dart';
import 'gemini_service.dart';

const _uuid = Uuid();

/// Nama tampilan asisten AI di seluruh aplikasi.
const String kAiAlias = 'RASA AI';

/// true = data lokal (demo). Bisa di-toggle live dari halaman Profil.
/// Default dari --dart-define=DEMO_MODE (default: true).
final demoModeProvider = StateProvider<bool>((ref) => AppConfig.kDemoMode);

/// Kata kunci pencarian di feed.
final searchQueryProvider = StateProvider<String>((ref) => '');

bool get _cloudReady {
  try {
    return Firebase.apps.isNotEmpty;
  } catch (_) {
    return false;
  }
}

// ─── TEMA (terang / gelap / sistem, tersimpan) ───────────────────

final themeModeProvider =
    StateNotifierProvider<ThemeNotifier, ThemeMode>((ref) {
  return ThemeNotifier();
});

class ThemeNotifier extends StateNotifier<ThemeMode> {
  ThemeNotifier() : super(ThemeMode.system) {
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      state = switch (p.getString('rasa_theme')) {
        'light' => ThemeMode.light,
        'dark' => ThemeMode.dark,
        _ => ThemeMode.system,
      };
    } catch (_) {}
  }

  Future<void> setMode(ThemeMode mode) async {
    state = mode;
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(
        'rasa_theme',
        switch (mode) {
          ThemeMode.light => 'light',
          ThemeMode.dark => 'dark',
          ThemeMode.system => 'system',
        },
      );
    } catch (_) {}
  }
}

// ─── SESSION (user anonim + streak) ──────────────────────────────

class SessionState {
  final String userId;
  final String alias;
  final bool onboarded;
  final bool initialized;
  final String? todayMood;
  final int streak;
  const SessionState({
    required this.userId,
    required this.alias,
    required this.onboarded,
    required this.initialized,
    required this.todayMood,
    required this.streak,
  });

  SessionState copyWith({
    String? alias,
    bool? onboarded,
    bool? initialized,
    String? todayMood,
    int? streak,
  }) {
    return SessionState(
      userId: userId,
      alias: alias ?? this.alias,
      onboarded: onboarded ?? this.onboarded,
      initialized: initialized ?? this.initialized,
      todayMood: todayMood ?? this.todayMood,
      streak: streak ?? this.streak,
    );
  }
}

final sessionProvider =
    StateNotifierProvider<SessionNotifier, SessionState>((ref) {
  return SessionNotifier(ref);
});

class SessionNotifier extends StateNotifier<SessionState> {
  final Ref ref;
  SessionNotifier(this.ref)
      : super(
          SessionState(
            userId: _uuid.v4(),
            alias: kAnonAliases[Random().nextInt(kAnonAliases.length)],
            onboarded: false,
            initialized: false,
            todayMood: null,
            streak: 0,
          ),
        ) {
    _load();
  }

  Future<void> _load() async {
    try {
      final p = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);

      // Firebase anonymous login (mode production saja)
      String uid = p.getString('rasa_user_id') ?? _uuid.v4();
      if (!ref.read(demoModeProvider) && _cloudReady) {
        try {
          final cred = await FirebaseAuth.instance.signInAnonymously();
          if (cred.user != null) uid = cred.user!.uid;
        } catch (_) {}
      }

      // Streak: reset kalau kemarin bolong
      int streak = p.getInt('rasa_streak') ?? 0;
      final lastActive = p.getString('rasa_last_active');
      if (lastActive != null && lastActive != today) {
        final diff =
            DateTime.parse(today).difference(DateTime.parse(lastActive)).inDays;
        if (diff > 1) streak = 0;
      }

      state = SessionState(
        userId: uid,
        alias: p.getString('rasa_alias') ?? state.alias,
        onboarded: p.getBool('rasa_onboarded') ?? false,
        initialized: true,
        todayMood: p.getString('rasa_mood_date') == today
            ? p.getString('rasa_mood')
            : null,
        streak: streak,
      );
      await p.setString('rasa_user_id', uid);
    } catch (_) {
      state = state.copyWith(initialized: true);
    }
  }

  Future<void> finishOnboarding(String mood) async {
    state = state.copyWith(onboarded: true, todayMood: mood);
    try {
      final p = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      await p.setBool('rasa_onboarded', true);
      await p.setString('rasa_mood', mood);
      await p.setString('rasa_mood_date', today);
      await p.setString('rasa_alias', state.alias);
    } catch (_) {}
  }

  Future<void> shuffleAlias() async {
    final next = kAnonAliases[Random().nextInt(kAnonAliases.length)];
    state = state.copyWith(alias: next);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('rasa_alias', next);
    } catch (_) {}
  }

  /// Ganti nama samaran manual. Return error kalau tidak valid.
  Future<String?> setAlias(String alias) async {
    final clean = alias.trim();
    if (clean.isEmpty) return 'Nama samaran tidak boleh kosong.';
    if (clean.length > AppConfig.maxAliasLength) {
      return 'Maksimal ${AppConfig.maxAliasLength} karakter.';
    }
    if (containsBanned(clean)) {
      return 'Nama samaran mengandung kata yang kurang pantas.';
    }
    state = state.copyWith(alias: clean);
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString('rasa_alias', clean);
    } catch (_) {}
    return null;
  }

  /// Dipanggil tiap user bikin cerita/tanggapan → update streak harian.
  Future<void> markActiveToday() async {
    try {
      final p = await SharedPreferences.getInstance();
      final today = DateTime.now().toIso8601String().substring(0, 10);
      final last = p.getString('rasa_last_active');
      var streak = state.streak;
      if (last != today) {
        final diff = last == null
            ? 99
            : DateTime.parse(today).difference(DateTime.parse(last)).inDays;
        streak = (diff == 1) ? streak + 1 : 1;
        await p.setString('rasa_last_active', today);
        await p.setInt('rasa_streak', streak);
        state = state.copyWith(streak: streak);
      }
    } catch (_) {}
  }
}

// ─── FILTER KATA KASAR (lapis client) ────────────────────────────

bool containsBanned(String text) {
  final lower = text.toLowerCase();
  return kBannedWords.any(lower.contains);
}

// ─── FEED ────────────────────────────────────────────────────────

final moodFilterProvider = StateProvider<String?>((ref) => null);

final feedProvider = StateNotifierProvider<FeedNotifier, List<RasaPost>>((ref) {
  return FeedNotifier(ref);
});

class FeedNotifier extends StateNotifier<List<RasaPost>> {
  final Ref ref;
  FeedNotifier(this.ref) : super([]) {
    _init();
  }

  bool get _useCloud => !ref.read(demoModeProvider) && _cloudReady;

  Future<void> _init() async {
    if (_useCloud) {
      try {
        FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .snapshots()
            .listen((snap) {
          state =
              snap.docs.map((d) => RasaPost.fromMap(d.id, d.data())).toList();
        }, onError: (_) => state = dummyPosts());
        return;
      } catch (_) {}
    }
    // Demo mode: data dummy + jeda kecil biar ada efek loading
    await Future.delayed(const Duration(milliseconds: 600));
    state = dummyPosts();
  }

  /// Dipanggil pull-to-refresh. Mode cloud ambil ulang, demo biarkan state.
  Future<void> reload() async {
    if (_useCloud) {
      try {
        final snap = await FirebaseFirestore.instance
            .collection('posts')
            .orderBy('createdAt', descending: true)
            .limit(50)
            .get();
        state = snap.docs.map((d) => RasaPost.fromMap(d.id, d.data())).toList();
      } catch (_) {}
      return;
    }
    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Bikin cerita baru. Return error message kalau gagal, null kalau sukses.
  Future<String?> addPost({required String text, required String mood}) async {
    final clean = text.trim();
    if (clean.isEmpty) return 'Tulis dulu ceritamu.';
    if (clean.length > AppConfig.maxPostLength) {
      return 'Maksimal ${AppConfig.maxPostLength} karakter ya.';
    }
    if (containsBanned(clean)) {
      return 'Ada kata yang kurang pantas. Coba ubah sedikit bahasanya.';
    }

    final s = ref.read(sessionProvider);
    final post = RasaPost(
      id: _uuid.v4(),
      text: clean,
      mood: mood,
      authorId: s.userId,
      alias: s.alias,
      createdAt: DateTime.now(),
    );

    if (_useCloud) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('posts')
            .add(post.toMap());
        // AI reply async (tidak blocking UI)
        _attachAi(doc.id, clean, mood);
        ref.read(sessionProvider.notifier).markActiveToday();
        return null;
      } catch (_) {
        return 'Gagal mengirim. Periksa koneksi lalu coba lagi.';
      }
    }

    state = [post, ...state];
    ref.read(sessionProvider.notifier).markActiveToday();

    // AI reply otomatis (delay biar natural)
    final ai = await ref
        .read(geminiServiceProvider)
        .empathyReply(postText: clean, moodLabel: mood);
    state = [
      for (final p in state) p.id == post.id ? p.copyWith(aiReply: ai) : p,
    ];
    ref.read(repliesProvider(post.id).notifier).addAiReply(ai, postId: post.id);
    return null;
  }

  Future<void> _attachAi(String postId, String text, String mood) async {
    try {
      final ai = await ref
          .read(geminiServiceProvider)
          .empathyReply(postText: text, moodLabel: mood);
      final db = FirebaseFirestore.instance;
      await db.collection('posts').doc(postId).update({'aiReply': ai});
      await db.collection('posts').doc(postId).collection('replies').add(
            RasaReply(
              id: _uuid.v4(),
              postId: postId,
              text: ai,
              alias: kAiAlias,
              authorId: 'ai',
              createdAt: DateTime.now(),
              isAI: true,
            ).toMap(),
          );
      await db.collection('posts').doc(postId).update({
        'replyCount': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  /// Hapus cerita milik sendiri.
  Future<void> deletePost(String postId) async {
    if (_useCloud) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .delete();
      } catch (_) {}
    }
    state = [for (final p in state) if (p.id != postId) p];
  }

  void toggleHug(String postId) {
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(
            hugged: !p.hugged,
            hugCount: p.hugCount + (p.hugged ? -1 : 1),
          )
        else
          p,
    ];
    if (_useCloud) {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'hugCount': FieldValue.increment(1),
      }).ignore();
    }
  }

  void toggleMeToo(String postId) {
    state = [
      for (final p in state)
        if (p.id == postId)
          p.copyWith(
            meToo: !p.meToo,
            meTooCount: p.meTooCount + (p.meToo ? -1 : 1),
          )
        else
          p,
    ];
    if (_useCloud) {
      FirebaseFirestore.instance.collection('posts').doc(postId).update({
        'meTooCount': FieldValue.increment(1),
      }).ignore();
    }
  }

  void bumpReplyCount(String postId) {
    state = [
      for (final p in state)
        if (p.id == postId) p.copyWith(replyCount: p.replyCount + 1) else p,
    ];
  }

  void debumpReplyCount(String postId) {
    state = [
      for (final p in state)
        if (p.id == postId && p.replyCount > 0)
          p.copyWith(replyCount: p.replyCount - 1)
        else
          p,
    ];
  }
}

// ─── REPLIES (per cerita) ────────────────────────────────────────

final repliesProvider =
    StateNotifierProvider.family<RepliesNotifier, List<RasaReply>, String>(
        (ref, postId) {
  return RepliesNotifier(ref, postId);
});

class RepliesNotifier extends StateNotifier<List<RasaReply>> {
  final Ref ref;
  final String postId;
  RepliesNotifier(this.ref, this.postId) : super([]) {
    _init();
  }

  bool get _useCloud => !ref.read(demoModeProvider) && _cloudReady;

  Future<void> _init() async {
    if (_useCloud) {
      try {
        FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('replies')
            .orderBy('createdAt')
            .snapshots()
            .listen((snap) {
          state = snap.docs
              .map((d) => RasaReply.fromMap(d.id, postId, d.data()))
              .toList();
        }, onError: (_) {});
        return;
      } catch (_) {}
    }
    state = dummyReplies()[postId] ?? [];
  }

  /// Return error message kalau gagal, null kalau sukses.
  Future<String?> addReply(String text) async {
    final clean = text.trim();
    if (clean.isEmpty) return 'Tulis dulu tanggapanmu.';
    if (clean.length > AppConfig.maxReplyLength) {
      return 'Maksimal ${AppConfig.maxReplyLength} karakter ya.';
    }
    if (containsBanned(clean)) {
      return 'Ada kata yang kurang pantas.';
    }
    final s = ref.read(sessionProvider);
    final reply = RasaReply(
      id: _uuid.v4(),
      postId: postId,
      text: clean,
      alias: s.alias,
      authorId: s.userId,
      createdAt: DateTime.now(),
    );

    if (_useCloud) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('replies')
            .add(reply.toMap());
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({'replyCount': FieldValue.increment(1)});
        ref.read(sessionProvider.notifier).markActiveToday();
        return null;
      } catch (_) {
        return 'Gagal mengirim. Coba lagi.';
      }
    }

    state = [...state, reply];
    ref.read(feedProvider.notifier).bumpReplyCount(postId);
    ref.read(sessionProvider.notifier).markActiveToday();
    return null;
  }

  /// Hapus tanggapan milik sendiri (AI tidak bisa dihapus).
  Future<void> deleteReply(String replyId, String requesterId) async {
    RasaReply? target;
    for (final r in state) {
      if (r.id == replyId) target = r;
    }
    if (target == null || target.isAI || target.authorId != requesterId) {
      return;
    }
    if (_useCloud) {
      try {
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('replies')
            .doc(replyId)
            .delete();
        await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .update({'replyCount': FieldValue.increment(-1)});
      } catch (_) {}
    }
    state = [for (final r in state) if (r.id != replyId) r];
    ref.read(feedProvider.notifier).debumpReplyCount(postId);
  }

  void addAiReply(String text, {required String postId}) {
    state = [
      ...state,
      RasaReply(
        id: _uuid.v4(),
        postId: postId,
        text: text,
        alias: kAiAlias,
        authorId: 'ai',
        createdAt: DateTime.now(),
        isAI: true,
      ),
    ];
    ref.read(feedProvider.notifier).bumpReplyCount(postId);
  }
}

// ─── PERTANYAAN HARIAN ───────────────────────────────────────────

final dailyQuestionProvider = Provider<String>((ref) {
  final days = DateTime.now().millisecondsSinceEpoch ~/ 86400000;
  return kDailyQuestions[days % kDailyQuestions.length];
});
