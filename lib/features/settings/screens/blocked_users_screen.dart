import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/widgets/common.dart';
import '../../admin/widgets/moderation_actions.dart';
import '../../profile/data/profile.dart';
import '../../profile/data/profile_repository.dart';

final blockedUsersProvider = FutureProvider.autoDispose<List<ProfileSummary>>(
  (ref) => ref.watch(profileRepositoryProvider).blockedUsers(),
);

/// Gizlilik: engellenen kullanıcılar ve engeli kaldırma.
class BlockedUsersScreen extends ConsumerWidget {
  const BlockedUsersScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(blockedUsersProvider);
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsBlocked)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(blockedUsersProvider)),
        data: (users) => users.isEmpty
            ? EmptyState(icon: LucideIcons.ban, title: l.noBlockedUsers)
            : ListView.separated(
                itemCount: users.length,
                separatorBuilder: (_, _) => const Hairline(indent: 72),
                itemBuilder: (_, i) {
                  final u = users[i];
                  return ListTile(
                    leading: UserAvatar(url: u.avatarUrl, name: u.name),
                    title: Text(u.name),
                    subtitle: Text(u.handle),
                    trailing: OutlinedButton(
                      onPressed: () async {
                        if (await unblockUser(context, ref, u.id, u.name)) ref.invalidate(blockedUsersProvider);
                      },
                      child: Text(l.unblock),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
