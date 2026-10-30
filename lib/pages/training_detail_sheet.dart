// Rich, opaque training detail. Uses only data the app actually stores:
// workout summary, sessions, Health summary and the downsampled HR series.
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../health/health_service.dart';
import '../health/health_source.dart';
import '../health/hr_zones.dart';
import '../health/pace_series.dart';
import '../health/splits.dart';
import '../lib/format.dart';
import '../l10n/app_localizations.dart';
import '../models/types.dart';
import '../training/timeline.dart';
import '../training/training.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../ui/workout_colors.dart';

Future<void> showTrainingDetails(BuildContext context, Training training) =>
    showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      barrierColor: Colors.black54,
      builder: (_) => FractionallySizedBox(
        heightFactor: 0.94,
        child: _TrainingDetailSheet(training: training),
      ),
    );

class _TrainingDetailSheet extends StatelessWidget {
  final Training training;
  const _TrainingDetailSheet({required this.training});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final t = _liveTraining(store);
    final accent = progressTrainingColor(t);
    final title = t.sessions.length == 1
        ? (t.sessions.first.name)
        : l.historyTraining;
    final subtitle = [
      dayLabel(t.start, lang),
      fmtTimeOfDay(t.start),
      if (t.links.isNotEmpty && t.links.first.sourceName.isNotEmpty)
        t.links.first.sourceName,
      if (t.hasHealth) l.historyHealth else l.progressSourceApp,
    ].join(' · ');
    final healthLink = t.links.where((e) => e.hasSeries).firstOrNull;
    final entries = _trainingEntries(t);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
        border: Border.all(color: AppColors.line),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          const SizedBox(height: 9),
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(99),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 12, 8, 8),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 48,
                  decoration: BoxDecoration(
                    color: accent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 23,
                          height: 1.05,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 12,
                          height: 1.3,
                          color: AppColors.mut,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton2(
                  Icons.close,
                  size: 23,
                  onTap: () => Navigator.pop(context),
                ),
              ],
            ),
          ),
          Divider(height: 1, color: AppColors.line),
          Expanded(
            child: SingleChildScrollView(
              padding: EdgeInsets.fromLTRB(
                18,
                16,
                18,
                28 + MediaQuery.paddingOf(context).bottom,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _Hero(training: t),
                  if (healthLink != null) ...[
                    const SizedBox(height: 20),
                    Text(
                      l.trainingDetailHeartRate.toUpperCase(),
                      style: AppText.overline,
                    ),
                    const SizedBox(height: 8),
                    _TimelineStrip(
                      training: t,
                      onTapGap: (gap) =>
                          _declareSegment(context, store, t, gap),
                      onTapSegment: (segment) =>
                          _editSegment(context, store, t, segment),
                    ),
                    const SizedBox(height: 8),
                    _HeartRateChart(
                      training: t,
                      externalId: healthLink.externalId,
                    ),
                  ],
                  if (t.avgHr != null ||
                      t.maxHr != null ||
                      t.energyKcal != null ||
                      t.distanceKm != null) ...[
                    const SizedBox(height: 12),
                    _MiniStats(training: t),
                  ],
                  if (t.sessions.any((s) => s.type == WorkoutType.running)) ...[
                    const SizedBox(height: 20),
                    _SplitsSection(training: t),
                  ],
                  if (healthLink != null) ...[
                    const SizedBox(height: 20),
                    _ZonesSection(training: t),
                  ],
                  if (t.links.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    _HealthDetails(links: t.links, lang: lang, l: l),
                  ],
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          l.trainingDetailSessions.toUpperCase(),
                          style: AppText.overline,
                        ),
                      ),
                      TextButton.icon(
                        onPressed: () => _editNotes(context, store, t),
                        style: TextButton.styleFrom(
                          foregroundColor: AppColors.primary,
                          minimumSize: const Size(0, 34),
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                        ),
                        icon: const Icon(Icons.edit_note_rounded, size: 17),
                        label: Text(
                          l.trainingDetailAddNote.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  for (var i = 0; i < entries.length; i++) ...[
                    if (i > 0) const SizedBox(height: 9),
                    if (entries[i] case final SessionRecord session)
                      _SessionCard(
                        session: session,
                        accent: progressTypeColor(session.type),
                        onDelete: () => _deleteSession(context, store, session),
                      )
                    else if (entries[i] case final TrainingSegment segment)
                      _SegmentCard(
                        segment: segment,
                        onTap: () => _editSegment(context, store, t, segment),
                        onDelete: () => _deleteSegment(context, store, segment),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// The sheet is opened with a snapshot, but declared blocks and notes change
  /// the training while it is open: rebuild it from the store so edits show
  /// immediately.
  Training _liveTraining(AppStore store) {
    for (final candidate in trainingsOf(
      store.data.sessions,
      store.data.healthLinks,
      segments: store.data.segments,
    )) {
      if (candidate.id == training.id) return candidate;
    }
    return training;
  }

  Future<void> _editNotes(
    BuildContext context,
    AppStore store,
    Training training,
  ) async {
    final l = AppLocalizations.of(context)!;
    final controllers = {
      for (final session in training.sessions)
        session.id: TextEditingController(text: session.notes ?? ''),
    };
    final saved = await showAppModal<bool>(
      context,
      title: l.trainingDetailEditNotesTitle,
      builder: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (final session in training.sessions) ...[
            Field(
              label: session.name,
              child: TextField(
                controller: controllers[session.id],
                minLines: 2,
                maxLines: 4,
                decoration: InputDecoration(hintText: l.trainingDetailNoteHint),
              ),
            ),
            const SizedBox(height: 12),
          ],
          Button(
            label: l.trainingDetailSaveNotes,
            size: BtnSize.lg,
            onTap: () => Navigator.pop(context, true),
          ),
        ],
      ),
    );
    if (saved == true) {
      for (final session in training.sessions) {
        final text = controllers[session.id]?.text.trim() ?? '';
        store.updateSession(
          session.copyWith(
            notes: text.isEmpty ? null : text,
            clearNotes: text.isEmpty,
          ),
        );
      }
      if (context.mounted) context.showToast(l.trainingDetailNotesSaved);
    }
    for (final controller in controllers.values) {
      controller.dispose();
    }
  }

  Future<void> _deleteSession(
    BuildContext context,
    AppStore store,
    SessionRecord session,
  ) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showConfirm(
      context,
      title: l.historyDeleteSession,
      message: l.historyDeleteMsg,
      cancelLabel: l.commonCancel,
      confirmLabel: l.commonDelete,
    );
    if (!ok || !context.mounted) return;
    final before = store.snapshot;
    store.deleteSession(session.id);
    Navigator.pop(context);
    context.showToast(
      l.historySessionDeleted,
      actionLabel: l.commonUndo,
      onAction: () => store.restore(before),
    );
  }

  /// Sessions and declared blocks in chronological order.
  List<Object> _trainingEntries(Training t) {
    final items = <({int start, Object value})>[
      for (final session in t.sessions)
        (start: sessionStart(session), value: session),
      for (final segment in t.segments) (start: segment.start, value: segment),
    ]..sort((a, b) => a.start.compareTo(b.start));
    return [for (final item in items) item.value];
  }

  Future<void> _declareSegment(
    BuildContext context,
    AppStore store,
    Training training,
    TimelineGap gap,
  ) => _editSegmentSheet(context, store, training, gap: gap);

  Future<void> _editSegment(
    BuildContext context,
    AppStore store,
    Training training,
    TrainingSegment segment,
  ) => _editSegmentSheet(context, store, training, segment: segment);

  /// Declares a gap as a rest or a timer-less exercise, or edits/deletes an
  /// existing declared block. Both feed the timeline behind the heart rate.
  Future<void> _editSegmentSheet(
    BuildContext context,
    AppStore store,
    Training training, {
    TimelineGap? gap,
    TrainingSegment? segment,
  }) async {
    final l = AppLocalizations.of(context)!;
    final start = segment?.start ?? gap!.start;
    final end = segment?.end ?? gap!.end;
    var kind = segment?.kind ?? TrainingSegmentKind.pause;
    var type = segment?.type ?? WorkoutType.conditioning;
    final defaultPause = l.commonPause;
    final nameCtrl = TextEditingController(
      text:
          segment != null &&
              segment.kind == TrainingSegmentKind.pause &&
              segment.name == defaultPause
          ? ''
          : (segment?.name ?? ''),
    );
    final isNew = segment == null;

    final result = await showAppModal<String>(
      context,
      title: isNew ? l.trainingDetailBlockDeclare : l.trainingDetailBlockEdit,
      builder: (_) => StatefulBuilder(
        builder: (ctx, setModalState) => Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              '${fmtTimeOfDay(start)}–${fmtTimeOfDay(end)} · '
              '${fmtDurationHuman((end - start) / 1000)}',
              style: TextStyle(fontSize: 12, color: AppColors.mut),
            ),
            const SizedBox(height: 14),
            Segmented<TrainingSegmentKind>(
              value: kind,
              options: [
                (
                  value: TrainingSegmentKind.pause,
                  label: l.trainingDetailBlockPause,
                ),
                (
                  value: TrainingSegmentKind.activity,
                  label: l.trainingDetailBlockActivity,
                ),
              ],
              onChanged: (v) => setModalState(() => kind = v),
            ),
            if (kind == TrainingSegmentKind.activity) ...[
              const SizedBox(height: 14),
              Field(
                label: l.commonType,
                child: Select<WorkoutType>(
                  value: type,
                  options: [
                    for (final wt in workoutTypes)
                      (
                        value: wt.id,
                        label:
                            '${wt.icon} ${workoutTypeLabel(wt.id, store.lang)}',
                      ),
                  ],
                  onChanged: (v) => setModalState(() => type = v),
                ),
              ),
              const SizedBox(height: 12),
              Field(
                label: l.trainingDetailBlockName,
                child: TextField(
                  controller: nameCtrl,
                  maxLength: 30,
                  decoration: InputDecoration(
                    hintText: l.trainingDetailBlockNameHint,
                    counterText: '',
                  ),
                ),
              ),
            ],
            const SizedBox(height: 18),
            Button(
              label: l.commonSave,
              size: BtnSize.lg,
              onTap: () => Navigator.pop(ctx, 'save'),
            ),
            if (!isNew) ...[
              const SizedBox(height: 8),
              Button(
                label: l.commonDelete,
                variant: BtnVariant.danger,
                onTap: () => Navigator.pop(ctx, 'delete'),
              ),
            ],
          ],
        ),
      ),
    );

    final fallback = kind == TrainingSegmentKind.activity
        ? workoutTypeLabel(type, store.lang)
        : l.commonPause;
    final name = nameCtrl.text.trim();
    nameCtrl.dispose();

    if (result == 'save') {
      final value = TrainingSegment(
        id: segment?.id ?? uid(),
        groupId: training.id,
        start: start,
        end: end,
        kind: kind,
        name: name.isEmpty ? fallback : name,
        type: kind == TrainingSegmentKind.activity ? type : null,
      );
      if (isNew) {
        store.addTrainingSegment(value);
      } else {
        store.updateTrainingSegment(value);
      }
      if (context.mounted) context.showToast(l.trainingDetailBlockSaved);
    } else if (result == 'delete' && segment != null && context.mounted) {
      final before = store.snapshot;
      store.deleteTrainingSegment(segment.id);
      context.showToast(
        l.trainingDetailBlockDeleted,
        actionLabel: l.commonUndo,
        onAction: () => store.restore(before),
      );
    }
  }

  Future<void> _deleteSegment(
    BuildContext context,
    AppStore store,
    TrainingSegment segment,
  ) async {
    final l = AppLocalizations.of(context)!;
    final ok = await showConfirm(
      context,
      title: l.trainingDetailBlockDeleteTitle,
      message: l.trainingDetailBlockDeleteMsg,
      cancelLabel: l.commonCancel,
      confirmLabel: l.commonDelete,
    );
    if (!ok || !context.mounted) return;
    final before = store.snapshot;
    store.deleteTrainingSegment(segment.id);
    context.showToast(
      l.trainingDetailBlockDeleted,
      actionLabel: l.commonUndo,
      onAction: () => store.restore(before),
    );
  }
}

