// History page ported from src/pages/HistoryPage.tsx.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart' show computeLoad;
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

/// History list with search/filter (no scrolling of its own); rendered inside
/// the dedicated [HistoryPage].
class HistoryContent extends StatefulWidget {
  const HistoryContent({super.key});

  @override
  State<HistoryContent> createState() => _HistoryContentState();
}

class _HistoryContentState extends State<HistoryContent> {
  String _query = '';
  final Set<WorkoutType> _types = {};
  DateTime? _from;
  DateTime? _to;
  final Set<String> _expanded = {};

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    var sessions = [...store.data.sessions]
      ..sort((a, b) => b.date.compareTo(a.date));

    if (_query.isNotEmpty) {
      sessions = sessions
          .where(
            (s) =>
                s.name.toLowerCase().contains(_query.toLowerCase()) ||
                (s.notes ?? '').toLowerCase().contains(_query.toLowerCase()),
          )
          .toList();
    }
    if (_types.isNotEmpty) {
      sessions = sessions.where((s) => _types.contains(s.type)).toList();
    }
    if (_from != null)
      sessions = sessions
          .where((s) => s.date >= _from!.millisecondsSinceEpoch)
          .toList();
    if (_to != null) {
      final end = DateTime(_to!.year, _to!.month, _to!.day + 1);
      sessions = sessions
          .where((s) => s.date < end.millisecondsSinceEpoch)
          .toList();
    }

