// Text-to-speech for combo announcements, built on the system TTS engine.
//
// Sits alongside the synthesized cue bells (see audio.dart). On iOS the audio
// session is configured to mix with the other players so speaking a combo does
// not silence the timer cues. Every call is defensive: on platforms without an
// available engine (or in widget tests) speech simply does nothing.
import 'package:flutter_tts/flutter_tts.dart';

class Speech {
  static FlutterTts? _tts;
  static bool _ready = false;

  static FlutterTts _instance() => _tts ??= FlutterTts();

  /// Configures language/voice once. Safe to call repeatedly. Each platform
  /// call is isolated so one failure cannot skip the rest of the setup.
  static Future<void> _init() async {
    if (_ready) return;
    _ready = true;
    final tts = _instance();
    try {
      await tts.setLanguage('it-IT');
    } catch (_) {}
    try {
      await tts.setSpeechRate(0.45);
    } catch (_) {}
    try {
      await tts.setPitch(1.0);
    } catch (_) {}
    try {
      await tts.setVolume(1.0);
    } catch (_) {}
    try {
      // Share the audio session with the cue players and duck them while
      // speaking, so combo announcements and timer bells coexist on iOS.
      await tts.setSharedInstance(true);
      await tts.setIosAudioCategory(IosTextToSpeechAudioCategory.playback, [
        IosTextToSpeechAudioCategoryOptions.mixWithOthers,
        IosTextToSpeechAudioCategoryOptions.duckOthers,
      ]);
    } catch (_) {}
  }

  /// Speaks [words] as a single announcement, replacing any in-flight one.
  static Future<void> speakCombo(List<String> words) async {
    if (words.isEmpty) return;
    await _init();
    try {
      await _instance().stop();
      await _instance().speak(words.join(', '));
    } catch (_) {}
  }

  static Future<void> stop() async {
    try {
      await _instance().stop();
    } catch (_) {}
  }
}
