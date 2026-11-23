// İçerik detayı (okuma ekranı): okuma ayarlarına göre font/boyut/tema,
// beğeni, kaydetme, yorumlar; yazara düzenle/sabitle/sil; diğerlerine şikayet.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/cache/app_database.dart';
import '../../../core/connectivity/connectivity.dart';
import '../../../core/errors/error_text.dart';
import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/supabase/supabase_providers.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/reading_styles.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../../admin/data/moderation_repository.dart';
import '../../admin/widgets/moderation_actions.dart';
import '../../comments/data/comment_repository.dart';
import '../../comments/widgets/comment_input_bar.dart';
import '../../comments/widgets/comments_section.dart';
import '../../editor/widgets/quill_support.dart';
import '../data/post.dart';
import '../data/post_repository.dart';
import '../post_events.dart';
import '../widgets/reading_settings_sheet.dart';

class PostDetailScreen extends ConsumerStatefulWidget {
  const PostDetailScreen({super.key, required this.postId});
  final String postId;

  @override
  ConsumerState<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends ConsumerState<PostDetailScreen> {
  Post? _post;
  Object? _error;
  bool _loading = true;
  bool _notFound = false;
  bool _fromCache = false;
  bool _liked = false;
  bool _bookmarked = false;
  Comment? _replyRoot;
  Comment? _replyTarget;
  final _commentFocus = FocusNode();

  PostRepository get _repo => ref.read(postRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _commentFocus.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final post = await _repo.getPost(widget.postId);
      if (post == null) {
        setState(() => _notFound = true);
        return;
      }
      final results = await Future.wait([_repo.isLiked(post.id), _repo.isBookmarked(post.id)]);
      if (!mounted) return;
      setState(() {
        _post = post;
        _liked = results[0];
        _bookmarked = results[1];
        _fromCache = false;
      });
      ref.read(appDatabaseProvider).savePost(post);
    } catch (e) {
      final cached = isNetworkError(e) ? await ref.read(appDatabaseProvider).getPost(widget.postId) : null;
      if (!mounted) return;
      setState(() {
        if (cached != null) {
          _post = cached;
          _fromCache = true;
        } else {
          _error = e;
        }
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _toggleLike() async {
    final post = _post!;
    final wasLiked = _liked;
    setState(() {
      _liked = !wasLiked;
      _post = post.copyWith(likeCount: post.likeCount + (wasLiked ? -1 : 1));
    });
    try {
      wasLiked ? await _repo.unlike(post.id) : await _repo.like(post.id);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _liked = wasLiked;
        _post = post;
      });
      showError(context, e);
    }
  }

  Future<void> _toggleBookmark() async {
    final was = _bookmarked;
    final l = context.l10n;
    setState(() => _bookmarked = !was);
    try {
      was ? await _repo.unbookmark(_post!.id) : await _repo.bookmark(_post!.id);
      showSnack(was ? l.bookmarkRemoved : l.bookmarkAdded);
    } catch (e) {
      if (!mounted) return;
      setState(() => _bookmarked = was);
      showError(context, e);
    }
  }

  Future<void> _togglePin() async {
    final post = _post!;
    try {
      await _repo.setPinned(post.id, !post.isPinned);
      setState(() => _post = post.copyWith(isPinned: !post.isPinned));
      ref.read(postsVersionProvider.notifier).bump();
      if (mounted) showSnack(post.isPinned ? context.l10n.unpinned : context.l10n.pinnedDone);
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  Future<void> _delete() async {
    final l = context.l10n;
    final ok = await confirmDialog(
      context,
      title: l.deletePostTitle,
      message: l.deletePostBody,
      confirmLabel: l.delete,
      destructive: true,
    );
    if (!ok) return;
    try {
      await _repo.deletePost(_post!.id);
      ref.read(postsVersionProvider.notifier).bump();
      showSnack(l.postDeleted);
      if (mounted) context.pop();
    } catch (e) {
      if (mounted) showError(context, e);
    }
  }

  void _reply(Comment root, Comment target) {
    setState(() {
      _replyRoot = root;
      _replyTarget = target;
    });
    _commentFocus.requestFocus();
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(appSettingsProvider);
    final r = ReadingStyles.of(settings);
    // Okuma ekranı kendi temasını kullanır (Koyu / Açık / Sepya).
    return Theme(
      data: AppTheme.build(r.palette),
      child: Builder(builder: (context) => _buildPage(context, r)),
    );
  }

  Widget _buildPage(BuildContext context, ReadingStyles r) {
    final l = context.l10n;
    final c = context.colors;
    final post = _post;
    final me = ref.watch(currentUserIdProvider);
    final offline = isOffline(ref);
    final mine = post != null && post.authorId == me;

    Widget body;
    if (_loading && post == null) {
      body = const LoadingView();
    } else if (_notFound) {
      body = EmptyState(icon: LucideIcons.fileQuestion, title: l.postNotFound, message: l.postNotFoundHint);
    } else if (post == null) {
      body = ErrorState(error: _error ?? l.errGeneric, onRetry: _load);
    } else {
      body = RefreshIndicator(
        onRefresh: _load,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(Space.space4, Space.space2, Space.space4, Space.space8),
          children: [
            if (_fromCache)
              Padding(
                padding: const EdgeInsets.only(bottom: Space.space3),
                child: Text(l.showingCached, style: context.text.bodySmall),
              ),
            if (post.isRemoved)
              Container(
                margin: const EdgeInsets.only(bottom: Space.space4),
                padding: const EdgeInsets.all(Space.space3),
                decoration: BoxDecoration(color: c.accentSoft, borderRadius: Radii.mdAll),
                child: Text(l.postRemovedNotice, style: context.text.bodyMedium),
              ),
            Row(
              children: [
                Icon(post.type.icon, size: 16, color: c.inkMuted),
                const SizedBox(width: Space.space1),
                Text(post.type.label(l), style: context.text.labelMedium?.copyWith(color: c.inkMuted)),
              ],
            ),
            const SizedBox(height: Space.space3),
            Text(post.title, style: r.title),
            const SizedBox(height: Space.space4),
            _AuthorRow(post: post, meta: r.meta),
            const SizedBox(height: Space.space6),
            if (post.coverUrl != null) ...[
              NetImage(url: post.coverUrl!, width: double.infinity, fit: BoxFit.fitWidth),
              const SizedBox(height: Space.space6),
            ],
            PostBodyView(
              delta: post.body,
              styles: post.type == PostType.quote ? r.withBody(r.quote) : r,
            ),
            if (post.type == PostType.quote && (post.personalNote?.isNotEmpty ?? false)) ...[
              const SizedBox(height: Space.space4),
              Text(l.personalNote, style: context.text.labelMedium?.copyWith(color: c.inkMuted)),
              const SizedBox(height: Space.space2),
              Text(post.personalNote!, style: r.body),
            ],
            if (post.gallery.isNotEmpty) ...[
              const SizedBox(height: Space.space6),
              _Gallery(urls: post.gallery.map((g) => g.url).toList()),
            ],
            if (post.tags.isNotEmpty) ...[
              const SizedBox(height: Space.space6),
              Wrap(
                spacing: Space.space2,
                runSpacing: Space.space2,
                children: [for (final t in post.tags) Chip(label: Text('#$t'))],
              ),
            ],
            const SizedBox(height: Space.space6),
            Row(
              children: [
                _ActionButton(
                  icon: LucideIcons.heart,
                  filled: _liked,
                  label: compactCount(l, post.likeCount),
                  tooltip: _liked ? l.unlike : l.like,
                  onTap: offline || !post.isPublished ? null : _toggleLike,
                ),
                const SizedBox(width: Space.space4),
                _ActionButton(
                  icon: LucideIcons.messageCircle,
                  label: compactCount(l, post.commentCount),
                  tooltip: l.comment,
                  onTap: offline || !post.isPublished ? null : () => _commentFocus.requestFocus(),
                ),
                const Spacer(),
                _ActionButton(
                  icon: LucideIcons.bookmark,
                  filled: _bookmarked,
                  tooltip: _bookmarked ? l.removeBookmark : l.bookmark,
                  onTap: offline || !post.isPublished ? null : _toggleBookmark,
                ),
              ],
            ),
            const Hairline(),
            if (post.isPublished && !_fromCache)
              CommentsSection(postId: post.id, postAuthorId: post.authorId, onReply: _reply),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
            tooltip: l.readingSettings,
            icon: const Icon(LucideIcons.type),
            onPressed: () => showReadingSettings(context),
          ),
          if (post != null)
            PopupMenuButton<String>(
              icon: const Icon(LucideIcons.moreVertical),
              onSelected: (v) async {
                switch (v) {
                  case 'edit':
                    await context.push(Routes.editor(postId: post.id));
                    _load();
                  case 'pin':
                    _togglePin();
                  case 'delete':
                    _delete();
                  case 'report':
                    reportContent(context, ref, ReportTarget.post, post.id);
                  case 'author':
                    context.push(Routes.user(post.authorId));
                }
              },
              itemBuilder: (_) => [
                if (mine && !post.isRemoved) PopupMenuItem(value: 'edit', child: Text(l.edit)),
                if (mine && post.isPublished)
                  PopupMenuItem(value: 'pin', child: Text(post.isPinned ? l.unpin : l.pinToProfile)),
                if (mine) PopupMenuItem(value: 'delete', child: Text(l.delete, style: TextStyle(color: c.danger))),
                if (!mine) PopupMenuItem(value: 'author', child: Text(l.viewProfile)),
                if (!mine) PopupMenuItem(value: 'report', child: Text(l.report)),
              ],
            ),
        ],
      ),
      body: body,
      bottomNavigationBar: post != null && post.isPublished && !_fromCache
          ? Padding(
              padding: EdgeInsets.only(bottom: MediaQuery.viewInsetsOf(context).bottom),
              child: CommentInputBar(
                postId: post.id,
                focusNode: _commentFocus,
                replyRoot: _replyRoot,
                replyTarget: _replyTarget,
                onCancelReply: () => setState(() {
                  _replyRoot = null;
                  _replyTarget = null;
                }),
                onSent: () {
                  FocusScope.of(context).unfocus();
                  setState(() {
                    _replyRoot = null;
                    _replyTarget = null;
                    _post = _post?.copyWith(commentCount: (_post?.commentCount ?? 0) + 1);
                  });
                },
              ),
            )
          : null,
    );
  }
}

class _AuthorRow extends StatelessWidget {
  const _AuthorRow({required this.post, required this.meta});
  final Post post;
  final TextStyle meta;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final a = post.author;
    final date = post.isDraft ? post.updatedAt : post.publishedAt;
    return InkWell(
      onTap: a == null ? null : () => context.push(Routes.user(a.id)),
      child: Row(
        children: [
          UserAvatar(url: a?.avatarUrl, name: a?.name ?? '?', size: 36),
          const SizedBox(width: Space.space3),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(a?.name ?? l.deletedUser, style: context.text.labelLarge),
                Text(
                  [
                    if (a != null) a.handle,
                    fullDate(l, date),
                    if (post.editedAt != null) l.edited,
                  ].join(' · '),
                  style: meta,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({required this.icon, required this.tooltip, this.onTap, this.label, this.filled = false});
  final IconData icon;
  final String tooltip;
  final VoidCallback? onTap;
  final String? label;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = filled ? c.accent : c.inkMuted;
    return Tooltip(
      message: tooltip,
      child: InkWell(
        borderRadius: Radii.mdAll,
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.space2, vertical: Space.space3),
          child: Row(
            children: [
              // Lucide'da dolgulu ikon yok: seçili durum vurgu rengi + yumuşak zeminle gösterilir.
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(color: filled ? c.accentSoft : null, shape: BoxShape.circle),
                child: Icon(icon, size: 20, color: color),
              ),
              if (label != null) ...[
                const SizedBox(width: Space.space1),
                Text(label!, style: context.text.labelMedium?.copyWith(color: color)),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

class _Gallery extends StatelessWidget {
  const _Gallery({required this.urls});
  final List<String> urls;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: urls.length,
        separatorBuilder: (_, _) => const SizedBox(width: Space.space2),
        itemBuilder: (context, i) => GestureDetector(
          onTap: () => showDialog<void>(
            context: context,
            builder: (_) => Dialog(
              insetPadding: const EdgeInsets.all(Space.space2),
              child: InteractiveViewer(child: NetImage(url: urls[i], fit: BoxFit.contain)),
            ),
          ),
          child: NetImage(url: urls[i], width: 260, height: 200),
        ),
      ),
    );
  }
}
