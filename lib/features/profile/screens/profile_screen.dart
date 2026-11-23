// Profil = kişinin kütüphanesi: kapak, fotoğraf, ad, @nickname, biyografi,
// sabitlenmiş içerik ve tür sekmeleri. Kendi profilinde gizli 'Kaydedilenler'.
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
import '../../../core/widgets/common.dart';
import '../../admin/data/moderation_repository.dart';
import '../../admin/widgets/moderation_actions.dart';
import '../../feed/widgets/paged_post_list.dart';
import '../../feed/widgets/post_card.dart';
import '../../post/data/post.dart';
import '../../post/data/post_repository.dart';
import '../../post/post_events.dart';
import '../data/profile.dart';
import '../data/profile_repository.dart';

/// Profil: id veya nickname ile.
final profileLookupProvider = FutureProvider.autoDispose.family<Profile?, ({String? id, String? nickname})>((ref, key) {
  final repo = ref.watch(profileRepositoryProvider);
  return key.id != null ? repo.getProfile(key.id!) : repo.getProfileByNickname(key.nickname!);
});

final isBlockedProvider = FutureProvider.autoDispose.family<bool, String>(
  (ref, userId) => ref.watch(profileRepositoryProvider).isBlocked(userId),
);

final pinnedPostProvider = FutureProvider.autoDispose.family<Post?, String>((ref, userId) {
  ref.watch(postsVersionProvider);
  return ref.watch(postRepositoryProvider).pinnedPost(userId);
});

/// Alt navigasyondaki "Profil" sekmesi.
class MyProfileScreen extends ConsumerWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(myProfileProvider);
    if (profile == null) return const Scaffold(body: LoadingView());
    return ProfileView(profile: profile, isMe: true);
  }
}

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key, this.userId, this.nickname});
  final String? userId;
  final String? nickname;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final me = ref.watch(currentUserIdProvider);
    final myProfile = ref.watch(myProfileProvider);
    if ((userId != null && userId == me) || (nickname != null && nickname == myProfile?.nickname)) {
      if (myProfile != null) return ProfileView(profile: myProfile, isMe: true, standalone: true);
    }
    final async = ref.watch(profileLookupProvider((id: userId, nickname: nickname)));
    return async.when(
      loading: () => Scaffold(appBar: AppBar(), body: const LoadingView()),
      error: (e, _) => Scaffold(
        appBar: AppBar(),
        body: ErrorState(error: e, onRetry: () => ref.invalidate(profileLookupProvider((id: userId, nickname: nickname)))),
      ),
      data: (p) => p == null
          ? Scaffold(
              appBar: AppBar(),
              body: EmptyState(icon: LucideIcons.userX, title: context.l10n.userNotFound),
            )
          : ProfileView(profile: p, isMe: false, standalone: true),
    );
  }
}

class ProfileView extends ConsumerWidget {
  const ProfileView({super.key, required this.profile, required this.isMe, this.standalone = false});
  final Profile profile;
  final bool isMe;

  /// Alt navigasyon dışında açıldıysa geri butonu gösterilir.
  final bool standalone;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final repo = ref.read(postRepositoryProvider);
    final blocked = isMe ? false : (ref.watch(isBlockedProvider(profile.id)).value ?? false);

