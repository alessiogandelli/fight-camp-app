// Complete page ported from src/pages/CompletePage.tsx.
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_args.dart';
import '../data/storage.dart';
import '../data/store.dart';
import '../lib/format.dart';
import '../lib/stats.dart' show computeLoad;
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
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
  final _notes = TextEditingController();
  late final AnimationController _heroCtrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 600),
  )..forward();

  @override
  void dispose() {
    _notes.dispose();
    _heroCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;
    final l = AppLocalizations.of(context)!;
    final args = widget.args;

    if (args == null) {
      // Guarded like the web version: redirect home.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (context.mounted) context.go('/');
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final cfg = args.config;
    final summary = args.summary;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 24, 20, 40),
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
                        Text(
                          l.completeHowHard.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 1.2,
                            color: AppColors.mut,
                          ),
                        ),
                        const SizedBox(height: 10),
                        LayoutBuilder(
                          builder: (context, constraints) {
                            // All 10 RPE chips on a single row, sized to fit.
                            const gap = 6.0;
                            final size = ((constraints.maxWidth - gap * 9) / 10)
                                .clamp(30.0, 44.0);
                            return Wrap(
                              spacing: gap,
                              runSpacing: gap,
                              children: [
                                for (var i = 1; i <= 10; i++)
                                  GestureDetector(
                                    onTap: () => setState(() => _rpe = i),
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
                                        borderRadius: BorderRadius.circular(10),
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
                        const SizedBox(height: 8),
                        Text(
                          l.completeRpe + (_rpe != null ? ' ${_rpe}' : ''),
                          style: const TextStyle(
                            fontSize: 12.5,
                            color: AppColors.mut,
                          ),
                        ),
                        if (_rpe != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 4),
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
                  const SizedBox(height: 14),
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
                            onChanged: (v) => setState(() => _energy = v),
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
                                onTap: () => setState(() => _feeling = f),
                              ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Field(
                          label: l.completeNotes,
                          child: TextField(
                            controller: _notes,
                            maxLines: 3,
                            decoration: InputDecoration(
                              hintText: l.completeNotesPlaceholder,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Row(
                    children: [
                      Expanded(
                        child: Button(
                          label: l.completeDiscard,
                          variant: BtnVariant.ghost,
                          size: BtnSize.lg,
                          onTap: () async {
                            final ok = await showConfirm(
                              context,
                              title: l.completeDiscardTitle,
                              message: l.completeDiscardMsg,
                              cancelLabel: l.commonCancel,
                              confirmLabel: l.completeDiscard,
                            );
                            if (!ok || !context.mounted) return;
                            await clearActive();
                            if (context.mounted) context.go('/');
                          },
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Button(
                          label: l.completeSaveSession,
                          size: BtnSize.lg,
                          onTap: _rpe == null
                              ? () => context.showToast(l.completeSelectRpe)
                              : () {
                                  final load = computeLoad(
                                    summary.workSeconds > 0
                                        ? summary.workSeconds
                                        : summary.totalSeconds,
                                    _rpe,
                                  );
                                  store.addSession(
                                    SessionRecord(
                                      id: uid(),
                                      date:
                                          DateTime.now().millisecondsSinceEpoch,
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
                                      notes: _notes.text.trim().isEmpty
                                          ? null
                                          : _notes.text.trim(),
                                      energyBefore: _energy,
                                      feelingAfter: _feeling,
                                      combosUsed: summary.combosUsed,
                                      techniqueUsage: summary.techniqueUsage,
                                    ),
                                  );
                                  clearActive();
                                  context.showToast(l.completeSaved);
                                  context.go('/progress');
                                },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
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
