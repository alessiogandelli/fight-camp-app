// Workouts page: saved single-configuration workouts (ADR 0003).
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
import '../ui/workout_icons.dart';
import '../l10n/app_localizations.dart';
import 'workout_builder_page.dart';

Future<void> _openWorkoutBuilder(
  BuildContext context, {
  String? workoutId,
}) async {
  final store = context.read<AppStore>();
  final l = AppLocalizations.of(context)!;
  final result = await showWorkoutBuilderSheet(context, workoutId: workoutId);
  if (!context.mounted || result == null) return;
  context.showToast(l.builderSaved);
  if (result.start) {
    context.push(
      '/live',
      extra: LiveArgs(
        configFromWorkout(
          result.workout,
          store.data.combinations,
          store.data.techniques,
          store.data.settings.prepSeconds,
        ),
        autostart: true,
      ),
    );
  }
}

class WorkoutsPage extends StatelessWidget {
  const WorkoutsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final workouts = [...store.data.workouts]
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));

    return Stack(
      children: [
        SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            16,
            MediaQuery.paddingOf(context).top + kAppHeaderHeight + 8,
            16,
            glassNavClearance(context) + 72,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 768),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  SectionTitle(l.workoutsTitle),
                  const SizedBox(height: 4),
                  if (workouts.isEmpty)
                    EmptyState(
                      title: l.workoutsEmpty,
                      message: l.workoutsEmptyMsg,
                      action: Button(
                        label: l.workoutsCreate,
                        icon: Icons.add,
                        size: BtnSize.sm,
                        onTap: () => _openWorkoutBuilder(context),
                      ),
                    )
                  else ...[
                    for (var i = 0; i < workouts.length; i++) ...[
                      if (i > 0) const SizedBox(height: AppSpacing.sm + 4),
                      _WorkoutCard(workout: workouts[i]),
                    ],
                  ],
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: glassNavClearance(context) - 8,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: AppColors.primary,
            foregroundColor: Colors.white,
            tooltip: l.workoutsCreate,
            onPressed: () => _openWorkoutBuilder(context),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatelessWidget {
  final Workout workout;
  const _WorkoutCard({required this.workout});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final totals = workoutTotals(workout);

    Future<bool> confirmDelete() async {
      final ok = await showConfirm(
        context,
        title: l.workoutsDeleteTitle,
        message: l.workoutsDeleteMsg(workout.name),
        cancelLabel: l.commonCancel,
        confirmLabel: l.commonDelete,
      );
      if (ok) {
        final before = store.snapshot;
        store.deleteWorkout(workout.id);
        if (context.mounted) {
          context.showToast(
            l.workoutsDeleted,
            actionLabel: l.commonUndo,
            onAction: () => store.restore(before),
          );
        }
      }
      return ok;
    }

    return Dismissible(
      key: ValueKey(workout.id),
      direction: DismissDirection.endToStart,
      confirmDismiss: (_) => confirmDelete(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.error.withAlpha(38),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.error.withAlpha(140)),
        ),
        child: Icon(Icons.delete_outline, color: AppColors.error),
      ),
      child: ActionCard(
        icon: workoutIconFor(workout, type: store.workoutTypeOf(workout)),
        title: workout.name,
        meta:
            '${workoutTypeLabel(store.workoutTypeOf(workout), store.lang)} · '
            '${totals.total > 0 ? fmtClock(totals.total) : '—'}',
        body: _WorkoutBody(workout: workout),
        playLabel: l.commonStart,
        menuTitle: l.commonActions,
        onPlay: () => context.push(
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
        ),
        onTap: () => _openWorkoutBuilder(context, workoutId: workout.id),
        menu: [
          CardMenuAction(
            label: l.commonDuplicate,
            icon: Icons.copy_rounded,
            onTap: () {
              final copy = store.duplicateWorkout(workout.id);
              context.showToast(
                copy != null ? l.workoutsDuplicated : l.comboNotFoundMsg,
              );
            },
          ),
          CardMenuAction(
            label: l.commonEdit,
            icon: Icons.edit_outlined,
            onTap: () => _openWorkoutBuilder(context, workoutId: workout.id),
          ),
        ],
      ),
    );
  }
}

/// The card body: for a conditioning workout that references a circuit, lists
/// the exercises with their reps; otherwise the compact time summary.
class _WorkoutBody extends StatelessWidget {
  final Workout workout;
  const _WorkoutBody({required this.workout});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final techById = {for (final t in store.data.techniques) t.id: t};
    final labels = <String>[];
    for (final cid in workout.combinationIds) {
      Combination? circuit;
      for (final c in store.data.combinations) {
        if (c.id == cid) {
          circuit = c;
          break;
        }
      }
      if (circuit == null || !store.isCircuit(circuit)) continue;
      for (var i = 0; i < circuit.techniqueIds.length; i++) {
        final t = techById[circuit.techniqueIds[i]];
        if (t == null) continue;
        final r = circuit.repsAt(i);
        labels.add(r != null ? '${t.shortIn(lang)} ×$r' : t.shortIn(lang));
      }
    }
    if (labels.isEmpty) {
      return Text(
        summarizeWorkout(workout, l),
        style: TextStyle(fontSize: 11.5, color: AppColors.mut),
      );
    }
    return Wrap(
      crossAxisAlignment: WrapCrossAlignment.center,
      spacing: 5,
      runSpacing: 4,
      children: [
        for (var i = 0; i < labels.length; i++) ...[
          Text(
            labels[i],
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w700,
              color: AppColors.mut,
            ),
          ),
          if (i < labels.length - 1)
            Text('→', style: TextStyle(fontSize: 10, color: AppColors.mut)),
        ],
      ],
    );
  }
}
