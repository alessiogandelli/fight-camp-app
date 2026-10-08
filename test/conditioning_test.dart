// Guards the conditioning illustration pipeline: every conditioning seed
// technique must map to an SVG asset that ships with the app.
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/conditioning.dart';
import 'package:fight_camp/models/seed.dart';
import 'package:fight_camp/models/types.dart';

void main() {
  final conditioning = seedTechniques
      .where((t) => t.category == TechniqueCategory.conditioning)
      .toList();

  test('every conditioning technique has an SVG illustration', () {
    expect(conditioning, isNotEmpty);
    for (final t in conditioning) {
      expect(
        conditioningImageFor(t.id),
        isNotNull,
        reason: '${t.id} has no illustration mapped in conditioning.dart',
      );
    }
  });

  test('every mapped SVG exists on disk', () {
    final missing = <String>[];
    for (final t in conditioning) {
      final asset = conditioningImageFor(t.id);
      if (asset != null && !File(asset).existsSync()) missing.add(asset);
    }
    expect(missing, isEmpty);
  });
}
