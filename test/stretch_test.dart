// Guards the stretching illustration pipeline: every stretching seed
// technique must map to an SVG asset that ships with the app.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/stretch.dart';
import 'package:fight_camp/models/seed.dart';
import 'package:fight_camp/models/types.dart';

void main() {
  final stretching = seedTechniques
      .where((t) => t.category == TechniqueCategory.stretching)
      .toList();

  test('every stretching technique has an SVG illustration', () {
    expect(stretching, isNotEmpty);
    for (final t in stretching) {
      expect(
        stretchImageFor(t.id),
        isNotNull,
        reason: '${t.id} has no illustration mapped in stretch.dart',
      );
    }
  });

  test('every mapped SVG exists on disk', () {
    final missing = <String>[];
    for (final t in stretching) {
      final asset = stretchImageFor(t.id);
      if (asset != null && !File(asset).existsSync()) missing.add(asset);
    }
    expect(missing, isEmpty);
  });
}
