import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/models/post_model.dart';
import '../../data/services/gemini_service.dart';

/// Chat 1-on-1 dengan RASA AI — teman mengobrol yang selalu ada.
/// Jalan offline pakai balasan bawaan, makin pintar kalau GEMINI_KEY diisi.
class AiChatScreen extends ConsumerStatefulWidget {
  const AiChatScreen({super.key});

  @override
  ConsumerState<AiChatScreen> createState() => _AiChatScreenState();
}

class _AiChatScreenState extends ConsumerState<AiChatScreen> {
  final _ctrl = TextEditingController();
  final _scroll = ScrollController();
  final List<ChatMsg> _msgs = [
    ChatMsg(
      'Halo, saya RASA AI. Teman mengobrol yang siap mendengarkan kapan pun. Apa yang sedang kamu rasakan saat ini?',
      false,
      DateTime.now(),
    ),
  ];
  bool _typing = false;

  @override
  void dispose() {
    _ctrl.dispose();
    _scroll.dispose();
    super.dispose();
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

  Future<void> _send([String? preset]) async {
    final text = (preset ?? _ctrl.text).trim();
    if (text.isEmpty || _typing) return;
    _ctrl.clear();
    setState(() {
      _msgs.add(ChatMsg(text, true, DateTime.now()));
      _typing = true;
    });
    _toBottom();

    final reply = await ref
        .read(geminiServiceProvider)
        .chatReply(List.of(_msgs), text);
    if (!mounted) return;
    setState(() {
      _msgs.add(ChatMsg(reply, false, DateTime.now()));
      _typing = false;
    });
    _toBottom();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final aiReady = ref.watch(geminiServiceProvider).ready;

    return Scaffold(
      appBar: RasaAppBar(
        title: 'RASA AI',
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 6),
            padding:
                const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(999),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: scheme.onPrimary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 7),
                Text(
                  'Online',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: scheme.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          if (!aiReady)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 6, 16, 0),
              padding: const EdgeInsets.all(13),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(18),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    size: 18,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 9),
                  const Expanded(
                    child: Text(
                      'Mode hemat: respons bawaan (offline). Isi GEMINI_KEY agar semakin pintar.',
                      style: TextStyle(fontSize: 12, height: 1.45),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.fromLTRB(16, 14, 16, 8),
              itemCount: _msgs.length + (_typing ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _msgs.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 10),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 18, vertical: 15),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(20).copyWith(
                          bottomLeft: const Radius.circular(6),
                        ),
                      ),
                      child: const TypingDots(),
                    ),
                  );
                }
                final m = _msgs[i];
                return ChatBubble(text: m.text, mine: m.mine);
              },
            ),
          ),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final s in kQuickPrompts)
                  Padding(
                    padding: const EdgeInsets.only(right: 9, bottom: 10),
                    child: RasaChip(
                      icon: Icons.north_east_rounded,
                      label: s,
                      selected: false,
                      onSelected: (_) {
                        if (!_typing) _send(s);
                      },
                    ),
                  ),
              ],
            ),
          ),
          ChatComposer(
            controller: _ctrl,
            hint: 'Ceritakan apa saja',
            onSend: () => _send(),
          ),
        ],
      ),
    );
  }
}
