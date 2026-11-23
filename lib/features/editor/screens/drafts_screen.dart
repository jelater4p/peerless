import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/widgets/common.dart';
import '../../feed/widgets/post_card.dart';
import '../../post/data/post.dart';
import '../../post/data/post_repository.dart';
import '../../post/post_events.dart';

final myDraftsProvider = FutureProvider.autoDispose<List<Post>>((ref) {
  ref.watch(postsVersionProvider);
  return ref.watch(postRepositoryProvider).myDrafts();
});

/// Taslaklarım: en son düzenlenen başta; dokununca editörde açılır.
class DraftsScreen extends ConsumerWidget {
  const DraftsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(myDraftsProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.myDrafts)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(myDraftsProvider)),
        data: (drafts) => drafts.isEmpty
            ? EmptyState(icon: LucideIcons.penLine, title: l.noDrafts, message: l.noDraftsHint)
            : RefreshIndicator(
                onRefresh: () => ref.refresh(myDraftsProvider.future),
                child: ListView.separated(
                  itemCount: drafts.length,
                  separatorBuilder: (_, _) => const Hairline(indent: 16),
                  itemBuilder: (_, i) => PostCard(
                    post: drafts[i],
                    onTap: () async {
                      await context.push(Routes.editor(postId: drafts[i].id));
                      ref.invalidate(myDraftsProvider);
                    },
                  ),
                ),
              ),
      ),
    );
  }
}
