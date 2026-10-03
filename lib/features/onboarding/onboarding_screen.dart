import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';

/// Onboarding 1 layar: kenalan → nama samaran → mood → mulai.
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  String _mood = 'flat';

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final session = ref.watch(sessionProvider);

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 16),
            const RasaLogo(size: 88),
            const SizedBox(height: 20),
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                letterSpacing: 4,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              AppConfig.tagline,
              style: TextStyle(color: scheme.onSurfaceVariant, fontSize: 15),
            ),
            const SizedBox(height: 28),
            const _Step(
              icon: Icons.visibility_off,
              title: 'Anonim Penuh',
              desc: 'Tanpa nama asli, tanpa foto. Hanya kamu dan ceritamu.',
            ),
            const _Step(
              icon: Icons.auto_awesome,
              title: 'Didampingi AI dan Komunitas',
              desc: 'Setiap cerita langsung direspons AI, lalu ditemani sesama pengguna.',
            ),
            const _Step(
              icon: Icons.shield_outlined,
              title: 'Ruang Aman',
              desc: 'Moderasi aktif dan filter otomatis menjaga percakapan tetap sehat.',
            ),
            const SizedBox(height: 24),
            const SectionTitle('Nama samaranmu'),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          color: scheme.onPrimaryContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            session.alias,
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: scheme.onPrimaryContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filledTonal(
                  onPressed: () =>
                      ref.read(sessionProvider.notifier).shuffleAlias(),
                  icon: const Icon(Icons.shuffle),
                  tooltip: 'Acak nama lain',
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionTitle('Bagaimana perasaanmu hari ini?'),
            MoodPicker(
              selected: _mood,
              onPick: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 28),
            FilledButton.icon(
              onPressed: () => ref
                  .read(sessionProvider.notifier)
                  .finishOnboarding(_mood),
              icon: const Icon(Icons.arrow_forward),
              label: const Text(
                'Mulai Bercerita',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dengan melanjutkan, kamu setuju untuk menjaga percakapan tetap sehat dan saling menghargai.',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 12, color: scheme.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }
}

class _Step extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;
  const _Step({required this.icon, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: scheme.secondaryContainer,
            child: Icon(
              icon,
              size: 18,
              color: scheme.onSecondaryContainer,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontWeight: FontWeight.w700)),
                Text(desc,
                    style: TextStyle(
                        fontSize: 13, color: scheme.onSurfaceVariant)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
