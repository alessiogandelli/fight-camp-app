// Complete page: the session was already auto-saved when it finished, so this
// screen only lets the athlete add optional detail (RPE, energy, feeling, notes)
// and confirm. The primary action is always visible; nothing blocks saving.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_args.dart';
import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart' show computeLoad;
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

class CompletePage extends StatefulWidget {
  final CompleteArgs? args;
  const CompletePage({super.key, this.args});

  @override
  State<CompletePage> createState() => _CompletePageState();
}

class _CompletePageState extends State<CompletePage>
    with SingleTickerProviderStateMixin {
  int? _rpe;
  int? _energy;
  Feeling? _feeling;
  bool _showDetails = false;

  /// Id of the stored record. Starts as the auto-saved id; if auto-save failed
  /// it is generated on first persist so the fallback never duplicates.
  String? _savedId;
  final _notes = TextEditingController();
  late final AnimationController _heroCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void initState() {
    super.initState();
    _savedId = widget.args?.sessionId;
  }

  @override
  void dispose() {
    _notes.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  SessionRecord? _existing(AppStore store) {
    final id = _savedId;
    if (id == null) return null;
    for (final s in store.data.sessions) {
      if (s.id == id) return s;
    }
    return null;
  }

  /// Writes the current optional details to the stored session. Auto-save
  /// already recorded the workout; this only enriches it (or creates it when
  /// auto-save failed).
  void _persist() {
    final args = widget.args;
    if (args == null) return;
    final store = context.read<AppStore>();
    final summary = args.summary;
    final cfg = args.config;
    final existing = _existing(store);
    final load = computeLoad(
      summary.workSeconds > 0 ? summary.workSeconds : summary.totalSeconds,
      _rpe,
    );
    final text = _notes.text.trim();
    final record = SessionRecord(
      id: existing?.id ?? (_savedId ??= uid()),
      date: existing?.date ?? DateTime.now().millisecondsSinceEpoch,
      type: cfg.type,
      source: 'timer',
      workoutId: cfg.workoutId,
      name: cfg.name.toUpperCase(),
      roundsCompleted: summary.totalRounds,
      totalRounds: summary.totalRounds,
      duration: summary.totalSeconds,
      workDuration: summary.workSeconds,
      rpe: _rpe,
      load: load,
      notes: text.isEmpty ? null : text,
      energyBefore: _energy,
      feelingAfter: _feeling,
      combosUsed: summary.combosUsed,
      techniqueUsage: summary.techniqueUsage,
    );
    if (existing != null) {
      store.updateSession(record);
    } else {
      store.addSession(record);
    }
  }

  void _done() {
    _persist();
    context.go('/progress');
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final args = widget.args;

    if (args == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final cfg = args.config;
    final summary = args.summary;
    final saved = _savedId != null;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 560),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ScaleTransition(
                          scale: Tween(begin: 0.4, end: 1.0).animate(
                            CurvedAnimation(
                              parent: _heroCtrl,
                              curve: Curves.easeOutBack,
                            ),
                          ),
                          child: FadeTransition(
                            opacity: CurvedAnimation(
                              parent: _heroCtrl,
                              curve: Curves.easeOut,
                            ),
                            child: Container(
                              width: 84,
                              height: 84,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: AppColors.go.withAlpha(28),
                                border: Border.all(
                                  color: AppColors.go.withAlpha(120),
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: AppColors.go.withAlpha(60),
                                    blurRadius: 32,
                                    spreadRadius: 4,
                                  ),
                                ],
                              ),
                              child: const Icon(
                                Icons.check_rounded,
                                color: AppColors.go,
                                size: 44,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 14),
                        Text(
                          l.completeTitle,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 22,
                          ),
                        ),
                        Text(
                          cfg.name.toUpperCase(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.mut,
                            fontSize: 12,
                            letterSpacing: 1.2,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              saved
                                  ? Icons.cloud_done_rounded
                                  : Icons.cloud_off_rounded,
                              size: 14,
                              color: saved ? AppColors.go : AppColors.warn,
                            ),
                            const SizedBox(width: 6),
                            Flexible(
                              child: Text(
                                saved
                                    ? l.completeSavedToProgress
                                    : l.completeAutoSaveFailed,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 11.5,
                                  fontWeight: FontWeight.w700,
                                  color: saved ? AppColors.go : AppColors.warn,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 18),
                        CardWidget(
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  _Stat(
                                    label: l.completeRounds,
                                    value: '${summary.totalRounds}',
                                  ),
                                  _Stat(
                                    label: l.completeEstSession,
                                    value: fmtClock(summary.totalSeconds),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 14),
                              Row(
                                children: [
                                  _Stat(
                                    label: l.completeWork,
                                    value: fmtClock(summary.workSeconds),
                                  ),
                                  _Stat(
                                    label: l.completeRest,
                                    value: fmtClock(summary.restSeconds),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 16),
                        CardWidget(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    l.completeHowHard.toUpperCase(),
                                    style: const TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: 1.2,
                                      color: AppColors.mut,
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Expanded(
                                    child: Text(
                                      l.completeRpeOptional,
                                      textAlign: TextAlign.right,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 10.5,
                                        color: AppColors.mut,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 10),
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  const gap = 6.0;
                                  final size =
                                      ((constraints.maxWidth - gap * 9) / 10)
                                          .clamp(30.0, 44.0);
                                  return Wrap(
                                    spacing: gap,
                                    runSpacing: gap,
                                    children: [
                                      for (var i = 1; i <= 10; i++)
                                        GestureDetector(
                                          onTap: () {
                                            setState(() => _rpe = i);
                                            _persist();
                                          },
                                          child: Container(
                                            width: size,
                                            height: size,
                                            alignment: Alignment.center,
                                            decoration: BoxDecoration(
                                              color: _rpe == i
                                                  ? (i >= 8
                                                        ? AppColors.accent
                                                        : AppColors.panel2)
                                                  : AppColors.bg,
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              border: Border.all(
                                                color: _rpe == i
                                                    ? Colors.transparent
                                                    : AppColors.line,
                                              ),
                                            ),
                                            child: Text(
                                              '$i',
                                              style: TextStyle(
                                                fontSize: size > 38 ? 15 : 13,
                                                fontWeight: FontWeight.w800,
                                                color: _rpe == i
                                                    ? Colors.white
                                                    : AppColors.mut,
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  );
                                },
                              ),
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Text(
                                    l.completeRpeEasy,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.mut,
                                    ),
                                  ),
                                  const Spacer(),
                                  Text(
                                    l.completeRpeMax,
                                    style: const TextStyle(
                                      fontSize: 10.5,
                                      color: AppColors.mut,
                                    ),
                                  ),
                                ],
                              ),
                              if (_rpe != null)
                                Padding(
                                  padding: const EdgeInsets.only(top: 8),
                                  child: Text(
                                    l.completeLoadApprox(
                                      computeLoad(
                                        summary.workSeconds > 0
                                            ? summary.workSeconds
                                            : summary.totalSeconds,
                                        _rpe,
                                      ),
                                    ),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                      color: AppColors.accent,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Button(
                          label: l.completeAddDetails,
                          variant: BtnVariant.ghost,
                          icon: _showDetails
                              ? Icons.expand_less_rounded
                              : Icons.expand_more_rounded,
                          onTap: () =>
                              setState(() => _showDetails = !_showDetails),
                        ),
                        if (_showDetails) ...[
                          const SizedBox(height: 10),
                          CardWidget(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Field(
                                  label: l.completeEnergyBefore,
                                  child: NumStepper(
                                    value: _energy ?? 3,
                                    min: 1,
                                    max: 5,
                                    onChanged: (v) {
                                      setState(() => _energy = v);
                                      _persist();
                                    },
                                  ),
                                ),
                                const SizedBox(height: 14),
                                Wrap(
                                  spacing: 6,
                                  runSpacing: 6,
                                  children: [
                                    for (final f in Feeling.values)
                                      ChipWidget(
                                        label: feelingLabel(f, lang),
                                        active: _feeling == f,
                                        onTap: () {
                                          setState(() => _feeling = f);
                                          _persist();
                                        },
                                      ),
                                  ],
                                ),
                                const SizedBox(height: 14),
                                Field(
                                  label: l.completeNotes,
                                  child: TextField(
                                    controller: _notes,
                                    maxLines: 3,
                                    onChanged: (_) => _persist(),
                                    decoration: InputDecoration(
                                      hintText: l.completeNotesPlaceholder,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 560),
                  child: Button(
                    label: l.completeDone,
                    icon: Icons.check_rounded,
                    size: BtnSize.lg,
                    expanded: true,
                    onTap: _done,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(
      children: [
        Text(
          value.toUpperCase(),
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 19,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(height: 3),
        Text(
          label.toUpperCase(),
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 9,
            fontWeight: FontWeight.w700,
            color: AppColors.mut,
            letterSpacing: 0.8,
          ),
        ),
      ],
    ),
  );
}
