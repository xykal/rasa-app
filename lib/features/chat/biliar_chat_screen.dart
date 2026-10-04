import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
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
    RasaSnack.show(
      context,
      timeout
          ? 'Waktu mengobrol habis. Terima kasih sudah menemani $_partner.'
          : 'Obrolan selesai. Semoga harimu terasa lebih ringan.',
      icon: Icons.timer_outlined,
    );
  }

  void _send() {
    final text = _ctrl.text.trim();
    if (text.isEmpty || _phase != _Phase.chatting) return;
    _ctrl.clear();
    setState(() => _msgs.add(ChatMsg(text, true, DateTime.now())));
    _toBottom();
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
    return Scaffold(
      appBar: RasaAppBar(
        title: 'Biliar Chat',
        actions: [
          if (_phase == _Phase.chatting)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: RasaMiniBadge(
                icon: Icons.timer_outlined,
                label: _timerText,
              ),
            ),
        ],
      ),
      body: switch (_phase) {
        _Phase.idle => _idleView(),
        _Phase.searching => _searchingView(),
        _Phase.chatting => _chatView(),
      },
    );
  }

  Widget _idleView() {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 116,
              width: 116,
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(36),
                boxShadow: RasaShadows.soft(scheme),
              ),
              child: Icon(
                Icons.casino_rounded,
                size: 58,
                color: scheme.onPrimary,
              ),
            ),
            const SizedBox(height: 22),
            Text(
              'Ngobrol Acak 5 Menit',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 9),
            Text(
              'Dipertemukan dengan orang asing yang anonim.\nTidak cocok? Akhiri kapan pun, tanpa drama.',
              textAlign: TextAlign.center,
              style: TextStyle(color: scheme.onSurfaceVariant, height: 1.55),
            ),
            const SizedBox(height: 26),
            RasaButton(
              label: 'Cari Teman Mengobrol',
              icon: Icons.shuffle_rounded,
              onPressed: _startSearch,
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchingView() {
    return const RasaLoader(label: 'Mencari teman mengobrol');
  }

  Widget _chatView() {
    final scheme = Theme.of(context).colorScheme;
    return Column(
      children: [
        Container(
          width: double.infinity,
          margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
          padding: const EdgeInsets.all(13),
          decoration: BoxDecoration(
            color: scheme.primary,
            borderRadius: BorderRadius.circular(22),
            boxShadow: RasaShadows.soft(scheme),
          ),
          child: Row(
            children: [
              RasaAvatar(name: _partner, radius: 19),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _partner,
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
                      ),
                    ),
                    Text(
                      'Anonim • terhubung',
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onPrimary.withValues(alpha: 0.85),
                      ),
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: _endChat,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 15, vertical: 9),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(999),
                  ),
                  child: Text(
                    'Akhiri',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                      color: scheme.primary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            controller: _scroll,
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
            itemCount: _msgs.length,
            itemBuilder: (ctx, i) {
              final m = _msgs[i];
              return ChatBubble(text: m.text, mine: m.mine);
            },
          ),
        ),
        ChatComposer(
          controller: _ctrl,
          hint: 'Sapa dia',
          onSend: _send,
        ),
      ],
    );
  }
}
