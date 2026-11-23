// Bildirimler: yorum, yanıt, beğeni, @bahsetme ve moderasyon.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/common.dart';
import '../data/notification_repository.dart';
import '../notification_providers.dart';

class NotificationsScreen extends ConsumerStatefulWidget {
  const NotificationsScreen({super.key});

  @override
  ConsumerState<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends ConsumerState<NotificationsScreen> {
  final _items = <AppNotification>[];
  bool _loading = false;
  bool _hasMore = true;
  Object? _error;

  NotificationRepository get _repo => ref.read(notificationRepositoryProvider);

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading || (!reset && !_hasMore)) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    try {
      final page = await _repo.list(offset: reset ? 0 : _items.length);
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page);
        _hasMore = page.length >= NotificationRepository.pageSize;
      });
      // Açılınca hepsi okundu sayılır (vurgu bu oturumda kalır).
      if (reset && page.any((n) => n.isUnread)) {
        await _repo.markAllRead();
        ref.read(unreadCountProvider.notifier).clear();
      }
    } catch (e) {
      if (mounted) setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _open(AppNotification n) {
    if (n.kind == NotificationKind.moderation) {
      _showModeration(n);
    } else if (n.postId != null) {
      context.push(Routes.post(n.postId!));
    }
  }

  void _showModeration(AppNotification n) {
    final l = context.l10n;
    final note = n.meta['note'] as String?;
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.moderationNoticeTitle),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_moderationText(l, n)),
            if (note != null && note.isNotEmpty) ...[
              const SizedBox(height: Space.space3),
              Text(l.adminNote, style: ctx.text.labelMedium),
              Text(note),
            ],
          ],
        ),
        actions: [
          if (n.postId != null && n.meta['target_type'] == 'post')
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                context.push(Routes.post(n.postId!));
              },
              child: Text(l.viewPost),
            ),
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.ok)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    Widget body;
    if (_items.isEmpty && _loading) {
      body = const LoadingView();
    } else if (_items.isEmpty && _error != null) {
      body = ErrorState(error: _error!, onRetry: () => _load(reset: true));
    } else if (_items.isEmpty) {
      body = LayoutBuilder(
        builder: (_, box) => SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: box.maxHeight,
            child: EmptyState(icon: LucideIcons.bell, title: l.noNotifications, message: l.noNotificationsHint),
          ),
        ),
      );
    } else {
      body = NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels > n.metrics.maxScrollExtent - 400) _load();
          return false;
        },
        child: ListView.separated(
          physics: const AlwaysScrollableScrollPhysics(),
          itemCount: _items.length,
          separatorBuilder: (_, _) => const Hairline(),
          itemBuilder: (_, i) => _NotificationTile(item: _items[i], onTap: () => _open(_items[i])),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(l.navNotifications)),
      body: RefreshIndicator(onRefresh: () => _load(reset: true), child: body),
    );
  }
}

String _moderationText(AppLocalizations l, AppNotification n) => switch (n.meta['action']) {
      'remove_content' => l.moderationRemoved,
      'warn' => l.moderationWarned,
      'ban' => l.moderationBanned,
      _ => l.moderationGeneric,
    };

class _NotificationTile extends StatelessWidget {
  const _NotificationTile({required this.item, required this.onTap});
  final AppNotification item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final actor = item.actor;
    final who = actor?.handle ?? '';
    final text = switch (item.kind) {
      NotificationKind.comment => l.notifComment(who),
      NotificationKind.reply => l.notifReply(who),
      NotificationKind.like => l.notifLike(who),
      NotificationKind.mention => l.notifMention(who),
      NotificationKind.moderation => _moderationText(l, item),
    };
    return Material(
      color: item.isUnread ? c.accentSoft : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(Space.space4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (item.kind == NotificationKind.moderation)
                CircleAvatar(
                  radius: 18,
                  backgroundColor: c.surface,
                  child: Icon(LucideIcons.shieldAlert, size: 18, color: c.danger),
                )
              else
                UserAvatar(url: actor?.avatarUrl, name: actor?.name ?? '?', size: 36),
              const SizedBox(width: Space.space3),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(text, style: context.text.bodyMedium),
                    if (item.postTitle != null && item.kind != NotificationKind.moderation) ...[
                      const SizedBox(height: 2),
                      Text(
                        item.postTitle!,
                        style: context.text.bodySmall?.copyWith(color: c.inkMuted),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 2),
                    Text(relativeTime(l, item.createdAt), style: context.text.bodySmall),
                  ],
                ),
              ),
              Icon(
                switch (item.kind) {
                  NotificationKind.comment => LucideIcons.messageCircle,
                  NotificationKind.reply => LucideIcons.messageCircle,
                  NotificationKind.like => LucideIcons.heart,
                  NotificationKind.mention => LucideIcons.atSign,
                  NotificationKind.moderation => LucideIcons.flag,
                },
                size: 16,
                color: c.inkMuted,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
