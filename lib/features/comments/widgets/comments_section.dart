// Yorum listesi: tek seviye yanıt, düzenleme/silme, @bahsetme vurgusu.
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../admin/data/moderation_repository.dart';
import '../../admin/widgets/moderation_actions.dart';
import '../comments_controller.dart';
import '../data/comment_repository.dart';

/// Yorumlar bölümü (içerik detayının altında).
class CommentsSection extends ConsumerWidget {
  const CommentsSection({super.key, required this.postId, required this.postAuthorId, required this.onReply});
  final String postId;
  final String postAuthorId;

  /// Yanıtla'ya basılınca: hangi ana yoruma, kime.
  final void Function(Comment root, Comment target) onReply;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(commentsProvider(postId));
    return async.when(
      loading: () => const Padding(padding: EdgeInsets.all(Space.space6), child: LoadingView()),
      error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(commentsProvider(postId))),
      data: (threads) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: Space.space4),
            child: Text(l.commentsCount(commentTotal(threads)), style: context.text.titleSmall),
          ),
          if (threads.isEmpty)
            Padding(
              padding: const EdgeInsets.only(bottom: Space.space6),
              child: Text(l.noComments, style: context.text.bodyMedium?.copyWith(color: context.colors.inkMuted)),
            ),
          for (final t in threads) ...[
            CommentTile(comment: t.root, postAuthorId: postAuthorId, onReply: () => onReply(t.root, t.root)),
            for (final r in t.replies)
              Padding(
                padding: const EdgeInsets.only(left: 40),
                child: CommentTile(comment: r, postAuthorId: postAuthorId, onReply: () => onReply(t.root, r)),
              ),
          ],
        ],
      ),
    );
  }
}

class CommentTile extends ConsumerWidget {
  const CommentTile({super.key, required this.comment, required this.postAuthorId, required this.onReply});
  final Comment comment;
  final String postAuthorId;
  final VoidCallback onReply;

  Future<void> _edit(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final controller = TextEditingController(text: comment.body);
    final text = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.editComment),
        content: TextField(
          controller: controller,
          maxLines: 5,
          minLines: 2,
          autofocus: true,
          inputFormatters: [LengthLimitingTextInputFormatter(1000)],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.cancel)),
          TextButton(onPressed: () => Navigator.pop(ctx, controller.text), child: Text(l.save)),
        ],
      ),
    );
    if (text == null || text.trim().isEmpty || text.trim() == comment.body) return;
    try {
      await ref.read(commentsProvider(comment.postId).notifier).edit(comment.id, text);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  Future<void> _delete(BuildContext context, WidgetRef ref) async {
    final l = context.l10n;
    final ok = await confirmDialog(context, title: l.deleteCommentTitle, confirmLabel: l.delete, destructive: true);
    if (!ok) return;
    try {
      await ref.read(commentsProvider(comment.postId).notifier).delete(comment.id);
    } catch (e) {
      if (context.mounted) showError(context, e);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final me = ref.watch(currentUserIdProvider);
    final isAdmin = ref.watch(sessionProvider).isAdmin;
    final mine = comment.authorId == me;
    final canDelete = mine || postAuthorId == me || isAdmin;
    final author = comment.author;

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: Space.space2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: author == null ? null : () => context.push(Routes.user(author.id)),
            child: UserAvatar(url: author?.avatarUrl, name: author?.name ?? '?', size: 28),
          ),
          const SizedBox(width: Space.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        author?.name ?? l.deletedUser,
                        style: context.text.labelMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    Text(
                      ' · ${relativeTime(l, comment.createdAt)}${comment.editedAt != null ? ' · ${l.edited}' : ''}',
                      style: context.text.bodySmall,
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                MentionText(text: comment.body, style: context.text.bodyMedium),
                const SizedBox(height: Space.space1),
                Row(
                  children: [
                    InkWell(
                      onTap: onReply,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: Space.space1),
                        child: Text(l.reply, style: context.text.labelSmall?.copyWith(color: c.inkMuted)),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          PopupMenuButton<String>(
            icon: Icon(LucideIcons.moreVertical, size: 18, color: c.inkMuted),
            onSelected: (v) => switch (v) {
              'edit' => _edit(context, ref),
              'delete' => _delete(context, ref),
              'report' => reportContent(context, ref, ReportTarget.comment, comment.id),
              _ => null,
            },
            itemBuilder: (_) => [
              if (mine) PopupMenuItem(value: 'edit', child: Text(l.edit)),
              if (canDelete) PopupMenuItem(value: 'delete', child: Text(l.delete, style: TextStyle(color: c.danger))),
              if (!mine) PopupMenuItem(value: 'report', child: Text(l.report)),
            ],
          ),
        ],
      ),
    );
  }
}

/// @nickname'leri vurgulayıp profile bağlayan metin.
class MentionText extends StatelessWidget {
  const MentionText({super.key, required this.text, this.style});
  final String text;
  final TextStyle? style;

  static final _pattern = RegExp(r'@([a-z0-9_.]{3,20})', caseSensitive: false);

  @override
  Widget build(BuildContext context) {
    final spans = <InlineSpan>[];
    var last = 0;
    for (final m in _pattern.allMatches(text)) {
      if (m.start > last) spans.add(TextSpan(text: text.substring(last, m.start)));
      final nick = m.group(1)!.toLowerCase().replaceAll(RegExp(r'\.+$'), '');
      spans.add(
        TextSpan(
          text: m.group(0),
          style: TextStyle(color: context.colors.accent, fontWeight: FontWeight.w500),
          recognizer: TapGestureRecognizer()..onTap = () => context.push(Routes.userByNickname(nick)),
        ),
      );
      last = m.end;
    }
    if (last < text.length) spans.add(TextSpan(text: text.substring(last)));
    return Text.rich(TextSpan(style: style, children: spans));
  }
}
