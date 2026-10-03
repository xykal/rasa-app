import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/post_model.dart';
import '../../data/services/gemini_service.dart';

/// Chat 1-on-1 dengan RASA AI — teman ngobrol yang selalu ada.
/// Jalan offline pakai balasan bawaan, makin pinter kalau GEMINI_KEY diisi.
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
      'Hai, aku RASA AI ✨ Teman ngobrolmu kapan pun. Lagi ngerasa apa malam ini? Cerita aja, semua aman di sini.',
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

  Future<void> _send() async {
    final text = _ctrl.text.trim();
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
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text('✨', style: TextStyle(fontSize: 18)),
            ),
            const SizedBox(width: 10),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RASA AI',
                      style: TextStyle(fontWeight: FontWeight.w800)),
                  Text('Selalu online buat kamu',
                      style: TextStyle(fontSize: 12)),
                ],
              ),
            ),
          ],
        ),
      ),
      body: Column(
        children: [
          if (!aiReady)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.fromLTRB(16, 8, 16, 0),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Text(
                '💡 Mode hemat: AI bawaan (offline). Isi GEMINI_KEY biar makin pinter.',
                style: TextStyle(fontSize: 12),
              ),
            ),
          Expanded(
            child: ListView.builder(
              controller: _scroll,
              padding: const EdgeInsets.all(16),
              itemCount: _msgs.length + (_typing ? 1 : 0),
              itemBuilder: (ctx, i) {
                if (i == _msgs.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 8),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 12),
                      decoration: BoxDecoration(
                        color: scheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      child: const Text('nulis… ✨'),
                    ),
                  );
                }
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
                      borderRadius: BorderRadius.circular(18).copyWith(
                        bottomRight: m.mine
                            ? const Radius.circular(4)
                            : const Radius.circular(18),
                        bottomLeft: m.mine
                            ? const Radius.circular(18)
                            : const Radius.circular(4),
                      ),
                    ),
                    child: Text(
                      m.text,
                      style: TextStyle(
                        height: 1.45,
                        color: m.mine
                            ? scheme.onPrimary
                            : scheme.onSurface,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          // Saran cepat
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                for (final s in const [
                  'Aku capek banget 😔',
                  'Kasih semangat dong ✨',
                  'Aku overthinking nih',
                  'Hari ini seru banget!',
                ])
                  Padding(
                    padding: const EdgeInsets.only(right: 8, bottom: 8),
                    child: ActionChip(
                      label: Text(s),
                      onPressed: _typing
                          ? null
                          : () {
                              _ctrl.text = s;
                              _send();
                            },
                    ),
                  ),
              ],
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
                        hintText: 'Cerita apa aja…',
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
      ),
    );
  }
}
