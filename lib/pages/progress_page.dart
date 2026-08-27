// Progress page: merged Stats + History (one tab for how training is going).
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart';
import '../l10n/app_localizations.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import 'history_page.dart';
import 'stats_page.dart';

class ProgressPage extends StatelessWidget {
  const ProgressPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final weekSessions = filterSince(store.data.sessions, 7);
    final vol = volumeStats(weekSessions);
    final streak = streaks(store.data.sessions);

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.xl),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Row of Expanded cards instead of a GridView: no orphan cell,
              // no clipping from a fixed childAspectRatio. IntrinsicHeight keeps
              // the three cards equal height without an unbounded constraint.
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(
                      child: StatCard(label: l.progressWeekSessions.toUpperCase(), value: '${vol.sessions}'),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatCard(label: l.statsTrainingTime.toUpperCase(), value: fmtMinutes(vol.minutes * 60)),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(
                      child: StatCard(label: l.statsCurrentStreak.toUpperCase(), value: '${streak.current}', sub: l.unitSessions),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const StatsContent(),
              const SizedBox(height: AppSpacing.lg),
              const HistoryContent(),
            ],
          ),
        ),
      ),
    );
  }
}
