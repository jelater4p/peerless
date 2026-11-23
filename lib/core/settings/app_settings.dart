// Cihazda saklanan tercihler: dil, tema, okuma ayarları, tanıtım görüldü mü.
// shared_preferences ile telefona yazılır; hesapla senkronize edilmez.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../theme/tokens.dart';

/// main.dart'ta gerçek örnekle değiştirilir (ProviderScope overrides).
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError('main.dart içinde override edilmeli'),
);

enum AppThemeChoice { dark, light }

/// Okuma ekranı teması: koyu / açık / sepya.
enum ReadingTheme {
  dark,
  light,
  sepia;

  PeerlessPalette get palette => switch (this) {
        ReadingTheme.dark => PeerlessPalette.dark,
        ReadingTheme.light => PeerlessPalette.light,
        ReadingTheme.sepia => PeerlessPalette.sepia,
      };
}

/// Okuma ekranında seçilebilen fontlar.
enum ReadingFont {
  tinos(Fonts.serif),
  dejavuSerif(Fonts.dejavu),
  playfair(Fonts.display),
  kaushan(Fonts.script),
  inter(Fonts.sans);

  const ReadingFont(this.family);
  final String family;
}

/// Yazı boyutu: Küçük 16 / Orta 18 / Büyük 21 px.
enum ReadingSize {
  small(16),
  medium(18),
  large(21);

  const ReadingSize(this.px);
  final double px;
}

/// Satır aralığı: dar 1.45 / normal 1.65 / geniş 1.85.
enum ReadingLineHeight {
  narrow(1.45),
  normal(1.65),
  wide(1.85);

  const ReadingLineHeight(this.value);
  final double value;
}

@immutable
class AppSettings {
  const AppSettings({
    required this.locale,
    required this.theme,
    required this.readingFont,
    required this.readingSize,
    required this.readingLineHeight,
    required this.readingTheme,
    required this.seenIntro,
    required this.recentSearches,
  });

  /// null = telefonun dili (varsayılan)
  final Locale? locale;
  final AppThemeChoice theme;
  final ReadingFont readingFont;
  final ReadingSize readingSize;
  final ReadingLineHeight readingLineHeight;

  /// null = uygulama temasını izle
  final ReadingTheme? readingTheme;
  final bool seenIntro;

  /// Son aramalar (en fazla 10, en yenisi başta)
  final List<String> recentSearches;

  ReadingTheme get effectiveReadingTheme =>
      readingTheme ?? (theme == AppThemeChoice.dark ? ReadingTheme.dark : ReadingTheme.light);

  AppSettings copyWith({
    Locale? Function()? locale,
    AppThemeChoice? theme,
    ReadingFont? readingFont,
    ReadingSize? readingSize,
    ReadingLineHeight? readingLineHeight,
    ReadingTheme? Function()? readingTheme,
    bool? seenIntro,
    List<String>? recentSearches,
  }) {
    return AppSettings(
      locale: locale != null ? locale() : this.locale,
      theme: theme ?? this.theme,
      readingFont: readingFont ?? this.readingFont,
      readingSize: readingSize ?? this.readingSize,
      readingLineHeight: readingLineHeight ?? this.readingLineHeight,
      readingTheme: readingTheme != null ? readingTheme() : this.readingTheme,
      seenIntro: seenIntro ?? this.seenIntro,
      recentSearches: recentSearches ?? this.recentSearches,
    );
  }
}

T _byName<T extends Enum>(List<T> values, String? name, T fallback) {
  for (final v in values) {
    if (v.name == name) return v;
  }
  return fallback;
}

class AppSettingsController extends Notifier<AppSettings> {
  static const _kLocale = 'locale';
  static const _kTheme = 'theme';
  static const _kFont = 'reading_font';
  static const _kSize = 'reading_size';
  static const _kLine = 'reading_line_height';
  static const _kReadingTheme = 'reading_theme';
  static const _kSeenIntro = 'seen_intro';
  static const _kRecent = 'recent_searches';

  SharedPreferences get _prefs => ref.read(sharedPreferencesProvider);

  @override
  AppSettings build() {
    final p = ref.watch(sharedPreferencesProvider);
    final localeCode = p.getString(_kLocale);
    return AppSettings(
      locale: localeCode == null ? null : Locale(localeCode),
      theme: _byName(AppThemeChoice.values, p.getString(_kTheme), AppThemeChoice.dark),
      readingFont: _byName(ReadingFont.values, p.getString(_kFont), ReadingFont.tinos),
      readingSize: _byName(ReadingSize.values, p.getString(_kSize), ReadingSize.medium),
      readingLineHeight: _byName(ReadingLineHeight.values, p.getString(_kLine), ReadingLineHeight.normal),
      readingTheme: p.getString(_kReadingTheme) == null
          ? null
          : _byName(ReadingTheme.values, p.getString(_kReadingTheme), ReadingTheme.dark),
      seenIntro: p.getBool(_kSeenIntro) ?? false,
      recentSearches: p.getStringList(_kRecent) ?? const [],
    );
  }

  void setLocale(Locale? locale) {
    locale == null ? _prefs.remove(_kLocale) : _prefs.setString(_kLocale, locale.languageCode);
    state = state.copyWith(locale: () => locale);
  }

  void setTheme(AppThemeChoice theme) {
    _prefs.setString(_kTheme, theme.name);
    state = state.copyWith(theme: theme);
  }

  void setReadingFont(ReadingFont font) {
    _prefs.setString(_kFont, font.name);
    state = state.copyWith(readingFont: font);
  }

  void setReadingSize(ReadingSize size) {
    _prefs.setString(_kSize, size.name);
    state = state.copyWith(readingSize: size);
  }

  void setReadingLineHeight(ReadingLineHeight value) {
    _prefs.setString(_kLine, value.name);
    state = state.copyWith(readingLineHeight: value);
  }

  void setReadingTheme(ReadingTheme? theme) {
    theme == null ? _prefs.remove(_kReadingTheme) : _prefs.setString(_kReadingTheme, theme.name);
    state = state.copyWith(readingTheme: () => theme);
  }

  void markIntroSeen() {
    _prefs.setBool(_kSeenIntro, true);
    state = state.copyWith(seenIntro: true);
  }

  void addRecentSearch(String query) {
    final q = query.trim();
    if (q.isEmpty) return;
    final list = [q, ...state.recentSearches.where((e) => e != q)].take(10).toList();
    _prefs.setStringList(_kRecent, list);
    state = state.copyWith(recentSearches: list);
  }

  void removeRecentSearch(String query) {
    final list = state.recentSearches.where((e) => e != query).toList();
    _prefs.setStringList(_kRecent, list);
    state = state.copyWith(recentSearches: list);
  }
}

final appSettingsProvider = NotifierProvider<AppSettingsController, AppSettings>(AppSettingsController.new);
