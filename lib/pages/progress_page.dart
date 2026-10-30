// Progress: a single calm dashboard built around real trainings, followed by
// the complete log. Apple Health imports and app sessions share the same view.
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/progress_stats.dart';
import '../lib/stats.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../training/training.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import 'log_session_modal.dart';
import 'progress_categorize_sheet.dart';
import 'progress_filters_sheet.dart';
import 'progress_log.dart';
import 'progress_overview.dart';
import 'training_detail_sheet.dart';

class ProgressPage extends StatefulWidget {
  const ProgressPage({super.key});

  @override
  State<ProgressPage> createState() => _ProgressPageState();
}

class _ProgressPageState extends State<ProgressPage> {
  StatsRange _range = StatsRange.weeks4;
  int _periodOffset = 0;
  String? _selectedDayKey;
  String _query = '';
  final Set<WorkoutType> _types = {};
  TrainingSourceFilter _source = TrainingSourceFilter.all;
  final GlobalKey _logKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final trainings = trainingsOf(
      store.data.sessions,
      store.data.healthLinks,
      segments: store.data.segments,
    );
    final maxOffset = maxProgressOffset(_range, trainings);
    final offset = _periodOffset.clamp(0, maxOffset);
    final period = progressPeriodFor(_range, offset: offset);
    final current = trainingsInPeriod(trainings, period.current);
    final previous = period.previous == null
        ? const <Training>[]
        : trainingsInPeriod(trainings, period.previous!);
    final globalEmpty = trainings.isEmpty;
    final filtersActive =
        _query.trim().isNotEmpty ||
        _source != TrainingSourceFilter.all ||
        _selectedDayKey != null;

    return SingleChildScrollView(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.md,
        MediaQuery.paddingOf(context).top + kAppHeaderHeight + 12,
        AppSpacing.md,
        glassNavClearance(context),
      ),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 768),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      alignment: Alignment.centerLeft,
                      child: Text(
                        l.progressTitle.toUpperCase(),
                        maxLines: 1,
                        style: const TextStyle(
                          fontSize: 34,
                          height: 1,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  _PeriodPill(
                    range: _range,
                    onChanged: (value) => setState(() {
                      _range = value;
                      _periodOffset = 0;
                      _selectedDayKey = null;
                    }),
                  ),
                  const SizedBox(width: 7),
                  _FilterButton(active: filtersActive, onTap: _openFilters),
                ],
              ),
              if (_range != StatsRange.all) ...[
                const SizedBox(height: 4),
                _PeriodBar(
                  label: _periodLabel(period, store.lang),
                  canBack: offset < maxOffset,
                  canForward: offset > 0,
                  onBack: () => setState(() {
                    _periodOffset = offset + 1;
                    _selectedDayKey = null;
                  }),
                  onForward: () => setState(() {
                    _periodOffset = (offset - 1).clamp(0, maxOffset);
                    _selectedDayKey = null;
                  }),
                ),
              ],
              const SizedBox(height: AppSpacing.lg),
              if (globalEmpty)
                EmptyState(
                  title: l.progressNoTrainings,
                  message: l.progressEmptyMsg,
                  action: Button(
                    label: l.historyLogOne,
                    icon: Icons.add,
                    size: BtnSize.sm,
                    onTap: () => showLogSessionModal(context, store),
                  ),
                )
              else if (current.isEmpty)
                EmptyState(
                  title: l.progressNoTrainingsPeriod,
                  message: l.progressNoTrainingsPeriodMsg,
                  action: Button(
                    label: l.historyLogOne,
                    icon: Icons.add,
                    size: BtnSize.sm,
                    onTap: () => showLogSessionModal(context, store),
                  ),
                )
              else ...[
                ProgressOverview(
                  period: period,
                  trainings: current,
                  previousTrainings: previous,
                  selectedDayKey: _selectedDayKey,
                  onSelectDay: _selectDay,
                  onOpenType: _openType,
                  onSortUncategorized: _sortUncategorized,
                ),
                const SizedBox(height: AppSpacing.lg),
                ProgressLog(
                  key: _logKey,
                  trainings: current,
                  selectedDayKey: _selectedDayKey,
                  query: _query,
                  types: _types,
                  source: _source,
                  onToggleType: _toggleType,
                  onOpenTraining: (training) =>
                      showTrainingDetails(context, training),
                  onClearFilters: _clearFilters,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  void _selectDay(String? key) {
    setState(() => _selectedDayKey = key);
    if (key != null) _scrollToLog();
  }

  String _periodLabel(ProgressPeriod period, Lang lang) {
    final locale = lang == Lang.it ? 'it_IT' : 'en_US';
    final format = DateFormat.MMMd(locale);
    final start = period.start!;
    final end = period.end == null
        ? DateTime.now()
        : DateTime(period.end!.year, period.end!.month, period.end!.day - 1);
    return '${format.format(start)} – ${format.format(end)}';
  }

  void _openType(WorkoutType type) {
    setState(() {
      _clearFiltersState();
      _types.add(type);
    });
    _scrollToLog();
  }

  void _toggleType(WorkoutType type) {
    setState(() {
      if (!_types.remove(type)) _types.add(type);
    });
  }

  void _clearFilters() {
    setState(_clearFiltersState);
  }

  void _clearFiltersState() {
    _query = '';
    _types.clear();
    _source = TrainingSourceFilter.all;
    _selectedDayKey = null;
  }

  void _scrollToLog() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _logKey.currentContext;
      if (context == null) return;
      Scrollable.ensureVisible(
        context,
        duration: const Duration(milliseconds: 260),
        curve: Curves.easeOutCubic,
        alignment: 0.04,
      );
    });
  }

  Future<void> _openFilters() async {
    final result = await showProgressFilters(
      context,
      query: _query,
      source: _source,
    );
    if (result == null || !mounted) return;
    setState(() {
      _query = result.query;
      _source = result.source;
    });
  }

  Future<void> _sortUncategorized() async {
    final store = context.read<AppStore>();
    final l = AppLocalizations.of(context)!;
    final trainings = trainingsOf(
      store.data.sessions,
      store.data.healthLinks,
      segments: store.data.segments,
    );
    final current = trainingsInPeriod(trainings, periodFor(_range));
    final sessions = uncategorizedSessions(current);
    if (sessions.isEmpty) return;
    final saved = await showCategorizeSessions(context, sessions);
    if (saved > 0 && mounted) {
      context.showToast(l.progressCategorized);
    }
  }
}

