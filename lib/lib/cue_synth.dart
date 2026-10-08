// Pure offline synthesis of the cue sounds. No Flutter/plugin dependencies, so
// it can run both at runtime (via audio.dart) and from a plain Dart script
// (tool/generate_cues.dart) that bakes the generated WAVs into assets/audio/.
import 'dart:math' as math;
import 'dart:typed_data';

const sampleRate = 22050;

class CuePart {
  final double freq;
  final double durationSec;
  final int partials;
  final String wave; // 'triangle' | 'square' | 'sine'
  final double offset;
  const CuePart(
    this.freq,
    this.durationSec,
    this.partials,
    this.wave, {
    this.offset = 0,
  });
}

final cueParts = <String, List<CuePart>>{
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
      final env = math.exp(-tSec * 6) * (tSec < 0.004 ? tSec / 0.004 : 1);
      var v = 0.0;
      for (var h = 1; h <= part.partials; h++) {
        final amp = 1.0 / (h * h);
        v += amp * _osc(part.wave, part.freq * h * tSec);
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

/// Renders every cue with its balancing gain applied. This is what gets baked
/// into the `assets/audio/` WAV files.
Map<String, Uint8List> renderCueBank() => {
  for (final e in cueParts.entries)
    e.key: renderWav(e.value, gain: cueGain[e.key] ?? 1.0),
};
