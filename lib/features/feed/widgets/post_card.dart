import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../post/data/post.dart';

/// Medium tarzı liste kartı: solda başlık + 2 satır özet, sağda küçük kapak,
/// altta yazar, tarih ve tür rozeti.
class PostCard extends StatelessWidget {
  const PostCard({super.key, required this.post, this.showPinned = false, this.onTap});
  final Post post;
  final bool showPinned;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final author = post.author;
    final meta = context.text.bodySmall;

    return InkWell(
      onTap: onTap ?? () => context.push(post.isDraft ? Routes.editor(postId: post.id) : Routes.post(post.id)),
      child: Padding(
        padding: const EdgeInsets.all(Space.space4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (showPinned && post.isPinned)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.space2),
                child: Row(
                  children: [
                    Icon(LucideIcons.pin, size: 14, color: c.accent),
                    const SizedBox(width: Space.space1),
                    Text(l.pinned, style: meta?.copyWith(color: c.accent)),
                  ],
                ),
              ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        post.title.isEmpty ? l.untitled : post.title,
                        style: context.text.titleMedium,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (post.excerpt.isNotEmpty) ...[
                        const SizedBox(height: Space.space1),
                        Text(
                          post.excerpt,
                          style: context.text.bodyMedium?.copyWith(color: c.inkMuted),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
                if (post.coverUrl != null) ...[
                  const SizedBox(width: Space.space3),
                  NetImage(url: post.coverUrl!, width: 80, height: 80),
                ],
              ],
            ),
            const SizedBox(height: Space.space3),
            Row(
              children: [
                if (author != null) ...[
                  UserAvatar(url: author.avatarUrl, name: author.name, size: 20),
                  const SizedBox(width: Space.space2),
                  Flexible(
                    child: Text(author.name, style: context.text.labelMedium, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                  Text(' · ', style: meta),
                ],
                Text(
                  post.isDraft ? relativeTime(l, post.updatedAt) : relativeTime(l, post.publishedAt),
                  style: meta,
                ),
                const Spacer(),
                if (post.likeCount > 0) ...[
                  Icon(LucideIcons.heart, size: 14, color: c.inkMuted),
                  const SizedBox(width: 2),
                  Text(compactCount(l, post.likeCount), style: meta),
                  const SizedBox(width: Space.space3),
                ],
                if (post.commentCount > 0) ...[
                  Icon(LucideIcons.messageCircle, size: 14, color: c.inkMuted),
                  const SizedBox(width: 2),
                  Text(compactCount(l, post.commentCount), style: meta),
                  const SizedBox(width: Space.space3),
                ],
                Tooltip(
                  message: post.type.label(l),
                  child: Icon(post.type.icon, size: 16, color: c.inkMuted),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
