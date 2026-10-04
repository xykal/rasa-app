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
    if (_sending || _ctrl.text.trim().isEmpty) return;
    setState(() => _sending = true);
    final err = await ref
        .read(repliesProvider(widget.postId).notifier)
        .addReply(_ctrl.text);
    if (!mounted) return;
    setState(() => _sending = false);
    if (err != null) {
      RasaSnack.show(context, err, icon: Icons.info_outline_rounded);
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
    RasaSnack.show(context, 'Cerita dihapus.', icon: Icons.delete_outline_rounded);
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
      appBar: RasaAppBar(
        title: 'Detail Cerita',
        actions: [
          if (isMine)
            Padding(
              padding: const EdgeInsets.only(right: 6),
              child: Material(
                color: const Color(0xFFE5484D).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(16),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () => _deletePost(post),
                  child: const Padding(
                    padding: EdgeInsets.all(11),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 22,
                      color: Color(0xFFE5484D),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
      body: post == null
          ? const RasaEmptyState(
              icon: Icons.delete_outline_rounded,
              title: 'Cerita tidak ditemukan',
              message: 'Cerita ini mungkin sudah dihapus pemiliknya.',
            )
          : Column(
              children: [
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 6, 16, 16),
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
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(18),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                scheme.tertiaryContainer,
                                scheme.primaryContainer,
                              ],
                            ),
                            borderRadius: BorderRadius.circular(26),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    width: 34,
                                    height: 34,
                                    decoration: BoxDecoration(
                                      gradient: rasaGradient(scheme),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      Icons.auto_awesome_rounded,
                                      size: 18,
                                      color: scheme.onPrimary,
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Respons RASA AI',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 15,
                                      color: scheme.onTertiaryContainer,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              Text(
                                post.aiReply!,
                                style: TextStyle(
                                  height: 1.55,
                                  color: scheme.onTertiaryContainer,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      const SizedBox(height: 18),
                      Text(
                        '${replies.length} tanggapan dari komunitas',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(fontWeight: FontWeight.w800),
                      ),
                      const SizedBox(height: 10),
                      if (replies.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 14),
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
                          const SizedBox(height: 9),
                        ],
                    ],
                  ),
                ),
                ChatComposer(
                  controller: _ctrl,
                  hint: 'Tulis kata penyemangat',
                  onSend: _send,
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
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isAI ? scheme.tertiaryContainer : scheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: isAI
            ? Border.all(color: scheme.tertiary.withValues(alpha: 0.4))
            : Border.all(color: scheme.outlineVariant),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (isAI) ...[
                Icon(Icons.auto_awesome_rounded,
                    size: 15, color: scheme.onTertiaryContainer),
                const SizedBox(width: 6),
              ] else ...[
                RasaAvatar(name: reply.alias, radius: 13),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Text(
                  reply.alias,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
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
                GestureDetector(
                  onTap: onDelete,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.delete_outline_rounded,
                      size: 19,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            reply.text,
            style: TextStyle(
              height: 1.5,
              color: isAI ? scheme.onTertiaryContainer : scheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
