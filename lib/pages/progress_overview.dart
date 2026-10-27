// Progress overview: the compact training dashboard above the Log.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/progress_stats.dart';
import '../lib/stats.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../training/training.dart';
import '../ui/theme.dart';
import '../ui/workout_colors.dart';

const int kWeeklyActiveDayGoal = 4;

class ProgressOverview extends StatelessWidget {
  final ProgressPeriod period;
  final List<Training> trainings;
  final List<Training> previousTrainings;
  final String? selectedDayKey;
  final ValueChanged<String?> onSelectDay;
  final ValueChanged<WorkoutType> onOpenType;
  final VoidCallback onSortUncategorized;

  const ProgressOverview({
    super.key,
    required this.period,
    required this.trainings,
    required this.previousTrainings,
    required this.selectedDayKey,
    required this.onSelectDay,
    required this.onOpenType,
    required this.onSortUncategorized,
  });

  @override
  Widget build(BuildContext context) {
    final summary = summarizeProgress(trainings);
    final days = progressDaysByKey(trainings);
    final mix = trainingMix(trainings);
    final metricWeeks = period.weeks > 0
        ? period.weeks
        : weeksSpannedBy(period, trainings);
    final goal = periodGoalStats(trainings, period);
    final load = periodLoadStats(trainings, weeks: metricWeeks);
    final previousLoad = periodLoadStats(previousTrainings, weeks: metricWeeks);
    final uncategorized = uncategorizedSessions(trainings).length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _Summary(
          summary: summary,
          range: period.range,
          previousWorkouts: previousTrainings.isEmpty
              ? null
              : previousTrainings.length,
        ),
        const SizedBox(height: AppSpacing.lg),
        SizedBox(
          height: 172,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: _GoalCard(stats: goal)),
              const SizedBox(width: 12),
              Expanded(
                child: _LoadCard(
                  load: load,
                  previous: previousLoad,
                  range: period.range,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _ActivityCard(
          period: period,
          trainings: trainings,
          days: days,
          selectedDayKey: selectedDayKey,
          onSelectDay: onSelectDay,
        ),
        if (mix.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.md),
          _MixCard(rows: mix, onOpenType: onOpenType),
        ],
        if (uncategorized > 0) ...[
          const SizedBox(height: AppSpacing.md),
          _UncategorizedBanner(
            count: uncategorized,
            onTap: onSortUncategorized,
          ),
        ],
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _Summary extends StatelessWidget {
  final ProgressSummary summary;
  final StatsRange range;
  final int? previousWorkouts;

  const _Summary({
    required this.summary,
    required this.range,
    required this.previousWorkouts,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final diff = previousWorkouts == null
        ? null
        : summary.workouts - previousWorkouts!;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              flex: 7,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.statsTrainingTime.toUpperCase(),
                    style: AppText.overline,
                  ),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      fmtDurationHuman(summary.durationSec),
                      style: const TextStyle(
                        fontSize: 43,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -1.2,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _SideMetric(
                  value: '${summary.workouts}',
                  label: l.progressWorkouts,
                ),
                const SizedBox(height: 12),
                _SideMetric(
                  value: '${summary.activeDays}',
                  label: l.progressActiveDaysLabel,
                ),
              ],
            ),
          ],
        ),
        if (range != StatsRange.all) ...[
          const SizedBox(height: 10),
          Row(
            children: [
              if (diff != null && diff != 0) ...[
                Icon(
                  diff > 0
                      ? Icons.arrow_upward_rounded
                      : Icons.arrow_downward_rounded,
                  size: 15,
                  color: diff > 0 ? AppColors.success : AppColors.mut,
                ),
                const SizedBox(width: 3),
                Text(
                  '${diff > 0 ? '+' : ''}$diff',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    color: diff > 0 ? AppColors.success : AppColors.mut,
                    fontFeatures: const [FontFeature.tabularFigures()],
                  ),
                ),
                const SizedBox(width: 5),
              ],
              Expanded(
                child: Text(
                  diff == null
                      ? l.progressNoPreviousPeriod
                      : diff == 0
                      ? l.progressSameAsPrevious
                      : range == StatsRange.week
                      ? l.progressVsPreviousWeek
                      : l.progressVsPrevious4Weeks,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppColors.mut,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ],
      ],
    );
  }
}

class _SideMetric extends StatelessWidget {
  final String value;
  final String label;
  const _SideMetric({required this.value, required this.label});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 24,
          height: 0.95,
          fontWeight: FontWeight.w900,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label.toUpperCase(),
        textAlign: TextAlign.right,
        style: AppText.overline,
      ),
    ],
  );
}

