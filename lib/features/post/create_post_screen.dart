import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';

/// Editor curhat: pilih mood → tulis → kirim → AI otomatis nemenin.
class CreatePostScreen extends ConsumerStatefulWidget {
  final String initialText;
  const CreatePostScreen({super.key, this.initialText = ''});

  @override
  ConsumerState<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends ConsumerState<CreatePostScreen> {
  late final TextEditingController _ctrl;
  String _mood = 'flat';
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _ctrl = TextEditingController(text: widget.initialText);
    final saved = ref.read(sessionProvider).todayMood;
    if (saved != null) _mood = saved;
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    final err = await ref
        .read(feedProvider.notifier)
        .addPost(text: _ctrl.text, mood: _mood);
    if (!mounted) return;
    setState(() => _sending = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Curhat terkirim 🌙 AI lagi nemenin kamu…'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Curhat Baru 🌙'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton(
              onPressed: _sending ? null : _send,
              child: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text('Kirim'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundColor: scheme.primaryContainer,
                child: Text(moodEmoji(_mood)),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('🎭 ${session.alias}',
                      style: const TextStyle(fontWeight: FontWeight.w700)),
                  Text(
                    'Posting sebagai anonim',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text('Mood kamu sekarang?',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          MoodPicker(
            selected: _mood,
            onPick: (m) => setState(() => _mood = m),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _ctrl,
            maxLines: 8,
            maxLength: AppConfig.maxPostLength,
            autofocus: true,
            decoration: const InputDecoration(
              hintText:
                  'Tulis isi hatimu di sini…\n\nNggak ada yang nge-judge. Semua aman. 💜',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: .5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Text('✨', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Begitu terkirim, RASA AI bakal langsung nemenin + komunitas bisa kasih peluk.',
                    style: TextStyle(
                      fontSize: 13,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
