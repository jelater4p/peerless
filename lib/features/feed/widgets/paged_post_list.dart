// Sonsuz kaydırmalı, yukarı çekince yenilenen içerik listesi (20'şer).
// İnternet yoksa önbellekteki son ilk sayfayı gösterir.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/cache/app_database.dart';
import '../../../core/errors/error_text.dart';
import '../../../core/l10n.dart';
import '../../../core/widgets/common.dart';
import '../../post/data/post.dart';
import '../../post/data/post_repository.dart';
import '../../post/post_events.dart';
import 'post_card.dart';

typedef PostFetcher = Future<List<Post>> Function(int offset);

class PagedPostList extends ConsumerStatefulWidget {
  const PagedPostList({
    super.key,
    required this.fetch,
    this.cacheKey,
    this.header,
    this.empty,
    this.showPinned = false,
    this.pageSize = PostRepository.pageSize,
  });

  final PostFetcher fetch;

  /// Verilirse ilk sayfa çevrimdışı kullanım için önbelleğe yazılır.
  final String? cacheKey;

  /// Listenin üstünde kayan içerik (ör. etiket çipleri).
  final Widget? header;
  final Widget? empty;
  final bool showPinned;
  final int pageSize;

  @override
  ConsumerState<PagedPostList> createState() => _PagedPostListState();
}

class _PagedPostListState extends ConsumerState<PagedPostList> with AutomaticKeepAliveClientMixin {
  final _items = <Post>[];
  bool _loading = false;
  bool _hasMore = true;
  bool _fromCache = false;
  Object? _error;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _load(reset: true);
  }

  @override
  void didUpdateWidget(covariant PagedPostList oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.cacheKey != widget.cacheKey) _load(reset: true);
  }

  Future<void> _load({bool reset = false}) async {
    if (_loading) return;
    if (!reset && !_hasMore) return;
    setState(() {
      _loading = true;
      if (reset) _error = null;
    });
    final offset = reset ? 0 : _items.length;
    try {
      final page = await widget.fetch(offset);
      if (!mounted) return;
      setState(() {
        if (reset) _items.clear();
        _items.addAll(page);
        _hasMore = page.length >= widget.pageSize;
        _fromCache = false;
      });
      if (reset && widget.cacheKey != null) {
        ref.read(appDatabaseProvider).saveList(widget.cacheKey!, page);
      }
    } catch (e) {
      if (!mounted) return;
      if (reset && widget.cacheKey != null && isNetworkError(e)) {
        final cached = await ref.read(appDatabaseProvider).getList(widget.cacheKey!);
        if (!mounted) return;
        if (cached != null) {
          setState(() {
            _items
              ..clear()
              ..addAll(cached);
            _hasMore = false;
            _fromCache = true;
          });
          return;
        }
      }
      setState(() => _error = e);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    // Bir içerik eklenince/silinince yenile.
    ref.listen(postsVersionProvider, (_, _) => _load(reset: true));

    final l = context.l10n;
    Widget body;
    if (_items.isEmpty && _loading) {
      body = const LoadingView();
    } else if (_items.isEmpty && _error != null) {
      body = ErrorState(error: _error!, onRetry: () => _load(reset: true));
    } else if (_items.isEmpty) {
      body = widget.empty ?? EmptyState(icon: LucideIcons.bookOpen, title: l.emptyList);
    } else {
      body = const SizedBox.shrink();
    }

    final showList = _items.isNotEmpty;
    return RefreshIndicator(
      onRefresh: () => _load(reset: true),
      child: NotificationListener<ScrollNotification>(
        onNotification: (n) {
          if (n.metrics.pixels > n.metrics.maxScrollExtent - 600) _load();
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            if (widget.header != null) SliverToBoxAdapter(child: widget.header),
            if (_fromCache)
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  child: Text(l.showingCached, style: Theme.of(context).textTheme.bodySmall),
                ),
              ),
            if (!showList)
              SliverFillRemaining(hasScrollBody: false, child: body)
            else
              SliverList.separated(
                itemCount: _items.length + (_hasMore ? 1 : 0),
                separatorBuilder: (_, _) => const Hairline(indent: 16),
                itemBuilder: (context, i) {
                  if (i >= _items.length) {
                    return const Padding(padding: EdgeInsets.all(24), child: LoadingView());
                  }
                  return PostCard(post: _items[i], showPinned: widget.showPinned);
                },
              ),
          ],
        ),
      ),
    );
  }
}
