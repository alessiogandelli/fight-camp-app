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
import '../l10n/app_localizations.dart';

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
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
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
                        onTap: () => context.go('/workouts/new'),
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
          bottom: 20,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            tooltip: l.workoutsCreate,
            onPressed: () => context.go('/workouts/new'),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}

class _WorkoutCard extends StatefulWidget {
  final Workout workout;
  const _WorkoutCard({required this.workout});

  @override
  State<_WorkoutCard> createState() => _WorkoutCardState();
}

class _WorkoutCardState extends State<_WorkoutCard> {
  bool _down = false;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final workout = widget.workout;
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
          color: AppColors.accent.withAlpha(38),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.accent.withAlpha(140)),
        ),
        child: const Icon(Icons.delete_outline, color: AppColors.accent),
      ),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _down = true),
        onTapCancel: () => setState(() => _down = false),
        onTapUp: (_) => setState(() => _down = false),
        onTap: () => context.go('/workouts/${workout.id}'),
        child: ScaleTransition(
          scale: AlwaysStoppedAnimation(_down ? 0.98 : 1.0),
          child: CardWidget(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      workoutTypeMeta(workout.type).icon,
                      style: const TextStyle(fontSize: 18),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        workout.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 13.5,
                          letterSpacing: 0.6,
                        ),
                      ),
                    ),
                    Text(
                      totals.total > 0 ? fmtClock(totals.total) : '—',
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.mut,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  summarizeWorkout(workout, l),
                  style: const TextStyle(fontSize: 11.5, color: AppColors.mut),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Button(
                      label: l.commonStart,
                      size: BtnSize.sm,
                      onTap: () => context.push(
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
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    IconButton2(
                      Icons.copy_rounded,
                      onTap: () {
                        final copy = store.duplicateWorkout(workout.id);
                        context.showToast(
                          copy != null
                              ? l.workoutsDuplicated
                              : l.comboNotFoundMsg,
                        );
                      },
                    ),
                    const Spacer(),
                    Text(
                      l.commonEdit.toUpperCase(),
                      style: const TextStyle(
                        fontSize: 10.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.8,
                        color: AppColors.mut,
                      ),
                    ),
                    const Icon(
                      Icons.chevron_right_rounded,
                      size: 16,
                      color: AppColors.mut,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
