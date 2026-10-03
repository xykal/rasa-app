import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/widgets/rasa_widgets.dart';
import '../../data/models/post_model.dart';
import '../../data/services/app_providers.dart';

/// Detail cerita: isi penuh + respons AI + semua tanggapan.
/// Pemilik bisa menghapus cerita & tanggapannya sendiri.
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

  Future<void> _deletePost(RasaPost post) async {
    final ok = await confirmDelete(
      context,
      'Cerita ini beserta seluruh tanggapannya akan dihapus permanen.',
    );
    if (!ok || !mounted) return;
    await ref.read(feedProvider.notifier).deletePost(post.id);
    if (!mounted) return;
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Cerita dihapus.')),
    );
  }

  Future<void> _deleteReply(RasaReply reply, String myId) async {
    final ok = await confirmDelete(context, 'Tanggapan ini akan dihapus.');
    if (!ok) return;
    await ref
        .read(repliesProvider(widget.postId).notifier)
        .deleteReply(reply.id, myId);
  }

  @override
  Widget build(BuildContext context) {
    final feed = ref.watch(feedProvider);
    final replies = ref.watch(repliesProvider(widget.postId));
    final session = ref.watch(sessionProvider);
    final post = _find(feed);
    final scheme = Theme.of(context).colorScheme;
    final isMine = post != null && post.authorId == session.userId;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Detail Cerita'),
        actions: [
          if (isMine)
            IconButton(
              icon: const Icon(Icons.delete_outline),
              tooltip: 'Hapus cerita',
              onPressed: () => _deletePost(post),
            ),
        ],
      ),
      body: post == null
          ? const EmptyFeed(
              icon: Icons.delete_outline,
              title: 'Cerita tidak ditemukan',
              message: 'Cerita ini mungkin sudah dihapus pemiliknya.',
            )
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
                        onReport: isMine
                            ? null
                            : () => showReportSheet(context, post.id),
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
                                  Icon(
                                    Icons.auto_awesome,
                                    size: 18,
                                    color: scheme.onTertiaryContainer,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Respons RASA AI',
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
                        '${replies.length} tanggapan dari komunitas',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: 8),
                      if (replies.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          child: Text(
                            'Belum ada tanggapan. Jadilah yang pertama memberikan dukungan.',
                            style: TextStyle(color: scheme.onSurfaceVariant),
                          ),
                        )
                      else
                        for (final r in replies) ...[
                          _ReplyBubble(
                            reply: r,
                            isMine:
                                !r.isAI && r.authorId == session.userId,
                            onDelete: () => _deleteReply(r, session.userId),
                          ),
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
                              hintText: 'Tulis kata penyemangat',
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
  final bool isMine;
  final VoidCallback onDelete;
  const _ReplyBubble({
    required this.reply,
    required this.isMine,
    required this.onDelete,
  });

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
            ? Border.all(color: scheme.tertiary.withValues(alpha: 0.4))
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isAI) ...[
                Icon(Icons.auto_awesome,
                    size: 14, color: scheme.onTertiaryContainer),
                const SizedBox(width: 6),
              ],
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
              if (isMine)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 18),
                  visualDensity: VisualDensity.compact,
                  tooltip: 'Hapus tanggapan',
                  onPressed: onDelete,
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
