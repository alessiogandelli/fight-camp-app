// Unit tests for the training-progression helpers in lib/lib/stats.dart.
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/lib/stats.dart';
import 'package:fight_camp/models/types.dart';

SessionRecord _rec({
  required String id,
  required int ms,
  int? rounds,
  int duration = 600,
  int? work,
  List<NameRef>? combos,
}) => SessionRecord(
  id: id,
  date: ms,
  type: WorkoutType.heavyBag,
  source: 'manual',
  name: id,
  roundsCompleted: rounds,
  totalRounds: rounds,
  duration: duration,
  workDuration: work,
  load: 0,
  combosUsed: combos,
);

void main() {
  group('percentChange', () {
    test('rounds to a whole percent and handles direction', () {
      expect(percentChange(150, 100), 50);
      expect(percentChange(50, 100), -50);
      expect(percentChange(100, 100), 0);
    });

    test('is null without a baseline so callers can hide the delta', () {
      expect(percentChange(5, 0), isNull);
      expect(percentChange(0, 0), isNull);
    });

    test('down to zero is a real -100%', () {
      expect(percentChange(0, 5), -100);
    });
  });

  group('periods', () {
    final now = DateTime(2026, 9, 12, 10); // Saturday

    test('week is the current calendar week', () {
      final week = periodFor(StatsRange.week, now: now);
      expect(week.start, DateTime(2026, 9, 7));
      expect(week.end, isNull);
    });

    test('previous week is the week before', () {
      final prev = previousPeriodFor(StatsRange.week, now: now)!;
      expect(prev.start, DateTime(2026, 8, 31));
      expect(prev.end, DateTime(2026, 9, 7));
    });

    test('four weeks spans the 4 calendar weeks ending today', () {
      final w4 = periodFor(StatsRange.weeks4, now: now);
      expect(w4.start, DateTime(2026, 8, 17));
      final prev = previousPeriodFor(StatsRange.weeks4, now: now)!;
      expect(prev.start, DateTime(2026, 7, 20));
      expect(prev.end, DateTime(2026, 8, 17));
    });

    test('all-time has no bounds and no previous period', () {
      final all = periodFor(StatsRange.all, now: now);
      expect(all.start, isNull);
      expect(all.end, isNull);
      expect(previousPeriodFor(StatsRange.all, now: now), isNull);
    });

    test('sessionsInPeriod keeps only the window', () {
      final sessions = [
        _rec(id: 'in', ms: DateTime(2026, 9, 8).millisecondsSinceEpoch),
        _rec(id: 'before', ms: DateTime(2026, 9, 6).millisecondsSinceEpoch),
      ];
      final week = sessionsInPeriod(
        sessions,
        periodFor(StatsRange.week, now: now),
      );
      expect(week.map((s) => s.id), ['in']);
    });
  });

  group('personalRecords', () {
    test('picks the best value per metric across all sessions', () {
      final now = DateTime.now().millisecondsSinceEpoch;
      final rec = personalRecords([
        _rec(id: 'a', ms: now, rounds: 4, duration: 1200),
        _rec(
          id: 'b',
          ms: now,
          rounds: 8,
          duration: 600,
          combos: const [NameRef('c1', 'JAB')],
        ),
      ]);
      expect(rec.maxRounds, 8);
      expect(rec.longestSessionSeconds, 1200);
      expect(rec.totalCombos, 1);
      expect(rec.isEmpty, isFalse);
    });

    test('is empty with no sessions', () {
      expect(personalRecords(const []).isEmpty, isTrue);
    });
  });

  test('combosUsedCount sums combinations across sessions', () {
    final now = DateTime.now().millisecondsSinceEpoch;
    final count = combosUsedCount([
      _rec(
        id: 'a',
        ms: now,
        combos: const [NameRef('c1', 'JAB'), NameRef('c2', 'CROSS')],
      ),
      _rec(id: 'b', ms: now, combos: const [NameRef('c1', 'JAB')]),
    ]);
    expect(count, 3);
  });
}
