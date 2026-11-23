// Okuma ekranı yazı stilleri (Design System > Okuma grubu) — kullanıcının
// seçtiği font, boyut ve satır aralığına göre üretilir.
import 'package:material_ui/material_ui.dart';

import '../settings/app_settings.dart';
import 'tokens.dart';

@immutable
class ReadingStyles {
  const ReadingStyles({
    required this.palette,
    required this.title,
    required this.body,
    required this.quote,
    required this.heading,
    required this.meta,
  });

  /// [palette] verilirse okuma teması yerine o renkler kullanılır (ör. editörde).
  factory ReadingStyles.of(AppSettings s, {PeerlessPalette? palette}) {
    final p = palette ?? s.effectiveReadingTheme.palette;
    final size = s.readingSize.px;
    final family = s.readingFont.family;
    final lh = s.readingLineHeight.value;
    return ReadingStyles(
      palette: p,
      // post-title: Playfair Display 28/34 700
      title: TextStyle(fontFamily: Fonts.display, fontSize: 28, height: 34 / 28, fontWeight: FontWeight.w700, color: p.ink),
      // post-body: varsayılan Tinos 18/30 (kullanıcı değiştirebilir)
      body: TextStyle(fontFamily: family, fontSize: size, height: lh, color: p.ink),
      // post-quote: 22/32 italik
      quote: TextStyle(
        fontFamily: family,
        fontSize: size + 4,
        height: lh * 0.97,
        fontStyle: FontStyle.italic,
        color: p.ink,
      ),
      heading: TextStyle(fontFamily: family, fontSize: size + 4, height: 1.3, fontWeight: FontWeight.w700, color: p.ink),
      meta: TextStyle(fontFamily: Fonts.sans, fontSize: 13, height: 18 / 13, color: p.inkMuted),
    );
  }

  /// Alıntı türünde gövde alıntı stiliyle gösterilir.
  ReadingStyles withBody(TextStyle body) =>
      ReadingStyles(palette: palette, title: title, body: body, quote: quote, heading: heading, meta: meta);

  final PeerlessPalette palette;
  final TextStyle title;
  final TextStyle body;
  final TextStyle quote;
  final TextStyle heading;
  final TextStyle meta;
}
