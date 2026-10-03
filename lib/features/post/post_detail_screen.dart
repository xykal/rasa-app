import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/rasa_widgets.dart';
import '../../data/models/post_model.dart';
import '../../data/services/app_providers.dart';

/// Detail postingan: curhat full + balasan AI highlight + semua balasan.
class PostDetailScreen extends ConsumerStatefulWidget {
  final String postId;
  const PostDetailScreen({super.key, required this.postId});

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  final _ctrl = TextEditingController();
  bool _sending = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  RasaPost? _find(List<RasaPost> feed) {
    for (final p in feed) {
      if (p.id == widget.postId) return p;
    }
    return null;
  }

  Future<void> _send() async {
    if (_sending) return;
    setState(() => _sending = true);
    final err = await ref
        .read(repliesProvider(widget.postId).notifier)
        .addReply(_ctrl.text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (err != null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(err)));
      return;
    }
    _ctrl.clear();
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final replies = ref.watch(repliesProvider(widget.postId));
    final post = _find(feed);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Curhatan 💬')),
      body: post == null
          ? const Center(child: Text('Postingan tidak ditemukan / dihapus.'))
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      RasaPostCard(
                        post: post,
                        onHug: () => ref
                            .read(feedProvider.notifier)
                            .toggleHug(post.id),
                        onMeToo: () => ref
                            .read(feedProvider.notifier)
                            .toggleMeToo(post.id),
                        onReport: () => showReportSheet(context, post.id),
                      ),
                      if (post.aiReply != null) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.tertiaryContainer,
                                scheme.primaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text('✨',
                                      style: TextStyle(fontSize: 18)),
                                  const SizedBox(width: 8),
                                  Text(
                                    'RASA AI nemenin',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: scheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Text(
                                post.aiReply!,
                                style: TextStyle(
                                  height: 1.5,
                                  color: scheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 16),
                      Text(
                        '${replies.length} balasan dari sesama manusia',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: 8),
                      if (replies.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Belum ada balasan. Jadi yang pertama nemenin yuk 🫂',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        )
                      else
                        for (final r in replies) ...[
                          _ReplyBubble(reply: r),
                          const SizedBox(height: 8),
                        ],
                    ],
                  ),
                ),
                SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: _ctrl,
                            maxLines: 3,
                            minLines: 1,
                            decoration: const InputDecoration(
                              hintText: 'Kasih kata penyemangat… 🫂',
                            ),
                            onSubmitted: (_) => _send(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton.filled(
                          onPressed: _sending ? null : _send,
                          icon: _sending
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                      strokeWidth: 2),
                                )
                              : const Icon(Icons.send),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }
}

class _ReplyBubble extends StatelessWidget {
  final RasaReply reply;
  const _ReplyBubble({required this.reply});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isAI = reply.isAI;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isAI ? scheme.tertiaryContainer : scheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: isAI
            ? Border.all(color: scheme.tertiary.withValues(alpha: .4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  reply.alias,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 13,
                    color: isAI
                        ? scheme.onTertiaryContainer
                        : scheme.onSurface,
                  ),
                ),
              ),
              Text(
                timeId(reply.createdAt),
                style: TextStyle(
                  fontSize: 11,
                  color: scheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            reply.text,
            style: TextStyle(
              height: 1.45,
              color: isAI ? scheme.onTertiaryContainer : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
