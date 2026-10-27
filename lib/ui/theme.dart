// Dark theme tokens ported from src/index.css.
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../engine/plan.dart';

/// Spacing scale tokens. Use these instead of ad-hoc paddings/margins.
///
/// xs = 4, sm = 8, md = 16, lg = 24, xl = 32 (logical pixels).
/// [pill] is the border radius for pill-shaped chips/buttons.
/// Fixed height of the app header bar, shared between the shell and pages
/// that need to render content underneath it (e.g. the home hero).
const double kAppHeaderHeight = 60;

/// Floating glass bottom navigation metrics. The bar rides above the bottom
/// safe area; pages must leave [glassNavClearance] of space at the bottom so
/// their content is not hidden behind it (the body extends behind the bar).
///
/// These mirror the `GlassTabBar.bottom` used by the shell: total height is
/// `barHeight + 2 * verticalPadding`.
const double kGlassNavHeight = 64;
const double kGlassNavVerticalPadding = 8;
double glassNavClearance(BuildContext context) =>
    kGlassNavHeight +
    kGlassNavVerticalPadding * 2 +
    16 +
    MediaQuery.paddingOf(context).bottom;

/// Fixed top glow shared by the shell: fades from a dark maroon at the
/// physical top into [AppColors.bg]. Sized in logical pixels below the status
/// bar; the shell adds the top safe-area inset on top of it.
const double kHeroGlowHeight = 140;

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double pill = 999;
}

/// One complete colour set. The app ships a dark and a light palette with the
/// same token names, so every screen can be written once.
///
/// Both palettes keep the brand red; only the timer/feedback hues shift darker
/// in the light palette so they stay readable as text on white.
class AppPalette {
  final Brightness brightness;
  final Color bg;
  final Color panel;
  final Color panel2;
  final Color line;
  final Color ink;
  final Color mut;
  final Color primary;
  final Color glow;
  final Color work;
  final Color rest;
  final Color error;
  final Color warning;
  final Color success;

  const AppPalette({
    required this.brightness,
    required this.bg,
    required this.panel,
    required this.panel2,
    required this.line,
    required this.ink,
    required this.mut,
    required this.primary,
    required this.glow,
    required this.work,
    required this.rest,
    required this.error,
    required this.warning,
    required this.success,
  });

  static const dark = AppPalette(
    brightness: Brightness.dark,
    bg: Color(0xFF09090B),
    panel: Color(0xFF121216),
    panel2: Color(0xFF1A1A20),
    line: Color(0xFF26262E),
    ink: Color(0xFFF4F4F1),
    mut: Color(0xFF9A9AA5),
    primary: Color(0xFFE63946),
    glow: Color(0xFF2A1416),
    work: Color(0xFF22C55E),
    rest: Color(0xFFEF4444),
    error: Color(0xFFB91C1C),
    warning: Color(0xFFF59E0B),
    success: Color(0xFF22C55E),
  );

  static const light = AppPalette(
    brightness: Brightness.light,
    bg: Color(0xFFF5F5F7),
    panel: Color(0xFFFFFFFF),
    panel2: Color(0xFFEDEDF1),
    line: Color(0xFFE0E0E6),
    ink: Color(0xFF14141A),
    mut: Color(0xFF6C6C77),
    primary: Color(0xFFE01E2B),
    glow: Color(0xFFF7E7E8),
    work: Color(0xFF15803D),
    rest: Color(0xFFD62B2B),
    error: Color(0xFFB91C1C),
    warning: Color(0xFF9A5B00),
    success: Color(0xFF15803D),
  );
}

/// Semantic colour tokens. Pick by meaning, not by hue.
///
/// The active palette is swapped by the app shell when the platform brightness
/// changes (see [AppColors.palette]); widgets read these getters during build,
/// so a theme flip rebuilds them with the new values.
///
/// Rules (see `docs/adr/0005-colori-semantici.md`):
/// - [primary] is the brand red. Never use it for errors or the timer.
/// - [work] / [rest] are the timer states: green = WORK, red = REST.
/// - [error] is for real errors, validation and destructive actions.
/// - [warning] and [success] are generic feedback.
abstract final class AppColors {
  static AppPalette _palette = AppPalette.dark;

