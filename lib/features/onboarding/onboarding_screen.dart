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
          padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
          children: [
            const SizedBox(height: 12),
            const RasaLogo(size: 92),
            const SizedBox(height: 20),
            Text(
              AppConfig.appName,
              style: TextStyle(
                fontSize: 42,
                fontWeight: FontWeight.w800,
                letterSpacing: 5,
                color: scheme.primary,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              AppConfig.tagline,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                fontSize: 15,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 26),
            const _Step(
              icon: Icons.visibility_off_rounded,
              title: 'Anonim Penuh',
              desc: 'Tanpa nama asli, tanpa foto. Hanya kamu dan ceritamu.',
            ),
            const _Step(
              icon: Icons.auto_awesome_rounded,
              title: 'Didampingi AI dan Komunitas',
              desc: 'Setiap cerita langsung direspons AI, lalu ditemani sesama pengguna.',
            ),
            const _Step(
              icon: Icons.shield_outlined,
              title: 'Ruang Aman',
              desc: 'Moderasi aktif dan filter otomatis menjaga percakapan tetap sehat.',
            ),
            const SizedBox(height: 22),
            const SectionTitle('Nama samaranmu'),
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 15),
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: RasaShadows.soft(scheme),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.account_circle_outlined,
                          color: scheme.onPrimary,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            session.alias,
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                              color: scheme.onPrimary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                RasaShuffleButton(
                  onTap: () =>
                      ref.read(sessionProvider.notifier).shuffleAlias(),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const SectionTitle('Bagaimana perasaanmu hari ini?'),
            MoodPicker(
              selected: _mood,
              onPick: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 30),
            RasaButton(
              label: 'Mulai Bercerita',
              icon: Icons.arrow_forward_rounded,
              onPressed: () => ref
                  .read(sessionProvider.notifier)
                  .finishOnboarding(_mood),
            ),
            const SizedBox(height: 14),
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

class RasaShuffleButton extends StatelessWidget {
  final VoidCallback onTap;
  const RasaShuffleButton({super.key, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          color: scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(19),
          border: Border.all(color: scheme.outlineVariant),
        ),
        child: Icon(Icons.shuffle_rounded, color: scheme.primary),
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
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              color: scheme.primary,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, size: 22, color: scheme.onPrimary),
          ),
          const SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(
                        fontSize: 15, fontWeight: FontWeight.w800)),
                const SizedBox(height: 3),
                Text(desc,
                    style: TextStyle(
                        fontSize: 13,
                        color: scheme.onSurfaceVariant,
                        height: 1.45)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
