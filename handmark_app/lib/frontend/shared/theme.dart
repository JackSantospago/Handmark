import 'package:flutter/material.dart';

/// A quiet gallery: warm off-white ground, deep charcoal text and buttons,
/// one muted accent (brass) kept for the "Handmark Verified" mark and small
/// highlights. Fraunces (serif) for headings, Inter for everything else; both
/// are bundled in assets/fonts. Square-ish corners, hairlines instead of
/// shadows, lots of space: it should feel like a catalogue, not a consumer app.
abstract final class AppTheme {
  static const display = 'Fraunces';
  static const body = 'Inter';

  /// Corner radius used everywhere (cards, buttons, fields, images).
  static const radius = 2.0;

  static ThemeData light() => _build(_light);
  static ThemeData dark() => _build(_dark);

  static const _light = ColorScheme(
    brightness: Brightness.light,
    primary: Color(0xFF1F1E1C), // charcoal: buttons, selected states
    onPrimary: Color(0xFFF7F4EF),
    primaryContainer: Color(0xFFE9E4DC),
    onPrimaryContainer: Color(0xFF1F1E1C),
    secondary: Color(0xFF8C6D3F), // brass: the one accent
    onSecondary: Colors.white,
    secondaryContainer: Color(0xFFF0E8DA),
    onSecondaryContainer: Color(0xFF3E2F17),
    tertiary: Color(0xFF8C6D3F),
    onTertiary: Colors.white,
    tertiaryContainer: Color(0xFFEFE9DF),
    onTertiaryContainer: Color(0xFF3E3527),
    error: Color(0xFF9A3B2E),
    onError: Colors.white,
    errorContainer: Color(0xFFF4E1DC),
    onErrorContainer: Color(0xFF3E120B),
    surface: Color(0xFFF7F4EF), // warm off-white ground
    onSurface: Color(0xFF1F1E1C),
    onSurfaceVariant: Color(0xFF6F6A62),
    surfaceContainerLowest: Color(0xFFFCFAF7),
    surfaceContainerLow: Color(0xFFF3EFE9),
    surfaceContainer: Color(0xFFEEEAE3),
    surfaceContainerHigh: Color(0xFFE8E3DB),
    surfaceContainerHighest: Color(0xFFE1DBD2),
    outline: Color(0xFFCFC8BD),
    outlineVariant: Color(0xFFE3DED6),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFF2A2926),
    onInverseSurface: Color(0xFFF2EEE8),
    inversePrimary: Color(0xFFE8E2D8),
    surfaceTint: Colors.transparent,
  );

  static const _dark = ColorScheme(
    brightness: Brightness.dark,
    primary: Color(0xFFEDE8E0),
    onPrimary: Color(0xFF1A1917),
    primaryContainer: Color(0xFF2E2C29),
    onPrimaryContainer: Color(0xFFEDE8E0),
    secondary: Color(0xFFC9A86E),
    onSecondary: Color(0xFF2B2010),
    secondaryContainer: Color(0xFF3A3020),
    onSecondaryContainer: Color(0xFFF0E2C6),
    tertiary: Color(0xFFC9A86E),
    onTertiary: Color(0xFF2B2010),
    tertiaryContainer: Color(0xFF302B23),
    onTertiaryContainer: Color(0xFFEDE3D2),
    error: Color(0xFFE8A598),
    onError: Color(0xFF4A150C),
    errorContainer: Color(0xFF5E2318),
    onErrorContainer: Color(0xFFF4E1DC),
    surface: Color(0xFF161514),
    onSurface: Color(0xFFEDE8E0),
    onSurfaceVariant: Color(0xFFA39D93),
    surfaceContainerLowest: Color(0xFF1B1A18),
    surfaceContainerLow: Color(0xFF1F1E1C),
    surfaceContainer: Color(0xFF242320),
    surfaceContainerHigh: Color(0xFF2B2A27),
    surfaceContainerHighest: Color(0xFF33312E),
    outline: Color(0xFF4F4B45),
    outlineVariant: Color(0xFF34322E),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: Color(0xFFEDE8E0),
    onInverseSurface: Color(0xFF2A2926),
    inversePrimary: Color(0xFF1F1E1C),
    surfaceTint: Colors.transparent,
  );

  static TextTheme _text(ColorScheme c) {
    final base = Typography.material2021(platform: TargetPlatform.android).black.apply(
          fontFamily: body,
          bodyColor: c.onSurface,
          displayColor: c.onSurface,
        );
    TextStyle? serif(TextStyle? s, {double? size, FontWeight weight = FontWeight.w500}) =>
        s?.copyWith(fontFamily: display, fontSize: size, fontWeight: weight, letterSpacing: -0.4, height: 1.15);
    return base.copyWith(
      displaySmall: serif(base.displaySmall, size: 36),
      headlineLarge: serif(base.headlineLarge, size: 32),
      headlineMedium: serif(base.headlineMedium, size: 28),
      headlineSmall: serif(base.headlineSmall, size: 23),
      titleLarge: serif(base.titleLarge, size: 20),
      titleMedium: serif(base.titleMedium, size: 16.5)?.copyWith(letterSpacing: -0.1, height: 1.25),
      titleSmall: base.titleSmall?.copyWith(fontWeight: FontWeight.w600, letterSpacing: 0),
      bodyLarge: base.bodyLarge?.copyWith(fontSize: 15.5, height: 1.6, letterSpacing: 0),
      bodyMedium: base.bodyMedium?.copyWith(fontSize: 14, height: 1.5, letterSpacing: 0),
      bodySmall: base.bodySmall?.copyWith(fontSize: 12.5, height: 1.4, letterSpacing: 0, color: c.onSurfaceVariant),
      labelLarge: base.labelLarge?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.2),
      labelMedium: base.labelMedium?.copyWith(fontWeight: FontWeight.w500, letterSpacing: 0.2),
      // Small caps-style labels ("PROVENANCE", "HANDMARK VERIFIED").
      labelSmall: base.labelSmall?.copyWith(fontSize: 10.5, fontWeight: FontWeight.w600, letterSpacing: 1.4),
    );
  }

  static ThemeData _build(ColorScheme c) {
    final text = _text(c);
    final hairline = BorderSide(color: c.outlineVariant);
    final square = RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius));
    return ThemeData(
      colorScheme: c,
      useMaterial3: true,
      fontFamily: body,
      textTheme: text,
      scaffoldBackgroundColor: c.surface,
      visualDensity: VisualDensity.standard,
      splashFactory: InkRipple.splashFactory,
      dividerTheme: DividerThemeData(color: c.outlineVariant, space: 1, thickness: 1),
      appBarTheme: AppBarTheme(
        backgroundColor: c.surface,
        foregroundColor: c.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        titleTextStyle: text.labelSmall?.copyWith(color: c.onSurface),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        indicatorColor: Colors.transparent,
        labelTextStyle: WidgetStateProperty.resolveWith((states) => TextStyle(
              fontFamily: body,
              fontSize: 11,
              letterSpacing: 0.4,
              fontWeight: states.contains(WidgetState.selected) ? FontWeight.w600 : FontWeight.w400,
              color: states.contains(WidgetState.selected) ? c.onSurface : c.onSurfaceVariant,
            )),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              size: 22,
              color: states.contains(WidgetState.selected) ? c.onSurface : c.onSurfaceVariant,
            )),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: c.surfaceContainerLowest,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(radius), side: hairline),
        margin: EdgeInsets.zero,
      ),
      chipTheme: ChipThemeData(
        backgroundColor: Colors.transparent,
        selectedColor: c.primary,
        secondarySelectedColor: c.primary,
        checkmarkColor: c.onPrimary,
        showCheckmark: false,
        side: BorderSide(color: c.outline),
        shape: square,
        labelStyle: text.labelMedium?.copyWith(color: c.onSurface),
        secondaryLabelStyle: text.labelMedium?.copyWith(color: c.onPrimary),
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: c.surfaceContainerLowest,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        labelStyle: text.bodyMedium?.copyWith(color: c.onSurfaceVariant),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: c.outline)),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: c.outline)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(radius), borderSide: BorderSide(color: c.onSurface)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(64, 54),
          shape: square,
          textStyle: text.labelLarge?.copyWith(fontSize: 14.5, letterSpacing: 0.6),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(48, 50),
          foregroundColor: c.onSurface,
          side: BorderSide(color: c.onSurface.withValues(alpha: 0.5)),
          shape: square,
          textStyle: text.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: c.onSurface, textStyle: text.labelLarge, shape: square),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: c.inverseSurface,
        contentTextStyle: text.bodyMedium?.copyWith(color: c.onInverseSurface),
        shape: square,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: square,
        titleTextStyle: text.headlineSmall,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: c.surface,
        surfaceTintColor: Colors.transparent,
        shape: square,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: c.onSurface, linearTrackColor: c.outlineVariant),
    );
  }
}
