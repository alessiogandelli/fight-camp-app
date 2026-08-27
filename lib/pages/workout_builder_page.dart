// Workout builder page ported from src/pages/WorkoutBuilderPage.tsx.
// Rebuilt around the blocks model (ADR 0002).
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_args.dart';
import '../data/store.dart';
import '../lib/format.dart';
import '../lib/session.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../widgets/combo_picker.dart';
import '../l10n/app_localizations.dart';

class WorkoutBuilderPage extends StatefulWidget {
  final String? workoutId;
  const WorkoutBuilderPage({super.key, this.workoutId});

  @override
  State<WorkoutBuilderPage> createState() => _WorkoutBuilderPageState();
}

class _WorkoutBuilderPageState extends State<WorkoutBuilderPage> {
  late String _id;
  bool _exists = true;
  late final TextEditingController _name;
  WorkoutType _type = WorkoutType.heavyBag;
  List<WorkoutBlock> _blocks = [];
  final Set<String> _expanded = {};

  @override
  void initState() {
    super.initState();
    final store = context.read<AppStore>();
    Workout? src;
    if (widget.workoutId != null) {
      for (final w in store.data.workouts) {
        if (w.id == widget.workoutId) src = w;
      }
    }
    _exists = src != null || widget.workoutId == null;
    _id = src?.id ?? uid();
    _name = TextEditingController(text: src?.name ?? '');
    _type = src?.type ?? WorkoutType.heavyBag;
    if (src != null) {
      _blocks = [for (final b in src.blocks) b.copyWith()];
    } else {
      _blocks = [_defaultBlock(BlockType.round)];
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  WorkoutBlock _defaultBlock(BlockType type) => switch (type) {
        BlockType.round => WorkoutBlock(id: uid(), type: type, rounds: 3, duration: 120, restDuration: 60),
        BlockType.circuit => WorkoutBlock(id: uid(), type: type, rounds: 8, duration: 20, restDuration: 10),
        BlockType.aerobic => WorkoutBlock(id: uid(), type: type, duration: 600),
        BlockType.stretching => WorkoutBlock(id: uid(), type: type, duration: 600),
        BlockType.free => WorkoutBlock(id: uid(), type: type, duration: 300),
      };

  Future<void> _addBlock() async {
    final lang = context.read<AppStore>().lang;
    final l = AppLocalizations.of(context)!;
    final picked = await showAppModal<BlockType>(
      context,
      title: l.builderBlockType,
      builder: (ctx) => Column(
        children: [
          for (final bt in blockTypes)
            Container(
              margin: const EdgeInsets.only(bottom: 8),
              child: GestureDetector(
                onTap: () => Navigator.pop(ctx, bt.id),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.panel2,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.line),
                  ),
                  child: Row(
                    children: [
                      Text(bt.icon, style: const TextStyle(fontSize: 18)),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(child: Text(blockTypeLabel(bt.id, lang), style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13.5))),
                      const Icon(Icons.chevron_right, color: AppColors.mut),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
    if (picked != null && mounted) {
      setState(() {
        final b = _defaultBlock(picked);
        _blocks.add(b);
        _expanded.add(b.id);
      });
    }
  }

  void _move(int index, int delta) {
    final j = index + delta;
    if (j < 0 || j >= _blocks.length) return;
    setState(() {
      final tmp = _blocks[index];
      _blocks[index] = _blocks[j];
      _blocks[j] = tmp;
    });
  }

  String _blockSummary(WorkoutBlock b, Lang lang) {
    final l = AppLocalizations.of(context)!;
    switch (b.type) {
      case BlockType.round || BlockType.circuit:
        return '${b.rounds}×${fmtClock(b.duration)}${b.restDuration > 0 ? ' · ${fmtClock(b.restDuration)} ${l.sessionRest}' : ''}';
      case BlockType.aerobic || BlockType.stretching || BlockType.free:
        return fmtClock(b.duration);
    }
  }

  Future<void> _save({bool start = false}) async {
    final l = AppLocalizations.of(context)!;
    final store = context.read<AppStore>();
    if (_name.text.trim().isEmpty) return context.showToast(l.builderGiveName);
    if (_blocks.isEmpty) return context.showToast(l.builderAddRound);
    if (_blocks.any((b) => b.duration < 5)) return context.showToast(l.builderMinSeconds);

    final blocks = [
      for (final b in _blocks) b.copyWith(id: b.id.isEmpty ? uid() : b.id),
    ];
    final workout = Workout(
      id: _id,
      name: _name.text.trim().toUpperCase(),
      type: _type,
      createdAt: DateTime.now().millisecondsSinceEpoch,
      blocks: blocks,
    );
    store.saveWorkout(workout);
    if (!mounted) return;
    context.showToast(l.builderSaved);
    if (start) {
      context.pushReplacement('/live', extra: LiveArgs(configFromWorkout(workout, store.data.settings.prepSeconds)));
    } else {
      context.go('/workouts');
    }
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final totals = workoutTotals(Workout(id: _id, name: '', type: _type, blocks: _blocks, createdAt: 0));

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text((widget.workoutId == null ? l.builderNew : l.builderEdit).toUpperCase(),
                  style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 15, letterSpacing: 1)),
              if (!_exists)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(l.builderNotFound, style: const TextStyle(color: AppColors.warn, fontSize: 12.5)),
                ),
              const SizedBox(height: AppSpacing.md),
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Field(label: l.builderWorkoutName, child: TextInput(controller: _name, uppercase: true)),
                    const SizedBox(height: AppSpacing.sm + 4),
                    Field(
                      label: l.commonType,
                      child: Select<WorkoutType>(
                        value: _type,
                        options: [
                          for (final wt in workoutTypes)
                            if (wt.id != WorkoutType.running && wt.id != WorkoutType.strength)
                              (value: wt.id, label: '${wt.icon} ${workoutTypeLabel(wt.id, lang)}'),
                        ],
                        onChanged: (v) => setState(() => _type = v),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    Text(
                      l.builderWorkRest(fmtClock(totals.work), fmtClock(totals.rest)),
                      style: const TextStyle(fontSize: 11.5, color: AppColors.mut),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              ..._blockCards(store),
              Button(label: l.builderAddBlock, variant: BtnVariant.ghost, icon: Icons.add, onTap: _addBlock),
              const SizedBox(height: AppSpacing.lg),
              Row(children: [
                Expanded(child: Button(label: l.commonCancel, variant: BtnVariant.ghost, onTap: () => context.go('/workouts'))),
                const SizedBox(width: 10),
                Expanded(child: Button(label: l.builderSaveStart, onTap: () => _save(start: true))),
                const SizedBox(width: 10),
                Expanded(child: Button(label: l.commonSave, variant: BtnVariant.ghost, onTap: () => _save())),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  List<Widget> _blockCards(AppStore store) {
    final cards = <Widget>[];
    for (var i = 0; i < _blocks.length; i++) {
      cards.add(_blockCard(store, i));
      cards.add(const SizedBox(height: 10));
    }
    return cards;
  }

  Widget _blockCard(AppStore store, int i) {
    final lang = store.lang;
    final b = _blocks[i];
    final meta = blockTypeMeta(b.type);
    final open = _expanded.contains(b.id);
    return CardWidget(
      key: ValueKey(b.id),
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(meta.icon, style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Expanded(
                child: GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTap: () => setState(() => open ? _expanded.remove(b.id) : _expanded.add(b.id)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('${blockTypeLabel(b.type, lang).toUpperCase()} ${i + 1}',
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, letterSpacing: 1.2, color: AppColors.mut)),
                      const SizedBox(height: 2),
                      Text(_blockSummary(b, lang),
                          style: const TextStyle(fontSize: 13.5, fontWeight: FontWeight.w800, fontFeatures: [])),
                    ],
                  ),
                ),
              ),
              IconButton2(Icons.keyboard_arrow_up_rounded, size: 18, onTap: i > 0 ? () => _move(i, -1) : null),
              IconButton2(Icons.keyboard_arrow_down_rounded, size: 18, onTap: i < _blocks.length - 1 ? () => _move(i, 1) : null),
              IconButton2(Icons.copy_rounded, size: 18, onTap: () => setState(() => _blocks.insert(i + 1, b.copyWith(id: uid())))),
              IconButton2(Icons.delete_outline, size: 18, color: AppColors.accent, onTap: () => setState(() => _blocks.removeAt(i))),
              IconButton2(open ? Icons.expand_less : Icons.expand_more, size: 20,
                  onTap: () => setState(() => open ? _expanded.remove(b.id) : _expanded.add(b.id))),
            ],
          ),
          if (open) ...[
            const SizedBox(height: 12),
            ..._blockEditor(store, i),
          ],
        ],
      ),
    );
  }

  List<Widget> _blockEditor(AppStore store, int i) {
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final b = _blocks[i];
    void update(WorkoutBlock nb) => setState(() => _blocks[i] = nb);

    switch (b.type) {
      case BlockType.round:
      case BlockType.circuit:
        return [
          Field(label: l.builderSeries, child: NumStepper(value: b.rounds, min: 1, max: 30, onChanged: (v) => update(b.copyWith(rounds: v)))),
          const SizedBox(height: 12),
          Row(children: [
            Expanded(child: Field(label: l.commonWork, child: TimeField(value: b.duration, onChanged: (v) => update(b.copyWith(duration: v))))),
            const SizedBox(width: 10),
            Expanded(
              child: Field(
                label: l.builderRestAfter,
                child: TimeField(value: b.restDuration, min: 0, step: 15, onChanged: (v) => update(b.copyWith(restDuration: v))),
              ),
            ),
          ]),
          if (b.type == BlockType.round) ...[
            const SizedBox(height: 12),
            Button(
              label: b.combinationIds.isEmpty
                  ? l.builderSelectCombos
                  : '${l.builderSelected(b.combinationIds.length)} · ${l.commonEdit}',
              variant: BtnVariant.outline,
              size: BtnSize.sm,
              expanded: true,
              icon: Icons.format_list_numbered_rounded,
              onTap: () async {
                final sel = await showComboPicker(context, selected: b.combinationIds);
                if (sel != null && mounted) update(b.copyWith(combinationIds: sel));
              },
            ),
          ],
        ];
      case BlockType.stretching:
        final routines = store.data.combinations.where(store.isStretchRoutine).toList();
        final routine = routines.where((r) => b.combinationIds.contains(r.id)).firstOrNull;
        return [
          Field(label: l.commonDuration, child: TimeField(value: b.duration, min: 60, max: 3600, step: 60, onChanged: (v) => update(b.copyWith(duration: v)))),
          const SizedBox(height: 12),
          Field(
            label: l.builderChooseRoutine,
            child: Select<String>(
              value: routine?.id ?? '',
              options: [(value: '', label: l.commonNone), for (final r in routines) (value: r.id, label: r.name)],
              onChanged: (v) => update(b.copyWith(combinationIds: v.isEmpty ? const [] : [v])),
            ),
          ),
        ];
      case BlockType.aerobic:
      case BlockType.free:
        return [
          Field(label: l.commonDuration, child: TimeField(value: b.duration, min: 60, max: 7200, step: 60, onChanged: (v) => update(b.copyWith(duration: v)))),
          const SizedBox(height: 12),
          Field(label: l.builderFocusLabel, child: TextInput(uppercase: true, onChanged: (v) => update(b.copyWith(label: v)))),
        ];
    }
  }

}
