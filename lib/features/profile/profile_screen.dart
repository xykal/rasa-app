import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';
import '../post/post_detail_screen.dart';

/// Profil anonim: identitas, statistik, cerita sendiri, & pengaturan.
class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  Future<void> _editAlias(
      BuildContext context, WidgetRef ref, String current) async {
    final ctrl = TextEditingController(text: current);
    final result = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Ubah Nama Samaran'),
        content: TextField(
          controller: ctrl,
          autofocus: true,
          maxLength: AppConfig.maxAliasLength,
          decoration: const InputDecoration(
            hintText: 'Contoh: Senja Tenang',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, ctrl.text.trim()),
            child: const Text('Simpan'),
          ),
        ],
      ),
    );
    if (result == null || result.isEmpty || !context.mounted) return;
    final err = await ref.read(sessionProvider.notifier).setAlias(result);
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(err ?? 'Nama samaran diperbarui.'),
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final feed = ref.watch(feedProvider);
    final isDemo = ref.watch(demoModeProvider);
    final themeMode = ref.watch(themeModeProvider);
    final scheme = Theme.of(context).colorScheme;

    final myPosts = feed.where((p) => p.authorId == session.userId).toList();
    final hugs = myPosts.fold<int>(0, (s, p) => s + p.hugCount);

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
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
                  backgroundColor: scheme.onPrimary.withValues(alpha: 0.25),
                  child: Text(
                    session.alias.isEmpty ? 'R' : session.alias[0],
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
                        'Anggota anonim',
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: 0.8),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => _editAlias(context, ref, session.alias),
                  icon: Icon(Icons.edit_outlined, color: scheme.onPrimary),
                  tooltip: 'Ubah nama samaran',
                ),
                IconButton(
                  onPressed: () =>
                      ref.read(sessionProvider.notifier).shuffleAlias(),
                  icon: Icon(Icons.shuffle, color: scheme.onPrimary),
                  tooltip: 'Acak nama samaran',
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Statistik
          Row(
            children: [
              _Stat(
                icon: Icons.local_fire_department,
                value: '${session.streak} hari',
                label: 'Streak',
              ),
              const SizedBox(width: 8),
              _Stat(
                icon: Icons.edit_note,
                value: '${myPosts.length}',
                label: 'Cerita',
              ),
              const SizedBox(width: 8),
              _Stat(
                icon: Icons.volunteer_activism,
                value: '$hugs',
                label: 'Dukungan',
              ),
            ],
          ),
          const SizedBox(height: 20),
          const SectionTitle('Cerita Saya'),
          if (myPosts.isEmpty)
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: scheme.surfaceContainerHighest,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  Icon(Icons.nights_stay_outlined,
                      color: scheme.onSurfaceVariant),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Kamu belum pernah bercerita. Cerita pertamamu ditunggu.',
                      style: TextStyle(
                          color: scheme.onSurfaceVariant, height: 1.5),
                    ),
                  ),
                ],
              ),
            )
          else
            for (final p in myPosts) ...[
              RasaPostCard(
                post: p,
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => PostDetailScreen(postId: p.id),
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],

          const SizedBox(height: 20),
          const SectionTitle('Tampilan'),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: SegmentedButton<ThemeMode>(
                segments: const [
                  ButtonSegment(
                    value: ThemeMode.light,
                    icon: Icon(Icons.light_mode),
                    label: Text('Terang'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.system,
                    icon: Icon(Icons.brightness_auto),
                    label: Text('Auto'),
                  ),
                  ButtonSegment(
                    value: ThemeMode.dark,
                    icon: Icon(Icons.dark_mode),
                    label: Text('Gelap'),
                  ),
                ],
                selected: {themeMode},
                onSelectionChanged: (s) =>
                    ref.read(themeModeProvider.notifier).setMode(s.first),
              ),
            ),
          ),

          const SizedBox(height: 12),
          const SectionTitle('Pengaturan'),
          Card(
            child: SwitchListTile(
              secondary: const Icon(Icons.science_outlined),
              title: const Text('Mode Demo (data lokal)'),
              subtitle: Text(
                isDemo
                    ? 'Aktif — berjalan tanpa Firebase, cocok untuk review'
                    : 'Nonaktif — memakai Firebase production',
                style: const TextStyle(fontSize: 12),
              ),
              value: isDemo,
              onChanged: (v) {
                ref.read(demoModeProvider.notifier).state = v;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(v
                        ? 'Mode demo aktif — mulai ulang aplikasi untuk hasil penuh'
                        : 'Mode Firebase aktif — pastikan google-services.json sudah dipasang'),
                  ),
                );
              },
            ),
          ),
          Card(
            child: ListTile(
              leading: const Icon(Icons.info_outline),
              title: Text('Tentang ${AppConfig.appName}'),
              subtitle: const Text(
                  'v${AppConfig.version} • Flutter + Firebase + Gemini AI'),
              onTap: () => showAboutDialog(
                context: context,
                applicationName: AppConfig.appName,
                applicationVersion: AppConfig.version,
                children: const [
                  Text(
                    'RASA adalah ruang aman untuk bercerita secara anonim, ditemani AI dan sesama pengguna. Dibuat di Indonesia.',
                  ),
                ],
              ),
            ),
          ),
          Card(
            child: ListTile(
              leading: Icon(Icons.restart_alt, color: scheme.error),
              title:
                  Text('Reset demo', style: TextStyle(color: scheme.error)),
              subtitle: const Text('Hapus nama samaran dan status onboarding'),
              onTap: () async {
                final ok = await confirmDelete(
                  context,
                  'Seluruh data demo lokal akan dihapus dan onboarding tampil lagi.',
                );
                if (!ok || !context.mounted) return;
                final p = await SharedPreferences.getInstance();
                await p.clear();
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Direset. Mulai ulang aplikasi untuk melihat onboarding lagi.'),
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
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

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
            Icon(icon, color: scheme.primary),
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
