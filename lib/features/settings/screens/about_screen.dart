import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../core/config/env.dart';
import '../../../core/l10n.dart';
import '../../../core/router/app_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';

final packageInfoProvider = FutureProvider<PackageInfo>((ref) => PackageInfo.fromPlatform());

/// Hakkında: sürüm, KVKK aydınlatma metni, kullanım koşulları,
/// açık kaynak lisansları, iletişim e-postası.
class AboutScreen extends ConsumerWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final c = context.colors;
    final info = ref.watch(packageInfoProvider).value;
    final version = info == null ? '' : '${info.version} (${info.buildNumber})';
    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAbout)),
      body: ListView(
        children: [
          const SizedBox(height: Space.space6),
          const Center(child: PeerlessLogo(size: 64)),
          const SizedBox(height: Space.space3),
          Center(child: Text('Peerless', style: TextStyle(fontFamily: Fonts.display, fontSize: 24, color: c.ink))),
          Center(child: Text(l.versionLabel(version), style: context.text.bodySmall)),
          const SizedBox(height: Space.space6),
          const Hairline(),
          ListTile(
            leading: const Icon(LucideIcons.shieldCheck),
            title: Text(l.privacyNotice),
            onTap: () => context.push('${Routes.settings}/legal/kvkk'),
          ),
          ListTile(
            leading: const Icon(LucideIcons.scale),
            title: Text(l.termsOfUse),
            onTap: () => context.push('${Routes.settings}/legal/terms'),
          ),
          ListTile(
            leading: const Icon(LucideIcons.fileText),
            title: Text(l.openSourceLicenses),
            onTap: () => showLicensePage(context: context, applicationName: 'Peerless', applicationVersion: version),
          ),
          ListTile(
            leading: const Icon(LucideIcons.mail),
            title: Text(l.contact),
            subtitle: const Text(Env.contactEmail),
            onTap: () => launchUrl(Uri(scheme: 'mailto', path: Env.contactEmail)),
          ),
        ],
      ),
    );
  }
}
