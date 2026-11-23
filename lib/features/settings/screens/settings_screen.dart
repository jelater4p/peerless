// Ayarlar: profil sayfasındaki dişli ikonundan açılır.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/common.dart';
import '../sign_out.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    Widget item(IconData icon, String title, String path) => ListTile(
          leading: Icon(icon),
          title: Text(title),
          trailing: Icon(LucideIcons.chevronRight, size: 18, color: c.inkMuted),
          onTap: () => context.push('${Routes.settings}/$path'),
        );
    return Scaffold(
      appBar: AppBar(title: Text(l.settings)),
      body: ListView(
        children: [
          item(LucideIcons.user, l.settingsAccount, 'account'),
          item(LucideIcons.squarePen, l.editProfile, 'profile'),
          item(LucideIcons.bell, l.settingsNotifications, 'notifications'),
          item(LucideIcons.sun, l.settingsAppearance, 'appearance'),
          item(LucideIcons.ban, l.settingsBlocked, 'blocked'),
          item(LucideIcons.info, l.settingsAbout, 'about'),
          const Hairline(),
          ListTile(
            leading: Icon(LucideIcons.logOut, color: c.danger),
            title: Text(l.signOut, style: TextStyle(color: c.danger)),
            onTap: () async {
              final ok = await confirmDialog(context, title: l.signOutConfirm, confirmLabel: l.signOut);
              if (ok) await signOutEverywhere(ref);
            },
          ),
        ],
      ),
    );
  }
}
