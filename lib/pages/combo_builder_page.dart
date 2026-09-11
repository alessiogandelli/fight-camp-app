// Combo builder page ported from src/pages/ComboBuilderPage.tsx.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

Future<bool?> showComboBuilderSheet(BuildContext context, {String? comboId}) {
  final l = AppLocalizations.of(context)!;
  return showAppModal<bool>(
    context,
    title: comboId == null ? l.comboNew : l.comboEdit,
    scrollable: false,
    builder: (_) => ComboBuilderPage(comboId: comboId),
  );
}

class ComboBuilderPage extends StatefulWidget {
  final String? comboId;
  const ComboBuilderPage({super.key, this.comboId});

  @override
  State<ComboBuilderPage> createState() => _ComboBuilderPageState();
}

class _ComboBuilderPageState extends State<ComboBuilderPage> {
  late String _id;
  bool _exists = true;
  late final TextEditingController _name;
  List<String> _steps = [];

  @override
  void initState() {
    super.initState();
    final store = context.read<AppStore>();
    Combination? src;
    if (widget.comboId != null) {
      for (final c in store.data.combinations) {
        if (c.id == widget.comboId) src = c;
      }
    }
    _exists = src != null || widget.comboId == null;
    _id = src?.id ?? uid();
    _name = TextEditingController(
      text:
          src?.name ??
          (widget.comboId == null
              ? nextComboName(store.data.combinations)
              : ''),
    );
    _steps = src != null ? [...src.techniqueIds] : [];
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final store = context.read<AppStore>();
    final l = AppLocalizations.of(context)!;
    if (_steps.isEmpty) return context.showToast(l.comboAddTechnique);
    if (_name.text.trim().isEmpty) return context.showToast(l.comboGiveName);
    store.saveCombination(
      Combination(
        id: _id,
        name: _name.text.trim().toUpperCase(),
        techniqueIds: [..._steps],
        favorite: false,
        createdAt: DateTime.now().millisecondsSinceEpoch,
      ),
    );
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  Future<void> _addCustomTechnique() async {
    final store = context.read<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final nameCtrl = TextEditingController();
    final shortCtrl = TextEditingController();
    var category = TechniqueCategory.boxing;
    final descCtrl = TextEditingController();

    final ok = await showAppModal<bool>(
      context,
      title: l.comboNewTechnique,
      builder: (_) => StatefulBuilder(
        builder: (context, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Field(
              label: l.commonName,
              child: TextField(
                controller: nameCtrl,
                onChanged: (v) => setModalState(() {}),
              ),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.comboShortName,
              child: TextField(controller: shortCtrl),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.commonCategory,
              child: Select<TechniqueCategory>(
                value: category,
                options: [
                  for (final c in techniqueCategories)
                    (value: c.id, label: categoryLabel(c.id, lang)),
                ],
                onChanged: (v) => setModalState(() => category = v),
              ),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.comboDescription,
              child: TextField(controller: descCtrl, maxLines: 2),
            ),
            const SizedBox(height: 14),
            Button(
              label: l.comboAddTechniqueBtn,
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        ),
      ),
    );
    if (ok != true || !mounted) return;
    final name = nameCtrl.text.trim();
    if (name.isEmpty) return context.showToast(l.comboTechniqueNeedsName);
    final tech = Technique(
      id: uid(),
      name: name,
      shortName: shortCtrl.text.trim().toUpperCase().isEmpty
          ? name.toUpperCase()
          : shortCtrl.text.trim().toUpperCase(),
      category: category,
      description: descCtrl.text.trim().isEmpty ? null : descCtrl.text.trim(),
      custom: true,
    );
    final created = store.addTechnique(tech);
    setState(() => _steps.add(created.id));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;

    // Group techniques by category.
    final byCat = <TechniqueCategory, List<Technique>>{};
    for (final tech in store.data.techniques) {
      byCat.putIfAbsent(tech.category, () => []).add(tech);
    }

    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (!_exists)
                      Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          l.comboNotFoundMsg,
                          style: const TextStyle(
                            color: AppColors.warn,
                            fontSize: 12.5,
                          ),
                        ),
                      ),
                    const SizedBox(height: 14),
                    LayoutBuilder(
                      builder: (context, constraints) {
                        final wide = constraints.maxWidth >= 700;
                        final left = _StepsPanel(
                          nameController: _name,
                          steps: _steps,
                          onReorder: (a, b) => setState(() {
                            final tmp = _steps[a];
                            _steps[a] = _steps[b];
                            _steps[b] = tmp;
                          }),
                          onRemove: (i) => setState(() => _steps.removeAt(i)),
                        );
                        final right = _LibraryPanel(
                          byCat: byCat,
                          onPick: (tech) => setState(() => _steps.add(tech.id)),
                          onAddNew: _addCustomTechnique,
                        );
                        return wide
                            ? Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(child: left),
                                  const SizedBox(width: 12),
                                  Expanded(child: right),
                                ],
                              )
                            : Column(
                                children: [
                                  left,
                                  const SizedBox(height: 12),
                                  right,
                                ],
                              );
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            Expanded(
              child: Button(
                label: l.commonCancel,
                variant: BtnVariant.ghost,
                onTap: () => Navigator.of(context).pop(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Button(label: l.commonSave, onTap: _save),
            ),
          ],
        ),
      ],
    );
  }
}

