// Mirrors the in-app theme choice onto native iOS chrome.
//
// The liquid-glass tab bar on iOS 26+ is a real UITabBar drawn by the system,
// so it follows the app's UIUserInterfaceStyle rather than the Flutter theme.
// Without this channel, forcing "Scuro" on a phone set to light would leave a
// white tab bar under a dark app. Android needs nothing: its bars are styled
// from Dart via SystemChrome, and Material widgets follow the Flutter theme.
import 'package:flutter/services.dart';

abstract final class NativeAppearance {
  static const _channel = MethodChannel('fight_camp/appearance');
  static String? _last;

  /// [style] is `system`, `light` or `dark`. Idempotent and failure-tolerant
  /// (widget tests and non-iOS platforms simply ignore it).
  static Future<void> apply(String style) async {
    if (style == _last) return;
    _last = style;
    try {
      await _channel.invokeMethod<void>('setStyle', style);
    } catch (_) {}
  }
}
