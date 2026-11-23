// 'Yeni sürüm var' uyarısı. APK ile dağıtımda güncellemeler otomatik gelmez;
// admin app_config tablosuna yeni sürümü ve indirme linkini yazar.
import 'package:material_ui/material_ui.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

import '../l10n.dart';

/// "1.2.10" > "1.2.9" gibi sürüm karşılaştırması.
bool isNewerVersion(String candidate, String current) {
  List<int> parse(String v) => v.split('+').first.split('.').map((e) => int.tryParse(e) ?? 0).toList();
  final a = parse(candidate), b = parse(current);
  for (var i = 0; i < 3; i++) {
    final x = i < a.length ? a[i] : 0, y = i < b.length ? b[i] : 0;
    if (x != y) return x > y;
  }
  return false;
}

Future<void> checkForUpdate(BuildContext context, SupabaseClient client) async {
  try {
    final row = await client.from('app_config').select().eq('id', 1).maybeSingle();
    if (row == null) return;
    final current = (await PackageInfo.fromPlatform()).version;
    final latest = row['latest_version'] as String? ?? current;
    final minimum = row['min_version'] as String? ?? current;
    final url = row['apk_url'] as String?;
    if (!isNewerVersion(latest, current) || !context.mounted) return;
    final forced = isNewerVersion(minimum, current);
    final l = context.l10n;
    await showDialog<void>(
      context: context,
      barrierDismissible: !forced,
      builder: (ctx) => PopScope(
        canPop: !forced,
        child: AlertDialog(
          title: Text(l.updateTitle),
          content: Text(forced ? l.updateRequired(latest) : l.updateAvailable(latest)),
          actions: [
            if (!forced) TextButton(onPressed: () => Navigator.pop(ctx), child: Text(l.later)),
            if (url != null && url.isNotEmpty)
              TextButton(
                onPressed: () => launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication),
                child: Text(l.download),
              ),
          ],
        ),
      ),
    );
  } catch (_) {
    // Çevrimdışıysa sessizce geç.
  }
}
