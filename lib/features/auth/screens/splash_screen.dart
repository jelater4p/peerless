import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/session/session_controller.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';

/// Açılış: oturum kontrol edilirken logo; internet yoksa tekrar dene.
class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final session = ref.watch(sessionProvider);
    final offline = session.status == SessionStatus.offline;
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const PeerlessLogo(size: 72),
            const SizedBox(height: Space.space6),
            if (offline) ...[
              Text(context.l10n.errOffline, style: context.text.bodyMedium, textAlign: TextAlign.center),
              const SizedBox(height: Space.space4),
              OutlinedButton(
                onPressed: () => ref.read(sessionProvider.notifier).refresh(),
                child: Text(context.l10n.retry),
              ),
            ] else
              const SizedBox(width: 24, height: 24, child: CircularProgressIndicator(strokeWidth: 2)),
          ],
        ),
      ),
    );
  }
}
