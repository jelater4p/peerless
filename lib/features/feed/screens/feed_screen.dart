// Ana akış: tür sekmeleri + etiket filtresi + sıralama (en yeni / popüler).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../post/data/post.dart';
import '../../post/data/post_repository.dart';
import '../widgets/paged_post_list.dart';

final popularTagsProvider = FutureProvider<List<String>>((ref) => ref.watch(postRepositoryProvider).popularTags());

class FeedScreen extends ConsumerStatefulWidget {
  const FeedScreen({super.key});

  @override
  ConsumerState<FeedScreen> createState() => _FeedScreenState();
}

class _FeedScreenState extends ConsumerState<FeedScreen> {
  FeedSort _sort = FeedSort.latest;
  String? _tag;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final types = <PostType?>[null, ...PostType.values];

    return DefaultTabController(
      length: types.length,
      child: Scaffold(
        appBar: AppBar(
          titleSpacing: Space.space4,
          title: Row(
            children: [
              const PeerlessLogo(size: 28),
              const SizedBox(width: Space.space2),
              Text('Peerless', style: TextStyle(fontFamily: Fonts.display, fontSize: 22, fontWeight: FontWeight.w700, color: c.ink)),
            ],
          ),
          actions: [
            PopupMenuButton<FeedSort>(
              tooltip: l.sort,
              icon: const Icon(LucideIcons.arrowUpDown),
              initialValue: _sort,
              onSelected: (s) => setState(() => _sort = s),
              itemBuilder: (_) => [
                CheckedPopupMenuItem(value: FeedSort.latest, checked: _sort == FeedSort.latest, child: Text(l.sortLatest)),
                CheckedPopupMenuItem(value: FeedSort.popular, checked: _sort == FeedSort.popular, child: Text(l.sortPopular)),
              ],
            ),
          ],
          bottom: TabBar(
            isScrollable: true,
            tabs: [for (final t in types) Tab(text: t == null ? l.tabAll : t.pluralLabel(l))],
          ),
        ),
        body: TabBarView(
          children: [
            for (final t in types)
              PagedPostList(
                key: ValueKey('${t?.name}-$_tag-${_sort.name}'),
                cacheKey: 'feed:${t?.name ?? 'all'}:${_tag ?? '-'}:${_sort.name}',
                header: _TagBar(selected: _tag, onSelected: (tag) => setState(() => _tag = tag), sort: _sort),
                fetch: (offset) => ref.read(postRepositoryProvider).feed(type: t, tag: _tag, sort: _sort, offset: offset),
                empty: EmptyState(
                  icon: _sort == FeedSort.popular ? LucideIcons.heart : LucideIcons.bookOpen,
                  title: _sort == FeedSort.popular ? l.emptyPopular : l.emptyFeed,
                  message: l.emptyFeedHint,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Popüler etiketlerden filtre çipleri.
class _TagBar extends ConsumerWidget {
  const _TagBar({required this.selected, required this.onSelected, required this.sort});
  final String? selected;
  final ValueChanged<String?> onSelected;
  final FeedSort sort;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final tags = ref.watch(popularTagsProvider).value ?? const <String>[];
    final all = {?selected, ...tags}.toList();
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (all.isNotEmpty)
          SizedBox(
            height: 48,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: Space.space4, vertical: Space.space2),
              itemCount: all.length,
              separatorBuilder: (_, _) => const SizedBox(width: Space.space2),
              itemBuilder: (_, i) {
                final tag = all[i];
                final isSel = tag == selected;
                return FilterChip(
                  label: Text('#$tag'),
                  selected: isSel,
                  onSelected: (_) => onSelected(isSel ? null : tag),
                );
              },
            ),
          ),
        if (sort == FeedSort.popular)
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.space4, Space.space2, Space.space4, 0),
            child: Text(l.popularHint, style: context.text.bodySmall),
          ),
      ],
    );
  }
}
