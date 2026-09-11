// Progress: a motivational pulse at the top, deep analytics below, and a
// dedicated History page reached from a recent-sessions card.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'history_page.dart';
import 'stats_page.dart';

/// The weekly target shown in the pulse. Deliberately fixed for now.
const int kWeeklyGoal = 4;

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.xl,
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _PulseCard(
                weeklyStreak: weeklyStreak(store.data.sessions),
                thisWeek: sessionsThisWeek(store.data.sessions),
              ),
              const SizedBox(height: AppSpacing.md),
              const StatsContent(),
              const SizedBox(height: AppSpacing.lg),
              _HistoryCard(recent: store.data.sessions),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  final int weeklyStreak;
  final int thisWeek;
  const _PulseCard({required this.weeklyStreak, required this.thisWeek});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final reached = thisWeek >= kWeeklyGoal;
    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: _metric(
                    label: l.progressWeeklyStreak,
                    value: '$weeklyStreak',
                    unit: l.progressWeeksUnit,
                    color: AppColors.ink,
                  ),
                ),
                const VerticalDivider(color: AppColors.line, width: 1),
                Expanded(
                  child: _metric(
                    label: l.progressWeekWorkouts,
                    value: '$thisWeek',
                    color: reached ? AppColors.go : AppColors.ink,
                  ),
                ),
              ],
            ),
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
                '$thisWeek/$kWeeklyGoal',
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
            borderRadius: BorderRadius.circular(99),
            child: LinearProgressIndicator(
              value: (thisWeek / kWeeklyGoal).clamp(0.0, 1.0),
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

  Widget _metric({
    required String label,
    required String value,
    String? unit,
    required Color color,
  }) => Padding(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(label.toUpperCase(), style: AppText.micro, maxLines: 2),
        const SizedBox(height: AppSpacing.xs),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              value,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.w800,
                color: color,
                fontFeatures: const [FontFeature.tabularFigures()],
              ),
            ),
            if (unit != null) ...[
              const SizedBox(width: AppSpacing.xs),
              Flexible(
                child: Text(
                  unit,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: AppText.micro,
                ),
              ),
            ],
          ],
        ),
      ],
    ),
  );
}

class _HistoryCard extends StatelessWidget {
  final List<SessionRecord> recent;
  const _HistoryCard({required this.recent});

  @override
  Widget build(BuildContext context) {
    final store = context.read<AppStore>();
    final l = AppLocalizations.of(context)!;
    final sorted = [...recent]..sort((a, b) => b.date.compareTo(a.date));
    final top = sorted.take(3).toList();

    return CardWidget(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: SectionTitle(l.historyTitle)),
              TextButton(
                onPressed: () => context.go('/progress/history'),
                style: TextButton.styleFrom(foregroundColor: AppColors.accent),
                child: Text(
                  l.progressViewHistory.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                  ),
                ),
              ),
            ],
          ),
          if (top.isEmpty)
            EmptyState(
              title: l.historyEmpty,
              message: l.historyEmptyMsg,
              action: Button(
                label: l.historyLogOne,
                icon: Icons.add,
                size: BtnSize.sm,
                onTap: () => showLogSessionModal(context, store),
              ),
            )
          else
            ...top.map(
              (s) => InkWell(
                onTap: () => context.go('/progress/history'),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Row(
                    children: [
                      Text(
                        workoutTypeMeta(s.type).icon,
                        style: const TextStyle(fontSize: 15),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              s.name.toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 12.5,
                              ),
                            ),
                            Text(
                              '${dayLabel(s.date, store.lang)} · ${fmtClock(s.duration)}',
                              style: const TextStyle(
                                fontSize: 11,
                                color: AppColors.mut,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.chevron_right_rounded,
                        size: 16,
                        color: AppColors.mut,
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