class _PeriodPill extends StatelessWidget {
  final StatsRange range;
  final ValueChanged<StatsRange> onChanged;

  const _PeriodPill({required this.range, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = switch (range) {
      StatsRange.week => l.statsWeek,
      StatsRange.weeks4 => l.stats4Weeks,
      StatsRange.all => l.statsAllTime,
    };
    return PopupMenuButton<StatsRange>(
      onSelected: onChanged,
      color: AppColors.panel2,
      position: PopupMenuPosition.under,
      itemBuilder: (_) => [
        PopupMenuItem(value: StatsRange.week, child: Text(l.statsWeek)),
        PopupMenuItem(value: StatsRange.weeks4, child: Text(l.stats4Weeks)),
        PopupMenuItem(value: StatsRange.all, child: Text(l.statsAllTime)),
      ],
      child: Container(
        height: 40,
        padding: const EdgeInsets.symmetric(horizontal: 13),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(AppSpacing.pill),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 17,
              color: AppColors.mut,
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  final bool active;
  final VoidCallback onTap;

  const _FilterButton({required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(AppSpacing.pill),
        border: Border.all(color: active ? AppColors.primary : AppColors.line),
      ),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Icon(
            Icons.tune_rounded,
            size: 19,
            color: active ? AppColors.primary : AppColors.ink,
          ),
          if (active)
            Positioned(
              right: -3,
              top: -2,
              child: Container(
                width: 7,
                height: 7,
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  shape: BoxShape.circle,
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

class _PeriodBar extends StatelessWidget {
  final String label;
  final bool canBack;
  final bool canForward;
  final VoidCallback onBack;
  final VoidCallback onForward;

  const _PeriodBar({
    required this.label,
    required this.canBack,
    required this.canForward,
    required this.onBack,
    required this.onForward,
  });

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton2(
        Icons.chevron_left_rounded,
        key: const ValueKey('progress-period-back'),
        size: 20,
        onTap: canBack ? onBack : null,
      ),
      Expanded(
        child: Text(
          label,
          key: const ValueKey('progress-period-label'),
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 11,
            color: AppColors.mut,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      IconButton2(
        Icons.chevron_right_rounded,
        key: const ValueKey('progress-period-forward'),
        size: 20,
        onTap: canForward ? onForward : null,
      ),
    ],
  );
}