  static AppPalette get palette => _palette;
  static set palette(AppPalette value) => _palette = value;

  static Brightness get brightness => _palette.brightness;
  static bool get isDark => _palette.brightness == Brightness.dark;

  // Surfaces and text.
  static Color get bg => _palette.bg;
  static Color get panel => _palette.panel;
  static Color get panel2 => _palette.panel2;
  static Color get line => _palette.line;
  static Color get ink => _palette.ink;
  static Color get mut => _palette.mut;

  // Brand.
  static Color get primary => _palette.primary;

  // Home hero glow: brand wash fading into [bg].
  static Color get glow => _palette.glow;

  // Timer states.
  static Color get work => _palette.work;
  static Color get rest => _palette.rest;

  // Semantic feedback.
  static Color get error => _palette.error;
  static Color get warning => _palette.warning;
  static Color get success => _palette.success;
}

/// Single source of truth for timer phase colours: green = WORK, red = REST,
/// amber = preparation.
Color phaseColor(SegmentKind kind) => switch (kind) {
  SegmentKind.prep => AppColors.warning,
  SegmentKind.work => AppColors.work,
  SegmentKind.rest => AppColors.rest,
};

/// Shared text styles. Use these instead of ad-hoc font sizes so the
/// typography stays consistent across pages.
abstract final class AppText {
  /// Tiny uppercase section label, e.g. "PRESETS".
  static TextStyle get overline => TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.4,
    color: AppColors.mut,
  );

  /// Even smaller label used inside dense cards/stats.
  static TextStyle get micro => TextStyle(
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    color: AppColors.mut,
  );

  /// Muted body copy.
  static TextStyle get muted => TextStyle(fontSize: 13, color: AppColors.mut);

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

/// Builds the Material theme for [brightness], sourced from the matching
/// [AppPalette] so dialogs, inputs and Material widgets agree with the app.
ThemeData buildTheme([Brightness brightness = Brightness.dark]) {
  final p = brightness == Brightness.dark ? AppPalette.dark : AppPalette.light;
  final base = ThemeData(
    useMaterial3: true,
    brightness: brightness,
    scaffoldBackgroundColor: p.bg,
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: p.primary,
          brightness: brightness,
        ).copyWith(
          primary: p.primary,
          secondary: p.primary,
          surface: p.panel,
          error: p.error,
          onSurface: p.ink,
        ),
    fontFamilyFallback: const ['.SF UI Text', 'Roboto', 'Segoe UI'],
  );
  return base.copyWith(
    textTheme: base.textTheme.apply(bodyColor: p.ink, displayColor: p.ink),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: p.primary,
      selectionColor: p.primary.withAlpha(85),
      selectionHandleColor: p.primary,
    ),
    inputDecorationTheme: inputCls(p),
    dialogTheme: DialogThemeData(
      backgroundColor: p.panel,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: p.line),
      ),
      titleTextStyle: TextStyle(
        color: p.ink,
        fontWeight: FontWeight.w700,
        fontSize: 16,
      ),
      contentTextStyle: TextStyle(color: p.mut, fontSize: 14, height: 1.4),
    ),
  );
}

/// Status/navigation bar chrome for [brightness]: dark icons on a light bar,
/// light icons on a dark one.
SystemUiOverlayStyle overlayStyleFor(Brightness brightness) {
  final dark = brightness == Brightness.dark;
  final icons = dark ? Brightness.light : Brightness.dark;
  final p = dark ? AppPalette.dark : AppPalette.light;
  return (dark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark)
      .copyWith(
        statusBarColor: Colors.transparent,
        systemNavigationBarColor: p.bg,
        systemNavigationBarIconBrightness: icons,
        statusBarIconBrightness: icons,
      );
}

SystemUiOverlayStyle get overlayStyle => overlayStyleFor(AppColors.brightness);

InputDecorationTheme inputCls(AppPalette p) {
  OutlineInputBorder border(Color c) => OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: BorderSide(color: c),
  );
  return InputDecorationTheme(
    filled: true,
    fillColor: p.panel2,
    hintStyle: TextStyle(color: p.mut),
    labelStyle: TextStyle(color: p.mut),
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    border: border(p.line),
    enabledBorder: border(p.line),
    focusedBorder: border(p.mut),
  );
}
