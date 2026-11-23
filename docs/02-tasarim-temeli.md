# Adım 2 — Tasarım temeli (tema, fontlar, TR/EN)

**Bu adımda öğrenilenler:** Flutter'da widget ağacı ve tema, ThemeExtension, font
paketleme, çok dillilik (ARB dosyaları).

## Renkler ve ölçüler

Değerler **Peerless Design System**'den birebir alındı: `lib/core/theme/tokens.dart`.

- `PeerlessPalette.dark` (varsayılan), `.light`, `.sepia` (yalnızca okuma ekranında)
- `Space.space1…space8` (4'ün katları), `Radii.sm/md/full` (4 / 8 / tam yuvarlak)

`lib/core/theme/app_theme.dart` bu değerlerden Material `ThemeData` üretir. Ekranlarda
renk kodu yazılmaz, hep şöyle kullanılır:

```dart
final c = context.colors;   // PeerlessPalette
Text('Merhaba', style: TextStyle(color: c.inkMuted));
```

`test/unit_test.dart` her temada metin/zemin kontrastının en az 4.5:1 olduğunu test eder.

## Fontlar

`assets/fonts/` altında paketlenir (internetten indirilmez):

| Font | Kullanım | Lisans |
| --- | --- | --- |
| Inter | Arayüz (sabit) | SIL OFL 1.1 |
| Tinos | Okuma metni (varsayılan) | SIL OFL 1.1 |
| Playfair Display | İçerik başlığı | SIL OFL 1.1 |
| Kaushan Script | Okuma ekranında seçilebilir | SIL OFL 1.1 |
| DejaVu Serif | Okuma ekranında seçilebilir | Bitstream Vera / kamu malı |

Hepsi Türkçe karakterler (ç ş ğ ü ö ı İ) için tek tek kontrol edildi; eksik karakteri olan
yok. Lisans metinleri `assets/fonts/licenses/` altında ve uygulamada *Ayarlar > Hakkında >
Açık kaynak lisansları* sayfasında görünür (`main.dart` → `_registerFontLicenses`).

## Çok dillilik

- Metinler: `lib/l10n/app_tr.arb` (şablon) ve `lib/l10n/app_en.arb`
- Kodda: `context.l10n.signIn` gibi
- Yeni metin eklemek: iki ARB dosyasına aynı anahtarı ekle, sonra:
  ```bash
  flutter gen-l10n
  ```
- Dil varsayılan olarak telefonun dili (Türkçe değilse İngilizce); *Ayarlar > Görünüm*'den değişir.

## Material notu (Flutter 3.50)

Flutter 3.50'de Material widget'ları ayrı bir pakete (`material_ui`) taşındı. Uygulama
`import 'package:material_ui/material_ui.dart';` kullanır. Editör paketi (flutter_quill)
henüz eski yolu kullandığı için `QuillMaterialBridge` adlı küçük bir köprü var; flutter_quill
güncellenince kaldırılabilir.
