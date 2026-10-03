import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/config/app_config.dart';
import '../../core/widgets/rasa_widgets.dart';
import '../../data/services/app_providers.dart';
import '../post/create_post_screen.dart';
import '../post/post_detail_screen.dart';

/// Beranda: pencarian + pertanyaan harian + filter mood + feed cerita.
class FeedScreen extends ConsumerWidget {
  const FeedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final feed = ref.watch(feedProvider);
    final filter = ref.watch(moodFilterProvider);
    final query = ref.watch(searchQueryProvider);
    final question = ref.watch(dailyQuestionProvider);
    final session = ref.watch(sessionProvider);
    final isDemo = ref.watch(demoModeProvider);
    final scheme = Theme.of(context).colorScheme;

    final q = query.trim().toLowerCase();
    final posts = feed.where((p) {
      if (filter != null && p.mood != filter) return false;
      if (q.isEmpty) return true;
      return p.text.toLowerCase().contains(q) ||
          p.alias.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const RasaLogo(size: 30),
            const SizedBox(width: 8),
            Text(
              AppConfig.appName,
              style: const TextStyle(
                  fontWeight: FontWeight.w900, letterSpacing: 2),
            ),
          ],
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
            avatar: Icon(
              Icons.local_fire_department,
              size: 16,
              color: scheme.primary,
            ),
            label: Text('${session.streak}'),
            visualDensity: VisualDensity.compact,
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: feed.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: () => ref.read(feedProvider.notifier).reload(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  // Pencarian
                  TextField(
                    decoration: InputDecoration(
                      hintText: 'Cari cerita atau nama samaran',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: q.isEmpty
                          ? null
                          : IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () => ref
                                  .read(searchQueryProvider.notifier)
                                  .state = '',
                            ),
                    ),
                    onChanged: (v) => ref
                        .read(searchQueryProvider.notifier)
                        .state = v,
                  ),
                  const SizedBox(height: 12),
                  DailyQuestionCard(
                    question: question,
                    onAnswer: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => CreatePostScreen(
                          initialText: 'Menjawab "$question"\n\n',
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
                          avatar: const Icon(Icons.apps, size: 18),
                          label: const Text('Semua'),
                          selected: filter == null,
                          onSelected: (_) => ref
                              .read(moodFilterProvider.notifier)
                              .state = null,
                        ),
                        for (final m in kMoods) ...[
                          const SizedBox(width: 8),
                          ChoiceChip(
                            avatar:
                                Icon(m.icon, size: 18, color: m.color),
                            label: Text(m.label),
                            selected: filter == m.id,
                            onSelected: (_) => ref
                                .read(moodFilterProvider.notifier)
                                .state = m.id,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (q.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Text(
                        '${posts.length} hasil untuk "$query"',
                        style: TextStyle(
                          fontSize: 13,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (posts.isEmpty)
                    EmptyFeed(
                      icon: q.isNotEmpty
                          ? Icons.search_off
                          : Icons.forum_outlined,
                      title: q.isNotEmpty
                          ? 'Tidak ditemukan'
                          : 'Belum ada cerita',
                      message: q.isNotEmpty
                          ? 'Coba kata kunci lain atau ubah filter mood.'
                          : 'Jadilah yang pertama berbagi di sini.',
                    )
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
