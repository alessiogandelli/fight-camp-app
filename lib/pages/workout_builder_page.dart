// Workout builder: timer editor (work/rest/rounds) + optional combos or
// routine (mutually exclusive). ADR 0003 — single uniform configuration.
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
  int _work = 180;
  int _rest = 60;
  int _rounds = 3;
  List<String> _comboIds = [];
  String? _routineId;

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
    if (src != null) {
      _work = src.workDuration;
      _rest = src.restDuration;
      _rounds = src.rounds;
      _comboIds = src.combinationIds.toList();
      _routineId = src.routineId;
    }
  }

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  bool get _hasRoutine => _routineId != null;

  Future<void> _save({bool start = false}) async {
    final l = AppLocalizations.of(context)!;
    final store = context.read<AppStore>();
    if (_name.text.trim().isEmpty) return context.showToast(l.builderGiveName);
    if (!_hasRoutine && _work < 5)
      return context.showToast(l.builderMinSeconds);

    final rounds = _hasRoutine ? _routineLength(store) : _rounds;
    final workout = Workout(
      id: _id,
      name: _name.text.trim().toUpperCase(),
      workDuration: _hasRoutine ? stretchWorkSeconds : _work,
      restDuration: _hasRoutine ? stretchRestSeconds : _rest,
      rounds: rounds < 1 ? 1 : rounds,
      combinationIds: _hasRoutine ? const [] : _comboIds,
      routineId: _routineId,
      createdAt: DateTime.now().millisecondsSinceEpoch,
    );
    store.saveWorkout(workout);
    if (!mounted) return;
    context.showToast(l.builderSaved);
    if (start) {
      context.pushReplacement(
        '/live',
        extra: LiveArgs(
          configFromWorkout(
            workout,
            store.data.combinations,
            store.data.techniques,
            store.data.settings.prepSeconds,
          ),
          autostart: true,
        ),
      );
    } else {
      context.go('/workouts');
    }
  }

  int _routineLength(AppStore store) {
    final routines = store.data.combinations
        .where(store.isStretchRoutine)
        .toList();
    final r = routines.where((c) => c.id == _routineId).firstOrNull;
    return r?.techniqueIds.length ?? 1;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final effective = Workout(
      id: _id,
      name: '',
      workDuration: _hasRoutine ? stretchWorkSeconds : _work,
      restDuration: _hasRoutine ? stretchRestSeconds : _rest,
      rounds: _hasRoutine ? _routineLength(store) : _rounds,
      combinationIds: _hasRoutine ? const [] : _comboIds,
      routineId: _routineId,
      createdAt: 0,
    );
    final totals = workoutTotals(effective);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 672),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                (widget.workoutId == null ? l.builderNew : l.builderEdit)
                    .toUpperCase(),
                style: const TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 15,
                  letterSpacing: 1,
                ),
              ),
              if (!_exists)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    l.builderNotFound,
                    style: const TextStyle(
                      color: AppColors.warn,
                      fontSize: 12.5,
                    ),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Field(
                      label: l.builderWorkoutName,
                      child: TextInput(controller: _name, uppercase: true),
                    ),
                    const SizedBox(height: AppSpacing.sm + 4),
                    Text(
                      '${workoutTypeMeta(effective.type).icon} ${workoutTypeLabel(effective.type, lang)}',
                      style: const TextStyle(
                        fontSize: 11.5,
                        color: AppColors.mut,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.4,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              CardWidget(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_hasRoutine) ...[
                      Text(
                        l.builderWorkRest(
                          fmtClock(effective.workDuration),
                          fmtClock(effective.restDuration),
                        ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.mut,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${effective.rounds} × ${fmtClock(effective.workDuration)}',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w900,
                          fontFeatures: [FontFeature.tabularFigures()],
                        ),
                      ),
                    ] else ...[
                      Row(
                        children: [
                          Expanded(
                            child: Field(
                              label: l.commonWork,
                              child: TimeField(
                                value: _work,
                                onChanged: (v) => setState(() => _work = v),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Field(
                              label: l.commonRest,
                              child: TimeField(
                                value: _rest,
                                min: 0,
                                step: 15,
                                onChanged: (v) => setState(() => _rest = v),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm + 4),
                      Field(
                        label: l.commonRounds,
                        child: NumStepper(
                          value: _rounds,
                          min: 1,
                          max: 30,
                          onChanged: (v) => setState(() => _rounds = v),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.sm + 4),
              if (!_hasRoutine)
                CardWidget(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Button(
                        label: _comboIds.isEmpty
                            ? l.builderSelectCombos
                            : '${l.builderSelected(_comboIds.length)} · ${l.commonEdit}',
                        variant: BtnVariant.outline,
                        size: BtnSize.sm,
                        expanded: true,
                        icon: Icons.format_list_numbered_rounded,
                        onTap: () async {
                          final sel = await showComboPicker(
                            context,
                            selected: _comboIds,
                          );
                          if (sel != null && mounted)
                            setState(() => _comboIds = sel);
                        },
                      ),
                      if (_comboIds.isNotEmpty) ...[
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 5,
                          runSpacing: 5,
                          children: [
                            for (final id in _comboIds)
                              ChipWidget(
                                label:
                                    store.data.combinations
                                        .where((c) => c.id == id)
                                        .firstOrNull
                                        ?.name ??
                                    id,
                                active: true,
                                onTap: () => setState(
                                  () => _comboIds = _comboIds
                                      .where((c) => c != id)
                                      .toList(),
                                ),
                              ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),
              if (!_hasRoutine) const SizedBox(height: AppSpacing.sm + 4),
              CardWidget(
                child: Field(
                  label: l.builderChooseRoutine,
                  child: Select<String>(
                    value: _routineId ?? '',
                    options: [
                      (value: '', label: l.commonNone),
                      for (final r in store.data.combinations.where(
                        store.isStretchRoutine,
                      ))
                        (value: r.id, label: r.name),
                    ],
                    onChanged: (v) => setState(() {
                      _routineId = v.isEmpty ? null : v;
                      if (v.isNotEmpty) _comboIds = const [];
                    }),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                l.builderWorkRest(fmtClock(totals.work), fmtClock(totals.rest)),
                style: const TextStyle(fontSize: 11.5, color: AppColors.mut),
              ),
              const SizedBox(height: AppSpacing.lg),
              Row(
                children: [
                  Expanded(
                    child: Button(
                      label: l.commonCancel,
                      variant: BtnVariant.ghost,
                      onTap: () => context.go('/workouts'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Button(
                      label: l.builderSaveStart,
                      onTap: () => _save(start: true),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Button(
                      label: l.commonSave,
                      variant: BtnVariant.ghost,
                      onTap: () => _save(),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