class _GoalCard extends StatelessWidget {
  final PeriodGoalStats stats;
  const _GoalCard({required this.stats});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final store = context.watch<AppStore>();
    final progress = (stats.averageActiveDays / stats.goal).clamp(0.0, 1.0);
    final filled = (progress * 4).round();
    final average = _decimal(
      stats.averageActiveDays,
      store.lang == Lang.it ? ',' : '.',
    );
    final averageLabel = stats.averageActiveDays == 1
        ? l.progressAverageActiveDay(average)
        : l.progressAverageActiveDays(average);
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l.progressWeeklyGoal.toUpperCase(), style: AppText.overline),
          const SizedBox(height: 5),
          Text(
            stats.weeks == 1 ? l.progressActiveDays(stats.goal) : averageLabel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
          ),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (var i = 0; i < 4; i++) ...[
                if (i > 0) const SizedBox(width: 5),
                Container(
                  width: 9,
                  height: 24,
                  decoration: BoxDecoration(
                    color: i < filled ? AppColors.ink : AppColors.line,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ],
              const Spacer(),
              Text(
                l.progressGoalProgress(
                  _decimal(
                    stats.averageActiveDays,
                    Localizations.localeOf(context).languageCode == 'it'
                        ? ','
                        : '.',
                  ),
                  '${stats.goal}',
                ),
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.mut,
                  fontWeight: FontWeight.w700,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          if (stats.weeks > 1) ...[
            const SizedBox(height: 4),
            Text(
              l.progressWeeksOnGoal(stats.weeksOnGoal, stats.weeks),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 10, color: AppColors.mut),
            ),
          ],
        ],
      ),
    );
  }
}

