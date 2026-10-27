// Progressi counts trainings while summing every session inside them.
import 'package:fight_camp/lib/stats.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/training/training.dart';
import 'package:flutter_test/flutter_test.dart';

SessionRecord _rec(String id, int startMs, int duration, String groupId) =>
    SessionRecord(
      id: id,
      date: startMs + duration * 1000, // `date` is the recording moment (end)
      type: WorkoutType.heavyBag,
      source: 'timer',
      name: id,
      duration: duration,
      load: 12,
      groupId: groupId,
    );

void main() {
  // Dated inside the current calendar week so the windowed helpers agree
  // regardless of when the suite runs.
  final weekStart = startOfWeek(DateTime.now());
  final base = weekStart.add(const Duration(hours: 9)).millisecondsSinceEpoch;
  const min = 60000;

  final warmup = _rec('warmup', base, 10 * 60, 'g1');
  final bag = _rec('bag', base + 12 * min, 30 * 60, 'g1');
  final stretch = _rec('stretch', base + 47 * min, 10 * 60, 'g1');
  final other = _rec('other', base + 2 * 3600000, 40 * 60, 'g2');
  final sessions = [warmup, bag, stretch, other];

  test('one training of three sessions counts as one but sums its time', () {
    final vol = volumeStats(sessions);
    expect(vol.sessions, 2);
    expect(vol.minutes, 90);
    expect(vol.load, 48);
  });

  test('weekly buckets report trainings, not pieces', () {
    final bucket = weeklyBuckets(sessions, 1).single;
    expect(bucket.sessions, 2);
    expect(bucket.minutes, 90);
  });

  test('trainings per week and this week use the same unit', () {
    expect(sessionsThisWeek(sessions), 2);
    expect(sessionsPerWeek(sessions, 1), 2);
    expect(trainingCount(sessions), 2);
  });
}
