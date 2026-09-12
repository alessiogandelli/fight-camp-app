// Training-analytics sections rendered inside the Progress page. The page owns
// the selected range; each section derives its own slice of the shared session
// list so the whole screen stays consistent.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

/// Fixed weekly target shown in the hero. Deliberately not configurable yet.
const int kWeeklyGoal = 4;

// ---------------------------------------------------------------------------
// 1. Weekly overview (hero)
// ---------------------------------------------------------------------------

/// Always the current calendar week: the stable "how much did I train" anchor
/// at the top of the page, independent of the analytics range below.
class WeeklyHero extends StatelessWidget {
  final List<SessionRecord> sessions;
  const WeeklyHero({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final current = sessionsInPeriod(
      sessions,
      periodFor(StatsRange.week, now: now),
    );
    final previous = sessionsInPeriod(
      sessions,
      previousPeriodFor(StatsRange.week, now: now)!,
    );
    final vol = volumeStats(current);
    final diff = vol.sessions - previous.length;
    final hasBaseline = previous.isNotEmpty;
    final reached = vol.sessions >= kWeeklyGoal;

    Widget comparison;
    if (!hasBaseline) {
      comparison = Text(
        l.progressFirstWeek.toUpperCase(),
        style: AppText.micro,
      );
    } else if (diff == 0) {
      comparison = Text(
        l.progressSameAsLastWeek.toUpperCase(),
        style: AppText.micro,
      );
    } else {
      final up = diff > 0;
      final color = up ? AppColors.go : AppColors.warn;
      comparison = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            up ? Icons.arrow_upward_rounded : Icons.arrow_downward_rounded,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 3),
          Text(
            '${up ? '+' : ''}$diff',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w900,
              color: color,
              fontFeatures: const [FontFeature.tabularFigures()],
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              l.progressVsLastWeek,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 10.5,
                color: AppColors.mut,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      );
    }

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(l.progressThisWeek.toUpperCase(), style: AppText.overline),
          const SizedBox(height: AppSpacing.xs),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '${vol.sessions}',
                style: const TextStyle(
                  fontSize: 44,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Flexible(
                child: Text(
                  l.unitSessions.toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.micro,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          comparison,
          const SizedBox(height: AppSpacing.md),
          const Divider(height: 1, color: AppColors.line),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _InlineStat(
                  label: l.progressTraining,
                  value: fmtMinutes(vol.minutes * 60),
                ),
              ),
              Expanded(
                child: _InlineStat(
                  label: l.statsRounds,
                  value: '${vol.rounds}',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: Text(
                  l.progressWeeklyGoal.toUpperCase(),
                  style: AppText.micro,
                ),
              ),
              Text(
                '${vol.sessions}/$kWeeklyGoal',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: reached ? AppColors.go : AppColors.mut,
                  fontFeatures: const [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xs),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppSpacing.pill),
            child: LinearProgressIndicator(
              value: (vol.sessions / kWeeklyGoal).clamp(0.0, 1.0),
              minHeight: 5,
              backgroundColor: AppColors.line,
              valueColor: AlwaysStoppedAnimation(
                reached ? AppColors.go : AppColors.accent,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 2. Consistency
// ---------------------------------------------------------------------------

/// Compact activity strip: one row per week, one marker per day. Trained days
/// are filled, planned days are outlined, today is ringed. Tapping an empty day
/// plans it, tapping a plan toggles it, long-pressing deletes it.
class ConsistencyCard extends StatelessWidget {
  final List<SessionRecord> sessions;
  final List<WeekPlanItem> plans;
  final StatsRange range;
  const ConsistencyCard({
    super.key,
    required this.sessions,
    required this.plans,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final lang = store.lang;
    final now = DateTime.now();
    final thisWeek = startOfWeek(now);
    final todayKey = dateKey(now);

    final trained = {
      for (final s in sessions)
        dateKey(DateTime.fromMillisecondsSinceEpoch(s.date)),
    };
    final planByDay = <String, WeekPlanItem>{
      for (final p in plans) p.dateKey: p,
    };

    final weeksToShow = _weeksToShow(sessions, range, thisWeek);
    final period = periodFor(range, now: now);
    final periodSessions = sessionsInPeriod(sessions, period);
    final activeDays = {
      for (final s in periodSessions)
        dateKey(DateTime.fromMillisecondsSinceEpoch(s.date)),
    }.length;

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(l.progressConsistency),
          Row(
            children: [
              const SizedBox(width: 34),
              for (var i = 0; i < 7; i++)
                Expanded(
                  child: Text(
                    weekdayShort(thisWeek.add(Duration(days: i)), lang),
                    textAlign: TextAlign.center,
                    style: AppText.micro,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          for (var w = weeksToShow - 1; w >= 0; w--) ...[
            _WeekRow(
              weekStart: thisWeek.subtract(Duration(days: w * 7)),
              label: w == 0 ? l.progressNow.toUpperCase() : 'W-$w',
              trained: trained,
              planByDay: planByDay,
              todayKey: todayKey,
              lang: lang,
              onTapDay: (day, plan) {
                if (plan != null) {
                  store.togglePlan(plan.id);
                } else {
                  _addPlan(context, store, lang, day);
                }
              },
              onLongPressPlan: (plan) => store.deletePlan(plan.id),
            ),
          ],
          const SizedBox(height: AppSpacing.sm),
          Text(
            '${l.progressActiveDays(activeDays)} · '
            '${periodSessions.length} '
            '${periodSessions.length == 1 ? l.unitSession : l.unitSessions}',
            style: const TextStyle(fontSize: 11, color: AppColors.mut),
          ),
        ],
      ),
    );
  }

  int _weeksToShow(
    List<SessionRecord> sessions,
    StatsRange range,
    DateTime thisWeek,
  ) {
    if (range == StatsRange.week) return 1;
    if (range == StatsRange.weeks4) return 4;
    if (sessions.isEmpty) return 1;
    final earliest = sessions
        .map((s) => startOfWeek(DateTime.fromMillisecondsSinceEpoch(s.date)))
        .reduce((a, b) => a.isBefore(b) ? a : b);
    final weeks = thisWeek.difference(earliest).inDays ~/ 7 + 1;
    return weeks.clamp(1, 8);
  }
}

class _WeekRow extends StatelessWidget {
  final DateTime weekStart;
  final String label;
  final Set<String> trained;
  final Map<String, WeekPlanItem> planByDay;
  final String todayKey;
  final Lang lang;
  final void Function(DateTime day, WeekPlanItem? plan) onTapDay;
  final void Function(WeekPlanItem plan) onLongPressPlan;

  const _WeekRow({
    required this.weekStart,
    required this.label,
    required this.trained,
    required this.planByDay,
    required this.todayKey,
    required this.lang,
    required this.onTapDay,
    required this.onLongPressPlan,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        SizedBox(width: 34, child: Text(label, style: AppText.micro)),
        for (var i = 0; i < 7; i++)
          Expanded(
            child: _DayCell(
              trained: trained.contains(
                dateKey(weekStart.add(Duration(days: i))),
              ),
              plan: planByDay[dateKey(weekStart.add(Duration(days: i)))],
              today: dateKey(weekStart.add(Duration(days: i))) == todayKey,
              onTap: () {
                final day = weekStart.add(Duration(days: i));
                onTapDay(day, planByDay[dateKey(day)]);
              },
              onLongPress: () {
                final plan =
                    planByDay[dateKey(weekStart.add(Duration(days: i)))];
                if (plan != null) onLongPressPlan(plan);
              },
            ),
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  final bool trained;
  final WeekPlanItem? plan;
  final bool today;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  const _DayCell({
    required this.trained,
    required this.plan,
    required this.today,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    final planned = plan != null;
    Widget marker;
    if (trained) {
      marker = Container(
        width: 12,
        height: 12,
        decoration: const BoxDecoration(
          color: AppColors.accent,
          shape: BoxShape.circle,
        ),
      );
    } else if (planned) {
      marker = Container(
        width: 12,
        height: 12,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: plan!.done ? AppColors.go.withAlpha(60) : Colors.transparent,
          border: Border.all(
            color: plan!.done
                ? AppColors.go.withAlpha(160)
                : AppColors.accent.withAlpha(130),
            width: 1.5,
          ),
        ),
      );
    } else {
      marker = Container(
        width: 5,
        height: 5,
        decoration: const BoxDecoration(
          color: AppColors.line,
          shape: BoxShape.circle,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      onLongPress: planned ? onLongPress : null,
      child: SizedBox(
        height: 26,
        child: Center(
          child: Container(
            width: 20,
            height: 20,
            alignment: Alignment.center,
            decoration: today
                ? BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: AppColors.accent.withAlpha(150)),
                  )
                : null,
            child: marker,
          ),
        ),
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 3. Volume
// ---------------------------------------------------------------------------

/// Training minutes over time. The old "load" chart used RPE, which is
/// optional and therefore almost always zero; minutes are always available.
class VolumeCard extends StatelessWidget {
  final List<SessionRecord> sessions;
  final StatsRange range;
  final Lang lang;
  const VolumeCard({
    super.key,
    required this.sessions,
    required this.range,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAll = range == StatsRange.all;
    final buckets = isAll
        ? monthlyBuckets(sessions, months: 6, lang: lang)
        : weeklyBuckets(sessions, 8);
    final values = [for (final b in buckets) b.minutes];
    final current = values.isEmpty ? 0 : values.last;
    final previous = values.length >= 2 ? values[values.length - 2] : 0;
    final delta = percentChange(current, previous);
    final currentLabel = buckets.isEmpty ? '' : buckets.last.label;

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(l.progressVolume),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(
                '$current',
                style: const TextStyle(
                  fontSize: 28,
                  height: 1,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              const Text('min', style: AppText.micro),
              if (delta != null) ...[
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _DeltaPill(delta: delta),
                        const SizedBox(width: 5),
                        Flexible(
                          child: Text(
                            l.progressVsPrev,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.mut,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 140,
            child: _VolumeChart(buckets: buckets, values: values),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            currentLabel.isEmpty
                ? l.progressVolumeNote
                : '${l.progressVolumeNote} · $currentLabel',
            style: const TextStyle(fontSize: 11, color: AppColors.mut),
          ),
        ],
      ),
    );
  }
}

class _VolumeChart extends StatelessWidget {
  final List<LoadBucket> buckets;
  final List<int> values;
  const _VolumeChart({required this.buckets, required this.values});

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) return const SizedBox.shrink();
    final maxValue = values.fold<int>(1, (a, b) => b > a ? b : a);
    final maxY = (maxValue == 0 ? 1 : maxValue) * 1.25;
    final lastIndex = values.length - 1;
    final step = values.length > 6 ? 2 : 1;

    return LineChart(
      LineChartData(
        minX: 0,
        maxX: lastIndex.toDouble(),
        minY: 0,
        maxY: maxY,
        lineTouchData: const LineTouchData(enabled: false),
        gridData: const FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          leftTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          rightTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          topTitles: const AxisTitles(
            sideTitles: SideTitles(showTitles: false),
          ),
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 22,
              getTitlesWidget: (value, meta) {
                final i = value.toInt();
                if (i < 0 || i > lastIndex) return const SizedBox.shrink();
                if (i % step != 0 && i != lastIndex) {
                  return const SizedBox.shrink();
                }
                return Padding(
                  padding: const EdgeInsets.only(top: 6),
                  child: Text(
                    buckets[i].label,
                    style: const TextStyle(fontSize: 9, color: AppColors.mut),
                  ),
                );
              },
            ),
          ),
        ),
        lineBarsData: [
          LineChartBarData(
            spots: [
              for (var i = 0; i < values.length; i++)
                FlSpot(i.toDouble(), values[i].toDouble()),
            ],
            isCurved: true,
            curveSmoothness: 0.25,
            color: AppColors.accent,
            barWidth: 2.5,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, bar, index) => FlDotCirclePainter(
                radius: index == lastIndex ? 4 : 2,
                color: AppColors.accent,
                strokeWidth: 2,
                strokeColor: AppColors.bg,
              ),
            ),
            belowBarData: BarAreaData(
              show: true,
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  AppColors.accent.withAlpha(70),
                  AppColors.accent.withAlpha(0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 4. Progress / trend
// ---------------------------------------------------------------------------

/// Change versus the previous equivalent period. For all-time there is no
/// baseline, so it falls back to plain totals.
class TrendCard extends StatelessWidget {
  final List<SessionRecord> sessions;
  final StatsRange range;
  const TrendCard({super.key, required this.sessions, required this.range});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final isAll = range == StatsRange.all;
    final current = sessionsInPeriod(sessions, periodFor(range));
    final previousPeriod = previousPeriodFor(range);
    final previous = previousPeriod == null
        ? const <SessionRecord>[]
        : sessionsInPeriod(sessions, previousPeriod);

    final vol = volumeStats(current);
    final prevVol = volumeStats(previous);
    final combos = combosUsedCount(current);
    final prevCombos = combosUsedCount(previous);
    final hasBaseline = previous.isNotEmpty;

    final rows = <({String label, String value, int? delta})>[
      (
        label: l.statsTrainingTime,
        value: fmtMinutes(vol.minutes * 60),
        delta: hasBaseline ? percentChange(vol.minutes, prevVol.minutes) : null,
      ),
      (
        label: l.statsRounds,
        value: '${vol.rounds}',
        delta: hasBaseline ? percentChange(vol.rounds, prevVol.rounds) : null,
      ),
      (
        label: l.statsSessions,
        value: '${vol.sessions}',
        delta: hasBaseline
            ? percentChange(vol.sessions, prevVol.sessions)
            : null,
      ),
      (
        label: l.statsWorkTime,
        value: fmtClock(vol.workSeconds),
        delta: hasBaseline
            ? percentChange(vol.workSeconds, prevVol.workSeconds)
            : null,
      ),
      (
        label: l.progressCombos,
        value: '$combos',
        delta: hasBaseline ? percentChange(combos, prevCombos) : null,
      ),
    ];

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(isAll ? l.progressTotals : l.progressTrend),
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0) const Divider(height: 1, color: AppColors.line),
            _TrendRow(
              label: rows[i].label,
              value: rows[i].value,
              delta: rows[i].delta,
              showDelta: !isAll,
            ),
          ],
          if (!isAll && !hasBaseline) ...[
            const SizedBox(height: AppSpacing.sm),
            Text(
              l.progressNoBaseline,
              style: const TextStyle(fontSize: 11, color: AppColors.mut),
            ),
          ],
        ],
      ),
    );
  }
}

class _TrendRow extends StatelessWidget {
  final String label;
  final String value;
  final int? delta;
  final bool showDelta;
  const _TrendRow({
    required this.label,
    required this.value,
    required this.delta,
    required this.showDelta,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Expanded(
            child: Text(
              label.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.6,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            value,
            style: const TextStyle(
              fontSize: 13.5,
              fontWeight: FontWeight.w800,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          if (showDelta) ...[
            const SizedBox(width: AppSpacing.sm),
            SizedBox(
              width: 58,
              child: Align(
                alignment: Alignment.centerRight,
                child: FittedBox(
                  fit: BoxFit.scaleDown,
                  alignment: Alignment.centerRight,
                  child: _DeltaPill(delta: delta),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _DeltaPill extends StatelessWidget {
  final int? delta;
  const _DeltaPill({required this.delta});

  @override
  Widget build(BuildContext context) {
    final d = delta;
    if (d == null) {
      return const Text(
        '—',
        style: TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w800,
          color: AppColors.mut,
        ),
      );
    }
    final flat = d == 0;
    final up = d > 0;
    final color = flat ? AppColors.mut : (up ? AppColors.go : AppColors.warn);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          flat
              ? Icons.remove_rounded
              : (up
                    ? Icons.arrow_upward_rounded
                    : Icons.arrow_downward_rounded),
          size: 12,
          color: color,
        ),
        const SizedBox(width: 2),
        Text(
          '${d.abs()}%',
          style: TextStyle(
            fontSize: 12.5,
            fontWeight: FontWeight.w800,
            color: color,
            fontFeatures: const [FontFeature.tabularFigures()],
          ),
        ),
      ],
    );
  }
}

// ---------------------------------------------------------------------------
// 5. Combinations
// ---------------------------------------------------------------------------

class CombinationsCard extends StatelessWidget {
  final List<SessionRecord> sessions;
  final StatsRange range;
  const CombinationsCard({
    super.key,
    required this.sessions,
    required this.range,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final current = sessionsInPeriod(sessions, periodFor(range));
    final top = comboUsageStats(current).take(6).toList();

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(l.statsMostUsed),
          if (top.isEmpty)
            Container(
              padding: const EdgeInsets.all(AppSpacing.md),
              decoration: BoxDecoration(
                color: AppColors.bg.withAlpha(60),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.progressCombosEmptyTitle,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    l.progressCombosEmptyMsg,
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.mut,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            )
          else
            for (var i = 0; i < top.length; i++)
              Padding(
                padding: EdgeInsets.only(bottom: i == top.length - 1 ? 0 : 10),
                child: Row(
                  children: [
                    SizedBox(
                      width: 20,
                      child: Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w900,
                          color: i == 0 ? AppColors.accent : AppColors.mut,
                          fontFeatures: const [FontFeature.tabularFigures()],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: Text(
                        top[i].name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 12.5,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text(
                      '${top[i].count}×',
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: AppColors.accent,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 6. Personal records
// ---------------------------------------------------------------------------

class RecordsCard extends StatelessWidget {
  final List<SessionRecord> sessions;
  const RecordsCard({super.key, required this.sessions});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final rec = personalRecords(sessions);
    final items = <({String value, String? unit, String label})>[
      if (rec.maxRounds > 0)
        (
          value: '${rec.maxRounds}',
          unit: null,
          label: l.progressRecordMaxRounds,
        ),
      if (rec.longestSessionSeconds > 0)
        (
          value: fmtMinutes(rec.longestSessionSeconds),
          unit: null,
          label: l.progressRecordLongestSession,
        ),
      if (rec.totalCombos > 0)
        (
          value: '${rec.totalCombos}',
          unit: null,
          label: l.progressRecordCombos,
        ),
      if (rec.longestStreak > 0)
        (
          value: '${rec.longestStreak}',
          unit: l.progressDaysUnit,
          label: l.progressRecordStreak,
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(l.progressRecords),
          LayoutBuilder(
            builder: (context, constraints) {
              const gap = AppSpacing.sm;
              final width = (constraints.maxWidth - gap) / 2;
              return Wrap(
                spacing: gap,
                runSpacing: AppSpacing.md,
                children: [
                  for (final it in items)
                    SizedBox(
                      width: width,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.baseline,
                              textBaseline: TextBaseline.alphabetic,
                              children: [
                                Text(
                                  it.value,
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w900,
                                    fontFeatures: [
                                      FontFeature.tabularFigures(),
                                    ],
                                  ),
                                ),
                                if (it.unit != null) ...[
                                  const SizedBox(width: AppSpacing.xs),
                                  Text(it.unit!, style: AppText.micro),
                                ],
                              ],
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            it.label.toUpperCase(),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: AppText.micro,
                          ),
                        ],
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// 7. Detail (de-emphasized)
// ---------------------------------------------------------------------------

class DetailStatsCard extends StatelessWidget {
  final List<SessionRecord> sessions;
  final Lang lang;
  const DetailStatsCard({
    super.key,
    required this.sessions,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final techUsage = techniqueUsageStats(sessions).take(8).toList();
    final bag = bagStats(sessions);

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SectionTitle(l.progressDetail),
          Text(l.progressTechniques.toUpperCase(), style: AppText.micro),
          const SizedBox(height: AppSpacing.sm),
          if (techUsage.isEmpty)
            Text(
              l.statsTechEmpty,
              style: const TextStyle(fontSize: 12, color: AppColors.mut),
            )
          else
            for (final tc in techUsage)
              _TechBar(nameCount: tc, max: techUsage.first.count, lang: lang),
          if (bag.sessions > 0) ...[
            const SizedBox(height: AppSpacing.md),
            const Divider(height: 1, color: AppColors.line),
            const SizedBox(height: AppSpacing.md),
            Text(l.statsHeavyBag.toUpperCase(), style: AppText.micro),
            const SizedBox(height: AppSpacing.sm),
            Row(
              children: [
                Expanded(
                  child: _MiniStat(
                    label: l.statsBagSessions,
                    value: '${bag.sessions}',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: l.statsBagRounds,
                    value: '${bag.rounds}',
                  ),
                ),
                Expanded(
                  child: _MiniStat(
                    label: l.statsBagTime,
                    value: fmtClock(bag.seconds),
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

class _TechBar extends StatelessWidget {
  final NameCount nameCount;
  final int max;
  final Lang lang;
  const _TechBar({
    required this.nameCount,
    required this.max,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                nameCount.name.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 11.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            Text(
              '${nameCount.count}',
              style: const TextStyle(
                fontSize: 11.5,
                color: AppColors.mut,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppSpacing.pill),
          child: LinearProgressIndicator(
            value: max <= 0 ? 0 : nameCount.count / max,
            minHeight: 5,
            backgroundColor: AppColors.line,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      ],
    ),
  );
}

// ---------------------------------------------------------------------------
// Small shared pieces
// ---------------------------------------------------------------------------

class _InlineStat extends StatelessWidget {
  final String label;
  final String value;
  const _InlineStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label.toUpperCase(),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: AppText.micro,
      ),
    ],
  );
}

class _MiniStat extends StatelessWidget {
  final String label;
  final String value;
  const _MiniStat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        value,
        style: const TextStyle(
          fontSize: 17,
          fontWeight: FontWeight.w800,
          fontFeatures: [FontFeature.tabularFigures()],
        ),
      ),
      const SizedBox(height: 2),
      Text(
        label.toUpperCase(),
        maxLines: 2,
        overflow: TextOverflow.ellipsis,
        style: AppText.micro,
      ),
    ],
  );
}

// ---------------------------------------------------------------------------
// Plan modal (reused from the old weekly overview)
// ---------------------------------------------------------------------------

Future<void> _addPlan(
  BuildContext context,
  AppStore store,
  Lang lang,
  DateTime day,
) async {
  final l = AppLocalizations.of(context)!;
  var type = WorkoutType.other;
  final labelCtrl = TextEditingController();
  int minutes = 60;

  await showAppModal<bool>(
    context,
    title: l.statsPlanSession,
    builder: (_) => StatefulBuilder(
      builder: (context, setModalState) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Field(
              label: l.commonType,
              child: Select<WorkoutType>(
                value: type,
                options: [
                  for (final wt in workoutTypes)
                    (
                      value: wt.id,
                      label: '${wt.icon} ${workoutTypeLabel(wt.id, lang)}',
                    ),
                ],
                onChanged: (v) => setModalState(() => type = v),
              ),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.statsLabelOptional,
              child: TextInput(controller: labelCtrl),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.statsPlannedMinutes,
              child: NumStepper(
                value: minutes,
                min: 5,
                max: 300,
                step: 5,
                onChanged: (v) => setModalState(() => minutes = v),
              ),
            ),
            const SizedBox(height: 14),
            Button(
              label: l.statsAddToWeek,
              size: BtnSize.lg,
              onTap: () {
                store.addPlan(
                  WeekPlanItem(
                    id: uid(),
                    dateKey: dateKey(day),
                    type: type,
                    label: labelCtrl.text.trim().isEmpty
                        ? workoutTypeLabel(type, lang)
                        : labelCtrl.text.trim(),
                    durationMin: minutes,
                    done: false,
                  ),
                );
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    ),
  );
}