class _Hero extends StatelessWidget {
  final Training training;
  const _Hero({required this.training});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final rounds = training.sessions.fold<int>(
      0,
      (sum, s) => sum + (s.roundsCompleted ?? 0),
    );
    final isRun = training.sessions.any((s) => s.type == WorkoutType.running);
    final metrics = <({String label, String value})>[
      if (isRun && training.distanceKm != null)
        (label: l.progressDistance, value: fmtDistance(training.distanceKm)),
      (label: l.commonDuration, value: fmtDurationHuman(training.durationSec)),
      if (isRun && training.paceSecPerKm != null)
        (label: 'Pace', value: fmtPace(training.paceSecPerKm)),
      if (!isRun && rounds > 0) (label: l.statsRounds, value: '$rounds'),
      (label: l.progressWorkouts, value: '${training.sessions.length}'),
    ];

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        for (var i = 0; i < metrics.length; i++)
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(right: i == metrics.length - 1 ? 0 : 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(metrics[i].label.toUpperCase(), style: AppText.overline),
                  const SizedBox(height: 3),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      metrics[i].value,
                      maxLines: 1,
                      style: const TextStyle(
                        fontSize: 29,
                        height: 1,
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.8,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class _HeartRateChart extends StatefulWidget {
  final Training training;
  final String externalId;
  const _HeartRateChart({required this.training, required this.externalId});

  @override
  State<_HeartRateChart> createState() => _HeartRateChartState();
}

class _ChartData {
  final List<HeartSample> hr;
  final List<DistanceSample> distance;
  const _ChartData(this.hr, this.distance);
}

class _HeartRateChartState extends State<_HeartRateChart> {
  late final Future<_ChartData> _future = _load();

  Future<_ChartData> _load() async {
    final hr = await healthService.series.read(widget.externalId);
    final distance = await healthService.series.readDistance(widget.externalId);
    return _ChartData(hr, distance);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<_ChartData>(
      future: _future,
      builder: (context, snapshot) {
        final data = snapshot.data ?? const _ChartData([], []);
        final samples = data.hr;
        if (samples.length < 2) {
          return Text(
            l.trainingDetailNoHeartRate,
            style: TextStyle(fontSize: 12, color: AppColors.mut),
          );
        }
        final origin = widget.training.start;
        final lastMs = samples.last.ms > widget.training.end
            ? samples.last.ms
            : widget.training.end;
        final maxX = lastMs > origin ? (lastMs - origin) / 60000 : 1.0;
        final spots = [
          for (final sample in samples)
            FlSpot(
              ((sample.ms - origin) / 60000).clamp(0.0, maxX),
              sample.bpm.toDouble(),
            ),
        ];
        var minBpm = samples.first.bpm;
        var maxBpm = samples.first.bpm;
        for (final sample in samples) {
          if (sample.bpm < minBpm) minBpm = sample.bpm;
          if (sample.bpm > maxBpm) maxBpm = sample.bpm;
        }
        final minY = (minBpm - 8).toDouble();
        final maxY = (maxBpm + 8).toDouble();
        final interval = ((maxBpm - minBpm) / 3).clamp(8, 100).toDouble();

        // Declared and recorded blocks, as faint bands behind the curve.
        final bands = <VerticalRangeAnnotation>[];
        for (final segment in trainingTimeline(widget.training, store.lang)) {
          final x1 = ((segment.start - origin) / 60000).clamp(0.0, maxX);
          final x2 = ((segment.end - origin) / 60000).clamp(0.0, maxX);
          if (x2 <= x1) continue;
          final color = segment.kind == TimelineKind.pause
              ? AppColors.mut
              : progressTypeColor(segment.type ?? WorkoutType.other);
          bands.add(
            VerticalRangeAnnotation(x1: x1, x2: x2, color: color.withAlpha(34)),
          );
        }

        // Pace on a second, inverted axis mapped into the BPM space.
        final pace = computePaceSeries(
          samples: data.distance,
          start: origin,
          end: lastMs,
        );
        var paceFast = 0.0;
        var paceSlow = 0.0;
        var paceSpots = const <FlSpot>[];
        var rightInterval = 0.0;
        if (pace.length >= 2) {
          var fast = double.infinity;
          var slow = 0.0;
          for (final point in pace) {
            final value = point.secPerKm.toDouble();
            if (value < fast) fast = value;
            if (value > slow) slow = value;
          }
          if (slow - fast < 8) slow = fast + 8;
          paceFast = fast;
          paceSlow = slow;
          paceSpots = [
            for (final point in pace)
              FlSpot(
                ((point.ms - origin) / 60000).clamp(0.0, maxX),
                maxY - (point.secPerKm - fast) / (slow - fast) * (maxY - minY),
              ),
          ];
          final paceStep = ((slow - fast) / 3).clamp(10.0, 600.0);
          rightInterval = paceStep / (slow - fast) * (maxY - minY);
        }

        double paceAt(double y) =>
            paceFast + (maxY - y) / (maxY - minY) * (paceSlow - paceFast);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                _ChartLegend(
                  color: kProgressRed,
                  label: l.trainingDetailHeartRate,
                ),
                if (paceSpots.isNotEmpty) ...[
                  const SizedBox(width: 14),
                  _ChartLegend(
                    color: kProgressCyan,
                    label: l.trainingDetailPace,
                  ),
                ],
              ],
            ),
            const SizedBox(height: 6),
            SizedBox(
              height: 190,
              child: LineChart(
                LineChartData(
                  minX: 0,
                  maxX: maxX,
                  minY: minY,
                  maxY: maxY,
                  rangeAnnotations: RangeAnnotations(
                    verticalRangeAnnotations: bands,
                  ),
                  gridData: FlGridData(
                    show: true,
                    drawVerticalLine: false,
                    horizontalInterval: interval,
                    getDrawingHorizontalLine: (_) =>
                        FlLine(color: AppColors.line, strokeWidth: 1),
                  ),
                  borderData: FlBorderData(show: false),
                  lineTouchData: const LineTouchData(enabled: false),
                  titlesData: FlTitlesData(
                    topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false),
                    ),
                    rightTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: paceSpots.isNotEmpty,
                        reservedSize: 34,
                        interval: rightInterval <= 0 ? null : rightInterval,
                        getTitlesWidget: (value, meta) => Text(
                          fmtPace(paceAt(value).round()).replaceAll(' /km', ''),
                          style: TextStyle(
                            fontSize: 9,
                            color: kProgressCyan,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    leftTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 31,
                        interval: interval,
                        getTitlesWidget: (value, meta) => Text(
                          value.round().toString(),
                          style: TextStyle(
                            fontSize: 9,
                            color: AppColors.mut,
                            fontFeatures: const [FontFeature.tabularFigures()],
                          ),
                        ),
                      ),
                    ),
                    bottomTitles: AxisTitles(
                      sideTitles: SideTitles(
                        showTitles: true,
                        reservedSize: 22,
                        interval: maxX > 30 ? 10 : 5,
                        getTitlesWidget: (value, meta) => Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            '${value.round()}m',
                            style: TextStyle(fontSize: 9, color: AppColors.mut),
                          ),
                        ),
                      ),
                    ),
                  ),
                  lineBarsData: [
                    LineChartBarData(
                      spots: spots,
                      isCurved: true,
                      curveSmoothness: 0.18,
                      barWidth: 2,
                      color: kProgressRed,
                      dotData: const FlDotData(show: false),
                      belowBarData: BarAreaData(
                        show: true,
                        color: kProgressRed.withAlpha(28),
                      ),
                    ),
                    if (paceSpots.isNotEmpty)
                      LineChartBarData(
                        spots: paceSpots,
                        isCurved: true,
                        curveSmoothness: 0.2,
                        barWidth: 1.8,
                        color: kProgressCyan,
                        dotData: const FlDotData(show: false),
                      ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ChartLegend extends StatelessWidget {
  final Color color;
  final String label;
  const _ChartLegend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        width: 7,
        height: 7,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      const SizedBox(width: 5),
      Text(label.toUpperCase(), style: AppText.micro),
    ],
  );
}

/// The strip above the chart: one block per session or declared piece, with
/// gaps left as tappable "declare this" slots.
class _TimelineStrip extends StatelessWidget {
  final Training training;
  final ValueChanged<TimelineGap> onTapGap;
  final ValueChanged<TrainingSegment> onTapSegment;

  const _TimelineStrip({
    required this.training,
    required this.onTapGap,
    required this.onTapSegment,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final segments = trainingTimeline(training, store.lang);
    final gaps = timelineGaps(training);
    final total = training.end - training.start;
    if (total <= 0) return const SizedBox.shrink();

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        double left(int ms) =>
            ((ms - training.start) / total).clamp(0.0, 1.0) * width;
        double span(int start, int end) =>
            (left(end) - left(start)).clamp(2.0, width);

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(
              height: 30,
              child: Stack(
                children: [
                  for (final gap in gaps)
                    Positioned(
                      left: left(gap.start),
                      width: span(gap.start, gap.end),
                      top: 0,
                      bottom: 0,
                      child: GestureDetector(
                        onTap: () => onTapGap(gap),
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: AppColors.panel2,
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(color: AppColors.line),
                          ),
                          alignment: Alignment.center,
                          child: span(gap.start, gap.end) >= 16
                              ? Icon(
                                  Icons.add_rounded,
                                  size: 13,
                                  color: AppColors.mut,
                                )
                              : null,
                        ),
                      ),
                    ),
                  for (final segment in segments)
                    Positioned(
                      left: left(segment.start),
                      width: span(segment.start, segment.end),
                      top: 0,
                      bottom: 0,
                      child: _TimelineBlock(
                        segment: segment,
                        showLabel: span(segment.start, segment.end) >= 38,
                        onTap: segment.isDeclared
                            ? () {
                                final match = training.segments
                                    .where((s) => s.id == segment.segmentId)
                                    .firstOrNull;
                                if (match != null) onTapSegment(match);
                              }
                            : null,
                      ),
                    ),
                ],
              ),
            ),
            if (gaps.isNotEmpty) ...[
              const SizedBox(height: 5),
              Text(
                l.trainingDetailTimelineHint,
                style: TextStyle(fontSize: 9.5, color: AppColors.mut),
              ),
            ],
          ],
        );
      },
    );
  }
}

