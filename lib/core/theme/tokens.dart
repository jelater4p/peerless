// Peerless Design System değerleri (renk, boşluk, köşe).
// Kaynak: Peerless Design System > tokens.json. Bir değer değişirse önce
// orada değiştirilir, sonra buraya aynen taşınır.
import 'package:material_ui/material_ui.dart';

/// Bir temanın renk takımı. Uygulamada renk kodu yazılmaz; hep bunlar kullanılır.
@immutable
class PeerlessPalette {
  const PeerlessPalette({
    required this.brightness,
    required this.bg,
    required this.surface,
    required this.ink,
    required this.inkMuted,
    required this.hairline,
    required this.accent,
    required this.onAccent,
    required this.accentSoft,
    required this.danger,
  });

  final Brightness brightness;

  /// Sayfa arka planı. Koyu temada saf siyah yerine sıcak koyu gri.
  final Color bg;

  /// Kartlar, alt navigasyon, giriş alanları, bottom sheet.
  final Color surface;

  /// Ana metin.
  final Color ink;

  /// İkincil metin: tarih, nickname, sayaçlar, yer tutucu yazı.
  final Color inkMuted;

  /// Ayırıcı çizgiler ve kart kenarlıkları (gölge yerine).
  final Color hairline;

  /// Tek vurgu rengi (amber): birincil buton, aktif sekme, beğeni, link.
  final Color accent;

  /// accent zemin üzerindeki metin ve ikon.
  final Color onAccent;

  /// Seçili çip, alıntı bloğu zemini, okunmamış bildirim satırı.
  final Color accentSoft;

  /// Yalnızca hata ve yıkıcı eylemler.
  final Color danger;

  static const dark = PeerlessPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF1C1A17),
    surface: Color(0xFF26231F),
    ink: Color(0xFFEDE6DB),
    inkMuted: Color(0xFFA89F92),
    hairline: Color(0xFF3A3530),
    accent: Color(0xFFE0A347),
    onAccent: Color(0xFF1C1A17),
    accentSoft: Color(0xFF3A2E1C),
    danger: Color(0xFFEC8574),
  );

  static const light = PeerlessPalette(
    brightness: Brightness.light,
    bg: Color(0xFFFBF8F3),
    surface: Color(0xFFFFFFFF),
    ink: Color(0xFF2A2420),
    inkMuted: Color(0xFF6B6158),
    hairline: Color(0xFFE6DED2),
    accent: Color(0xFF99590C),
    onAccent: Color(0xFFFFFFFF),
    accentSoft: Color(0xFFF6E7CC),
    danger: Color(0xFFB3362A),
  );

  /// Yalnızca okuma ekranında seçilebilir.
  static const sepia = PeerlessPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF4ECD8),
    surface: Color(0xFFFBF5E6),
    ink: Color(0xFF3B2F22),
    inkMuted: Color(0xFF6B5A44),
    hairline: Color(0xFFD9CCB0),
    accent: Color(0xFF8C500B),
    onAccent: Color(0xFFFFF8EA),
    accentSoft: Color(0xFFEAD6AE),
    danger: Color(0xFFA3322A),
  );
}

/// Boşluklar 4'ün katları. Ekran kenarı ve kart iç boşluğu: [space4].
abstract final class Space {
  static const double space1 = 4; // ikon ile metin arası
  static const double space2 = 8; // çipler arası
  static const double space3 = 12; // kart içi öğeler arası
  static const double space4 = 16; // ekran kenarı, kart iç boşluğu
  static const double space6 = 24; // bölümler arası
  static const double space8 = 32; // büyük bölüm ayrımı
}

/// Köşe yuvarlaklıkları. Varsayılan [md] (8px).
abstract final class Radii {
  static const double sm = 4; // rozetler, küçük çipler
  static const double md = 8; // kart, buton, giriş alanı, görsel
  static const double full = 9999; // profil fotoğrafı, yuvarlak ikon butonlar

  static const BorderRadius smAll = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius mdAll = BorderRadius.all(Radius.circular(md));
}

/// Font aileleri (pubspec.yaml'da paketlenen adlarla aynı).
abstract final class Fonts {
  static const sans = 'Inter';
  static const serif = 'Tinos';
  static const display = 'Playfair Display';
  static const script = 'Kaushan Script';
  static const dejavu = 'DejaVu Serif';
}
