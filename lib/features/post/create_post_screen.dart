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
      RasaSnack.show(context, err, icon: Icons.info_outline_rounded);
      return;
    }
    Navigator.of(context).pop();
    RasaSnack.show(
      context,
      'Cerita terkirim. AI sedang menyiapkan respons untukmu.',
      icon: Icons.auto_awesome_rounded,
    );
  }

  @override
  Widget build(BuildContext context) {
    final session = ref.watch(sessionProvider);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: const RasaAppBar(title: 'Cerita Baru'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(20, 6, 20, 24),
        children: [
          RasaCard(
            padding: const EdgeInsets.all(15),
            child: Row(
              children: [
                MoodAvatar(mood: _mood, radius: 23),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(
                            Icons.account_circle_outlined,
                            size: 16,
                            color: scheme.primary,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            session.alias,
                            style: const TextStyle(
                                fontWeight: FontWeight.w800, fontSize: 15),
                          ),
                        ],
                      ),
                      const SizedBox(height: 3),
                      Text(
                        'Diposting sebagai anonim',
                        style: TextStyle(
                            fontSize: 12, color: scheme.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Mood kamu saat ini?'),
          MoodPicker(
            selected: _mood,
            onPick: (m) => setState(() => _mood = m),
          ),
          const SizedBox(height: 20),
          const SectionTitle('Ceritamu'),
          RasaTextField(
            controller: _ctrl,
            maxLines: 8,
            maxLength: AppConfig.maxPostLength,
            autofocus: true,
            hint: 'Tulis isi hatimu di sini. Tidak ada penilaian, semuanya aman.',
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: scheme.tertiaryContainer.withValues(alpha: 0.45),
              borderRadius: BorderRadius.circular(22),
            ),
            child: Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
                  decoration: BoxDecoration(
                    color: scheme.tertiary,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    Icons.auto_awesome_rounded,
                    color: scheme.onTertiary,
                    size: 22,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Setelah terkirim, RASA AI akan langsung merespons dan komunitas dapat memberikan dukungan.',
                    style: TextStyle(
                      fontSize: 13,
                      height: 1.5,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          RasaButton(
            label: 'Kirim Cerita',
            icon: Icons.send_rounded,
            busy: _sending,
            onPressed: _send,
          ),
        ],
      ),
    );
  }
}
