// RandomConfigEditor ported from src/components/RandomConfigEditor.tsx.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/random.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'combo_picker.dart' show techniqueChain;
import '../l10n/app_localizations.dart';

class RandomConfigEditor extends StatelessWidget {
  final RandomConfig value;
  final ValueChanged<RandomConfig> onChanged;
  const RandomConfigEditor({super.key, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;

    void toggleCategory(TechniqueCategory c) {
      final cats = [...value.categories];
      if (cats.contains(c)) {
        cats.remove(c);
      } else {
        cats.add(c);
      }
      onChanged(value.copyWith(categories: cats));
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Field(label: l.randomMinTechniques, child: NumStepper(value: value.minTechniques, min: 1, max: 12, onChanged: (v) => onChanged(value.copyWith(minTechniques: v)))),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Field(label: l.randomMaxTechniques, child: NumStepper(value: value.maxTechniques, min: 1, max: 12, onChanged: (v) => onChanged(value.copyWith(maxTechniques: v)))),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Field(
          label: l.randomAllowedCategories,
          child: Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final c in techniqueCategories)
                ChipWidget(
                  label: categoryLabel(c.id, lang),
                  active: value.categories.contains(c.id),
                  onTap: () => toggleCategory(c.id),
                ),
            ],
          ),
        ),
        const SizedBox(height: 10),
        _ToggleRow(label: l.randomRequirePunch, value: value.requirePunch, onChanged: (v) => onChanged(value.copyWith(requirePunch: v))),
        _ToggleRow(label: l.randomRequireKick, value: value.requireKick, onChanged: (v) => onChanged(value.copyWith(requireKick: v))),
        _ToggleRow(label: l.randomIncludeDefense, value: value.includeDefense, onChanged: (v) => onChanged(value.copyWith(includeDefense: v))),
        const SizedBox(height: 10),
        Text(
          '${l.randomGenerated}: ${generateCombos(value, store.data.techniques, 3).map((g) => g.techniqueIds.isEmpty ? '' : techniqueChain(g.techniqueIds, store.data.techniques, lang)).take(2).join(' · ')}',
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 11.5, color: AppColors.mut),
        ),
      ],
    );
  }
}

class _ToggleRow extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;
  const _ToggleRow({required this.label, required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.symmetric(vertical: 5),
        child: Row(
          children: [
            Expanded(child: Text(label, style: const TextStyle(fontSize: 13.5, color: AppColors.ink))),
            Toggle(value: value, onChanged: onChanged),
          ],
        ),
      );
}
