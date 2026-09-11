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
    final weekSessions = filterSince(store.data.sessions, 7);
    final vol = volumeStats(weekSessions);
    final streak = streaks(store.data.sessions);
    final perWeek = sessionsPerWeek(store.data.sessions);

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
                streak: streak.current,
                goalDone: vol.sessions,
                perWeek: perWeek,
              ),
              const SizedBox(height: AppSpacing.md),
              _HistoryCard(recent: store.data.sessions),
              const SizedBox(height: AppSpacing.lg),
              const StatsContent(),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulseCard extends StatelessWidget {
  final int streak;
  final int goalDone;
  final double perWeek;
  const _PulseCard({
    required this.streak,
    required this.goalDone,
    required this.perWeek,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final reached = goalDone >= kWeeklyGoal;
    return CardWidget(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
        AppSpacing.md,
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Expanded(
              child: _metric(
                context,
                value: '$streak',
                label: l.statsCurrentStreak,
                color: AppColors.ink,
              ),
            ),
            const VerticalDivider(color: AppColors.line, width: 1),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    l.progressWeeklyGoal.toUpperCase(),
                    style: AppText.micro,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$goalDone/$kWeeklyGoal',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w800,
                      color: reached ? AppColors.go : AppColors.ink,
                      fontFeatures: const [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(99),
                    child: LinearProgressIndicator(
                      value: (goalDone / kWeeklyGoal).clamp(0.0, 1.0),
                      minHeight: 5,
                      backgroundColor: AppColors.bg,
                      valueColor: AlwaysStoppedAnimation(
                        reached ? AppColors.go : AppColors.accent,
                      ),
                    ),
                  ),
                  if (reached)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        l.progressGoalReached,
                        style: const TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.go,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            const VerticalDivider(color: AppColors.line, width: 1),
            Expanded(
              child: _metric(
                context,
                value: perWeek.toStringAsFixed(1),
                label: l.statsSessionsPerWeek,
                color: AppColors.ink,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _metric(
    BuildContext context, {
    required String value,
    required String label,
    required Color color,
  }) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        label.toUpperCase(),
        style: AppText.micro,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      const SizedBox(height: 4),
      Text(
        value,
        style: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: color,
          fontFeatures: const [FontFeature.tabularFigures()],
        ),
      ),
    ],
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
