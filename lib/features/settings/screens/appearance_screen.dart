import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../../../core/widgets/common.dart';
import '../../post/widgets/reading_settings_sheet.dart';

/// Görünüm: dil, tema ve okuma varsayılanları.
class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(appSettingsProvider);
    final ctl = ref.read(appSettingsProvider.notifier);
    final lang = s.locale?.languageCode;

    Widget header(String t) => Padding(
          padding: const EdgeInsets.fromLTRB(Space.space4, Space.space6, Space.space4, Space.space2),
          child: Text(t, style: context.text.labelLarge?.copyWith(color: context.colors.inkMuted)),
        );

    return Scaffold(
      appBar: AppBar(title: Text(l.settingsAppearance)),
      body: ListView(
        children: [
          header(l.language),
          RadioGroup<String?>(
            groupValue: lang,
            onChanged: (v) => ctl.setLocale(v == null ? null : Locale(v)),
            child: Column(
              children: [
                RadioListTile<String?>(value: null, title: Text(l.languageSystem)),
                const RadioListTile<String?>(value: 'tr', title: Text('Türkçe')),
                const RadioListTile<String?>(value: 'en', title: Text('English')),
              ],
            ),
          ),
          header(l.theme),
          RadioGroup<AppThemeChoice>(
            groupValue: s.theme,
            onChanged: (v) => ctl.setTheme(v ?? AppThemeChoice.dark),
            child: Column(
              children: [
                RadioListTile(value: AppThemeChoice.dark, title: Text(l.themeDark)),
                RadioListTile(value: AppThemeChoice.light, title: Text(l.themeLight)),
              ],
            ),
          ),
          const Hairline(),
          const ReadingSettingsPanel(padding: EdgeInsets.fromLTRB(16, 24, 16, 24)),
        ],
      ),
    );
  }
}
