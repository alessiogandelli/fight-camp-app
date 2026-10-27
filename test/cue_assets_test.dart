// Guards that the committed cue assets stay in sync with cue_synth.dart.
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/cue_synth.dart';

Uint8List _bytesOf(ByteData data) =>
    data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('every cue asset matches the bytes rendered from cue_synth', () async {
    for (final bank in renderAllBanks().entries) {
      for (final entry in bank.value.entries) {
        final data = await rootBundle.load(
          'assets/audio/${bank.key}/${entry.key}.wav',
        );
        expect(
          _bytesOf(data),
          equals(entry.value),
          reason:
              '${bank.key}/${entry.key}.wav is out of sync — run '
              '`dart run tool/generate_cues.dart`',
        );
      }
    }
  });

  test('cue assets are valid RIFF/WAVE PCM files', () async {
    for (final bank in renderAllBanks().entries) {
      for (final name in bank.value.keys) {
        final data = await rootBundle.load(
          'assets/audio/${bank.key}/$name.wav',
        );
        final bytes = _bytesOf(data);
        expect(String.fromCharCodes(bytes.sublist(0, 4)), 'RIFF');
        expect(String.fromCharCodes(bytes.sublist(8, 12)), 'WAVE');
        expect(bytes.length, greaterThan(44));
      }
    }
  });

  test('three banks ship the same six cue names', () {
    final banks = renderAllBanks();
    expect(banks.keys.toList(), cueBanks);
    final reference = banks[defaultCueBank]!.keys.toList()..sort();
    expect(reference, ['count', 'done', 'prep', 'rest', 'warn', 'work']);
    for (final bank in banks.values) {
      expect(bank.keys.toList()..sort(), reference);
    }
  });
}
