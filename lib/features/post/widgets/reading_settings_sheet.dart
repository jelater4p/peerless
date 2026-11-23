// Okuma ekranı ayarları: font, yazı boyutu, satır aralığı ve tema.
// Seçimler cihazda saklanır.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/settings/app_settings.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';

Future<void> showReadingSettings(BuildContext context) => showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const ReadingSettingsPanel(),
    );

class ReadingSettingsPanel extends ConsumerWidget {
  const ReadingSettingsPanel({super.key, this.padding = const EdgeInsets.fromLTRB(16, 0, 16, 24)});
  final EdgeInsets padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l = context.l10n;
    final s = ref.watch(appSettingsProvider);
    final ctl = ref.read(appSettingsProvider.notifier);

    Widget section(String title, Widget child) => Padding(
          padding: const EdgeInsets.only(top: Space.space4),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: context.text.labelLarge),
              const SizedBox(height: Space.space2),
              child,
            ],
          ),
        );

    return SafeArea(
      child: SingleChildScrollView(
        padding: padding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l.readingSettings, style: context.text.titleMedium),
            section(
              l.font,
              Wrap(
                spacing: Space.space2,
                runSpacing: Space.space2,
                children: [
                  for (final f in ReadingFont.values)
                    ChoiceChip(
                      selected: s.readingFont == f,
                      onSelected: (_) => ctl.setReadingFont(f),
                      label: Text(_fontName(f), style: TextStyle(fontFamily: f.family, fontSize: 15)),
                    ),
                ],
              ),
            ),
            section(
              l.textSize,
              _Segmented<ReadingSize>(
                values: ReadingSize.values,
                selected: s.readingSize,
                label: (v) => switch (v) {
                  ReadingSize.small => l.sizeSmall,
                  ReadingSize.medium => l.sizeMedium,
                  ReadingSize.large => l.sizeLarge,
                },
                onChanged: ctl.setReadingSize,
              ),
            ),
            section(
              l.lineSpacing,
              _Segmented<ReadingLineHeight>(
                values: ReadingLineHeight.values,
                selected: s.readingLineHeight,
                label: (v) => switch (v) {
                  ReadingLineHeight.narrow => l.lineNarrow,
                  ReadingLineHeight.normal => l.lineNormal,
                  ReadingLineHeight.wide => l.lineWide,
                },
                onChanged: ctl.setReadingLineHeight,
              ),
            ),
            section(
              l.readingTheme,
              _Segmented<ReadingTheme>(
                values: ReadingTheme.values,
                selected: s.effectiveReadingTheme,
                label: (v) => switch (v) {
                  ReadingTheme.dark => l.themeDark,
                  ReadingTheme.light => l.themeLight,
                  ReadingTheme.sepia => l.themeSepia,
                },
                onChanged: ctl.setReadingTheme,
              ),
            ),
          ],
        ),
      ),
    );
  }

  static String _fontName(ReadingFont f) => switch (f) {
        ReadingFont.tinos => 'Tinos',
        ReadingFont.dejavuSerif => 'DejaVu Serif',
        ReadingFont.playfair => 'Playfair',
        ReadingFont.kaushan => 'Kaushan',
        ReadingFont.inter => 'Inter',
      };
}

class _Segmented<T> extends StatelessWidget {
  const _Segmented({required this.values, required this.selected, required this.label, required this.onChanged});
  final List<T> values;
  final T selected;
  final String Function(T) label;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: SegmentedButton<T>(
        showSelectedIcon: false,
        segments: [for (final v in values) ButtonSegment(value: v, label: Text(label(v)))],
        selected: {selected},
        onSelectionChanged: (s) => onChanged(s.first),
        style: ButtonStyle(
          backgroundColor: WidgetStateProperty.resolveWith(
            (st) => st.contains(WidgetState.selected) ? context.colors.accentSoft : context.colors.surface,
          ),
          foregroundColor: WidgetStatePropertyAll(context.colors.ink),
          side: WidgetStatePropertyAll(BorderSide(color: context.colors.hairline)),
          shape: const WidgetStatePropertyAll(RoundedRectangleBorder(borderRadius: Radii.mdAll)),
        ),
      ),
    );
  }
}
