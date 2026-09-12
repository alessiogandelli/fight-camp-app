// Progress: the training story in order — weekly anchor, consistency, volume,
// trend, what's being trained, personal records — then the session history.
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

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  StatsRange _range = StatsRange.week;

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final sessions = store.data.sessions;

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
              SectionTitle(l.progressTitle),
              if (sessions.isEmpty)
                EmptyState(
                  title: l.historyEmpty,
                  message: l.progressEmptyMsg,
                  action: Button(
                    label: l.historyLogOne,
                    icon: Icons.add,
                    size: BtnSize.sm,
                    onTap: () => showLogSessionModal(context, store),
                  ),
                )
              else ...[
                SizedBox(
                  width: double.infinity,
                  child: Segmented<StatsRange>(
                    value: _range,
                    options: [
                      (value: StatsRange.week, label: l.statsWeek),
                      (value: StatsRange.weeks4, label: l.stats4Weeks),
                      (value: StatsRange.all, label: l.statsAllTime),
                    ],
                    onChanged: (v) => setState(() => _range = v),
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                WeeklyHero(sessions: sessions),
                const SizedBox(height: AppSpacing.md),
                ConsistencyCard(
                  sessions: sessions,
                  plans: store.data.plans,
                  range: _range,
                ),
                const SizedBox(height: AppSpacing.md),
                VolumeCard(sessions: sessions, range: _range, lang: lang),
                const SizedBox(height: AppSpacing.md),
                TrendCard(sessions: sessions, range: _range),
                const SizedBox(height: AppSpacing.md),
                CombinationsCard(sessions: sessions, range: _range),
                const SizedBox(height: AppSpacing.md),
                RecordsCard(sessions: sessions),
                const SizedBox(height: AppSpacing.md),
                DetailStatsCard(sessions: sessions, lang: lang),
                const SizedBox(height: AppSpacing.lg),
                _HistoryCard(recent: sessions),
              ],
            ],
          ),
        ),
      ),
    );
  }
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
