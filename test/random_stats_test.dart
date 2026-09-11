// Tests ported from src/tests/random.test.ts and src/tests/stats.test.ts.
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/random.dart';
import 'package:fight_camp/lib/stats.dart';
import 'package:fight_camp/models/types.dart';

Technique tech(String id, TechniqueCategory cat) =>
    Technique(id: id, name: id, shortName: id.toUpperCase(), category: cat);

void main() {
  group('generateRandomCombo', () {
    final cfg = RandomConfig.def;

    test('generates combos within min/max length', () {
      for (var i = 0; i < 30; i++) {
        final ids = generateRandomCombo(cfg, [
          tech('a', TechniqueCategory.boxing),
          tech('b', TechniqueCategory.kicks),
          tech('c', TechniqueCategory.knees),
        ]);
        expect(ids.length, inInclusiveRange(3, 5));
      }
    });

    test('requires a punch and a kick when configured', () {
      final punches = [
        tech('p1', TechniqueCategory.boxing),
        tech('p2', TechniqueCategory.boxing),
      ];
      final kicks = [tech('k1', TechniqueCategory.kicks)];
      for (var i = 0; i < 20; i++) {
        final ids = generateRandomCombo(
          cfg.copyWith(
            categories: [TechniqueCategory.boxing, TechniqueCategory.kicks],
            includeDefense: false,
          ),
          [...punches, ...kicks],
        );
        expect(ids.any((id) => id.startsWith('p')), true);
        expect(ids.any((id) => id.startsWith('k')), true);
      }
    });

    test('excludes defense unless included', () {
      final pool = [
        tech('d1', TechniqueCategory.defense),
        tech('p', TechniqueCategory.boxing),
      ];
      for (var i = 0; i < 10; i++) {
        final ids = generateRandomCombo(
          RandomConfig.def.copyWith(requireKick: false, requirePunch: true),
          pool,
        );
        expect(ids.contains('d1'), false);
      }
      final withDef = generateRandomCombo(
        RandomConfig.def.copyWith(
          requirePunch: false,
          requireKick: false,
          includeDefense: true,
          minTechniques: 4,
          maxTechniques: 4,
        ),
        pool,
      );
      // With includeDefense the defense technique may appear.
      expect(withDef.length, 4);
    });

    test('returns empty when pool is empty', () {
      expect(generateRandomCombo(cfg, []), isEmpty);
    });
  });

  group('stats', () {
    test('computeLoad rounds minutes times rpe', () {
      expect(
        computeLoad(180 * 5 ~/ 5 * 60 ~/ (180 * 5) + 0, null),
        0,
      ); // no rpe -> 0
      expect(computeLoad(300, 10), 50); // 5 min × RPE 10
      expect(computeLoad(90, 7), 11); // 1.5 × 7 = 10.5 → 11
    });

    test('streaks counts consecutive training days', () {
      final now = DateTime.now();
      SessionRecord sessionAt(DateTime d) => SessionRecord(
        id: 's',
        date: DateTime(d.year, d.month, d.day).millisecondsSinceEpoch,
        type: WorkoutType.heavyBag,
        source: 'timer',
        name: 'S',
        duration: 600,
        load: 10,
      );
      final sessions = [
        sessionAt(now),
        sessionAt(now.subtract(const Duration(days: 1))),
        sessionAt(now.subtract(const Duration(days: 2))),
        sessionAt(now.subtract(const Duration(days: 9))),
      ];
      final st = streaks(sessions);
      expect(st.current, 3);
      expect(st.longest >= 3, true);
    });
  });

  group('weeklyStreak', () {
    final now = DateTime.now();
    DateTime weeksAgo(int n) => DateTime(now.year, now.month, now.day - n * 7);
    SessionRecord sessionAt(DateTime d) => SessionRecord(
      id: 's',
      date: d.millisecondsSinceEpoch,
      type: WorkoutType.heavyBag,
      source: 'timer',
      name: 'S',
      duration: 600,
      load: 10,
    );

    test('counts consecutive weeks with at least one session', () {
      final sessions = [
        sessionAt(weeksAgo(0)),
        sessionAt(weeksAgo(1)),
        sessionAt(weeksAgo(2)),
        sessionAt(weeksAgo(4)),
      ];
      expect(weeklyStreak(sessions), 3);
      expect(sessionsThisWeek(sessions), 1);
    });

    test('starts from the previous week when the current week is empty', () {
      final sessions = [sessionAt(weeksAgo(1)), sessionAt(weeksAgo(2))];
      expect(weeklyStreak(sessions), 2);
      expect(sessionsThisWeek(sessions), 0);
    });

    test('returns zero with no sessions', () {
      expect(weeklyStreak(const <SessionRecord>[]), 0);
      expect(sessionsThisWeek(const <SessionRecord>[]), 0);
    });
  });
}
