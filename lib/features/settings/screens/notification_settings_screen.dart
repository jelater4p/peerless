import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../notifications/data/notification_repository.dart';

final notificationSettingsProvider = FutureProvider.autoDispose<NotificationSettings>(
  (ref) => ref.watch(notificationRepositoryProvider).settings(),
);

/// Dört bildirim türü ayrı ayrı açılıp kapatılır. Moderasyon bildirimleri kapatılamaz.
class NotificationSettingsScreen extends ConsumerWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final async = ref.watch(notificationSettingsProvider);

    Future<void> set(String field, bool value) async {
      try {
        await ref.read(notificationRepositoryProvider).updateSetting(field, value);
        ref.invalidate(notificationSettingsProvider);
      } catch (e) {
        if (context.mounted) showError(context, e);
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsNotifications)),
      body: async.when(
        loading: () => const LoadingView(),
        error: (e, _) => ErrorState(error: e, onRetry: () => ref.invalidate(notificationSettingsProvider)),
        data: (s) => ListView(
          children: [
            SwitchListTile(value: s.comment, onChanged: (v) => set('comment', v), title: Text(l.notifSettingComment)),
            SwitchListTile(value: s.reply, onChanged: (v) => set('reply', v), title: Text(l.notifSettingReply)),
            SwitchListTile(value: s.like, onChanged: (v) => set('like', v), title: Text(l.notifSettingLike)),
            SwitchListTile(value: s.mention, onChanged: (v) => set('mention', v), title: Text(l.notifSettingMention)),
            Padding(
              padding: const EdgeInsets.all(Space.space4),
              child: Text(l.notifSettingModeration, style: context.text.bodySmall),
            ),
          ],
        ),
      ),
    );
  }
}
