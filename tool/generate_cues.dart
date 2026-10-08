// Bakes the synthesized cue sounds into committed WAV assets.
//
// Run from the project root:  dart run tool/generate_cues.dart
// Regenerate whenever cue_synth.dart changes so assets/audio stays in sync.
import 'dart:io';

import 'package:fight_camp/lib/cue_synth.dart';

void main() {
  final projectRoot = File.fromUri(Platform.script).parent.parent;
  final outDir = Directory('${projectRoot.path}/assets/audio')
    ..createSync(recursive: true);

  final bank = renderCueBank();
  for (final entry in bank.entries) {
    final file = File('${outDir.path}/${entry.key}.wav');
    file.writeAsBytesSync(entry.value);
    stdout.writeln('wrote ${file.path} (${entry.value.length} bytes)');
  }
}
