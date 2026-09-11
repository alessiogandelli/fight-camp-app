// Stats page ported from src/pages/StatsPage.tsx.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

enum _Range { d7, d30, all }

/// Stats section embedded in the Progress page (no scrolling of its own).
class StatsContent extends StatefulWidget {
  const StatsContent({super.key});

  @override
  State<StatsContent> createState() => _StatsContentState();
}

class _StatsContentState extends State<StatsContent> {
  _Range _range = _Range.d7;
  int _weekOffset = 0;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final sessions = filterSince(store.data.sessions, switch (_range) {
      _Range.d7 => 7,
      _Range.d30 => 30,
      _ => null,
    });

    if (store.data.sessions.isEmpty) {
      return Column(
        children: [EmptyState(title: l.statsTitle, message: l.statsEmpty)],
      );
    }

    final vol = volumeStats(sessions);
    final weekly = weeklyBuckets(store.data.sessions);
    final monthly = monthlyBuckets(store.data.sessions, lang: lang);
    final streak = streaks(store.data.sessions);
    final perWeek = sessionsPerWeek(store.data.sessions);
    final bag = bagStats(store.data.sessions);
    final topCombos = comboUsageStats(store.data.sessions).take(6).toList();
    final techUsage = techniqueUsageStats(
      store.data.sessions,
    ).take(10).toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            SectionTitle(l.statsTitle),
            const Spacer(),
            SizedBox(
              width: 260,
              child: Segmented<_Range>(
                value: _range,
                options: [
                  (value: _Range.d7, label: l.stats7days),
                  (value: _Range.d30, label: l.stats30days),
                  (value: _Range.all, label: l.statsAllTime),
                ],
                onChanged: (v) => setState(() => _range = v),
              ),
            ),
          ],
        ),
        GridView.count(
          crossAxisCount: MediaQuery.of(context).size.width > 600 ? 4 : 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 8,
          crossAxisSpacing: 8,
          childAspectRatio: 1.9,
          children: [
            StatCard(label: l.statsSessions, value: '${vol.sessions}'),
            StatCard(
              label: l.statsTrainingTime,
              value: fmtMinutes(vol.minutes * 60),
            ),
            StatCard(label: l.statsRounds, value: '${vol.rounds}'),
            StatCard(label: l.statsWorkTime, value: fmtClock(vol.workSeconds)),
          ],
        ),
        const SizedBox(height: 16),
        CardWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(l.statsWeeklyLoad),
              SizedBox(height: 170, child: _LoadChart(buckets: weekly)),
              const SizedBox(height: 14),
              SectionTitle(l.statsMonthlyLoad),
              SizedBox(height: 150, child: _LoadChart(buckets: monthly)),
              const SizedBox(height: 8),
              Text(
                l.statsLoadNote,
                style: const TextStyle(fontSize: 11, color: AppColors.mut),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CardWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(l.statsConsistency),
              // Current streak lives in the Progress pulse above; here we
              // show the long-run consistency figures.
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l.statsLongestStreak,
                      value: '${streak.longest}',
                      sub: l.unitSessions,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      label: l.statsSessionsPerWeek,
                      value: perWeek.toStringAsFixed(1),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CardWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(l.statsHeavyBag),
              Row(
                children: [
                  Expanded(
                    child: StatCard(
                      label: l.statsBagSessions,
                      value: '${bag.sessions}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      label: l.statsBagRounds,
                      value: '${bag.rounds}',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: StatCard(
                      label: l.statsBagTime,
                      value: fmtClock(bag.seconds),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CardWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(l.statsMostUsed),
              if (topCombos.isEmpty)
                Text(
                  l.statsMostUsedEmpty,
                  style: const TextStyle(fontSize: 12, color: AppColors.mut),
                )
              else
                ...topCombos.map(
                  (c) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            c.name.toUpperCase(),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          '${c.count}×',
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        CardWidget(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SectionTitle(l.statsTechFreq),
              if (techUsage.isEmpty)
                Text(
                  l.statsTechEmpty,
                  style: const TextStyle(fontSize: 12, color: AppColors.mut),
                )
              else
                ...techUsage.map(
                  (tc) => _TechBar(
                    nameCount: tc,
                    max: techUsage.first.count,
                    lang: lang,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        WeeklyOverview(
          weekOffset: _weekOffset,
          onWeekChange: (d) => setState(() => _weekOffset = d),
        ),
      ],
    );
  }
}

class _LoadChart extends StatelessWidget {
  final List<LoadBucket> buckets;
  const _LoadChart({required this.buckets});

  @override
  Widget build(BuildContext context) {
    final maxY =
        buckets.fold<int>(1, (a, b) => b.load > a ? b.load : a).toDouble() *
        1.15;
    return BarChart(
      BarChartData(
        alignment: BarChartAlignment.spaceAround,
        maxY: maxY < 1 ? 1 : maxY,
        barTouchData: BarTouchData(enabled: false),
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
              getTitlesWidget: (value, meta) => Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  buckets[value.toInt() % buckets.length].label,
                  style: const TextStyle(fontSize: 9, color: AppColors.mut),
                ),
              ),
            ),
          ),
        ),
        barGroups: [
          for (var i = 0; i < buckets.length; i++)
            BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: buckets[i].load.toDouble(),
                  width: 18,
                  borderRadius: BorderRadius.circular(4),
                  color: AppColors.accent.withAlpha(220),
                ),
              ],
            ),
        ],
      ),
      swapAnimationDuration: const Duration(milliseconds: 250),
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
          borderRadius: BorderRadius.circular(99),
          child: LinearProgressIndicator(
            value: max <= 0 ? 0 : nameCount.count / max,
            minHeight: 5,
            backgroundColor: AppColors.bg,
            valueColor: const AlwaysStoppedAnimation(AppColors.accent),
          ),
        ),
      ],
    ),
  );
}