    final tabs = <(String, Widget)>[
      (
        l.tabAll,
        PagedPostList(
          cacheKey: 'user:${profile.id}:all',
          header: _PinnedHeader(userId: profile.id),
          fetch: (o) => repo.userPosts(profile.id, excludePinned: true, offset: o),
          empty: EmptyState(icon: LucideIcons.bookOpen, title: isMe ? l.emptyMyLibrary : l.emptyLibrary),
        ),
      ),
      for (final t in PostType.values)
        (
          t.pluralLabel(l),
          PagedPostList(
            fetch: (o) => repo.userPosts(profile.id, type: t, offset: o),
            empty: EmptyState(icon: t.icon, title: l.emptyType),
          ),
        ),
      if (isMe)
        (
          l.bookmarks,
          PagedPostList(
            fetch: (o) => repo.bookmarks(offset: o),
            empty: EmptyState(icon: LucideIcons.bookmark, title: l.emptyBookmarks, message: l.emptyBookmarksHint),
          ),
        ),
    ];

    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: standalone,
          title: Text('@${profile.nickname ?? ''}'),
          actions: [
            if (isMe) ...[
              if (profile.isAdmin)
                IconButton(
                  tooltip: l.adminPanel,
                  icon: const Icon(LucideIcons.shieldCheck),
                  onPressed: () => context.push(Routes.admin),
                ),
              IconButton(
                tooltip: l.settings,
                icon: const Icon(LucideIcons.settings),
                onPressed: () => context.push(Routes.settings),
              ),
            ] else
              PopupMenuButton<String>(
                icon: const Icon(LucideIcons.moreVertical),
                onSelected: (v) async {
                  if (v == 'block') {
                    if (await blockUser(context, ref, profile.id, profile.name)) {
                      ref.invalidate(isBlockedProvider(profile.id));
                    }
                  } else if (v == 'unblock') {
                    if (await unblockUser(context, ref, profile.id, profile.name)) {
                      ref.invalidate(isBlockedProvider(profile.id));
                    }
                  } else if (v == 'report' && context.mounted) {
                    reportContent(context, ref, ReportTarget.profile, profile.id);
                  }
                },
                itemBuilder: (_) => [
                  if (blocked)
                    PopupMenuItem(value: 'unblock', child: Text(l.unblock))
                  else
                    PopupMenuItem(value: 'block', child: Text(l.block, style: TextStyle(color: context.colors.danger))),
                  PopupMenuItem(value: 'report', child: Text(l.report)),
                ],
              ),
          ],
        ),
        body: NestedScrollView(
          headerSliverBuilder: (context, _) => [
            SliverToBoxAdapter(child: _ProfileHeader(profile: profile, isMe: isMe, blocked: blocked)),
            SliverPersistentHeader(
              pinned: true,
              delegate: _TabBarDelegate(
                TabBar(isScrollable: true, tabs: [for (final t in tabs) Tab(text: t.$1)]),
                context.colors.bg,
              ),
            ),
          ],
          body: blocked
              ? EmptyState(icon: LucideIcons.ban, title: l.youBlockedUser, message: l.youBlockedUserHint)
              : TabBarView(children: [for (final t in tabs) t.$2]),
        ),
      ),
    );
  }
}

class _ProfileHeader extends StatelessWidget {
  const _ProfileHeader({required this.profile, required this.isMe, required this.blocked});
  final Profile profile;
  final bool isMe;
  final bool blocked;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return LayoutBuilder(
      builder: (context, box) {
        final coverHeight = box.maxWidth / 3;
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: coverHeight,
                  width: double.infinity,
                  child: profile.coverUrl != null
                      ? NetImage(url: profile.coverUrl!, radius: 0)
                      : ColoredBox(color: c.accentSoft),
                ),
                Positioned(
                  left: Space.space4,
                  bottom: -40,
                  child: Container(
                    padding: const EdgeInsets.all(3),
                    decoration: BoxDecoration(color: c.bg, shape: BoxShape.circle),
                    child: UserAvatar(url: profile.avatarUrl, name: profile.name, size: 80),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.space4, Space.space2, Space.space4, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isMe)
                    OutlinedButton(
                      onPressed: () => context.push('${Routes.settings}/profile'),
                      style: OutlinedButton.styleFrom(minimumSize: const Size(0, 36)),
                      child: Text(l.editProfile),
                    )
                  else
                    const SizedBox(height: 36),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(Space.space4, Space.space3, Space.space4, Space.space4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.displayName ?? profile.name, style: context.text.titleLarge),
                  Text('@${profile.nickname ?? ''}', style: context.text.bodyMedium?.copyWith(color: c.inkMuted)),
                  if (profile.bio != null && !blocked) ...[
                    const SizedBox(height: Space.space3),
                    Text(profile.bio!, style: context.text.bodyMedium),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _PinnedHeader extends ConsumerWidget {
  const _PinnedHeader({required this.userId});
  final String userId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pinned = ref.watch(pinnedPostProvider(userId)).value;
    if (pinned == null) return const SizedBox.shrink();
    return Column(
      children: [
        PostCard(post: pinned, showPinned: true),
        const Hairline(),
      ],
    );
  }
}

class _TabBarDelegate extends SliverPersistentHeaderDelegate {
  _TabBarDelegate(this.tabBar, this.background);
  final TabBar tabBar;
  final Color background;

  @override
  double get minExtent => tabBar.preferredSize.height;
  @override
  double get maxExtent => tabBar.preferredSize.height;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) =>
      ColoredBox(color: background, child: tabBar);

  @override
  bool shouldRebuild(covariant _TabBarDelegate old) => old.tabBar != tabBar || old.background != background;
}
