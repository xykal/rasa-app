import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../config/app_config.dart';
import '../../data/models/post_model.dart';

/// Format waktu ala "5 menit lalu" (Indonesia, fallback Inggris).
String timeId(DateTime dt) {
  try {
    return timeago.format(dt, locale: 'id');
  } catch (_) {
    return timeago.format(dt);
  }
}

/// Pilihan mood berbentuk chip — dipakai di onboarding & bikin post.
class MoodPicker extends StatelessWidget {
  final String? selected;
  final ValueChanged<String> onPick;
  const MoodPicker({super.key, required this.selected, required this.onPick});

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: [
        for (final m in kMoods)
          ChoiceChip(
            label: Text('${m.emoji} ${m.label}'),
            selected: selected == m.id,
            onSelected: (_) => onPick(m.id),
          ),
      ],
    );
  }
}

/// Tombol Peluk / Sama dengan animasi angka.
class HugButton extends StatelessWidget {
  final String emoji;
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  const HugButton({
    super.key,
    required this.emoji,
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              '$label • $count',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                color: active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu postingan curhat — dipakai di feed & profil.
class RasaPostCard extends StatelessWidget {
  final RasaPost post;
  final VoidCallback? onTap;
  final VoidCallback? onHug;
  final VoidCallback? onMeToo;
  final VoidCallback? onReport;
  const RasaPostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onHug,
    this.onMeToo,
    this.onReport,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: scheme.primaryContainer,
                    child: Text(
                      moodEmoji(post.mood),
                      style: const TextStyle(fontSize: 18),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          post.alias,
                          style: const TextStyle(fontWeight: FontWeight.w700),
                        ),
                        Text(
                          timeId(post.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: scheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (post.aiReply != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Text(
                        '✨ AI nemenin',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: scheme.onTertiaryContainer,
                        ),
                      ),
                    ),
                  if (onReport != null)
                    IconButton(
                      icon: const Icon(Icons.more_horiz),
                      onPressed: onReport,
                      visualDensity: VisualDensity.compact,
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(post.text, style: const TextStyle(fontSize: 15, height: 1.45)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  HugButton(
                    emoji: '🫂',
                    label: 'Peluk',
                    count: post.hugCount,
                    active: post.hugged,
                    onTap: onHug ?? () {},
                  ),
                  HugButton(
                    emoji: '🥺',
                    label: 'Sama',
                    count: post.meTooCount,
                    active: post.meToo,
                    onTap: onMeToo ?? () {},
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '💬 ${post.replyCount} balasan',
                    style: TextStyle(color: scheme.onSurfaceVariant),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Kartu pertanyaan harian di atas feed.
class DailyQuestionCard extends StatelessWidget {
  final String question;
  final VoidCallback onAnswer;
  const DailyQuestionCard({
    super.key,
    required this.question,
    required this.onAnswer,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '❓ PERTANYAAN HARI INI',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w800,
              letterSpacing: 1,
              color: scheme.onPrimary.withValues(alpha: .85),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            question,
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: scheme.onPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
          FilledButton.tonal(
            onPressed: onAnswer,
            child: const Text('Jawab sekarang ✨'),
          ),
        ],
      ),
    );
  }
}

/// Tampilan kosong saat feed belum ada isi / filter tidak cocok.
class EmptyFeed extends StatelessWidget {
  final String message;
  const EmptyFeed({super.key, this.message = 'Belum ada curhatan di sini.\nJadi yang pertama cerita yuk 🌙'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.6,
          ),
        ),
      ),
    );
  }
}

/// Bottom sheet lapor konten (masuk ke koleksi reports buat dimoderasi admin).
Future<void> showReportSheet(BuildContext context, String postId) {
  return showModalBottomSheet(
    context: context,
    showDragHandle: true,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const ListTile(
            title: Text('Laporkan postingan ini?'),
            subtitle: Text('Tim moderasi bakal meninjau dalam 1x24 jam.'),
          ),
          for (final r in const [
            'Ujaran kebencian / toxic',
            'Spam / promosi',
            'Konten dewasa',
            'Bahaya (self-harm / kekerasan)',
            'Lainnya',
          ])
            ListTile(
              leading: const Icon(Icons.flag_outlined),
              title: Text(r),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Makasih laporannya 🙏 Bakal kami tinjau.'),
                  ),
                );
              },
            ),
          const SizedBox(height: 8),
        ],
      ),
    ),
  );
}
