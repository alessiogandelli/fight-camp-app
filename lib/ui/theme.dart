// Dark theme tokens ported from src/index.css.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Spacing scale tokens. Use these instead of ad-hoc paddings/margins.
///
/// xs = 4, sm = 8, md = 16, lg = 24, xl = 32 (logical pixels).
/// [pill] is the border radius for pill-shaped chips/buttons.
/// Fixed height of the app header bar, shared between the shell and pages
/// that need to render content underneath it (e.g. the home hero).
const double kAppHeaderHeight = 60;

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;
}

class AppColors {
  static const bg = Color(0xFF09090B);
  static const panel = Color(0xFF121216);
  static const panel2 = Color(0xFF1A1A20);
  static const line = Color(0xFF26262E);
  static const ink = Color(0xFFF4F4F1);
  static const mut = Color(0xFF9A9AA5);
  static const accent = Color(0xFFFF4D4D);
  static const rest = Color(0xFF4CC3FF);
  static const warn = Color(0xFFFFB224);
  static const go = Color(0xFF3DDC84);
}

/// Shared text styles. Use these instead of ad-hoc font sizes so the
/// typography stays consistent across pages.
abstract final class AppText {
  /// Tiny uppercase section label, e.g. "PRESETS".
  static const TextStyle overline = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.mut,
  );

  /// Even smaller label used inside dense cards/stats.
  static const TextStyle micro = TextStyle(
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.mut,
  );

  /// Muted body copy.
  static const TextStyle muted = TextStyle(fontSize: 13, color: AppColors.mut);

  /// Small bold uppercase label.
  static const TextStyle label = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.2,
  );

  /// Big tabular number for stat cards.
  static const TextStyle statValue = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w800,
    fontFeatures: [FontFeature.tabularFigures()],
  );
}

ThemeData buildTheme() {
  final base = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.bg,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.accent,
      secondary: AppColors.accent,
      surface: AppColors.panel,
      error: AppColors.accent,
    ),
    fontFamilyFallback: const ['.SF UI Text', 'Roboto', 'Segoe UI'],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(
      bodyColor: AppColors.ink,
      displayColor: AppColors.ink,
    ),
    textSelectionTheme: const TextSelectionThemeData(
      cursorColor: AppColors.accent,
      selectionColor: Color(0x55FF4D4D),
      selectionHandleColor: AppColors.accent,
    ),
    inputDecorationTheme: inputCls(),
    dialogTheme: DialogThemeData(
      backgroundColor: AppColors.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.line),
      ),
      titleTextStyle: const TextStyle(
        color: AppColors.ink,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      contentTextStyle: const TextStyle(
        color: AppColors.mut,
        fontSize: 14,
        height: 1.4,
      ),
    ),
  );
}

SystemUiOverlayStyle get overlayStyle => SystemUiOverlayStyle.light.copyWith(
  statusBarColor: Colors.transparent,
  systemNavigationBarColor: AppColors.bg,
  systemNavigationBarIconBrightness: Brightness.light,
  statusBarIconBrightness: Brightness.light,
);

InputDecorationTheme inputCls() {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );
  return InputDecorationTheme(
    filled: true,
    fillColor: AppColors.panel2,
    hintStyle: const TextStyle(color: AppColors.mut),
    labelStyle: const TextStyle(color: AppColors.mut),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: border(AppColors.line),
    enabledBorder: border(AppColors.line),
    focusedBorder: border(AppColors.mut),
  );
}
