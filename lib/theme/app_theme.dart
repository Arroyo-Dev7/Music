import 'package:flutter/material.dart';

/// Sala de escucha: tinta cálida, oro viejo y tipografía editorial.
class AppFonts {
  AppFonts._();

  static const display = 'PlayfairDisplay';
  static const body = 'Figtree';
}

class AppColors {
  AppColors._();

  static const background = Color(0xFF0B0908);
  static const card = Color(0xFF161210);
  static const cardHigh = Color(0xFF1F1A17);
  static const accent = Color(0xFFC9A36A);
  static const accentAlt = Color(0xFFD9785A);
  static const cream = Color(0xFFF3EEE6);
  static const ink = Color(0xFF1A1410);
  static const textMuted = Color(0xFF9A9088);
  static const hairline = Color(0x22F3EEE6);

  static const accentGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFD4B07A), Color(0xFFB0894F)],
  );
}

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    surface: AppColors.background,
    primary: AppColors.accent,
    secondary: AppColors.accentAlt,
    onPrimary: AppColors.ink,
    onSecondary: AppColors.ink,
    onSurface: AppColors.cream,
  );

  final base = ThemeData(
    brightness: Brightness.dark,
    fontFamily: AppFonts.body,
  ).textTheme.apply(
    fontFamily: AppFonts.body,
    bodyColor: AppColors.cream,
    displayColor: AppColors.cream,
  );

  TextStyle display(TextStyle? style, {double? size, double? spacing}) =>
      (style ?? const TextStyle()).copyWith(
        fontFamily: AppFonts.display,
        fontWeight: FontWeight.w600,
        color: AppColors.cream,
        fontSize: size,
        letterSpacing: spacing,
        height: 1.05,
      );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    brightness: Brightness.dark,
    fontFamily: AppFonts.body,
    scaffoldBackgroundColor: AppColors.background,
    canvasColor: AppColors.background,
    textTheme: base.copyWith(
      headlineMedium: display(base.headlineMedium, size: 34, spacing: -0.6),
      headlineSmall: display(base.headlineSmall, size: 26, spacing: -0.3),
      titleLarge: base.titleLarge?.copyWith(
        fontWeight: FontWeight.w600,
        letterSpacing: -0.2,
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: AppColors.cream,
      surfaceTintColor: Colors.transparent,
      scrolledUnderElevation: 0,
      centerTitle: false,
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.cardHigh,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: const TextStyle(
        fontFamily: AppFonts.display,
        fontWeight: FontWeight.w600,
        fontSize: 24,
        color: AppColors.cream,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    ),
    popupMenuTheme: PopupMenuThemeData(
      color: AppColors.cardHigh,
      surfaceTintColor: Colors.transparent,
      textStyle: const TextStyle(fontFamily: AppFonts.body, color: AppColors.cream),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: AppColors.card,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      backgroundColor: AppColors.cardHigh,
      contentTextStyle: const TextStyle(
        fontFamily: AppFonts.body,
        color: AppColors.cream,
      ),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
    ),
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.ink,
        textStyle: const TextStyle(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
        ),
        shape: const StadiumBorder(),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: AppColors.accent),
    ),
    sliderTheme: const SliderThemeData(
      trackHeight: 3,
      activeTrackColor: AppColors.accent,
      inactiveTrackColor: Color(0x33F3EEE6),
      thumbColor: AppColors.cream,
      thumbShape: RoundSliderThumbShape(enabledThumbRadius: 5),
      overlayShape: RoundSliderOverlayShape(overlayRadius: 12),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.card,
      hintStyle: const TextStyle(color: AppColors.textMuted, fontSize: 14.5),
      contentPadding: const EdgeInsets.symmetric(vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.hairline),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(color: AppColors.accent, width: 1.2),
      ),
    ),
  );
}
