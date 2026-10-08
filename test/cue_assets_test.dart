// Guards that the committed cue assets stay in sync with cue_synth.dart.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/cue_synth.dart';

Uint8List _bytesOf(ByteData data) =>
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every cue asset matches the bytes rendered from cue_synth', () async {
    final bank = renderCueBank();
    for (final entry in bank.entries) {
      final data = await rootBundle.load('assets/audio/${entry.key}.wav');
      expect(
        _bytesOf(data),
        equals(entry.value),
        reason:
            '${entry.key}.wav is out of sync — run '
            '`dart run tool/generate_cues.dart`',
      );
    }
  });

  test('cue assets are valid RIFF/WAVE PCM files', () async {
    for (final name in renderCueBank().keys) {
      final data = await rootBundle.load('assets/audio/$name.wav');
      final bytes = _bytesOf(data);
      expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
      expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
      expect(bytes.length, greaterThan(44));
    }
  });
}
