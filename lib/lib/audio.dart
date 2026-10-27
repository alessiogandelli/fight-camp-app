// Cue sounds played from baked WAV assets in assets/audio/<bank>/.
//
// The waveforms are generated offline from cue_synth.dart by
// tool/generate_cues.dart and committed. Playing them through AssetSource lets
// audioplayers copy the file to a temp path that keeps the .wav extension,
// which AVPlayer on iOS needs to pick the right decoder. (A BytesSource is
// written extension-less and fails there with AVPlayerItem.Status.failed.)
import 'dart:math' as math;

import 'package:audioplayers/audioplayers.dart';

import 'cue_synth.dart';

class Sound {
  static final List<AudioPlayer> _pool = List.generate(
    4,
    (_) => AudioPlayer(playerId: 'cue-${_uid()}'),
  );
  static int _next = 0;
  static bool _primed = false;

  /// Which cue bank plays. Set once from settings on load and whenever the
  /// athlete changes it in Settings; unknown ids fall back to the classic bank.
  static String get bank => _bank;

  static set bank(String value) {
    _bank = cueBanks.contains(value) ? value : defaultCueBank;
  }

  static String _bank = defaultCueBank;

  static String _uid() =>
      '${DateTime.now().microsecondsSinceEpoch}-${math.Random().nextInt(999999)}';

  static Source _source(String name) => AssetSource('audio/$_bank/$name.wav');

  /// Warms the audio session and preloads each pooled player so the first cue
  /// of a session fires without the usual cold-start lag. Idempotent.
  static Future<void> unlock() async {
    if (_primed) return;
    _primed = true;
    for (final p in _pool) {
      try {
        await p.setReleaseMode(ReleaseMode.stop);
        await p.setVolume(0);
        await p.play(_source('count'));
        await p.stop();
        await p.setVolume(1);
      } catch (_) {}
    }
  }

  static Future<void> _play(String name) async {
    final p = _pool[_next % _pool.length];
    _next++;
    try {
      await p.stop();
      await p.play(_source(name));
    } catch (_) {}
  }

  static Future<void> prep() => _play('prep');
  static Future<void> work() => _play('work');
  static Future<void> rest() => _play('rest');
  static Future<void> done() => _play('done');
  static Future<void> warn() => _play('warn');
  static Future<void> count() => _play('count');

  /// Plays a single cue outside a session (Settings preview).
  static Future<void> preview([String name = 'done']) => _play(name);
}
