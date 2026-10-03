import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';
import '../post/create_post_screen.dart';
import '../post/post_detail_screen.dart';

/// Beranda: pertanyaan harian + filter mood + feed curhatan.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final filter = ref.watch(moodFilterProvider);
    final question = ref.watch(dailyQuestionProvider);
    final session = ref.watch(sessionProvider);
    final isDemo = ref.watch(demoModeProvider);
    final scheme = Theme.of(context).colorScheme;

    final posts =
        filter == null ? feed : feed.where((p) => p.mood == filter).toList();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '💜 ${AppConfig.appName}',
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 2),
        ),
        actions: [
          if (isDemo)
            Container(
              margin: const EdgeInsets.only(right: 4),
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: scheme.tertiaryContainer,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'DEMO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: scheme.onTertiaryContainer,
                ),
              ),
            ),
          Chip(
            avatar: const Text('🔥'),
            label: Text('${session.streak}'),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: feed.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () async {
                await Future.delayed(const Duration(milliseconds: 700));
              },
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  DailyQuestionCard(
                    question: question,
                    onAnswer: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreatePostScreen(
                          initialText: 'Jawaban untuk "$question"\n\n',
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        ChoiceChip(
                          label: const Text('✨ Semua'),
                          selected: filter == null,
                          onSelected: (_) => ref
                              .read(moodFilterProvider.notifier)
                              .state = null,
                        ),
                        const SizedBox(width: 8),
                        for (final m in kMoods) ...[
                          ChoiceChip(
                            label: Text('${m.emoji} ${m.label}'),
                            selected: filter == m.id,
                            onSelected: (_) => ref
                                .read(moodFilterProvider.notifier)
                                .state = m.id,
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (posts.isEmpty)
                    const EmptyFeed()
                  else
                    for (final p in posts) ...[
                      RasaPostCard(
                        post: p,
                        onTap: () => Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => PostDetailScreen(postId: p.id),
                          ),
                        ),
                        onHug: () => ref
                            .read(feedProvider.notifier)
                            .toggleHug(p.id),
                        onMeToo: () => ref
                            .read(feedProvider.notifier)
                            .toggleMeToo(p.id),
                        onReport: () => showReportSheet(context, p.id),
                      ),
                      const SizedBox(height: 10),
                    ],
                  const SizedBox(height: 24),
                ],
              ),
            ),
    );
  }
}