class _TimelineBlock extends StatelessWidget {
  final TimelineSegment segment;
  final bool showLabel;
  final VoidCallback? onTap;

  const _TimelineBlock({
    required this.segment,
    required this.showLabel,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = segment.kind == TimelineKind.pause
        ? AppColors.mut
        : progressTypeColor(segment.type ?? WorkoutType.other);
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 1),
        padding: const EdgeInsets.symmetric(horizontal: 5),
        decoration: BoxDecoration(
          color: color.withAlpha(60),
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: color.withAlpha(150)),
        ),
        alignment: Alignment.centerLeft,
        child: showLabel
            ? Text(
                segment.label.toUpperCase(),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 8,
                  height: 1.1,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.2,
                  color: AppColors.ink,
                ),
              )
            : null,
      ),
    );
  }
}

class _SplitsSection extends StatefulWidget {
  final Training training;
  const _SplitsSection({required this.training});

  @override
  State<_SplitsSection> createState() => _SplitsSectionState();
}

class _SplitsSectionState extends State<_SplitsSection> {
  late Future<List<KmSplit>> _future = _load();

  Future<List<KmSplit>> _load() async {
    for (final link in widget.training.links) {
      final distance = await healthService.series.readDistance(link.externalId);
      if (distance.isEmpty) continue;
      final hr = await healthService.series.read(link.externalId);
      return computeKmSplits(
        samples: distance,
        workoutStart: widget.training.start,
        workoutEnd: widget.training.end,
        hrSamples: hr,
      );
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return FutureBuilder<List<KmSplit>>(
      future: _future,
      builder: (context, snapshot) {
        final splits = snapshot.data ?? const <KmSplit>[];
        if (splits.isEmpty) return const SizedBox.shrink();
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.trainingDetailSplits.toUpperCase(), style: AppText.overline),
            const SizedBox(height: 8),
            Container(
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                children: [
                  for (var i = 0; i < splits.length; i++) ...[
                    if (i > 0) Divider(height: 1, color: AppColors.line),
                    _SplitRow(split: splits[i]),
                  ],
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _SplitRow extends StatelessWidget {
  final KmSplit split;
  const _SplitRow({required this.split});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final label = split.isComplete
        ? '${split.index} km'
        : split.distanceKm.toStringAsFixed(1);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
      child: Row(
        children: [
          SizedBox(
            width: 48,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                if (!split.isComplete)
                  Text(
                    l.trainingDetailPartial,
                    style: TextStyle(fontSize: 9, color: AppColors.mut),
                  ),
              ],
            ),
          ),
          Expanded(
            child: Text(
              fmtPace(split.paceSecPerKm),
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w900,
                fontFeatures: [FontFeature.tabularFigures()],
              ),
            ),
          ),
          Text(
            fmtDurationHuman(split.durationSec),
            style: TextStyle(fontSize: 11, color: AppColors.mut),
          ),
          if (split.avgHr != null) ...[
            const SizedBox(width: 10),
            Text(
              l.progressHrBpm(split.avgHr!),
              style: TextStyle(fontSize: 10.5, color: AppColors.mut),
            ),
          ],
        ],
      ),
    );
  }
}

class _ZonesSection extends StatefulWidget {
  final Training training;
  const _ZonesSection({required this.training});

