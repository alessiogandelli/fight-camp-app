// Stretching routine builder: a dedicated page distinct from the combo
// builder. Exercises are shown with their SVG illustrations prominently.
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stretch.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

Future<bool?> showRoutineBuilderSheet(
  BuildContext context, {
  String? routineId,
}) {
  final l = AppLocalizations.of(context)!;
  return showAppModal<bool>(
    context,
    title: routineId == null ? l.routineNew : l.routineEdit,
    scrollable: false,
    builder: (_) => StretchRoutineBuilderPage(routineId: routineId),
  );
}

class StretchRoutineBuilderPage extends StatefulWidget {
  final String? routineId;
  const StretchRoutineBuilderPage({super.key, this.routineId});

  @override
  State<StretchRoutineBuilderPage> createState() =>
      _StretchRoutineBuilderPageState();
}

class _StretchRoutineBuilderPageState extends State<StretchRoutineBuilderPage> {
  late String _id;
  bool _exists = true;
  late final TextEditingController _name;
  List<String> _steps = [];

  @override
  void initState() {
    super.initState();
    final store = context.read<AppStore>();
    Combination? src;
    if (widget.routineId != null) {
      for (final c in store.data.combinations) {
        if (c.id == widget.routineId) src = c;
      }
    }
    _exists = src != null || widget.routineId == null;
    _id = src?.id ?? uid();
    _name = TextEditingController(text: src?.name ?? '');
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
    if (_steps.isEmpty) return context.showToast(l.routineTapHint);
    if (_name.text.trim().isEmpty) return context.showToast(l.routineGiveName);
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

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final stretchTechs = store.data.techniques
        .where((t) => t.category == TechniqueCategory.stretching)
        .toList();

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
                        final left = _RoutineStepsPanel(
                          nameController: _name,
                          steps: _steps,
                          onReorder: (a, b) => setState(() {
                            final tmp = _steps[a];
                            _steps[a] = _steps[b];
                            _steps[b] = tmp;
                          }),
                          onRemove: (i) => setState(() => _steps.removeAt(i)),
                        );
                        final right = _StretchPanel(
                          techs: stretchTechs,
                          lang: lang,
                          onPick: (tech) => setState(() => _steps.add(tech.id)),
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

class _RoutineStepsPanel extends StatelessWidget {
  final TextEditingController nameController;
  final List<String> steps;
  final void Function(int, int) onReorder;
  final void Function(int) onRemove;
  const _RoutineStepsPanel({
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
    Technique? techOf(String id) =>
        store.data.techniques.where((t) => t.id == id).firstOrNull;

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
            l.routineExercisesCount(steps.length),
            style: const TextStyle(fontSize: 11, color: AppColors.mut),
          ),
          const SizedBox(height: 10),
          if (steps.isEmpty)
            Text(
              l.routineTapHint,
              style: const TextStyle(fontSize: 12.5, color: AppColors.mut),
            )
          else
            ...List.generate(steps.length, (i) {
              final tech = techOf(steps[i]);
              final img = tech != null ? stretchImageFor(tech.id) : null;
              return Container(
                margin: const EdgeInsets.only(bottom: 6),
                padding: const EdgeInsets.fromLTRB(10, 8, 4, 8),
                decoration: BoxDecoration(
                  color: AppColors.panel2,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppColors.line),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: AppColors.panel,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: img != null
                          ? SvgPicture.asset(img, width: 32, height: 32)
                          : const SizedBox.shrink(),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        (tech?.nameIn(lang) ?? l.sessionUnknown).toUpperCase(),
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

class _StretchPanel extends StatelessWidget {
  final List<Technique> techs;
  final Lang lang;
  final ValueChanged<Technique> onPick;
  const _StretchPanel({
    required this.techs,
    required this.lang,
    required this.onPick,
  });

  @override
  Widget build(BuildContext context) {
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(categoryLabel(TechniqueCategory.stretching, lang)),
          const SizedBox(height: 4),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: [
              for (final tech in techs) ...[
                GestureDetector(
                  onTap: () => onPick(tech),
                  child: Container(
                    width: 108,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.panel2,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Column(
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: AppColors.panel,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: stretchImageFor(tech.id) != null
                              ? SvgPicture.asset(
                                  stretchImageFor(tech.id)!,
                                  width: 40,
                                  height: 40,
                                )
                              : const SizedBox.shrink(),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          tech.shortIn(lang).toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
