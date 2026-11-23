// Herkesin kullandığı 'Şikayet et' ve 'Engelle' eylemleri.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/widgets/common.dart';
import '../../post/post_events.dart';
import '../../profile/data/profile_repository.dart';
import '../data/moderation_repository.dart';

/// Şikayet tek dokunuştur: neden sorulmaz, onay mesajı gösterilir.
Future<void> reportContent(BuildContext context, WidgetRef ref, ReportTarget target, String targetId) async {
  final l = context.l10n;
  try {
    final created = await ref.read(moderationRepositoryProvider).report(target, targetId);
    if (!context.mounted) return;
    if (!created) {
      showSnack(l.reportAlready);
      return;
    }
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l.reportSentTitle),
        content: Text(l.reportSentBody),
        actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.ok))],
      ),
    );
  } catch (e) {
    if (context.mounted) showError(context, e);
  }
}

/// Engelleme: engellediğin kişinin içerik ve yorumlarını görmezsin; o da
/// senin içeriklerine yorum, beğeni ve @bahsetme yapamaz.
Future<bool> blockUser(BuildContext context, WidgetRef ref, String userId, String name) async {
  final l = context.l10n;
  final ok = await confirmDialog(
    context,
    title: l.blockConfirmTitle(name),
    message: l.blockConfirmBody,
    confirmLabel: l.block,
    destructive: true,
  );
  if (!ok) return false;
  try {
    await ref.read(profileRepositoryProvider).block(userId);
    ref.read(postsVersionProvider.notifier).bump();
    showSnack(l.blocked(name));
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}

Future<bool> unblockUser(BuildContext context, WidgetRef ref, String userId, String name) async {
  try {
    await ref.read(profileRepositoryProvider).unblock(userId);
    ref.read(postsVersionProvider.notifier).bump();
    if (context.mounted) showSnack(context.l10n.unblocked(name));
    return true;
  } catch (e) {
    if (context.mounted) showError(context, e);
    return false;
  }
}