class _LoadCard extends StatelessWidget {
  final PeriodLoadStats load;
  final PeriodLoadStats previous;
  final StatsRange range;
  const _LoadCard({
    required this.load,
    required this.previous,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = switch (range) {
      StatsRange.week => l.progressLoadWeek,
      StatsRange.weeks4 => l.progressLoad4Weeks,
      StatsRange.all => l.progressLoadAll,
    };
    final hasData = load.measuredSessions > 0;
    final value = hasData ? '${load.weeklyAverage.round()}' : '—';
    final comparison = !hasData
        ? l.progressNoLoadData
        : !load.hasEnoughData
        ? l.progressLoadInsufficient
        : range == StatsRange.all || previous.weeklyAverage <= 0
        ? l.progressLoadCoverage(load.measuredSessions, load.totalSessions)
        : _deltaLabel(load.weeklyAverage, previous.weeklyAverage, range, l);
    final barRatio = load.coverage.clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(label.toUpperCase(), style: AppText.overline),
              ),
              Tooltip(
                message: l.progressLoadFormula,
                triggerMode: TooltipTriggerMode.tap,
                child: Icon(
                  Icons.info_outline_rounded,
                  size: 13,
                  color: AppColors.mut,
                ),
              ),
            ],
          ),
          const Spacer(),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 29,
                height: 1,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          const SizedBox(height: 3),
          Text(
            comparison,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: AppColors.mut),
          ),
          if (hasData && load.hasEnoughData) ...[
            const SizedBox(height: 3),
            Text(
              l.progressLoadCoverage(load.measuredSessions, load.totalSessions),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(fontSize: 9.5, color: AppColors.mut),
            ),
          ],
          const SizedBox(height: 7),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.pill),
            child: LinearProgressIndicator(
              value: barRatio,
              minHeight: 5,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation(
                load.hasEnoughData ? kProgressAmber : AppColors.mut,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _deltaLabel(
    double current,
    double previous,
    StatsRange range,
    AppLocalizations l,
  ) {
    final delta = ((current - previous) / previous * 100).round();
    final sign = delta > 0 ? '+' : '';
    final suffix = range == StatsRange.week
        ? l.progressVsPreviousWeek
        : l.progressVsPrevious4Weeks;
    return '$sign$delta% $suffix';
  }
}

class _ActivityCard extends StatelessWidget {
  final ProgressPeriod period;
  final List<Training> trainings;
  final Map<String, ProgressDay> days;
  final String? selectedDayKey;
  final ValueChanged<String?> onSelectDay;

  const _ActivityCard({
    required this.period,
    required this.trainings,
    required this.days,
    required this.selectedDayKey,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final currentWeek = startOfWeek(now);
    final calendarStart = period.range == StatsRange.all
        ? currentWeek.subtract(const Duration(days: 49))
        : period.start!;
    final weeks = period.range == StatsRange.all ? 8 : period.weeks;
    final showToday = period.current.contains(now.millisecondsSinceEpoch);
    final todayKey = showToday ? dateKey(now) : '';

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.progressActivity.toUpperCase(), style: AppText.overline),
          const SizedBox(height: 2),
          Text(
            l.progressTapDayFilter,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: AppColors.mut),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const SizedBox(width: 58),
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    weekdayShort(
                      _plusDays(calendarStart, i),
                      store.lang,
                    ).substring(0, 1),
                    textAlign: TextAlign.center,
                    style: AppText.micro,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 3),
          for (var w = 0; w < weeks; w++)
            _WeekRow(
              weekStart: _plusDays(calendarStart, w * 7),
              label:
                  showToday &&
                      dateKey(_plusDays(calendarStart, w * 7)) ==
                          dateKey(currentWeek)
                  ? l.progressThisWeekShort
                  : _weekLabel(_plusDays(calendarStart, w * 7), store.lang),
              days: days,
              todayKey: todayKey,
              selectedDayKey: selectedDayKey,
              onSelectDay: onSelectDay,
            ),
        ],
      ),
    );
  }

  String _weekLabel(DateTime start, Lang lang) {
    return DateFormat.MMMd(lang == Lang.it ? 'it_IT' : 'en_US').format(start);
  }
}

DateTime _plusDays(DateTime date, int days) =>
    DateTime(date.year, date.month, date.day + days);

class _WeekRow extends StatelessWidget {
  final DateTime weekStart;
  final String label;
  final Map<String, ProgressDay> days;
  final String todayKey;
  final String? selectedDayKey;
  final ValueChanged<String?> onSelectDay;

  const _WeekRow({
    required this.weekStart,
    required this.label,
    required this.days,
    required this.todayKey,
    required this.selectedDayKey,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) => SizedBox(
    height: 41,
    child: Row(
      children: [
        SizedBox(
          width: 58,
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontSize: 10.5, color: AppColors.mut),
          ),
        ),
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _DayCell(
              date: _plusDays(weekStart, i),
              day: days[dateKey(_plusDays(weekStart, i))],
              todayKey: todayKey,
              selectedDayKey: selectedDayKey,
              onSelectDay: onSelectDay,
            ),
          ),
      ],
    ),
  );
}

class _DayCell extends StatelessWidget {
  final DateTime date;
  final ProgressDay? day;
  final String todayKey;
  final String? selectedDayKey;
  final ValueChanged<String?> onSelectDay;

  const _DayCell({
    required this.date,
    required this.day,
    required this.todayKey,
    required this.selectedDayKey,
    required this.onSelectDay,
  });

  @override
  Widget build(BuildContext context) {
    final key = dateKey(date);
    final today = key == todayKey;
    final selected = key == selectedDayKey;
    final future = date.isAfter(DateTime.now()) && !today;
    final active = day != null && day!.workouts > 0;
    final slices = day == null
        ? const <({Color color, int weight})>[]
        : progressDaySlices(day!.typeSeconds);

    final circle = Container(
      width: 31,
      height: 31,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: active ? null : AppColors.panel2,
        border: Border.all(
          color: selected
              ? AppColors.ink
              : today
              ? kProgressCyan
              : Colors.transparent,
          width: selected || today ? 1.7 : 0,
        ),
      ),
      child: active ? CustomPaint(painter: _DaySlicesPainter(slices)) : null,
    );

