// Combination picker modal ported from src/components/ComboPicker.tsx.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

Future<List<String>?> showComboPicker(
  BuildContext context, {
  required List<String> selected,
  bool multi = true,
}) {
  return showAppModal<List<String>>(
    context,
    title: AppLocalizations.of(context)!.pickerTitle,
    scrollable: false,
    builder: (_) => _ComboPickerBody(initialSelected: selected, multi: multi),
  );
}

class _ComboPickerBody extends StatefulWidget {
  final List<String> initialSelected;
  final bool multi;
  const _ComboPickerBody({required this.initialSelected, required this.multi});

  @override
  State<_ComboPickerBody> createState() => _ComboPickerBodyState();
}

class _ComboPickerBodyState extends State<_ComboPickerBody> {
  late final Set<String> _selected = {...widget.initialSelected};
  late final Set<TechniqueCategory> _activeCats = {
    ...techniqueCategories.map((c) => c.id),
  };
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    var combos =
        store.data.combinations
            .where((c) => _matches(c, store.data.techniques))
            .toList()
          ..sort((a, b) {
            if (a.favorite != b.favorite) return a.favorite ? -1 : 1;
            return a.name.toLowerCase().compareTo(b.name.toLowerCase());
          });

    return Column(
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: l.pickerSearch,
            prefixIcon: const Icon(Icons.search, color: AppColors.mut),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            ChipWidget(
              label: l.commonAll,
              active: _allActive(),
              onTap: () => setState(
                () => _activeCats.addAll(techniqueCategories.map((c) => c.id)),
              ),
            ),
            for (final c in techniqueCategories)
              ChipWidget(
                label: categoryLabel(c.id, lang),
                active: _activeCats.contains(c.id),
                onTap: () => setState(() {
                  if (_activeCats.contains(c.id)) {
                    _activeCats.remove(c.id);
                  } else {
                    _activeCats.add(c.id);
                  }
                }),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Expanded(
          child: combos.isEmpty
              ? Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  child: Text(
                    l.pickerEmpty,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.mut),
                  ),
                )
              : ListView.builder(
                  itemCount: combos.length,
                  itemBuilder: (_, i) => _comboRow(combos[i], store, lang),
                ),
        ),
        if (widget.multi)
          Padding(
            padding: const EdgeInsets.only(top: 12),
            child: Row(
              children: [
                ChipWidget(
                  label: l.commonClear,
                  active: false,
                  onTap: () => setState(() => _selected.clear()),
                ),
                const SizedBox(width: 6),
                ChipWidget(
                  label: l.pickerSelectAll,
                  active: false,
                  onTap: () =>
                      setState(() => _selected.addAll(combos.map((c) => c.id))),
                ),
                const Spacer(),
                Button(
                  label: l.pickerDone(_selected.length),
                  onTap: () => Navigator.of(context).pop(_selected.toList()),
                ),
              ],
            ),
          ),
      ],
    );
  }

  bool _allActive() => _activeCats.length == techniqueCategories.length;

  bool _matches(Combination c, List<Technique> techniques) {
    if (_query.isNotEmpty &&
        !c.name.toLowerCase().contains(_query.toLowerCase()))
      return false;
    if (_allActive()) return true;
    if (_activeCats.isEmpty) return false;
    for (final tech in c.techniqueIds) {
      for (final t in techniques) {
        if (t.id == tech && _activeCats.contains(t.category)) return true;
      }
    }
    return false;
  }

  Widget _comboRow(Combination c, AppStore store, Lang lang) {
    final checked = _selected.contains(c.id);
    return GestureDetector(
      onTap: () {
        if (widget.multi) {
          setState(
            () => checked ? _selected.remove(c.id) : _selected.add(c.id),
          );
        } else {
          Navigator.of(context).pop([c.id]);
        }
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        decoration: BoxDecoration(
          color: checked ? AppColors.accent.withAlpha(30) : AppColors.panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: checked ? AppColors.accent.withAlpha(120) : AppColors.line,
          ),
        ),
        child: Row(
          children: [
            Icon(
              checked
                  ? Icons.check_box_rounded
                  : Icons.check_box_outline_blank_rounded,
              size: 20,
              color: checked ? AppColors.accent : AppColors.mut,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          c.name.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                      if (c.favorite) ...[
                        const SizedBox(width: 6),
                        const Icon(
                          Icons.star_rounded,
                          size: 13,
                          color: AppColors.warn,
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    techniqueChain(c.techniqueIds, store.data.techniques, lang),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: AppColors.mut),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

String techniqueChain(List<String> ids, List<Technique> techniques, Lang lang) {
  return ids
      .map((id) {
        for (final tech in techniques) {
          if (tech.id == id) return tech.shortIn(lang);
        }
        return '?';
      })
      .join(' → ');
}
