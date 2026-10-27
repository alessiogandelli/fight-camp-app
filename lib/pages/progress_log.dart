// The complete training log, embedded below the Progress overview.
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/progress_stats.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../training/training.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../ui/workout_colors.dart';
import '../widgets/training_card.dart';

class ProgressLog extends StatelessWidget {
  final List<Training> trainings;
  final String? selectedDayKey;
  final String query;
  final Set<WorkoutType> types;
  final TrainingSourceFilter source;
  final ValueChanged<WorkoutType> onToggleType;
  final ValueChanged<Training> onOpenTraining;
  final VoidCallback onClearFilters;

  const ProgressLog({
    super.key,
    required this.trainings,
    required this.selectedDayKey,
    required this.query,
    required this.types,
    required this.source,
    required this.onToggleType,
    required this.onOpenTraining,
    required this.onClearFilters,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final filtered = filterTrainings(
      trainings,
      query: query,
      types: types,
      source: source,
      dayKey: selectedDayKey,
    );

    final availableTypes = <WorkoutType>{
      for (final t in trainings)
        for (final s in t.sessions) s.type,
    };
    final typeOptions = [
      for (final wt in workoutTypes)
        if (availableTypes.contains(wt.id)) wt,
    ];

    final groups = <String, List<Training>>{};
    for (final training in filtered) {
      final key = dateKey(DateTime.fromMillisecondsSinceEpoch(training.start));
      groups.putIfAbsent(key, () => []).add(training);
    }

    final allActive =
        types.isEmpty &&
        selectedDayKey == null &&
        query.trim().isEmpty &&
        source == TrainingSourceFilter.all;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SectionTitle(l.progressLog),
        SizedBox(
          height: 38,
          child: ListView(
            scrollDirection: Axis.horizontal,
            children: [
              _FilterPill(
                key: const ValueKey('log-filter-all'),
                label: l.commonAll,
                active: allActive,
                onTap: onClearFilters,
              ),
              if (selectedDayKey != null) ...[
                const SizedBox(width: 7),
                _FilterPill(
                  key: const ValueKey('log-filter-selected-day'),
                  label: dayLabel(
                    trainings
                        .firstWhere(
                          (t) =>
                              dateKey(
                                DateTime.fromMillisecondsSinceEpoch(t.start),
                              ) ==
                              selectedDayKey,
                          orElse: () => trainings.first,
                        )
                        .start,
                    lang,
                  ),
                  active: true,
                  color: kProgressBlue,
                  trailing: Icons.close_rounded,
                  onTap: onClearFilters,
                ),
              ],
              for (final wt in typeOptions) ...[
                const SizedBox(width: 7),
                _FilterPill(
                  key: ValueKey('log-filter-${wt.id.json}'),
                  label: workoutTypeLabel(wt.id, lang),
                  active: types.contains(wt.id),
                  color: progressTypeColor(wt.id),
                  onTap: () => onToggleType(wt.id),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        if (filtered.isEmpty)
          EmptyState(
            title: l.progressNoMatchingTrainings,
            message: l.progressNoMatchingMsg,
            action: Button(
              label: l.progressResetFilters,
              size: BtnSize.sm,
              onTap: onClearFilters,
            ),
          )
        else
          for (final group in groups.entries) ...[
            Padding(
              padding: const EdgeInsets.only(top: 10, bottom: 6, left: 2),
              child: Text(
                dayLabel(group.value.first.start, lang),
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1.2,
                  color: AppColors.mut,
                ),
              ),
            ),
            for (final training in group.value)
              TrainingLogTile(
                key: ValueKey('log-training-${training.id}'),
                training: training,
                onTap: () => onOpenTraining(training),
              ),
          ],
      ],
    );
  }
}

class _FilterPill extends StatelessWidget {
  final String label;
  final bool active;
  final Color? color;
  final IconData? trailing;
  final VoidCallback onTap;

  const _FilterPill({
    super.key,
    required this.label,
    required this.active,
    required this.onTap,
    this.color,
    this.trailing,
  });

  @override
  Widget build(BuildContext context) {
    final foreground = active ? Colors.black : AppColors.ink;
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.fromLTRB(
          color == null ? 16 : 12,
          0,
          trailing == null ? 16 : 9,
          0,
        ),
        decoration: BoxDecoration(
          color: active ? AppColors.ink : AppColors.panel,
          borderRadius: BorderRadius.circular(AppSpacing.pill),
          border: Border.all(color: active ? AppColors.ink : AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            if (color != null) ...[
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(color: color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 7),
            ],
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w700,
                color: foreground,
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 4),
              Icon(trailing, size: 14, color: foreground),
            ],
          ],
        ),
      ),
    );
  }
}
