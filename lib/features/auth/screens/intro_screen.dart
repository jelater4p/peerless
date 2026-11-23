// İlk açılışta 3 kaydırılabilir tanıtım ekranı (yalnızca bir kez).
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons_flutter/lucide_icons.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';

class IntroScreen extends ConsumerStatefulWidget {
  const IntroScreen({super.key});

  @override
  ConsumerState<IntroScreen> createState() => _IntroScreenState();
}

class _IntroScreenState extends ConsumerState<IntroScreen> {
  final _controller = PageController();
  int _page = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _finish() => ref.read(appSettingsProvider.notifier).markIntroSeen();

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final c = context.colors;
    final pages = [
      (LucideIcons.bookOpen, l.intro1Title, l.intro1Body),
      (LucideIcons.quote, l.intro2Title, l.intro2Body),
      (LucideIcons.search, l.intro3Title, l.intro3Body),
    ];
    final last = _page == pages.length - 1;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(onPressed: _finish, child: Text(l.skip, style: TextStyle(color: c.inkMuted))),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _page = i),
                children: [
                  for (final (icon, title, body) in pages)
                    Padding(
                      padding: const EdgeInsets.all(Space.space8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (icon == LucideIcons.bookOpen) const PeerlessLogo(size: 56) else Icon(icon, size: 48, color: c.accent),
                          const SizedBox(height: Space.space8),
                          Text(title, style: TextStyle(fontFamily: Fonts.display, fontSize: 30, height: 1.2, fontWeight: FontWeight.w700, color: c.ink)),
                          const SizedBox(height: Space.space4),
                          Text(body, style: context.text.bodyLarge?.copyWith(color: c.inkMuted)),
                        ],
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(Space.space4),
              child: Row(
                children: [
                  for (var i = 0; i < pages.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: Space.space2),
                      width: i == _page ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: i == _page ? c.accent : c.hairline,
                        borderRadius: BorderRadius.circular(Radii.full),
                      ),
                    ),
                  const Spacer(),
                  FilledButton(
                    onPressed: last
                        ? _finish
                        : () => _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut),
                    child: Text(last ? l.getStarted : l.next),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
