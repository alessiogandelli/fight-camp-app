// Spoken rendering of a combo, used to announce the next round's techniques
// during the pause before it. Italian reads the basic punches by their boxing
// number (jab = uno, cross = due); everything else falls back to its full name.
import '../models/types.dart';

/// Italian boxing shorthand for the fundamental punches.
const _itSpoken = <String, String>{
  't-jab': 'uno',
  't-cross': 'due',
  't-jab-body': 'uno al corpo',
  't-cross-body': 'due al corpo',
};

String spokenTechnique(Technique? t, Lang lang) {
  if (t == null) return '';
  if (lang == Lang.it) {
    final mapped = _itSpoken[t.id];
    if (mapped != null) return mapped;
  }
  return t.nameIn(lang);
}

/// Resolves [techniqueIds] to speakable words, dropping ids that no longer
/// exist. Empty when there is nothing to announce.
List<String> spokenCombo(
  List<String> techniqueIds,
  Map<String, Technique> byId,
  Lang lang,
) => techniqueIds
    .map((id) => spokenTechnique(byId[id], lang))
    .where((s) => s.isNotEmpty)
    .toList();
