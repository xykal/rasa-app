import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';

/// Editor cerita: pilih mood → tulis → kirim → AI otomatis merespons.
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
        content: Text('Cerita terkirim. AI sedang menyiapkan respons untukmu.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cerita Baru'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: FilledButton.icon(
              onPressed: _sending ? null : _send,
              icon: _sending
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.send, size: 18),
              label: const Text('Kirim'),
            ),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Row(
            children: [
              MoodAvatar(mood: _mood, radius: 22),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.account_circle_outlined, size: 16),
                      const SizedBox(width: 6),
                      Text(
                        session.alias,
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  Text(
                    'Diposting sebagai anonim',
                    style: TextStyle(
                        fontSize: 12, color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          const SectionTitle('Mood kamu saat ini?'),
          MoodPicker(
            selected: _mood,
            onPick: (m) => setState(() => _mood = m),
          ),
          const SizedBox(height: 16),
          const SectionTitle('Ceritamu'),
          TextField(
            controller: _ctrl,
            maxLines: 8,
            maxLength: AppConfig.maxPostLength,
            autofocus: true,
            decoration: const InputDecoration(
              hintText:
                  'Tulis isi hatimu di sini. Tidak ada penilaian, semuanya aman.',
            ),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Icon(Icons.auto_awesome, color: scheme.tertiary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Setelah terkirim, RASA AI akan langsung merespons dan komunitas dapat memberikan dukungan.',
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
