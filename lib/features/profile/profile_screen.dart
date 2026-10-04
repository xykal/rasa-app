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
    final result = await showRasaDialog<String>(
      context,
      icon: Icons.edit_outlined,
      title: 'Ubah Nama Samaran',
      message: 'Pilih nama samaran baru. Maksimal ${AppConfig.maxAliasLength} karakter.',
      content: RasaTextField(
        controller: ctrl,
        hint: 'Contoh: Senja Tenang',
        maxLength: AppConfig.maxAliasLength,
        autofocus: true,
        onSubmitted: (_) => Navigator.pop(context, ctrl.text.trim()),
      ),
      actions: [
        RasaTonalButton(
          label: 'Batal',
          onPressed: () => Navigator.pop(context),
        ),
        _SaveAliasButton(controller: ctrl),
      ],
    );
    ctrl.dispose();
    if (result == null || result.isEmpty || !context.mounted) return;
    final err = await ref.read(sessionProvider.notifier).setAlias(result);
    if (!context.mounted) return;
    RasaSnack.show(
      context,
      err ?? 'Nama samaran diperbarui.',
      icon: err == null
          ? Icons.check_circle_rounded
          : Icons.info_outline_rounded,
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
      appBar: const RasaAppBar(title: 'Profil'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: rasaGradient(scheme),
              borderRadius: BorderRadius.circular(28),
              boxShadow: RasaShadows.glow(scheme),
            ),
            child: Row(
              children: [
                Container(
                  width: 64,
                  height: 64,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white.withValues(alpha: 0.22),
                  ),
                  child: Center(
                    child: Text(
                      session.alias.isEmpty
                          ? 'R'
                          : session.alias.trim()[0].toUpperCase(),
                      style: TextStyle(
                        fontSize: 30,
                        fontWeight: FontWeight.w800,
                        color: scheme.onPrimary,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 15),
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
                      const SizedBox(height: 3),
                      Text(
                        'Anggota anonim',
                        style: TextStyle(
                          color: scheme.onPrimary.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                _RoundIconButton(
                  icon: Icons.edit_outlined,
                  onTap: () => _editAlias(context, ref, session.alias),
                ),
                const SizedBox(width: 8),
                _RoundIconButton(
                  icon: Icons.shuffle_rounded,
                  onTap: () =>
                      ref.read(sessionProvider.notifier).shuffleAlias(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              _Stat(
                icon: Icons.local_fire_department_rounded,
                value: '${session.streak} hari',
                label: 'Streak',
              ),
              const SizedBox(width: 10),
              _Stat(
                icon: Icons.edit_note_rounded,
                value: '${myPosts.length}',
                label: 'Cerita',
              ),
              const SizedBox(width: 10),
              _Stat(
                icon: Icons.volunteer_activism_rounded,
                value: '$hugs',
                label: 'Dukungan',
              ),
            ],
          ),
          const SizedBox(height: 22),
          const SectionTitle('Cerita Saya'),
          if (myPosts.isEmpty)
            RasaCard(
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Icon(
                      Icons.nights_stay_outlined,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(width: 13),
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
              const SizedBox(height: 10),
            ],
          const SizedBox(height: 22),
          const SectionTitle('Tampilan'),
          RasaSegmented<ThemeMode>(
            segments: const [
              RasaSegment(
                value: ThemeMode.light,
                icon: Icons.light_mode_rounded,
                label: 'Terang',
              ),
              RasaSegment(
                value: ThemeMode.system,
                icon: Icons.brightness_auto_rounded,
                label: 'Auto',
              ),
              RasaSegment(
                value: ThemeMode.dark,
                icon: Icons.dark_mode_rounded,
                label: 'Gelap',
              ),
            ],
            value: themeMode,
            onChanged: (m) =>
                ref.read(themeModeProvider.notifier).setMode(m),
          ),
          const SizedBox(height: 22),
          const SectionTitle('Pengaturan'),
          RasaSettingTile(
            icon: Icons.science_outlined,
            title: 'Mode Demo (data lokal)',
            subtitle: isDemo
                ? 'Aktif — berjalan tanpa Firebase, cocok untuk review'
                : 'Nonaktif — memakai Firebase production',
            trailing: RasaSwitch(
              value: isDemo,
              onChanged: (v) {
                ref.read(demoModeProvider.notifier).state = v;
                RasaSnack.show(
                  context,
                  v
                      ? 'Mode demo aktif — mulai ulang aplikasi untuk hasil penuh'
                      : 'Mode Firebase aktif — pastikan google-services.json sudah dipasang',
                  icon: Icons.science_outlined,
                );
              },
            ),
          ),
          const SizedBox(height: 10),
          RasaSettingTile(
            icon: Icons.info_outline_rounded,
            title: 'Tentang ${AppConfig.appName}',
            subtitle:
                'v${AppConfig.version} • Flutter + Firebase + Gemini AI',
            onTap: () => showRasaDialog<void>(
              context,
              icon: Icons.spa_rounded,
              title: AppConfig.appName,
              message:
                  'RASA v${AppConfig.version} — ruang aman untuk bercerita secara anonim, ditemani AI dan sesama pengguna. Dibuat di Indonesia.',
              actions: [
                RasaButton(
                  label: 'Tutup',
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          RasaSettingTile(
            icon: Icons.restart_alt_rounded,
            title: 'Reset demo',
            subtitle: 'Hapus nama samaran dan status onboarding',
            danger: true,
            onTap: () async {
              final ok = await confirmDelete(
                context,
                'Seluruh data demo lokal akan dihapus dan onboarding tampil lagi.',
              );
              if (!ok || !context.mounted) return;
              final p = await SharedPreferences.getInstance();
              await p.clear();
              if (context.mounted) {
                RasaSnack.show(
                  context,
                  'Direset. Mulai ulang aplikasi untuk melihat onboarding lagi.',
                  icon: Icons.restart_alt_rounded,
                );
              }
            },
          ),
        ],
      ),
    );
  }
}

class _SaveAliasButton extends StatelessWidget {
  final TextEditingController controller;
  const _SaveAliasButton({required this.controller});

  @override
  Widget build(BuildContext context) {
    return RasaButton(
      label: 'Simpan',
      onPressed: () => Navigator.pop(context, controller.text.trim()),
    );
  }
}

class _RoundIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _RoundIconButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.22),
          borderRadius: BorderRadius.circular(15),
        ),
        child: Icon(icon, color: scheme.onPrimary, size: 21),
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
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: scheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                gradient: rasaGradient(scheme),
                borderRadius: BorderRadius.circular(14),
              ),
              child: Icon(icon, color: scheme.onPrimary, size: 20),
            ),
            const SizedBox(height: 8),
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
