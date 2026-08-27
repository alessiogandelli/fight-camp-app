// Lightweight haptics gateway for UI micro-haptics, gated by Settings.vibration.
// Session cue vibrations keep using the `vibration` plugin (see vibrate.dart);
// these are the subtle taps/ticks that make the UI feel native.
import 'package:flutter/services.dart';

class Haptics {
  static bool enabled = true;

  static void selection() {
    if (enabled) HapticFeedback.selectionClick();
  }

  static void light() {
    if (enabled) HapticFeedback.lightImpact();
  }
}
