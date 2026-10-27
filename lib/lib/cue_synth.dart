// Pure offline synthesis of the cue sounds. No Flutter/plugin dependencies, so
// it can run both at runtime (via audio.dart) and from a plain Dart script
// (tool/generate_cues.dart) that bakes the generated WAVs into assets/audio/.
//
// Cues come in a few "banks" — complete sets of the six cues. The athlete picks
// one in Settings; `Sound` just swaps the asset folder.
import 'dart:math' as math;
import 'dart:typed_data';

const sampleRate = 22050;

/// Bank ids, in the order they appear in Settings. `classic` is the default and
/// must stay first: unknown/legacy values fall back to it.
const cueBanks = ['classic', 'ring', 'beep'];

const defaultCueBank = 'classic';

class CuePart {
  final double freq;
  final double durationSec;
  final int partials;
  final String wave; // 'triangle' | 'square' | 'sine'
  final double offset;

  /// Exponential decay rate (per second). Higher = shorter, drier strike.
  final double decay;

  /// Attack ramp length in seconds: avoids a click on the first sample.
  final double attack;

  /// Partial frequency multipliers. Null means the harmonic series (1, 2, 3…),
  /// which is what the bells in the classic bank use. Inharmonic ratios give a
  /// metallic ring, like a struck plate or a real ring bell.
  final List<double>? ratios;

  const CuePart(
    this.freq,
    this.durationSec,
    this.partials,
    this.wave, {
    this.offset = 0,
    this.decay = 6,
    this.attack = 0.004,
    this.ratios,
  });
}

// Every cue is peak-normalized on its own, so without this map a 50 ms click
// would hit as hard as the multi-harmonic bells. These roughly balance the
// perceived loudness across the bank.
const cueGain = <String, double>{
  'prep': 1.0,
  'work': 1.0,
  'rest': 0.9,
  'done': 1.0,
  'warn': 0.7,
  'count': 0.6,
};

// ---- classic: triangle-wave bells, low sine rest tone ----

final _classic = <String, List<CuePart>>{
  // single bell
  'prep': [CuePart(880, 0.62, 3, 'triangle')],
  // two bells 300ms apart
  'work': [
    CuePart(880, 0.62, 3, 'triangle'),
    CuePart(880, 0.62, 3, 'triangle', offset: 0.30),
  ],
  // low descending tone
  'rest': [
    CuePart(440, 0.45, 2, 'sine'),
    CuePart(392, 0.35, 1, 'sine', offset: 0.18),
  ],
  // triple bell
  'done': [
    CuePart(880, 0.55, 3, 'triangle'),
    CuePart(880, 0.55, 3, 'triangle', offset: 0.25),
    CuePart(880, 0.75, 3, 'triangle', offset: 0.5),
  ],
  // double beep
  'warn': [
    CuePart(1320, 0.12, 2, 'triangle'),
    CuePart(1320, 0.12, 2, 'triangle', offset: 0.16),
  ],
  // short blip
  'count': [CuePart(1760, 0.09, 2, 'triangle')],
};

// ---- ring: struck metal, inharmonic partials and a long tail ----

const _bellRatios = [1.0, 2.76, 5.40, 8.93];

CuePart _ringStrike(
  double freq,
  double duration, {
  double offset = 0,
  double decay = 2.4,
}) => CuePart(
  freq,
  duration,
  4,
  'sine',
  offset: offset,
  decay: decay,
  attack: 0.002,
  ratios: _bellRatios,
);

final _ring = <String, List<CuePart>>{
  // single ring
  'prep': [_ringStrike(1175, 1.30)],
  // two rings 360ms apart
  'work': [_ringStrike(1175, 1.30), _ringStrike(1175, 1.30, offset: 0.36)],
  // two low struck tones, the second a step down
  'rest': [
    _ringStrike(587, 1.00, decay: 3.6),
    _ringStrike(523, 0.85, offset: 0.5, decay: 4.2),
  ],
  // triple ring, the last one left to ring out
  'done': [
    _ringStrike(1175, 1.20),
    _ringStrike(1175, 1.20, offset: 0.30),
    _ringStrike(1175, 1.60, offset: 0.60, decay: 1.9),
  ],
  // two short high taps
  'warn': [
    _ringStrike(1568, 0.26, decay: 16),
    _ringStrike(1568, 0.26, offset: 0.20, decay: 16),
  ],
  // short tap
  'count': [_ringStrike(2349, 0.20, decay: 20)],
};

// ---- beep: dry square-wave blips, for loud gyms ----