  @override
  State<_ZonesSection> createState() => _ZonesSectionState();
}

class _ZonesSectionState extends State<_ZonesSection> {
  late Future<List<HeartSample>> _future = _load();

  Future<List<HeartSample>> _load() async {
    for (final link in widget.training.links.where((l) => l.hasSeries)) {
      final samples = await healthService.series.read(link.externalId);
      if (samples.isNotEmpty) return samples;
    }
    return const [];
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final maxHr = store.data.settings.maxHeartRate;
    final restingHr = store.data.settings.restingHeartRate;
    return FutureBuilder<List<HeartSample>>(
      future: _future,
      builder: (context, snapshot) {
        final samples = snapshot.data ?? const <HeartSample>[];
        if (samples.isEmpty &&
            snapshot.connectionState != ConnectionState.done) {
          return const SizedBox.shrink();
        }
        if (maxHr == null || restingHr == null) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                l.trainingDetailZones.toUpperCase(),
                style: AppText.overline,
              ),
              const SizedBox(height: 6),
              Text(
                l.trainingDetailZonesSetup,
                style: TextStyle(fontSize: 12, color: AppColors.mut),
              ),
            ],
          );
        }
        final zones = computeKarvonenZones(
          samples: samples,
          maxHr: maxHr,
          restingHr: restingHr,
        );
        if (zones.isEmpty) return const SizedBox.shrink();
        final total = zones.fold<int>(0, (sum, zone) => sum + zone.seconds);
        const colors = [
          kProgressBlue,
          kProgressGreen,
          kProgressYellow,
          kProgressAmber,
          kProgressRed,
        ];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(l.trainingDetailZones.toUpperCase(), style: AppText.overline),
            const SizedBox(height: 8),
            if (total > 0)
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.pill),
                child: SizedBox(
                  height: 8,
                  child: Row(
                    children: [
                      for (var i = 0; i < zones.length; i++)
                        if (zones[i].seconds > 0)
                          Expanded(
                            flex: zones[i].seconds,
                            child: ColoredBox(color: colors[i]),
                          ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 8),
            for (var i = 0; i < zones.length; i++)
              Padding(
                padding: const EdgeInsets.only(bottom: 6),
                child: Row(
                  children: [
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: colors[i],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        l.trainingDetailHrZoneRange(
                          zones[i].index,
                          zones[i].minBpm,
                          zones[i].maxBpm,
                        ),
                        style: const TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      fmtDurationHuman(zones[i].seconds),
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.mut,
                        fontFeatures: const [FontFeature.tabularFigures()],
                      ),
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }
}

class _MiniStats extends StatelessWidget {
  final Training training;
  const _MiniStats({required this.training});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final items = <({String label, String value, Color color})>[
      if (training.avgHr != null)
        (
          label: l.trainingDetailAvgHr,
          value: '${training.avgHr}',
          color: kProgressRed,
        ),
      if (training.maxHr != null)
        (
          label: l.trainingDetailMaxHr,
          value: '${training.maxHr}',
          color: kProgressRed,
        ),
      if (training.energyKcal != null)
        (
          label: l.trainingDetailEnergy,
          value: '${training.energyKcal} kcal',
          color: kProgressAmber,
        ),
      if (training.distanceKm != null)
        (
          label: l.progressDistance,
          value: fmtDistance(training.distanceKm),
          color: kProgressCyan,
        ),
    ];
    if (items.isEmpty) return const SizedBox.shrink();

    return Row(
      children: [
        for (var i = 0; i < items.length; i++) ...[
          if (i > 0) const SizedBox(width: 8),
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(11),
              decoration: BoxDecoration(
                color: AppColors.panel,
                borderRadius: BorderRadius.circular(13),
                border: Border.all(color: AppColors.line),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    items[i].label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: AppText.micro,
                  ),
                  const SizedBox(height: 4),
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Text(
                      items[i].value,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w900,
                        fontFeatures: [FontFeature.tabularFigures()],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

class _HealthDetails extends StatelessWidget {
  final List<HealthLink> links;
  final Lang lang;
  final AppLocalizations l;
  const _HealthDetails({
    required this.links,
    required this.lang,
    required this.l,
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(13),
    decoration: BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppColors.line),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Icons.favorite_rounded, size: 13, color: AppColors.primary),
            const SizedBox(width: 6),
            Text(l.trainingDetailHealth.toUpperCase(), style: AppText.micro),
          ],
        ),
        const SizedBox(height: 7),
        for (final link in links)
          Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Text(
              [
                if (link.sourceName.isNotEmpty) link.sourceName,
                workoutTypeLabel(workoutTypeForActivity(link.activity), lang),
                if (link.energyKcal != null)
                  l.historyEnergy(link.energyKcal!.toString()),
                if (link.distanceKm != null) fmtDistance(link.distanceKm),
              ].join(' · '),
              style: TextStyle(fontSize: 11.5, color: AppColors.mut),
            ),
          ),
      ],
    ),
  );
}

class _SessionCard extends StatelessWidget {
  final SessionRecord session;
  final Color accent;
  final VoidCallback onDelete;
  const _SessionCard({
    required this.session,
    required this.accent,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final s = session;
    final detail = [
      if (s.roundsCompleted != null) '${s.roundsCompleted} ${l.historyRnd}',
      fmtDurationHuman(s.duration),
      if (s.workDuration != null)
        '${fmtDurationHuman(s.workDuration!)} ${l.historyWorkUnit.toLowerCase()}',
    ].join(' · ');

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 11, 6, 9),
      decoration: BoxDecoration(
        color: AppColors.panel,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 3,
                height: 30,
                decoration: BoxDecoration(
                  color: accent,
                  borderRadius: BorderRadius.circular(4),
                ),
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
                        fontSize: 12.5,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      detail,
                      style: TextStyle(fontSize: 10.5, color: AppColors.mut),
                    ),
                  ],
                ),
              ),
              IconButton2(
                Icons.delete_outline,
                size: 18,
                color: AppColors.mut,
                onTap: onDelete,
              ),
            ],
          ),
          if (s.notes != null && s.notes!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Text(s.notes!, style: const TextStyle(fontSize: 12, height: 1.4)),
          ],
          if (s.combosUsed != null && s.combosUsed!.isNotEmpty) ...[
            const SizedBox(height: 7),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (final combo in s.combosUsed!)
                  ChipWidget(
                    label: combo.name.toUpperCase(),
                    active: false,
                    onTap: () {},
                  ),
              ],
            ),
          ],
          if (s.strength != null && s.strength!.isNotEmpty) ...[
            const SizedBox(height: 7),
            for (final entry in s.strength!)
              Text(
                '• ${entry.exercise}: ${entry.sets}×${entry.reps}'
                '${entry.weightKg != null ? ' @ ${_kg(entry.weightKg!)}kg' : ''}',
                style: TextStyle(fontSize: 11.5, color: AppColors.mut),
              ),
          ],
        ],
      ),
    );
  }
}

