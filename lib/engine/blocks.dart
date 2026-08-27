// Compiles workout blocks into timer rounds (ADR 0002).
import '../models/types.dart';

/// Flattens a Workout's blocks into the flat round list the session engine
/// consumes. Round and circuit blocks expand to one [RoundBase] per series;
/// aerobic, stretching and free blocks become a single continuous round.
List<RoundBase> blockRounds(Workout w) {
  final out = <RoundBase>[];
  for (final b in w.blocks) {
    switch (b.type) {
      case BlockType.round:
        final type = b.hasCombos ? RoundType.combination : RoundType.free;
        for (var i = 0; i < b.rounds; i++) {
          out.add(RoundBase(
            label: b.label,
            duration: b.duration,
            restDuration: i < b.rounds - 1 ? b.restDuration : 0,
            type: type,
            combinationIds: b.combinationIds.toList(),
          ));
        }
      case BlockType.circuit:
        for (var i = 0; i < b.rounds; i++) {
          out.add(RoundBase(
            label: b.label,
            duration: b.duration,
            restDuration: i < b.rounds - 1 ? b.restDuration : 0,
            type: RoundType.conditioning,
          ));
        }
      case BlockType.aerobic:
        out.add(RoundBase(label: b.label, duration: b.duration, restDuration: 0, type: RoundType.free));
      case BlockType.stretching:
        out.add(RoundBase(
          label: b.label ?? 'STRETCHING',
          duration: b.duration,
          restDuration: 0,
          type: b.hasCombos ? RoundType.combination : RoundType.custom,
          combinationIds: b.combinationIds.toList(),
        ));
      case BlockType.free:
        out.add(RoundBase(label: b.label, duration: b.duration, restDuration: 0, type: RoundType.custom));
    }
  }
  return out;
}