    // group by day
    final groups = <String, List<SessionRecord>>{};
    for (final s in sessions) {
      final key = dateKey(DateTime.fromMillisecondsSinceEpoch(s.date));
      groups.putIfAbsent(key, () => []).add(s);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextField(
          onChanged: (v) => setState(() => _query = v),
          decoration: InputDecoration(
            hintText: l.historySearch,
            prefixIcon: const Icon(Icons.search, color: AppColors.mut),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 6,
          runSpacing: 6,
          children: [
            for (final wt in workoutTypes)
              ChipWidget(
                label: '${wt.icon} ${workoutTypeLabel(wt.id, lang)}',
                active: _types.contains(wt.id),
                onTap: () => setState(
                  () => _types.contains(wt.id)
                      ? _types.remove(wt.id)
                      : _types.add(wt.id),
                ),
              ),
          ],
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: Field(
                label: l.historyFrom,
                child: _DateButton(
                  value: _from,
                  onChanged: (v) => setState(() => _from = v),
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Field(
                label: l.historyTo,
                child: _DateButton(
                  value: _to,
                  onChanged: (v) => setState(() => _to = v),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        if (sessions.isEmpty)
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
          ...groups.entries.map(
            (g) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 10, bottom: 6, left: 4),
                  child: Text(
                    dayLabel(g.value.first.date, lang),
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                      color: AppColors.mut,
                    ),
                  ),
                ),
                ...g.value.map(
                  (s) => _SessionCard(
                    session: s,
                    expanded: _expanded.contains(s.id),
                    onToggle: () => setState(
                      () => _expanded.contains(s.id)
                          ? _expanded.remove(s.id)
                          : _expanded.add(s.id),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

/// Opens the "log a manual session" modal and saves the record on confirmation.
Future<void> showLogSessionModal(BuildContext context, AppStore store) async {
  final lang = store.lang;
  final l = AppLocalizations.of(context)!;
  var type = WorkoutType.other;
  final nameCtrl = TextEditingController();
  int duration = 1800;
  int? rpe;
  int? energy;
  Feeling? feeling;
  final notesCtrl = TextEditingController();
  final distCtrl = TextEditingController();
  final exercises =
      <
        ({
          TextEditingController ex,
          TextEditingController sets,
          TextEditingController reps,
          TextEditingController kg,
        })
      >[];

  final saved = await showAppModal<bool>(
    context,
    title: l.historyLogSession,
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
              label: l.historyNameOptional,
              child: TextInput(controller: nameCtrl, uppercase: true),
            ),
            const SizedBox(height: 10),
            Field(
              label: l.commonDuration,
              hint: l.historyMinDuration,
              child: TimeField(
                value: duration,
                min: 60,
                max: 21600,
                step: 60,
                onChanged: (v) => setModalState(() => duration = v),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              l.completeHowHard.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.mut,
              ),
            ),
            const SizedBox(height: 6),
            Wrap(
              spacing: 5,
              runSpacing: 5,
              children: [
                for (var i = 1; i <= 10; i++)
                  GestureDetector(
                    onTap: () => setModalState(() => rpe = i),
                    child: Container(
                      width: 38,
                      height: 38,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: rpe == i
                            ? (i >= 8 ? AppColors.accent : AppColors.panel2)
                            : AppColors.panel2,
                        borderRadius: BorderRadius.circular(9),
                        border: Border.all(
                          color: rpe == i ? Colors.transparent : AppColors.line,
                        ),
                      ),
                      child: Text(
                        '$i',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 14,
                          color: rpe == i ? Colors.white : AppColors.mut,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            if (rpe != null)
              Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  '${l.commonLoad}: ${computeLoad(duration, rpe)}',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.accent,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            if (type == WorkoutType.running) ...[
              const SizedBox(height: 10),
              Field(
                label: l.historyDistance,
                child: TextInput(controller: distCtrl, hint: '0.0'),
              ),
            ],
            if (type == WorkoutType.strength) ...[
              const SizedBox(height: 12),
              SectionTitle(l.historyExercises),
              for (final e in exercises)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextInput(
                          controller: e.ex,
                          hint: l.historyExercisePlaceholder,
                        ),
                      ),
                      const SizedBox(width: 6),
                      SizedBox(width: 48, child: TextInput(controller: e.sets)),
                      SizedBox(width: 52, child: TextInput(controller: e.reps)),
                      SizedBox(width: 56, child: TextInput(controller: e.kg)),
                      IconButton2(
                        Icons.close,
                        onTap: () => setModalState(() => exercises.remove(e)),
                      ),
                    ],
                  ),
                ),
              Text(
                l.historyNoExercises,
                style: const TextStyle(fontSize: 11, color: AppColors.mut),
              ),
              Button(
                label: l.historyAdd,
                variant: BtnVariant.ghost,
                size: BtnSize.sm,
                icon: Icons.add,
                onTap: () => setModalState(
                  () => exercises.add((
                    ex: TextEditingController(),
                    sets: TextEditingController(),
                    reps: TextEditingController(),
                    kg: TextEditingController(),
                  )),
                ),
              ),
            ],
            const SizedBox(height: 12),
            Field(
              label: l.completeEnergyBefore,
              child: NumStepper(
                value: energy ?? 3,
                min: 1,
                max: 5,
                onChanged: (v) => setModalState(() => energy = v),
              ),
            ),
            const SizedBox(height: 10),
            Wrap(
              spacing: 6,
              runSpacing: 6,
              children: [
                for (final f in Feeling.values)
                  ChipWidget(
                    label: feelingLabel(f, lang),
                    active: feeling == f,
                    onTap: () => setModalState(() => feeling = f),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Field(
              label: l.historyNotes,
              child: TextInput(controller: notesCtrl, maxLines: 3),
            ),
            const SizedBox(height: 16),
            Button(
              label: l.historySaveSession,
              size: BtnSize.lg,
              onTap: () => Navigator.pop(context, true),
            ),
          ],
        );
      },
    ),
  );

  if (saved != true || !context.mounted) return;

  final dist = double.tryParse(distCtrl.text.replaceAll(',', '.'));
  final pace = (dist != null && dist > 0 && duration > 0)
      ? (duration / dist).round()
      : null;
  store.addSession(
    SessionRecord(
      id: uid(),
      date: DateTime.now().millisecondsSinceEpoch,
      type: type,
      source: 'manual',
      name: nameCtrl.text.trim().toUpperCase().isEmpty
          ? workoutTypeLabel(type, lang).toUpperCase()
          : nameCtrl.text.trim().toUpperCase(),
      duration: duration,
      load: computeLoad(duration, rpe),
      rpe: rpe,
      notes: notesCtrl.text.trim().isEmpty ? null : notesCtrl.text.trim(),
      energyBefore: energy,
      feelingAfter: feeling,
      running: type == WorkoutType.running
          ? RunningExtra(distanceKm: dist, paceSecPerKm: pace)
          : null,
      strength: type == WorkoutType.strength
          ? [
              for (final e in exercises)
                StrengthEntry(
                  exercise: e.ex.text.trim(),
                  sets: int.tryParse(e.sets.text) ?? 1,
                  reps: int.tryParse(e.reps.text) ?? 0,
                  weightKg: double.tryParse(e.kg.text.replaceAll(',', '.')),
                ),
            ]
          : null,
    ),
  );
  context.showToast(l.historySessionLogged);
}

class _DateButton extends StatelessWidget {
  final DateTime? value;
  final ValueChanged<DateTime?> onChanged;
  const _DateButton({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: value ?? DateTime.now(),
          firstDate: DateTime(2020),
          lastDate: DateTime(2100),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        height: 46,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: AppColors.panel2,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.line),
        ),
        alignment: Alignment.centerLeft,
        child: Text(
          value != null ? dateKey(value!) : l.commonAll,
          style: const TextStyle(
            fontSize: 13,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
      ),
    );
  }
}

class _SessionCard extends StatelessWidget {
  final SessionRecord session;
  final bool expanded;
  final VoidCallback onToggle;
  const _SessionCard({
    required this.session,
    required this.expanded,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final s = session;

    String detailLine;
    if (s.source == 'manual' && s.type == WorkoutType.running) {
      detailLine = [
        fmtDistance(s.running?.distanceKm),
        fmtClock(s.duration),
        fmtPace(s.running?.paceSecPerKm),
      ].where((x) => x.isNotEmpty).join(' · ');
    } else if (s.source == 'manual' &&
        s.strength != null &&
        s.strength!.isNotEmpty) {
      detailLine =
          '${s.strength!.length} ${s.strength!.length == 1 ? l.unitExercise : l.unitExercises} · ${fmtClock(s.duration)}';
    } else {
      final parts = <String>[];
      if (s.roundsCompleted != null)
        parts.add('${s.roundsCompleted} ${l.historyRnd}');
      if (s.workDuration != null)
        parts.add('${fmtClock(s.workDuration!)} ${l.historyWorkUnit}');
      parts.add(fmtClock(s.duration));
      detailLine = parts.join(' · ');
    }

    return CardWidget(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          InkWell(
            onTap: onToggle,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      workoutTypeMeta(s.type).icon,
                      style: const TextStyle(fontSize: 15),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        s.name.toUpperCase(),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: 12.5,
                        ),
                      ),
                    ),
                    if (s.rpe != null) _Badge(text: 'RPE ${s.rpe}'),
                    if (s.load > 0) ...[
                      const SizedBox(width: 5),
                      _Badge(text: '${l.commonLoad} ${s.load}'),
                    ],
                    Icon(
                      expanded
                          ? Icons.keyboard_arrow_up_rounded
                          : Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.mut,
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  detailLine,
                  style: const TextStyle(fontSize: 11.5, color: AppColors.mut),
                ),
              ],
            ),
          ),
          if (expanded) ...[
            const Divider(color: AppColors.line, height: 20),
            if (s.notes != null && s.notes!.isNotEmpty) ...[
              Text(
                s.notes!,
                style: const TextStyle(fontSize: 12.5, height: 1.45),
              ),
              const SizedBox(height: 8),
            ],
            if (s.energyBefore != null)
              Text(
                l.historyEnergyBefore(s.energyBefore!),
                style: const TextStyle(fontSize: 11.5, color: AppColors.mut),
              ),
            if (s.feelingAfter != null)
              Text(
                l.historyFeelingAfter(feelingLabel(s.feelingAfter!, lang)),
                style: const TextStyle(fontSize: 11.5, color: AppColors.mut),
              ),
            if (s.strength != null && s.strength!.isNotEmpty) ...[
              const SizedBox(height: 8),
              for (final e in s.strength!)
                Text(
                  '• ${e.exercise}: ${e.sets}×${e.reps}${e.weightKg != null ? ' @ ${_kg(e.weightKg!)}kg' : ''}',
                  style: const TextStyle(fontSize: 12, color: AppColors.mut),
                ),
            ],
            if (s.combosUsed != null && s.combosUsed!.isNotEmpty) ...[
              const SizedBox(height: 10),
              SectionTitle(l.historyCombosUsed),
              Wrap(
                spacing: 5,
                runSpacing: 5,
                children: [
                  for (final c in s.combosUsed!)
                    ChipWidget(
                      label: c.name.toUpperCase(),
                      active: false,
                      onTap: () {},
                    ),
                ],
              ),
            ],
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.centerRight,
              child: IconButton2(
                Icons.delete_outline,
                color: AppColors.accent,
                onTap: () async {
                  final ok = await showConfirm(
                    context,
                    title: l.historyDeleteSession,
                    message: l.historyDeleteMsg,
                    cancelLabel: l.commonCancel,
                    confirmLabel: l.commonDelete,
                  );
                  if (ok && context.mounted) {
                    final before = store.snapshot;
                    store.deleteSession(s.id);
                    context.showToast(
                      l.historySessionDeleted,
                      actionLabel: l.commonUndo,
                      onAction: () => store.restore(before),
                    );
                  }
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}

String _kg(double v) => v % 1 == 0 ? v.toStringAsFixed(0) : v.toString();

class _Badge extends StatelessWidget {
  final String text;
  const _Badge({required this.text});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 3),
    decoration: BoxDecoration(
      color: AppColors.panel2,
      borderRadius: BorderRadius.circular(99),
      border: Border.all(color: AppColors.line),
    ),
    child: Text(
      text,
      style: const TextStyle(
        fontSize: 9.5,
        fontWeight: FontWeight.w800,
        color: AppColors.mut,
        letterSpacing: 0.4,
      ),
    ),
  );
}

/// Dedicated History page reached from the Progress tab. Keeps the bottom nav
/// (it is a nested route under /progress) and owns the "log a session" FAB.
class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.md,
            AppSpacing.sm,
            AppSpacing.md,
            96,
          ),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 768),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton2(
                        Icons.arrow_back,
                        onTap: () => context.go('/progress'),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        l.historyTitle.toUpperCase(),
                        style: const TextStyle(
                          fontWeight: FontWeight.w900,
                          fontSize: 15,
                          letterSpacing: 1,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  const HistoryContent(),
                ],
              ),
            ),
          ),
        ),
        Positioned(
          right: 20,
          bottom: 20,
          child: FloatingActionButton(
            heroTag: null,
            backgroundColor: AppColors.accent,
            foregroundColor: Colors.white,
            tooltip: l.historyLogOne,
            onPressed: () => showLogSessionModal(context, store),
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