    if (!active || future) {
      return KeyedSubtree(
        key: ValueKey('progress-day-$key'),
        child: Opacity(
          opacity: future ? 0.32 : 1,
          child: Center(child: circle),
        ),
      );
    }
    return GestureDetector(
      key: ValueKey('progress-day-$key'),
      behavior: HitTestBehavior.opaque,
      onTap: () => onSelectDay(selected ? null : key),
      child: Center(child: circle),
    );
  }
}

class _DaySlicesPainter extends CustomPainter {
  final List<({Color color, int weight})> slices;
  const _DaySlicesPainter(this.slices);

  @override
  void paint(Canvas canvas, Size size) {
    if (slices.isEmpty) return;
    final rect = Offset.zero & size;
    final inset = rect.deflate(2);
    if (slices.length == 1) {
      canvas.drawOval(inset, Paint()..color = slices.first.color);
      return;
    }
    final total = slices.fold<int>(0, (sum, slice) => sum + slice.weight);
    var start = -math.pi / 2;
    for (final slice in slices) {
      final sweep = math.pi * 2 * (slice.weight / total);
      canvas.drawArc(inset, start, sweep, true, Paint()..color = slice.color);
      start += sweep;
    }
  }

  @override
  bool shouldRepaint(covariant _DaySlicesPainter oldDelegate) =>
      oldDelegate.slices != slices;
}

class _MixCard extends StatelessWidget {
  final List<TrainingMixRow> rows;
  final ValueChanged<WorkoutType> onOpenType;
  const _MixCard({required this.rows, required this.onOpenType});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final total = rows.fold<int>(0, (sum, row) => sum + row.durationSec);

    return Container(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.progressTrainingMix.toUpperCase(), style: AppText.overline),
          const SizedBox(height: 12),
          if (total > 0)
            ClipRRect(
              borderRadius: BorderRadius.circular(AppSpacing.pill),
              child: SizedBox(
                height: 7,
                child: Row(
                  children: [
                    for (final row in rows)
                      Expanded(
                        flex: row.durationSec.clamp(1, 1 << 30),
                        child: ColoredBox(color: progressTypeColor(row.type)),
                      ),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 14),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const SizedBox(height: 9),
            InkWell(
              key: ValueKey('progress-mix-${rows[i].type.json}'),
              onTap: () => onOpenType(rows[i].type),
              child: Row(
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: progressTypeColor(rows[i].type),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 9),
                  Expanded(
                    child: Text(
                      workoutTypeLabel(rows[i].type, lang),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    fmtDurationHuman(rows[i].durationSec),
                    style: TextStyle(
                      fontSize: 12,
                      color: AppColors.mut,
                      fontWeight: FontWeight.w600,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _UncategorizedBanner extends StatelessWidget {
  final int count;
  final VoidCallback onTap;
  const _UncategorizedBanner({required this.count, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return CustomPaint(
      foregroundPainter: _DashedBorderPainter(
        color: AppColors.line,
        radius: 15,
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 0, 8, 0),
        child: Row(
          children: [
            Expanded(
              child: Text(
                l.progressUncategorized(count),
                style: const TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            TextButton(
              onPressed: onTap,
              style: TextButton.styleFrom(
                foregroundColor: AppColors.primary,
                minimumSize: const Size(0, 44),
              ),
              child: Text(
                l.progressSortThem,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double radius;
  const _DashedBorderPainter({required this.color, required this.radius});

  @override
  void paint(Canvas canvas, Size size) {
    final path = Path()
      ..addRRect(
        RRect.fromRectAndRadius(Offset.zero & size, Radius.circular(radius)),
      );
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;
    for (final metric in path.computeMetrics()) {
      var distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + 5, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += 9;
      }
    }
  }

  @override
  bool shouldRepaint(covariant _DashedBorderPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.radius != radius;
}

String _decimal(double value, String separator) {
  if (value % 1 == 0) return value.toStringAsFixed(0);
  return value.toStringAsFixed(1).replaceAll('.', separator);
}
