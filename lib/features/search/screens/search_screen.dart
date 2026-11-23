// Arama: tek kutu, yazdıkça sonuç; üstte en fazla 3 kişi, altta içerikler.
// Kutu boşken son aramalar (cihazda, en fazla 10) + haftanın popüler içerikleri.
import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../feed/widgets/paged_post_list.dart';
import '../../feed/widgets/post_card.dart';
import '../../post/data/post.dart';
import '../../post/data/post_repository.dart';
import '../../profile/data/profile.dart';
import '../../profile/data/profile_repository.dart';

final weeklyPopularProvider = FutureProvider.autoDispose<List<Post>>(
  (ref) => ref.watch(postRepositoryProvider).feed(sort: FeedSort.popular, limit: 10),
);

final _peopleSearchProvider = FutureProvider.autoDispose.family<List<Profile>, String>(
  (ref, q) => ref.watch(profileRepositoryProvider).search(q),
);

class SearchScreen extends ConsumerStatefulWidget {
  const SearchScreen({super.key});

  @override
  ConsumerState<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends ConsumerState<SearchScreen> {
  final _controller = TextEditingController();
  Timer? _debounce;
  String _query = '';

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onChanged(String v) {
    setState(() {});
    _debounce?.cancel();
    // Yazmayı bıraktıktan kısa süre sonra (300 ms) arar.
    _debounce = Timer(const Duration(milliseconds: 300), () => setState(() => _query = v.trim()));
  }

  void _searchFor(String q) {
    _controller.text = q;
    _controller.selection = TextSelection.collapsed(offset: q.length);
    setState(() => _query = q);
    ref.read(appSettingsProvider.notifier).addRecentSearch(q);
  }

  void _remember() {
    if (_query.isNotEmpty) ref.read(appSettingsProvider.notifier).addRecentSearch(_query);
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    return Scaffold(
      appBar: AppBar(
        titleSpacing: Space.space4,
        title: TextField(
          controller: _controller,
          onChanged: _onChanged,
          onSubmitted: (v) => _searchFor(v.trim()),
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: l.searchHint,
            isDense: true,
            prefixIcon: Icon(LucideIcons.search, size: 18, color: c.inkMuted),
            suffixIcon: _controller.text.isEmpty
                ? null
                : IconButton(
                    icon: Icon(LucideIcons.x, size: 18, color: c.inkMuted),
                    onPressed: () {
                      _controller.clear();
                      setState(() => _query = '');
                    },
                  ),
          ),
        ),
      ),
      body: _query.isEmpty ? _idle(context) : _results(context),
    );
  }

  Widget _idle(BuildContext context) {
    final l = context.l10n;
    final recent = ref.watch(appSettingsProvider).recentSearches;
    final popular = ref.watch(weeklyPopularProvider);
    return ListView(
      children: [
        if (recent.isNotEmpty) ...[
          _SectionTitle(l.recentSearches),
          for (final q in recent)
            ListTile(
              leading: const Icon(LucideIcons.history, size: 18),
              title: Text(q),
              onTap: () => _searchFor(q),
              trailing: IconButton(
                tooltip: l.remove,
                icon: const Icon(LucideIcons.x, size: 18),
                onPressed: () => ref.read(appSettingsProvider.notifier).removeRecentSearch(q),
              ),
            ),
        ],
        _SectionTitle(l.popularThisWeek),
        ...popular.when(
          loading: () => [const Padding(padding: EdgeInsets.all(24), child: LoadingView())],
          error: (e, _) => [ErrorState(error: e, onRetry: () => ref.invalidate(weeklyPopularProvider))],
          data: (posts) => posts.isEmpty
              ? [Padding(padding: const EdgeInsets.all(Space.space4), child: Text(l.emptyPopular))]
              : [
                  for (final p in posts) ...[PostCard(post: p), const Hairline(indent: 16)],
                ],
        ),
      ],
    );
  }

  Widget _results(BuildContext context) {
    final l = context.l10n;
    final q = _query;
    final people = ref.watch(_peopleSearchProvider(q));
    final peopleList = people.value ?? const <Profile>[];
    return PagedPostList(
      key: ValueKey('search:$q'),
      fetch: (offset) => ref.read(postRepositoryProvider).search(q, offset: offset),
      header: peopleList.isEmpty
          ? null
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _SectionTitle(l.people),
                for (final p in peopleList)
                  ListTile(
                    leading: UserAvatar(url: p.avatarUrl, name: p.name, size: 36),
                    title: Text(p.name),
                    subtitle: Text('@${p.nickname}'),
                    onTap: () {
                      _remember();
                      context.push(Routes.user(p.id));
                    },
                  ),
                _SectionTitle(l.posts),
              ],
            ),
      empty: peopleList.isNotEmpty
          ? EmptyState(icon: LucideIcons.search, title: l.noPostResults)
          : const _NoResults(),
    );
  }
}

class _NoResults extends ConsumerWidget {
  const _NoResults();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final popular = ref.watch(weeklyPopularProvider).value ?? const <Post>[];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        EmptyState(icon: LucideIcons.search, title: l.noResults),
        if (popular.isNotEmpty) ...[
          _SectionTitle(l.popularThisWeek),
          for (final p in popular.take(5)) PostCard(post: p),
        ],
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.fromLTRB(Space.space4, Space.space4, Space.space4, Space.space2),
        child: Text(text, style: context.text.labelLarge?.copyWith(color: context.colors.inkMuted)),
      );
}