class WeeklyOverview extends StatelessWidget {
  final int weekOffset;
  final ValueChanged<int> onWeekChange;
  const WeeklyOverview({
    super.key,
    required this.weekOffset,
    required this.onWeekChange,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;

    final now = DateTime.now();
    final thisWeekStart = startOfWeek(now);
    final weekStart = thisWeekStart.subtract(Duration(days: weekOffset * 7));

    final dayKeys = List.generate(
      7,
      (i) => dateKey(weekStart.add(Duration(days: i))),
    );
    final plans = store.data.plans
        .where((p) => dayKeys.contains(p.dateKey))
        .toList();
    final sessionsByDay = <String, List<SessionRecord>>{};
    for (final s in store.data.sessions) {
      final key = dateKey(DateTime.fromMillisecondsSinceEpoch(s.date));
      if (dayKeys.contains(key))
        sessionsByDay.putIfAbsent(key, () => []).add(s);
    }

    String headerLabel;
    if (weekOffset == 0) {
      headerLabel = l.statsThisWeek;
    } else if (weekOffset == 1) {
      headerLabel = l.statsLastWeek;
    } else {
      headerLabel =
          '${_fmtDate(weekStart)} – ${_fmtDate(weekStart.add(const Duration(days: 6)))}';
    }

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SectionTitle(l.statsWeeklyOverview),
          Row(
            children: [
              IconButton2(
                Icons.chevron_left_rounded,
                onTap: () => onWeekChange(weekOffset + 1),
              ),
              Expanded(
                child: Text(
                  headerLabel,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ),
              Opacity(
                opacity: weekOffset > 0 ? 1 : 0.3,
                child: IconButton2(
                  Icons.chevron_right_rounded,
                  onTap: weekOffset > 0
                      ? () => onWeekChange(weekOffset - 1)
                      : null,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          for (var d = 0; d < 7; d++)
            _DayRow(
              date: weekStart.add(Duration(days: d)),
              sessions: sessionsByDay[dayKeys[d]] ?? const [],
              plans: plans.where((p) => p.dateKey == dayKeys[d]).toList(),
            ),
          const SizedBox(height: 8),
          Button(
            label: l.statsPlan,
            variant: BtnVariant.ghost,
            icon: Icons.add,
            onTap: () => _addPlan(context, store, lang, weekStart),
          ),
        ],
      ),
    );
  }

  String _fmtDate(DateTime d) => '${d.day}/${d.month}';
}

class _DayRow extends StatelessWidget {
  final DateTime date;
  final List<SessionRecord> sessions;
  final List<WeekPlanItem> plans;
  const _DayRow({
    required this.date,
    required this.sessions,
    required this.plans,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isToday = dateKey(date) == dateKey(DateTime.now());

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 6),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: AppColors.line.withAlpha(90))),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 44,
            child: Text(
              '${date.day}',
              style: TextStyle(
                fontSize: 13,
                fontWeight: isToday ? FontWeight.w900 : FontWeight.w700,
                color: isToday ? AppColors.accent : AppColors.mut,
              ),
            ),
          ),
          Expanded(
            child: Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final s in sessions)
                  ChipWidget(
                    label:
                        '${workoutTypeMeta(s.type).icon} ${fmtMinutes(s.duration)}',
                    active: false,
                    onTap: () {},
                  ),
                for (final p in plans)
                  GestureDetector(
                    onTap: () => store.togglePlan(p.id),
                    onLongPress: () => store.deletePlan(p.id),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 9,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: p.done
                            ? AppColors.go.withAlpha(28)
                            : AppColors.panel2,
                        borderRadius: BorderRadius.circular(99),
                        border: Border.all(
                          color: p.done
                              ? AppColors.go.withAlpha(120)
                              : AppColors.line,
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            p.done
                                ? Icons.check_circle_rounded
                                : Icons.circle_outlined,
                            size: 12,
                            color: p.done ? AppColors.go : AppColors.mut,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            p.label +
                                (p.durationMin != null
                                    ? ' · ${p.durationMin}m'
                                    : ''),
                            style: TextStyle(
                              fontSize: 10.5,
                              fontWeight: FontWeight.w600,
                              color: p.done ? AppColors.go : AppColors.mut,
                              decoration: p.done
                                  ? TextDecoration.lineThrough
                                  : null,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (sessions.isEmpty && plans.isEmpty)
                  Text('—', style: const TextStyle(color: AppColors.line)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

Future<void> _addPlan(
  BuildContext context,
  AppStore store,
  Lang lang,
  DateTime weekStart,
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
                    dateKey: dateKey(weekStart),
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
