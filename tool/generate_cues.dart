// Bakes the synthesized cue sounds into committed WAV assets.
//
// Run from the project root:  dart run tool/generate_cues.dart
// Regenerate whenever cue_synth.dart changes so assets/audio stays in sync.
import 'dart:io';

import 'package:fight_camp/lib/cue_synth.dart';

void main() {
  final projectRoot = File.fromUri(Platform.script).parent.parent;
  final outRoot = Directory('${projectRoot.path}/assets/audio')
    ..createSync(recursive: true);

  // Drop legacy flat cue files: every bank now lives in its own subfolder.
  for (final entity in outRoot.listSync()) {
    if (entity is File && entity.path.endsWith('.wav')) entity.deleteSync();
  }

  var written = 0;
  for (final bank in renderAllBanks().entries) {
    final dir = Directory('${outRoot.path}/${bank.key}')
      ..createSync(recursive: true);
    for (final cue in bank.value.entries) {
      final file = File('${dir.path}/${cue.key}.wav');
      file.writeAsBytesSync(cue.value);
      stdout.writeln('wrote ${file.path} (${cue.value.length} bytes)');
      written++;
    }
  }
  stdout.writeln('$written cue files written across ${cueBanks.length} banks');
}
