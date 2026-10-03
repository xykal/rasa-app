import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../data/models/post_model.dart';

/// BILIAR CHAT — mengobrol anonim acak 1-on-1 dengan batas waktu.
///
/// VERSI MVP: lawan bicara disimulasikan biar buyer bisa demo
/// tanpa butuh 2 HP / server matchmaking.
/// TODO PRODUCTION (didokumentasikan di SETUP.md):
///   koleksi `queue` + `rooms` di Firestore buat matchmaking real-time
///   antar 2 user.
class BiliarChatScreen extends StatefulWidget {
  const BiliarChatScreen({super.key});

  @override
  State<BiliarChatScreen> createState() => _BiliarChatScreenState();
}

enum _Phase { idle, searching, chatting }

class _BiliarChatScreenState extends State<BiliarChatScreen> {
  _Phase _phase = _Phase.idle;
  String _partner = '';
  final List<ChatMsg> _msgs = [];
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final _rnd = Random();
  Timer? _botTimer;
  int _secondsLeft = AppConfig.biliarDurationSec;

  static const _botReplies = [
    'Saya paham sekali, pernah berada di posisi yang sama.',
    'Lalu bagaimana perasaanmu sekarang tentang hal itu?',
    'Ternyata banyak juga yang merasakan hal serupa di sini ya.',
    'Terima kasih sudah bercerita sejujur itu. Silakan lanjut, saya mendengarkan.',
    'Kalau saya di posisimu, mungkin akan merasa begitu juga.',
    'Kamu hebat, masih bisa bercerita dengan tenang seperti ini.',
    'Iya juga ya. Kadang hal kecil justru paling membekas.',
    'Tetap semangat ya, kita sama-sama berjuang di sini.',
  ];

  static const _openers = [
    'Halo! Akhirnya terhubung juga. Malam ini kamu merasa bagaimana?',
    'Hai, salam kenal. Saya sedang senggang, kamu bagaimana?',
    'Halo! Senang bisa mengobrol. Cerita apa saja boleh di sini.',
  ];

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    _botTimer?.cancel();
    super.dispose();
  }

  void _startSearch() {
    setState(() {
      _phase = _Phase.searching;
      _msgs.clear();
    });
    // Simulasi matchmaking 2 detik
    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted || _phase != _Phase.searching) return;
      setState(() {
        _phase = _Phase.chatting;
        _partner = kAnonAliases[_rnd.nextInt(kAnonAliases.length)];
        _secondsLeft = AppConfig.biliarDurationSec;
        _msgs.add(ChatMsg(
          _openers[_rnd.nextInt(_openers.length)],
          false,
          DateTime.now(),
        ));
      });
      _botTimer = Timer.periodic(const Duration(seconds: 1), (t) {
        if (!mounted) return;
        if (_secondsLeft <= 0) {
          t.cancel();
          if (mounted) _endChat(timeout: true);
          return;
        }
        setState(() => _secondsLeft--);
      });
    });
  }

  void _cancelSearch() => setState(() => _phase = _Phase.idle);

  void _endChat({bool timeout = false}) {
    _botTimer?.cancel();
    setState(() => _phase = _Phase.idle);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(timeout
            ? 'Waktu mengobrol habis. Terima kasih sudah menemani $_partner.'
            : 'Obrolan selesai. Semoga harimu terasa lebih ringan.'),
      ),
    );
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _phase != _Phase.chatting) return;
    _ctrl.clear();
    setState(() => _msgs.add(ChatMsg(text, true, DateTime.now())));
    _toBottom();
    // Balasan simulasi dengan jeda natural
    Future.delayed(Duration(milliseconds: 1200 + _rnd.nextInt(1500)), () {
      if (!mounted || _phase != _Phase.chatting) return;
      setState(() => _msgs.add(ChatMsg(
          _botReplies[_rnd.nextInt(_botReplies.length)],
          false,
          DateTime.now())));
      _toBottom();
    });
  }

  void _toBottom() {
    Future.delayed(const Duration(milliseconds: 100), () {
      if (_scroll.hasClients) {
        _scroll.animateTo(
          _scroll.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _timerText {
    final m = (_secondsLeft ~/ 60).toString().padLeft(2, '0');
    final s = (_secondsLeft % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Biliar Chat'),
        actions: [
          if (_phase == _Phase.chatting)
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Chip(
                avatar: Icon(
                  Icons.timer_outlined,
                  size: 16,
                  color: scheme.primary,
                ),
                label: Text(_timerText),
                visualDensity: VisualDensity.compact,
              ),
            ),
        ],
      ),
      body: switch (_phase) {
        _Phase.idle => _idleView(scheme),
        _Phase.searching => _searchingView(),
        _Phase.chatting => _chatView(scheme),
      },
    );
  }

  Widget _idleView(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 110,
              width: 110,
              decoration: BoxDecoration(
                color: scheme.primaryContainer,
                borderRadius: BorderRadius.circular(32),
              ),
              child: Icon(
                Icons.casino,
                size: 56,
                color: scheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Ngobrol Acak 5 Menit',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              'Dipertemukan dengan orang asing yang anonim.\nTidak cocok? Akhiri kapan pun, tanpa drama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _startSearch,
              icon: const Icon(Icons.shuffle),
              label: const Text('Cari Teman Mengobrol'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchingView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const CircularProgressIndicator(),
          const SizedBox(height: 20),
          const Text(
            'Mencari teman mengobrol',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _cancelSearch,
            child: const Text('Batalkan'),
          ),
        ],
      ),
    );
  }

  Widget _chatView(ColorScheme scheme) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: scheme.secondaryContainer,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Row(
            children: [
              Icon(
                Icons.account_circle_outlined,
                color: scheme.onSecondaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Terhubung dengan $_partner (anonim)',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: scheme.onSecondaryContainer,
                  ),
                ),
              ),
              TextButton(
                onPressed: _endChat,
                child: const Text('Akhiri'),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.all(16),
            itemCount: _msgs.length,
            itemBuilder: (ctx, i) {
              final m = _msgs[i];
              return Align(
                alignment:
                    m.mine ? Alignment.centerRight : Alignment.centerLeft,
                child: Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 12),
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(ctx).size.width * .78,
                  ),
                  decoration: BoxDecoration(
                    color: m.mine
                        ? scheme.primary
                        : scheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Text(
                    m.text,
                    style: TextStyle(
                      height: 1.45,
                      color: m.mine ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
        SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      hintText: 'Sapa dia',
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  onPressed: _send,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
