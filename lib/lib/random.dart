// Random combo generation ported from src/lib/random.ts.
import '../models/types.dart';

typedef Rng = double Function();

int randInt(int min, int max, [Rng rng = defaultRng]) =>
    (rng() * (max - min + 1)).floor() + min;

T pick<T>(List<T> arr, [Rng rng = defaultRng]) => arr[randInt(0, arr.length - 1, rng)];

List<T> shuffle<T>(List<T> arr, [Rng rng = defaultRng]) {
  final a = arr.toList();
  for (var i = a.length - 1; i > 0; i--) {
    final j = randInt(0, i, rng);
    final tmp = a[i];
    a[i] = a[j];
    a[j] = tmp;
  }
  return a;
}

double defaultRng() {
  return defaultRandom.nextDouble();
}

final defaultRandom = _SeededRandom(DateTime.now().microsecondsSinceEpoch);

class _SeededRandom {
  int _s;
  _SeededRandom(this._s);
  double nextDouble() {
    // xorshift for deterministic-ish behavior independent of dart:math import churn.
    // 32-bit mask keeps this JS-safe (dart2js ints are 53-bit doubles).
    _s ^= _s << 13;
    _s &= 0xFFFFFFFF;
    _s ^= _s >> 7;
    _s ^= _s << 17;
    _s &= 0xFFFFFFFF;
    return (_s & 0xFFFFFFFF) / 0x100000000;
  }
}

List<String> generateRandomCombo(RandomConfig cfg, List<Technique> techniques, [Rng? rng]) {
  final r = rng ?? defaultRng;
  final pool = techniques
      .where((t) => cfg.categories.contains(t.category) && (t.category != TechniqueCategory.defense || cfg.includeDefense))
      .toList();
  if (pool.isEmpty) return [];
  final lo = (cfg.minTechniques < cfg.maxTechniques ? cfg.minTechniques : cfg.maxTechniques) < 1
      ? 1
      : (cfg.minTechniques < cfg.maxTechniques ? cfg.minTechniques : cfg.maxTechniques);
  final hi = lo > cfg.maxTechniques ? lo : cfg.maxTechniques;
  final len = randInt(lo, hi, r);
  final ids = List<String>.filled(len, '');
  final positions = shuffle(List<int>.generate(len, (i) => i), r);
  var pi = 0;
  final required = <Technique>[];
  final punches = pool.where((t) => t.category == TechniqueCategory.boxing).toList();
  final kicks = pool.where((t) => t.category == TechniqueCategory.kicks).toList();
  if (cfg.requirePunch && punches.isNotEmpty) required.add(pick(punches, r));
  if (cfg.requireKick && kicks.isNotEmpty) required.add(pick(kicks, r));
  for (final t in required) {
    if (pi < positions.length) {
      ids[positions[pi++]] = t.id;
    }
  }
  for (var i = 0; i < len; i++) {
    if (ids[i].isNotEmpty) continue;
    final prevId = i > 0 ? ids[i - 1] : null;
    final nextId = i < len - 1 ? ids[i + 1] : null;
    var cands = pool.where((t) => t.id != prevId && t.id != nextId).toList();
    if (cands.isEmpty) cands = pool.where((t) => t.id != prevId).toList();
    if (cands.isEmpty) cands = pool;
    ids[i] = pick(cands, r).id;
  }
  return ids;
}

class GeneratedCombo {
  final String name;
  final List<String> techniqueIds;
  const GeneratedCombo(this.name, this.techniqueIds);
}

List<GeneratedCombo> generateCombos(RandomConfig cfg, List<Technique> techniques, int count, [Rng? rng]) {
  final r = rng ?? defaultRng;
  final n = count < 1 ? 1 : count;
  final out = <GeneratedCombo>[];
  final seen = <String>{};
  for (var i = 0; i < n; i++) {
    var ids = <String>[];
    for (var attempt = 0; attempt < 6; attempt++) {
      ids = generateRandomCombo(cfg, techniques, r);
      final sig = ids.join('.');
      if (ids.isEmpty) break;
      if (!seen.contains(sig)) {
        seen.add(sig);
        break;
      }
    }
    out.add(GeneratedCombo('${i + 1}', ids));
  }
  return out;
}
