// Vibration helper ported from src/lib/vibrate.ts.
import 'package:vibration/vibration.dart';

Future<void> vibrate(Object pattern, bool enabled) async {
  if (!enabled) return;
  try {
    final supported = await Vibration.hasVibrator();
    if (supported != true) return;
    if (pattern is int) {
      await Vibration.vibrate(duration: pattern);
    } else if (pattern is List<int>) {
      // Web patterns are [on, off, on, ...]; the plugin takes the pauses
      // between vibrations, so drop the first (initial) duration.
      final pauses = <int>[];
      for (var i = 1; i < pattern.length; i++) {
        pauses.add(pattern[i]);
      }
      await Vibration.vibrate(pattern: pauses);
    } else {
      await Vibration.vibrate();
    }
  } catch (_) {}
}

Future<bool> vibrationSupported() async {
  try {
    final v = await Vibration.hasVibrator();
    return v == true;
  } catch (_) {
    return false;
  }
}