class _StepsPanel extends StatelessWidget {
  final TextEditingController nameController;
  final List<String> steps;
  final void Function(int, int) onReorder;
  final void Function(int) onRemove;
  const _StepsPanel({
    required this.nameController,
    required this.steps,
    required this.onReorder,
    required this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Field(
            label: l.commonName,
            child: TextInput(controller: nameController, uppercase: true),
          ),
          const SizedBox(height: 6),
          Text(
            l.comboTechniquesCount(steps.length),
            style: const TextStyle(fontSize: 11, color: AppColors.mut),
          ),
          const SizedBox(height: 10),
          if (steps.isEmpty)
            Text(
              l.comboTapHint,
              style: const TextStyle(fontSize: 12.5, color: AppColors.mut),
            )
          else
            ...List.generate(steps.length, (i) {
              String label = l.sessionUnknown;
              for (final tech in store.data.techniques) {
                if (tech.id == steps[i]) {
                  label = tech.shortIn(lang);
                }
              }
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
                decoration: BoxDecoration(
                  color: AppColors.panel2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Text(
                      '${i + 1}.',
                      style: const TextStyle(
                        color: AppColors.mut,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        label.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13,
                        ),
                      ),
                    ),
                    IconButton2(
                      Icons.keyboard_arrow_up_rounded,
                      size: 17,
                      onTap: i > 0 ? () => onReorder(i, i - 1) : null,
                    ),
                    IconButton2(
                      Icons.keyboard_arrow_down_rounded,
                      size: 17,
                      onTap: i < steps.length - 1
                          ? () => onReorder(i, i + 1)
                          : null,
                    ),
                    IconButton2(
                      Icons.close,
                      size: 17,
                      onTap: () => onRemove(i),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }
}

class _LibraryPanel extends StatelessWidget {
  final Map<TechniqueCategory, List<Technique>> byCat;
  final ValueChanged<Technique> onPick;
  final VoidCallback onAddNew;
  const _LibraryPanel({
    required this.byCat,
    required this.onPick,
    required this.onAddNew,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final customTechs = store.data.techniques.where((t) => t.custom).toList();

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(l.comboTechniqueLibrary),
          for (final cat in techniqueCategories) ...[
            Text(
              categoryLabel(cat.id, lang).toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: AppColors.mut,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tech in byCat[cat.id] ?? const <Technique>[])
                  GestureDetector(
                    onTap: () => onPick(tech),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panel2,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(color: AppColors.line),
                      ),
                      child: Text(
                        tech.shortIn(lang),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 10),
          ],
          const SizedBox(height: 4),
          Button(
            label: l.comboNewTechnique,
            variant: BtnVariant.ghost,
            size: BtnSize.sm,
            icon: Icons.add,
            onTap: onAddNew,
          ),
          if (customTechs.isNotEmpty) ...[
            const SizedBox(height: 10),
            SectionTitle(l.comboCustomTechniques),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final tech in customTechs)
                  GestureDetector(
                    onTap: () => onPick(tech),
                    onLongPress: () async {
                      final ok = await showConfirm(
                        context,
                        title: l.comboDeleteTechniqueTitle,
                        message: l.comboDeleteTechniqueMsg,
                        cancelLabel: l.commonCancel,
                        confirmLabel: l.commonDelete,
                      );
                      if (!ok || !context.mounted) return;
                      final before = store.snapshot;
                      store.deleteTechnique(tech.id);
                      context.showToast(
                        l.combosDeleted,
                        actionLabel: l.commonUndo,
                        onAction: () => store.restore(before),
                      );
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 7,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.panel2,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: AppColors.accent.withAlpha(90),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            tech.shortIn(lang),
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.accent,
                            ),
                          ),
                          const SizedBox(width: 5),
                          const Icon(
                            Icons.close,
                            size: 11,
                            color: AppColors.mut,
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

/// Scans trailing numbers of existing combo names to produce "COMBO NN".
String nextComboName(List<Combination> combos) {
  var maxN = 0;
  for (final c in combos) {
    final match = RegExp(r'(\d+)\s*$').firstMatch(c.name);
    if (match != null) {
      final n = int.tryParse(match.group(1)!);
      if (n != null && n > maxN) maxN = n;
    }
  }
  final next = maxN + 1;
  return 'COMBO ${next.toString().padLeft(2, '0')}';
}
