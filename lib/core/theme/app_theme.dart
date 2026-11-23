// Uygulama teması: Design System token'larından Material ThemeData üretir.
// Ekranlarda renk için `context.colors` (PeerlessPalette) kullanılır.
import 'package:material_ui/material_ui.dart';

import 'tokens.dart';

/// ThemeData'ya eklenen Peerless renk takımı.
class PeerlessColors extends ThemeExtension<PeerlessColors> {
  const PeerlessColors(this.palette);

  final PeerlessPalette palette;

  @override
  PeerlessColors copyWith({PeerlessPalette? palette}) => PeerlessColors(palette ?? this.palette);

  @override
  PeerlessColors lerp(covariant PeerlessColors? other, double t) => t < 0.5 ? this : (other ?? this);
}

extension PeerlessThemeContext on BuildContext {
  /// Etkin temanın renkleri: context.colors.accent gibi.
  PeerlessPalette get colors => Theme.of(this).extension<PeerlessColors>()!.palette;
  TextTheme get text => Theme.of(this).textTheme;
}

abstract final class AppTheme {
  static ThemeData build(PeerlessPalette p) {
    final scheme = ColorScheme(
      brightness: p.brightness,
      primary: p.accent,
      onPrimary: p.onAccent,
      primaryContainer: p.accentSoft,
      onPrimaryContainer: p.ink,
      secondary: p.accent,
      onSecondary: p.onAccent,
      secondaryContainer: p.accentSoft,
      onSecondaryContainer: p.ink,
      error: p.danger,
      onError: p.onAccent,
      surface: p.surface,
      onSurface: p.ink,
      onSurfaceVariant: p.inkMuted,
      outline: p.hairline,
      outlineVariant: p.hairline,
      surfaceContainerLowest: p.bg,
      surfaceContainerLow: p.surface,
      surfaceContainer: p.surface,
      surfaceContainerHigh: p.surface,
      surfaceContainerHighest: p.surface,
      inverseSurface: p.ink,
      onInverseSurface: p.bg,
      shadow: Colors.transparent,
      scrim: Colors.black54,
    );

    // Arayüz yazı stilleri (Design System > Arayüz grubu). Font: Inter.
    final textTheme = TextTheme(
      headlineSmall: TextStyle(fontSize: 24, height: 32 / 24, fontWeight: FontWeight.w600, color: p.ink),
      titleLarge: TextStyle(fontSize: 20, height: 28 / 20, fontWeight: FontWeight.w600, color: p.ink), // heading
      titleMedium: TextStyle(fontSize: 17, height: 24 / 17, fontWeight: FontWeight.w600, color: p.ink), // card-title
      titleSmall: TextStyle(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w600, color: p.ink),
      bodyLarge: TextStyle(fontSize: 16, height: 24 / 16, fontWeight: FontWeight.w400, color: p.ink),
      bodyMedium: TextStyle(fontSize: 15, height: 22 / 15, fontWeight: FontWeight.w400, color: p.ink), // body
      bodySmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w400, color: p.inkMuted), // caption
      labelLarge: TextStyle(fontSize: 14, height: 20 / 14, fontWeight: FontWeight.w500, color: p.ink), // label
      labelMedium: TextStyle(fontSize: 13, height: 18 / 13, fontWeight: FontWeight.w500, color: p.ink),
      labelSmall: TextStyle(fontSize: 12, height: 16 / 12, fontWeight: FontWeight.w500, color: p.inkMuted),
    );

    final border = OutlineInputBorder(
      borderRadius: Radii.mdAll,
      borderSide: BorderSide(color: p.hairline),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: p.brightness,
      colorScheme: scheme,
      fontFamily: Fonts.sans,
      textTheme: textTheme,
      scaffoldBackgroundColor: p.bg,
      canvasColor: p.bg,
      dividerColor: p.hairline,
      splashFactory: InkSparkle.splashFactory,
      extensions: [PeerlessColors(p)],
      appBarTheme: AppBarTheme(
        backgroundColor: p.bg,
        foregroundColor: p.ink,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge,
        shape: Border(bottom: BorderSide(color: p.hairline, width: 0)),
      ),
      dividerTheme: DividerThemeData(color: p.hairline, thickness: 1, space: 1),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: p.surface,
        hintStyle: TextStyle(color: p.inkMuted),
        labelStyle: TextStyle(color: p.inkMuted),
        floatingLabelStyle: TextStyle(color: p.accent),
        helperStyle: TextStyle(color: p.inkMuted, fontSize: 12),
        errorStyle: TextStyle(color: p.danger, fontSize: 12),
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.space4, vertical: 14),
        border: border,
        enabledBorder: border,
        focusedBorder: border.copyWith(borderSide: BorderSide(color: p.accent, width: 1.5)),
        errorBorder: border.copyWith(borderSide: BorderSide(color: p.danger)),
        focusedErrorBorder: border.copyWith(borderSide: BorderSide(color: p.danger, width: 1.5)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: p.accent,
          foregroundColor: p.onAccent,
          disabledBackgroundColor: p.hairline,
          disabledForegroundColor: p.inkMuted,
          minimumSize: const Size(64, 48),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: p.ink,
          minimumSize: const Size(64, 48),
          side: BorderSide(color: p.hairline),
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: p.accent,
          textStyle: textTheme.labelLarge,
          shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(foregroundColor: p.ink),
      ),
      iconTheme: IconThemeData(color: p.ink, size: 22),
      chipTheme: ChipThemeData(
        backgroundColor: p.surface,
        selectedColor: p.accentSoft,
        side: BorderSide(color: p.hairline),
        labelStyle: textTheme.labelMedium,
        shape: const RoundedRectangleBorder(borderRadius: Radii.smAll),
        showCheckmark: false,
        padding: const EdgeInsets.symmetric(horizontal: Space.space2),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: p.accent,
        unselectedLabelColor: p.inkMuted,
        indicatorColor: p.accent,
        dividerColor: p.hairline,
        labelStyle: textTheme.labelLarge,
        unselectedLabelStyle: textTheme.labelLarge,
        tabAlignment: TabAlignment.start,
        indicatorSize: TabBarIndicatorSize.label,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        showDragHandle: true,
        dragHandleColor: p.hairline,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(Radii.md * 2)),
        ),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
        titleTextStyle: textTheme.titleMedium,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: p.ink,
        contentTextStyle: TextStyle(color: p.bg, fontFamily: Fonts.sans, fontSize: 14),
        actionTextColor: p.accentSoft,
        behavior: SnackBarBehavior.floating,
        shape: const RoundedRectangleBorder(borderRadius: Radii.mdAll),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: p.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: Radii.mdAll, side: BorderSide(color: p.hairline)),
        textStyle: textTheme.bodyMedium,
      ),
      listTileTheme: ListTileThemeData(
        iconColor: p.inkMuted,
        textColor: p.ink,
        contentPadding: const EdgeInsets.symmetric(horizontal: Space.space4),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.onAccent : p.inkMuted,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (s) => s.contains(WidgetState.selected) ? p.accent : p.hairline,
        ),
        trackOutlineColor: WidgetStateProperty.all(Colors.transparent),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: p.accent, linearTrackColor: p.hairline),
      textSelectionTheme: TextSelectionThemeData(
        cursorColor: p.accent,
        selectionColor: p.accent.withValues(alpha: 0.3),
        selectionHandleColor: p.accent,
      ),
      badgeTheme: BadgeThemeData(backgroundColor: p.accent, textColor: p.onAccent),
    );
  }
}
