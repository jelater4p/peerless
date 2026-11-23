// İnternet bağlantısı durumu. Bağlantı yokken üstte 'Bağlantı yok' şeridi
// çıkar; yazma, beğenme ve yorum devre dışı kalır.
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../l10n.dart';
import '../theme/app_theme.dart';
import '../theme/tokens.dart';

final isOfflineProvider = StreamProvider<bool>((ref) async* {
  final c = Connectivity();
  bool offline(List<ConnectivityResult> r) => r.isEmpty || r.every((e) => e == ConnectivityResult.none);
  yield offline(await c.checkConnectivity());
  yield* c.onConnectivityChanged.map(offline);
});

/// true ise yazma eylemleri kapalı.
bool isOffline(WidgetRef ref) => ref.watch(isOfflineProvider).value ?? false;

class OfflineBanner extends ConsumerWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (!isOffline(ref)) return const SizedBox.shrink();
    final c = context.colors;
    return Material(
      color: c.accentSoft,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: Space.space4, vertical: Space.space2),
          child: Row(
            children: [
              Icon(LucideIcons.wifiOff, size: 16, color: c.ink),
              const SizedBox(width: Space.space2),
              Expanded(child: Text(context.l10n.offlineBanner, style: context.text.labelMedium)),
            ],
          ),
        ),
      ),
    );
  }
}
