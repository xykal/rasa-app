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

/// Logo brand RASA — gradient + ikon, dipakai di splash, onboarding, appbar.
class RasaLogo extends StatelessWidget {
  final double size;
  const RasaLogo({super.key, this.size = 48});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [scheme.primary, scheme.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(size * 0.3),
      ),
      child: Icon(
        Icons.spa,
        color: scheme.onPrimary,
        size: size * 0.55,
      ),
    );
  }
}

/// Avatar mood berwarna — konsisten di feed, detail, dan editor.
class MoodAvatar extends StatelessWidget {
  final String mood;
  final double radius;
  const MoodAvatar({super.key, required this.mood, this.radius = 20});

  @override
  Widget build(BuildContext context) {
    final m = moodOf(mood);
    return CircleAvatar(
      radius: radius,
      backgroundColor: m.color.withValues(alpha: 0.15),
      child: Icon(m.icon, color: m.color, size: radius * 1.1),
    );
  }
}

/// Judul seksi kecil yang konsisten di semua layar.
class SectionTitle extends StatelessWidget {
  final String text;
  const SectionTitle(this.text, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: Theme.of(context)
            .textTheme
            .titleMedium
            ?.copyWith(fontWeight: FontWeight.w700),
      ),
    );
  }
}

/// Pilihan mood berbentuk chip — dipakai di onboarding & bikin cerita.
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
            avatar: Icon(m.icon, size: 18, color: m.color),
            label: Text(m.label),
            selected: selected == m.id,
            onSelected: (_) => onPick(m.id),
          ),
      ],
    );
  }
}

/// Tombol reaksi (Peluk / Sama) dengan ikon Material + animasi angka.
class HugButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final int count;
  final bool active;
  final VoidCallback onTap;
  const HugButton({
    super.key,
    required this.icon,
    required this.label,
    required this.count,
    required this.active,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final fg = active ? scheme.onPrimaryContainer : scheme.onSurfaceVariant;
    return InkWell(
      borderRadius: BorderRadius.circular(999),
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color:
              active ? scheme.primaryContainer : scheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(999),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 16, color: fg),
            const SizedBox(width: 6),
            Text(
              '$label • $count',
              style: TextStyle(fontWeight: FontWeight.w700, color: fg),
            ),
          ],
        ),
      ),
    );
  }
}

/// Kartu cerita — dipakai di feed & profil.
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
                  MoodAvatar(mood: post.mood),
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
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: scheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(999),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            size: 12,
                            color: scheme.onTertiaryContainer,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Ditemani AI',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: scheme.onTertiaryContainer,
                            ),
                          ),
                        ],
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
                    icon: Icons.volunteer_activism,
                    label: 'Peluk',
                    count: post.hugCount,
                    active: post.hugged,
                    onTap: onHug ?? () {},
                  ),
                  HugButton(
                    icon: Icons.groups,
                    label: 'Sama',
                    count: post.meTooCount,
                    active: post.meToo,
                    onTap: onMeToo ?? () {},
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 14,
                    color: scheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${post.replyCount} tanggapan',
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
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                size: 16,
                color: scheme.onPrimary.withValues(alpha: 0.85),
              ),
              const SizedBox(width: 6),
              Text(
                'PERTANYAAN HARI INI',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                  color: scheme.onPrimary.withValues(alpha: 0.85),
                ),
              ),
            ],
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
            child: const Text('Jawab Sekarang'),
          ),
        ],
      ),
    );
  }
}

/// Status kosong yang informatif — dipakai di feed, pencarian, & profil.
class EmptyFeed extends StatelessWidget {
  final IconData icon;
  final String title;
  final String message;
  const EmptyFeed({
    super.key,
    this.icon = Icons.forum_outlined,
    this.title = 'Belum ada cerita',
    this.message = 'Jadilah yang pertama berbagi di sini.',
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 56, color: scheme.outline),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 4),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                color: scheme.onSurfaceVariant,
                height: 1.6,
              ),
            ),
          ],
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
            leading: Icon(Icons.flag_outlined),
            title: Text('Laporkan cerita ini?'),
            subtitle: Text('Tim moderasi akan meninjau dalam 1x24 jam.'),
          ),
          for (final r in kReportReasons)
            ListTile(
              leading: const Icon(Icons.chevron_right),
              title: Text(r),
              onTap: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Terima kasih. Laporanmu akan kami tinjau.'),
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

/// Dialog konfirmasi hapus yang standar di seluruh aplikasi.
Future<bool> confirmDelete(BuildContext context, String message) async {
  final res = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: const Icon(Icons.delete_outline),
      title: const Text('Hapus?'),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Batal'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(ctx, true),
          child: const Text('Hapus'),
        ),
      ],
    ),
  );
  return res ?? false;
}
