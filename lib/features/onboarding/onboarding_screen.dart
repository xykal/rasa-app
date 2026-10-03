import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';

/// Onboarding 1 layar: kenalan → pilih nama samaran → pilih mood → gas.
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
            Container(
              height: 96,
              width: 96,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [scheme.primary, scheme.tertiary],
                ),
                borderRadius: BorderRadius.circular(28),
              ),
              child: const Center(
                child: Text('💜', style: TextStyle(fontSize: 48)),
              ),
            ),
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
            _Step(
              number: '1',
              title: '100% Anonim',
              desc: 'Nggak ada nama asli, nggak ada foto. Cuma kamu & ceritamu.',
            ),
            _Step(
              number: '2',
              title: 'Ditemenin AI + manusia',
              desc: 'Tiap curhat langsung dibalas AI empati, lalu ditemenin komunitas.',
            ),
            _Step(
              number: '3',
              title: 'Zona aman',
              desc: 'Ada moderasi & filter toxic. Yang jahat langsung ditendang.',
            ),
            const SizedBox(height: 24),
            Text('Nama samaranmu',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
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
                    child: Text(
                      '🎭 ${session.alias}',
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        color: scheme.onPrimaryContainer,
                      ),
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
            Text('Gimana perasaanmu hari ini?',
                style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 8),
            MoodPicker(
              selected: _mood,
              onPick: (m) => setState(() => _mood = m),
            ),
            const SizedBox(height: 28),
            FilledButton(
              onPressed: () => ref
                  .read(sessionProvider.notifier)
                  .finishOnboarding(_mood),
              child: const Text(
                'Mulai Curhat 💜',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Dengan lanjut, kamu setuju jadi warga yang baik & tidak toxic 🤝',
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
  final String number;
  final String title;
  final String desc;
  const _Step({required this.number, required this.title, required this.desc});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: scheme.secondaryContainer,
            child: Text(number,
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w800,
                    color: scheme.onSecondaryContainer)),
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
