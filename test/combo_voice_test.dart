import 'package:flutter_test/flutter_test.dart';

import 'package:fight_camp/lib/combo_voice.dart';
import 'package:fight_camp/models/seed.dart';
import 'package:fight_camp/models/types.dart';

void main() {
  final byId = {for (final t in seedTechniques) t.id: t};

  test('Italian reads jab and cross by their boxing number', () {
    expect(spokenCombo(['t-jab'], byId, Lang.it), ['uno']);
    expect(spokenCombo(['t-cross'], byId, Lang.it), ['due']);
    expect(spokenCombo(['t-jab-body'], byId, Lang.it), ['uno al corpo']);
    expect(spokenCombo(['t-cross-body'], byId, Lang.it), ['due al corpo']);
  });

  test('other techniques fall back to their full name, not shortName', () {
    expect(spokenCombo(['t-lead-hook'], byId, Lang.it), ['Gancio sinistro']);
    expect(spokenCombo(['t-rear-round'], byId, Lang.it), ['Calcio destro']);
  });

  test('missing ids are dropped', () {
    expect(spokenCombo(['t-jab', 'nope', 't-cross'], byId, Lang.it), [
      'uno',
      'due',
    ]);
    expect(spokenCombo(['nope'], byId, Lang.it), isEmpty);
  });

  test('a full combo reads in order', () {
    expect(
      spokenCombo(
        ['t-jab', 't-cross', 't-lead-hook', 't-rear-low'],
        byId,
        Lang.it,
      ),
      ['uno', 'due', 'Gancio sinistro', 'Calcio basso destro'],
    );
  });
}
