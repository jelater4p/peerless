// Ana iskelet: alt navigasyon (Akış · Arama · Yaz · Bildirimler · Profil),
// 'Bağlantı yok' şeridi, push bildirimi ve sürüm kontrolü.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/connectivity/connectivity.dart';
import '../../core/l10n.dart';
import '../../core/router/app_router.dart';
import '../../core/session/session_controller.dart';
import '../../core/supabase/supabase_providers.dart';
import '../../core/theme/app_theme.dart';
import '../../core/theme/tokens.dart';
import '../../core/update/update_checker.dart';
import '../../core/widgets/common.dart';
import '../notifications/notification_providers.dart';
import '../post/data/post.dart';
import '../profile/data/profile_repository.dart';

class HomeShell extends ConsumerStatefulWidget {
  const HomeShell({super.key, required this.navigationShell});
  final StatefulNavigationShell navigationShell;

  @override
  ConsumerState<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends ConsumerState<HomeShell> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(pushServiceProvider).start();
      checkForUpdate(context, ref.read(supabaseProvider));
      _syncLocale();
    });
  }

  /// Push metinleri doğru dilde gitsin diye uygulama dilini profile yazar.
  Future<void> _syncLocale() async {
    final profile = ref.read(myProfileProvider);
    final lang = Localizations.localeOf(context).languageCode == 'tr' ? 'tr' : 'en';
    if (profile == null || profile.locale == lang) return;
    try {
      await ref.read(profileRepositoryProvider).update({'locale': lang});
    } catch (_) {}
  }

  void _onTap(int branch) {
    widget.navigationShell.goBranch(branch, initialLocation: branch == widget.navigationShell.currentIndex);
    if (branch == 2) ref.read(unreadCountProvider.notifier).refresh();
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final unread = ref.watch(unreadCountProvider);
    final index = widget.navigationShell.currentIndex;
    final offline = isOffline(ref);

    return Scaffold(
      body: Column(
        children: [
          const OfflineBanner(),
          Expanded(child: widget.navigationShell),
        ],
      ),
      bottomNavigationBar: DecoratedBox(
        decoration: BoxDecoration(
          color: c.surface,
          border: Border(top: BorderSide(color: c.hairline)),
        ),
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 60,
            child: Row(
              children: [
                _NavItem(icon: LucideIcons.bookOpen, label: l.navFeed, selected: index == 0, onTap: () => _onTap(0)),
                _NavItem(icon: LucideIcons.search, label: l.navSearch, selected: index == 1, onTap: () => _onTap(1)),
                Expanded(
                  child: Center(
                    child: Semantics(
                      button: true,
                      label: l.navWrite,
                      child: InkWell(
                        borderRadius: Radii.mdAll,
                        onTap: offline ? null : () => showWriteSheet(context),
                        child: Container(
                          width: 48,
                          height: 40,
                          decoration: BoxDecoration(
                            color: offline ? c.hairline : c.accent,
                            borderRadius: Radii.mdAll,
                          ),
                          child: Icon(LucideIcons.penLine, color: offline ? c.inkMuted : c.onAccent, size: 22),
                        ),
                      ),
                    ),
                  ),
                ),
                _NavItem(
                  icon: LucideIcons.bell,
                  label: l.navNotifications,
                  selected: index == 2,
                  badge: unread,
                  onTap: () => _onTap(2),
                ),
                _NavItem(icon: LucideIcons.circleUser, label: l.navProfile, selected: index == 3, onTap: () => _onTap(3)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({required this.icon, required this.label, required this.selected, required this.onTap, this.badge = 0});
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;
  final int badge;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final color = selected ? c.accent : c.inkMuted;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        child: Semantics(
          selected: selected,
          label: label,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Badge(
                isLabelVisible: badge > 0,
                label: Text(badge > 99 ? '99+' : '$badge'),
                child: Icon(icon, color: color, size: 22),
              ),
              const SizedBox(height: 2),
              Text(label, style: TextStyle(fontSize: 11, color: color, fontWeight: selected ? FontWeight.w600 : FontWeight.w400)),
            ],
          ),
        ),
      ),
    );
  }
}

/// "Yaz" butonu: tür seçimi + taslaklar.
Future<void> showWriteSheet(BuildContext context) {
  final l = context.l10n;
  return showModalBottomSheet<void>(
    context: context,
    builder: (ctx) => SafeArea(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(Space.space4, 0, Space.space4, Space.space2),
            child: Text(l.writeWhat, style: ctx.text.titleMedium),
          ),
          for (final t in PostType.values)
            ListTile(
              leading: Icon(t.icon),
              title: Text(t.label(l)),
              subtitle: Text(_typeHint(l, t), style: ctx.text.bodySmall),
              onTap: () {
                Navigator.pop(ctx);
                context.push(Routes.editor(type: t));
              },
            ),
          const Hairline(),
          ListTile(
            leading: const Icon(LucideIcons.history),
            title: Text(l.myDrafts),
            onTap: () {
              Navigator.pop(ctx);
              context.push(Routes.drafts);
            },
          ),
          const SizedBox(height: Space.space2),
        ],
      ),
    ),
  );
}

String _typeHint(AppLocalizations l, PostType t) => switch (t) {
      PostType.quote => l.typeQuoteHint,
      PostType.thought => l.typeThoughtHint,
      PostType.thesis => l.typeThesisHint,
      PostType.project => l.typeProjectHint,
    };