class _SegmentCard extends StatelessWidget {
  final TrainingSegment segment;
  final VoidCallback onTap;
  final VoidCallback onDelete;

  const _SegmentCard({
    required this.segment,
    required this.onTap,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final isPause = segment.kind == TrainingSegmentKind.pause;
    final accent = isPause
        ? AppColors.mut
        : progressTypeColor(segment.type ?? WorkoutType.other);
    final detail = [
      '${fmtTimeOfDay(segment.start)}–${fmtTimeOfDay(segment.end)}',
      fmtDurationHuman(segment.durationSec),
      if (!isPause)
        workoutTypeLabel(segment.type ?? WorkoutType.other, store.lang),
    ].join(' · ');

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.fromLTRB(12, 11, 6, 9),
        decoration: BoxDecoration(
          color: AppColors.panel,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.line),
        ),
        child: Row(
          children: [
            Container(
              width: 3,
              height: 30,
              decoration: BoxDecoration(
                color: accent,
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        isPause ? Icons.pause_rounded : Icons.bolt_rounded,
                        size: 12,
                        color: accent,
                      ),
                      const SizedBox(width: 4),
                      Flexible(
                        child: Text(
                          segment.name.toUpperCase(),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    detail,
                    style: TextStyle(fontSize: 10.5, color: AppColors.mut),
                  ),
                ],
              ),
            ),
            IconButton2(
              Icons.delete_outline,
              size: 18,
              color: AppColors.mut,
              onTap: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}

String _kg(double value) =>
    value % 1 == 0 ? value.toStringAsFixed(0) : value.toString();
