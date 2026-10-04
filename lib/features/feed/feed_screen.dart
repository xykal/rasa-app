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
      appBar: RasaAppBar(
        title: AppConfig.appName,
        showLogo: true,
        actions: [
          if (isDemo)
            Container(
              margin: const EdgeInsets.only(right: 8),
              padding:
                  const EdgeInsets.symmetric(horizontal: 11, vertical: 7),
              decoration: BoxDecoration(
                color: scheme.primary,
                borderRadius: BorderRadius.circular(999),
              ),
              child: Text(
                'DEMO',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: scheme.onPrimary,
                ),
              ),
            ),
          RasaMiniBadge(
            icon: Icons.local_fire_department_rounded,
            label: '${session.streak}',
          ),
        ],
      ),
      body: feed.isEmpty
          ? const _FeedLoading()
          : RefreshIndicator(
              onRefresh: () => ref.read(feedProvider.notifier).reload(),
              color: scheme.primary,
              backgroundColor: scheme.surfaceContainerHigh,
              strokeWidth: 2.5,
              child: ListView(
                padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
                children: [
                  RasaTextField(
                    hint: 'Cari cerita atau nama samaran',
                    prefix: Icons.search_rounded,
                    suffix: q.isEmpty
                        ? null
                        : IconButton(
                            icon: const Icon(Icons.clear_rounded, size: 20),
                            onPressed: () => ref
                                .read(searchQueryProvider.notifier)
                                .state = '',
                          ),
                    onChanged: (v) => ref
                        .read(searchQueryProvider.notifier)
                        .state = v,
                  ),
                  const SizedBox(height: 14),
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
                  const SizedBox(height: 14),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        RasaChip(
                          icon: Icons.apps_rounded,
                          label: 'Semua',
                          selected: filter == null,
                          onSelected: (_) => ref
                              .read(moodFilterProvider.notifier)
                              .state = null,
                        ),
                        for (final m in kMoods) ...[
                          const SizedBox(width: 9),
                          RasaChip(
                            icon: m.icon,
                            iconColor: m.color,
                            label: m.label,
                            selected: filter == m.id,
                            onSelected: (_) => ref
                                .read(moodFilterProvider.notifier)
                                .state = m.id,
                          ),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  if (q.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 10),
                      child: Text(
                        '${posts.length} hasil untuk "$query"',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: scheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  if (posts.isEmpty)
                    RasaEmptyState(
                      icon: q.isNotEmpty
                          ? Icons.search_off_rounded
                          : Icons.forum_outlined,
                      title: q.isNotEmpty
                          ? 'Tidak ditemukan'
                          : 'Belum ada cerita',
                      message: q.isNotEmpty
                          ? 'Coba kata kunci lain atau ubah filter mood.'
                          : 'Jadilah yang pertama berbagi di sini.',
                      actionLabel:
                          q.isNotEmpty ? null : 'Tulis Cerita',
                      onAction: q.isNotEmpty
                          ? null
                          : () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const CreatePostScreen(),
                                ),
                              ),
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
                      const SizedBox(height: 12),
                    ],
                ],
              ),
            ),
    );
  }
}

/// Skeleton selagi feed dimuat — terasa instan, tanpa spinner.
class _FeedLoading extends StatelessWidget {
  const _FeedLoading();

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 110),
      children: const [
        RasaSkeleton(height: 56, radius: 20),
        SizedBox(height: 14),
        RasaSkeleton(height: 168, radius: 26),
        SizedBox(height: 14),
        Row(
          children: [
            RasaSkeleton(height: 40, width: 96, radius: 999),
            SizedBox(width: 9),
            RasaSkeleton(height: 40, width: 110, radius: 999),
            SizedBox(width: 9),
            RasaSkeleton(height: 40, width: 104, radius: 999),
          ],
        ),
        SizedBox(height: 14),
        RasaSkeleton(height: 190, radius: 26),
        SizedBox(height: 12),
        RasaSkeleton(height: 170, radius: 26),
        SizedBox(height: 12),
        RasaSkeleton(height: 180, radius: 26),
      ],
    );
  }
}
