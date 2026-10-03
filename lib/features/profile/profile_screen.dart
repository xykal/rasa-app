import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';

/// Profil anonim: alias, streak, statistik, postingan sendiri, & pengaturan.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final feed = ref.watch(feedProvider);
    final isDemo = ref.watch(demoModeProvider);
    final scheme = Theme.of(context).colorScheme;

    final myPosts =
        feed.where((p) => p.authorId == session.userId).toList();
    final hugs = myPosts.fold<int>(0, (s, p) => s + p.hugCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil 🎭')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Kartu identitas
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [scheme.primary, scheme.tertiary],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 30,
                  backgroundColor: scheme.onPrimary.withValues(alpha: .25),
                  child: Text(
                    session.alias.isEmpty ? '🎭' : session.alias[0],
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: scheme.onPrimary,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        session.alias,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: scheme.onPrimary,
                        ),
                      ),
                      Text(
                        'Warga anonim sejak 2026 🌙',
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: .8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(sessionProvider.notifier).shuffleAlias(),
                  icon: Icon(Icons.shuffle, color: scheme.onPrimary),
                  tooltip: 'Ganti nama samaran',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Statistik
          Row(
            children: [
              _Stat(
                emoji: '🔥',
                value: '${session.streak} hari',
                label: 'Streak',
              ),
              const SizedBox(width: 8),
              _Stat(
                emoji: '🌙',
                value: '${myPosts.length}',
                label: 'Curhatan',
              ),
              const SizedBox(width: 8),
              _Stat(
                emoji: '🫂',
                value: '$hugs',
                label: 'Peluk diterima',
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text('Curhatanku',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          if (myPosts.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'Kamu belum pernah curhat.\nCerita pertamamu ditunggu 🌙',
                style: TextStyle(color: scheme.onSurfaceVariant, height: 1.5),
              ),
            )
          else
            for (final p in myPosts) ...[
              RasaPostCard(post: p),
              const SizedBox(height: 8),
            ],

          const SizedBox(height: 20),
          Text('Pengaturan',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),

          // Toggle demo (buat buyer / developer)
          Card(
            child: SwitchListTile(
              title: const Text('Mode Demo (data lokal)'),
              subtitle: Text(
                isDemo
                    ? 'ON — jalan tanpa Firebase, cocok buat review'
                    : 'OFF — pakai Firebase production',
                style: const TextStyle(fontSize: 12),
              ),
              value: isDemo,
              onChanged: (v) {
                ref.read(demoModeProvider.notifier).state = v;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v
                        ? 'Mode demo ON — restart app biar full efek'
                        : 'Mode Firebase ON — pastikan google-services.json sudah dipasang'),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: const Text('Tentang ${AppConfig.appName}'),
              subtitle: const Text('v1.0.0 • Flutter + Firebase + Gemini AI'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: AppConfig.appName,
                applicationVersion: '1.0.0',
                children: const [
                  Text(
                    'RASA — ruang aman buat curhat anonim, ditemenin AI & sesama manusia. Dibuat dengan 💜 di Indonesia.',
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.restart_alt, color: scheme.error),
              title: Text('Reset demo',
                  style: TextStyle(color: scheme.error)),
              subtitle: const Text('Hapus nama samaran & status onboarding'),
              onTap: () async {
                final p = await SharedPreferences.getInstance();
                await p.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Direset. Restart app buat lihat onboarding lagi.'),
                    ),
                  );
                }
              },
            ),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String emoji;
  final String value;
  final String label;
  const _Stat({required this.emoji, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 4),
            Text(value,
                style: const TextStyle(fontWeight: FontWeight.w800)),
            Text(label,
                style: TextStyle(
                    fontSize: 11, color: scheme.onSurfaceVariant)),
          ],
        ),
      ),
    );
  }
}