final _beep = <String, List<CuePart>>{
  'prep': [CuePart(880, 0.12, 1, 'square', decay: 8)],
  'work': [
    CuePart(880, 0.12, 1, 'square', decay: 8),
    CuePart(880, 0.12, 1, 'square', decay: 8, offset: 0.18),
  ],
  'rest': [
    CuePart(440, 0.14, 1, 'square', decay: 7),
    CuePart(330, 0.16, 1, 'square', decay: 7, offset: 0.18),
  ],
  'done': [
    CuePart(990, 0.13, 1, 'square', decay: 8),
    CuePart(990, 0.13, 1, 'square', decay: 8, offset: 0.18),
    CuePart(990, 0.22, 1, 'square', decay: 6, offset: 0.36),
  ],
  'warn': [
    CuePart(1760, 0.09, 1, 'square', decay: 10),
    CuePart(1760, 0.09, 1, 'square', decay: 10, offset: 0.12),
  ],
  'count': [CuePart(2200, 0.06, 1, 'square', decay: 12)],
};

/// Cue definitions for [bank], falling back to the classic bank for unknown ids
/// (an old blob, a renamed bank).
Map<String, List<CuePart>> cuePartsFor(String bank) => switch (bank) {
  'ring' => _ring,
  'beep' => _beep,
  _ => _classic,
};

double _osc(String wave, double phase) {
  switch (wave) {
    case 'square':
      return phase % 1.0 < 0.5 ? 1.0 : -1.0;
    case 'triangle':
      final p = phase % 1.0;
      return p < 0.5 ? (4 * p - 1) : (3 - 4 * p);
    default:
      return math.sin(2 * math.pi * phase);
  }
}

Uint8List renderWav(List<CuePart> parts, {double gain = 1.0}) {
  var totalSamples = 0;
  for (final p in parts) {
    final end = ((p.offset + p.durationSec) * sampleRate).ceil();
    if (end > totalSamples) totalSamples = end;
  }
  final data = Float32List(totalSamples);
  for (final part in parts) {
    final n = (part.durationSec * sampleRate).ceil();
    final startOffset = (part.offset * sampleRate).round();
    for (var i = 0; i < n && startOffset + i < totalSamples; i++) {
      final tSec = i / sampleRate;
      final attack = part.attack <= 0
          ? 1.0
          : (tSec < part.attack ? tSec / part.attack : 1.0);
      final env = math.exp(-tSec * part.decay) * attack;
      var v = 0.0;
      for (var h = 1; h <= part.partials; h++) {
        final amp = 1.0 / (h * h);
        final ratio = part.ratios != null && h <= part.ratios!.length
            ? part.ratios![h - 1]
            : h.toDouble();
        v += amp * _osc(part.wave, part.freq * ratio * tSec);
      }
      data[startOffset + i] += v * env / part.partials;
    }
  }
  final pcm = Int16List(totalSamples);
  var peak = 0.0001;
  for (var i = 0; i < totalSamples; i++) {
    final a = data[i].abs();
    if (a > peak) peak = a;
  }
  for (var i = 0; i < totalSamples; i++) {
    pcm[i] = (data[i] / peak * 32000 * gain).round().clamp(-32768, 32767);
  }
  final bytes = BytesBuilder();
  void str(String s) => bytes.add(s.codeUnits);
  void u32(int v) {
    final b = ByteData(4)..setUint32(0, v, Endian.little);
    bytes.add(b.buffer.asUint8List());
  }

  void u16(int v) {
    final b = ByteData(2)..setUint16(0, v, Endian.little);
    bytes.add(b.buffer.asUint8List());
  }

  final dataSize = pcm.lengthInBytes;
  str('RIFF');
  u32(36 + dataSize);
  str('WAVE');
  str('fmt ');
  u32(16);
  u16(1); // PCM
  u16(1); // mono
  u32(sampleRate);
  u32(sampleRate * 2); // byte rate
  u16(2); // block align
  u16(16); // bits per sample
  str('data');
  u32(dataSize);
  bytes.add(pcm.buffer.asUint8List());
  return bytes.takeBytes();
}

/// Renders every cue of [bank] with its balancing gain applied. This is what
/// gets baked into the `assets/audio/<bank>/` WAV files.
Map<String, Uint8List> renderCueBank([String bank = defaultCueBank]) => {
  for (final e in cuePartsFor(bank).entries)
    e.key: renderWav(e.value, gain: cueGain[e.key] ?? 1.0),
};

/// Every bank, keyed by bank id. Used by the asset-baking script and the test
/// that keeps committed WAVs in sync with the synthesis.
Map<String, Map<String, Uint8List>> renderAllBanks() => {
  for (final bank in cueBanks) bank: renderCueBank(bank),
};
