// Live session player ported from src/pages/LivePage.tsx.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../data/storage.dart';
import '../engine/plan.dart';
import '../engine/resolve.dart';
import '../engine/session_engine.dart';
import '../lib/format.dart';
import '../lib/haptics.dart';
import '../lib/session.dart';
import '../models/types.dart';
import '../app_args.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

class LivePage extends StatefulWidget {
  final LiveConfig? config;
  final int? resumeElapsedMs;

  /// When true and there is no resume point, start immediately instead of
  /// showing the idle "ready" screen.
  final bool autostart;
  const LivePage({
    super.key,
    this.config,
    this.resumeElapsedMs,
    this.autostart = false,
  });

  @override
  State<LivePage> createState() => _LivePageState();
}

class _LivePageState extends State<LivePage> {
  LiveConfig? _config;
  SessionPlan? _plan;
  Set<String>? _seenComboIds;
  bool _exited = false;
  int? _resumeMs;
  bool _checkedSnapshot = false;
  bool _autostart = false;
  SessionEngine? _engine;

  @override
  void initState() {
    super.initState();
    // Unlock landscape on the live screen (prop the phone sideways on the bag);
    // the rest of the app stays portrait. Restored in dispose().
    SystemChrome.setPreferredOrientations(const [
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
    ]);
    WidgetsBinding.instance.addPostFrameCallback((_) => _init());
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations(const [DeviceOrientation.portraitUp]);
    super.dispose();
  }

  Future<void> _init() async {
    if (widget.config != null) {
      _applyConfig(
        widget.config!,
        resumeMs: widget.resumeElapsedMs,
        autostart: widget.autostart,
      );
    } else {
      final snap = await loadActive();
      if (!mounted) return;
      if (snap != null) {
        _applyConfig(
          snap.config,
          resumeMs: snap.totalElapsedMs,
          seenFromPlan: true,
        );
      } else if (mounted) {
        context.go('/');
      }
    }
    setState(() => _checkedSnapshot = true);
  }

  void _applyConfig(
    LiveConfig config, {
    int? resumeMs,
    bool seenFromPlan = false,
    bool autostart = false,
  }) {
    final store = context.read<AppStore>();
    _config = config;
    _plan = buildPlan(config, store.data.techniques, store.data.combinations);
    _seenComboIds = {};
    _resumeMs = resumeMs;
    _autostart = autostart && resumeMs == null;
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    if (!_checkedSnapshot || _config == null || _plan == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.accent)),
      );
    }
    final lang = store.lang;
    final plan = _plan!;
    final cfg = _config!;

    return ChangeNotifierProvider<SessionEngine>(
      key: ValueKey('engine-${cfg.name}-${_resumeMs ?? 0}'),
      create: (_) => SessionEngine(
        plan,
        soundOn: store.data.settings.sound,
        vibrationOn: store.data.settings.vibration && store.vibrationSupported,
        initialElapsedMs: _resumeMs ?? 0,
        onSnapshot: (ms, status) => _onSnapshot(cfg, ms, status),
        onDone: (ms) => _onDone(ms),
      ),
      child: Consumer<SessionEngine>(
        builder: (context, engine, _) {
          final view = engine.view;
          _engine = engine;
          // Routed starts skip the idle "ready" screen: begin immediately.
          if (_autostart && engine.status == EngineStatus.idle) {
            _autostart = false;
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) engine.start();
            });
          }
          // track seen combos
          if (_seenComboIds != null && view.segment?.kind == SegmentKind.work) {
            for (
              var i = 0;
              i <=
                  math.min(
                    view.slotIndex,
                    (view.segment?.slots.length ?? 1) - 1,
                  );
              i++
            ) {
              final id = view.segment!.slots[i].comboId;
              if (id != null) _seenComboIds!.add(id);
            }
          }
          return Scaffold(
            backgroundColor: AppColors.bg,
            body: SafeArea(
              child: engine.status == EngineStatus.idle
                  ? _IdleView(
                      config: cfg,
                      plan: plan,
                      onStart: engine.start,
                      onExit: () => _confirmExit(context),
                    )
                  : _buildActiveView(context, engine, cfg, lang),
            ),
          );
        },
      ),
    );
  }

  Widget _buildActiveView(
    BuildContext context,
    SessionEngine engine,
    LiveConfig cfg,
    Lang lang,
  ) {
    // Endless sessions hot-swap the engine's plan as rounds are appended;
    // always render from the live one.
    final plan = engine.plan;
    final l = AppLocalizations.of(context)!;
    final view = engine.view;
    final segColor = switch (view.segment?.kind) {
      SegmentKind.rest => AppColors.rest,
      SegmentKind.prep => AppColors.warn,
      _ => AppColors.accent,
    };
    final isLandscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;

    final seg = view.segment;
    final roundLabel = seg == null
        ? ''
        : seg.kind == SegmentKind.prep
        ? l.livePreparing
        : seg.kind == SegmentKind.work
        ? l.liveRoundOf(seg.round, seg.totalRounds)
        : l.trainRestSuffix;

    final header = Padding(
      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
      child: Row(
        children: [
          Expanded(
            child: Text(
              cfg.name.toUpperCase(),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 13,
                letterSpacing: 1,
              ),
            ),
          ),
          if (seg != null &&
              seg.totalRounds > 0 &&
              seg.kind != SegmentKind.prep)
            Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Row(
                children: [
                  for (var i = 1; i <= seg.totalRounds; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: i == seg.round ? 14 : 5,
                      height: 5,
                      margin: const EdgeInsets.only(left: 3),
                      decoration: BoxDecoration(
                        color: i <= seg.round ? segColor : AppColors.line,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                ],
              ),
            ),
          Text(
            roundLabel,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.2,
              color: segColor,
            ),
          ),
        ],
      ),
    );

    // Long-press = exit (deliberate, gloved). No swipe gestures change state.
    Widget exitHold(Widget child) => GestureDetector(
      behavior: HitTestBehavior.opaque,
      onLongPress: () => _confirmExit(context, engine),
      child: child,
    );

    final timer = TimerBlock(
      engine: engine,
      view: view,
      plan: plan,
      lang: lang,
    );
    final phase = PhaseContent(
      engine: engine,
      view: view,
      plan: plan,
      lang: lang,
      compact: isLandscape,
    );
    final controls = ControlsBar(
      engine: engine,
      onExit: () => _confirmExit(context, engine),
    );

    final Widget body;
    if (isLandscape) {
      // The surrounding screen stays upright: header remains at the top and
      // controls at the bottom. Only the two timer faces follow the phone's
      // long axis, so athletes on either side can read one of them.
      Widget timerFace(int quarterTurns) => Expanded(
        child: Center(
          child: RotatedBox(
            quarterTurns: quarterTurns,
            child: TimerBlock(
              engine: engine,
              view: view,
              plan: plan,
              lang: lang,
              showMeta: false,
              compact: true,
            ),
          ),
        ),
      );

      final timerFaces = Row(
        children: [
          timerFace(1),
          const SizedBox(width: AppSpacing.md),
          timerFace(3),
        ],
      );
      body = _hasCombo(view)
          ? Column(
              children: [
                Expanded(child: timerFaces),
                SizedBox(
                  height: 260,
                  // Cancel the fixed frame's quarter-turn so combinations
                  // read in the same direction as the primary timer face.
                  child: RotatedBox(quarterTurns: 3, child: phase),
                ),
              ],
            )
          : timerFaces;
    } else if (!_hasCombo(view)) {
      body = Center(
        child: TimerBlock(
          engine: engine,
          view: view,
          plan: plan,
          lang: lang,
          showMeta: false,
        ),
      );
    } else {
      body = Column(
        children: [
          timer,
          Expanded(child: phase),
        ],
      );
    }

    final sessionFrame = Column(
      children: [
        header,
        Expanded(child: exitHold(body)),
        controls,
        const SizedBox(height: 12),
      ],
    );

    if (!isLandscape) return sessionFrame;

    // Keep the portrait frame anchored to the phone itself. In the permitted
    // landscape direction this places the controls on the charging-port edge,
    // with the title on the opposite edge. The timer faces above are rotated
    // inside this frame, so they remain readable from opposite long sides.
    return LayoutBuilder(
      builder: (context, constraints) => Center(
        child: RotatedBox(
          quarterTurns: 1,
          child: SizedBox(
            width: constraints.maxHeight,
            height: constraints.maxWidth,
            child: sessionFrame,
          ),
        ),
      ),
    );
  }

  bool _hasCombo(ResolvedState view) {
    final seg = view.segment;
    if (seg == null || seg.kind != SegmentKind.work || seg.slots.isEmpty)
      return false;
    final idx = view.slotIndex.clamp(0, seg.slots.length - 1);
    final slot = seg.slots[idx];
    return slot.techniqueIds.isNotEmpty || slot.image != null;
  }

  void _onSnapshot(LiveConfig cfg, int ms, EngineStatus status) {
    if (status == EngineStatus.running || status == EngineStatus.paused) {
      saveActive(
        ActiveSnapshot(
          config: cfg,
          totalElapsedMs: ms,
          status: status == EngineStatus.running ? 'running' : 'paused',
          savedAt: DateTime.now().millisecondsSinceEpoch,
        ),
      );
    }
  }

  Future<void> _onDone(int elapsedMs) async {
    if (_exited || !mounted) return;
    await clearActive();
    if (!mounted) return;
    final store = context.read<AppStore>();
    final l = AppLocalizations.of(context)!;
    // Use the engine's (possibly hot-swapped) plan, and for endless sessions
    // truncate the totals to what was actually performed before stopping.
    final plan = _engine?.plan ?? _plan!;
    final summary = buildSummary(
      plan,
      _seenComboIds ?? {},
      store.data.combinations,
      store.data.techniques,
      l,
      elapsedSeconds: _config!.endless ? elapsedMs ~/ 1000 : null,
    );
    // Auto-save: the session is recorded the moment it finishes, so forgetting
    // to press Save on the completion screen can never lose it. The completion
    // screen then only edits this record (RPE / notes / feeling).
    String? sessionId;
    try {
      sessionId = uid();
      store.addSession(
        SessionRecord(
          id: sessionId,
          date: DateTime.now().millisecondsSinceEpoch,
          type: _config!.type,
          source: 'timer',
          workoutId: _config!.workoutId,
          name: _config!.name.toUpperCase(),
          roundsCompleted: summary.totalRounds,
          totalRounds: summary.totalRounds,
          duration: summary.totalSeconds,
          workDuration: summary.workSeconds,
          rpe: null,
          load: 0,
          combosUsed: summary.combosUsed,
          techniqueUsage: summary.techniqueUsage,
        ),
      );
    } catch (_) {
      sessionId = null;
    }
    if (!mounted) return;
    context.pushReplacement(
      '/complete',
      extra: CompleteArgs(_config!, summary, sessionId: sessionId),
    );
  }

  Future<void> _confirmExit(
    BuildContext context, [
    SessionEngine? engine,
  ]) async {
    final l = AppLocalizations.of(context)!;
    // Endless sessions have no natural finish, so stopping is the completion.
    if (_config?.endless == true && engine != null) {
      final choice = await showDialog<_EndlessChoice>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: Text(l.liveStopSaveTitle),
          content: Text(l.liveStopSaveMsg),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx, _EndlessChoice.discard),
              child: Text(l.completeDiscard),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _EndlessChoice.cancel),
              child: Text(l.commonCancel),
            ),
            TextButton(
              onPressed: () => Navigator.pop(ctx, _EndlessChoice.save),
              style: TextButton.styleFrom(
                foregroundColor: AppColors.accent,
                textStyle: const TextStyle(fontWeight: FontWeight.w800),
              ),
              child: Text(l.liveStopAndSave.toUpperCase()),
            ),
          ],
        ),
      );
      if (choice == null || choice == _EndlessChoice.cancel) return;
      if (choice == _EndlessChoice.save) {
        engine.finish();
        return;
      }
      _exited = true;
      await clearActive();
      if (context.mounted) context.go('/');
      return;
    }

    final ok = await showConfirm(
      context,
      title: l.liveExit,
      message: l.liveExitMsg,
      cancelLabel: l.commonCancel,
      confirmLabel: l.liveExit,
    );
    if (!ok) return;
    _exited = true;
    await clearActive();
    if (context.mounted) context.go('/');
  }
}

enum _EndlessChoice { save, discard, cancel }

// ---------------- Idle ----------------

class _IdleView extends StatelessWidget {
  final LiveConfig config;
  final SessionPlan plan;
  final VoidCallback onStart;
  final VoidCallback onExit;
  const _IdleView({
    required this.config,
    required this.plan,
    required this.onStart,
    required this.onExit,
  });

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              IconButton2(Icons.arrow_back, onTap: onExit),
              const Spacer(),
            ],
          ),
          const Spacer(),
          Text(
            config.name.toUpperCase(),
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w900,
              fontSize: 26,
              letterSpacing: 1,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.liveTotal(plan.rounds, fmtClock(plan.totalSeconds)),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.mut,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            l.liveReady,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mut, fontSize: 13),
          ),
          const Spacer(),
          SizedBox(
            height: 96,
            child: Button(
              label: l.commonStart,
              size: BtnSize.xl,
              onTap: onStart,
              expanded: true,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l.liveSoundHint,
            textAlign: TextAlign.center,
            style: const TextStyle(color: AppColors.mut, fontSize: 11.5),
          ),
        ],
      ),
    );
  }
}

// ---------------- Timer block ----------------

class TimerBlock extends StatelessWidget {
  final SessionEngine engine;
  final ResolvedState view;
  final SessionPlan plan;
  final Lang lang;
  final bool showMeta;
  final bool compact;
  const TimerBlock({
    super.key,
    required this.engine,
    required this.view,
    required this.plan,
    required this.lang,
    this.showMeta = true,
    this.compact = false,
  });

  Color get _phaseColor => switch (view.segment?.kind) {
    SegmentKind.rest => AppColors.rest,
    SegmentKind.prep => AppColors.warn,
    _ => AppColors.accent,
  };

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final warnMode =
        view.segRemaining <= 10 &&
        view.segment != null &&
        view.segment!.duration >= 10;
    final last3 = view.segRemaining <= 3;
    final color = last3
        ? Colors.white
        : (warnMode ? AppColors.warn : _phaseColor);
    final seg = view.segment;
    final phaseTag = seg == null
        ? ''
        : switch (seg.kind) {
            SegmentKind.rest => l.trainRestSuffix,
            SegmentKind.prep => l.livePreparing,
            _ => l.commonWork.toUpperCase(),
          };

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
          child: FittedBox(
            fit: BoxFit.scaleDown,
            child: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 150),
              style: TextStyle(
                color: color,
                fontWeight: FontWeight.w900,
                fontFeatures: const [FontFeature.tabularFigures()],
                fontSize: compact
                    ? (last3 ? 124 : (warnMode ? 60 : 70))
                    : (last3 ? 160 : (warnMode ? 76 : 88)),
              ),
              child: Text(
                last3 ? '${view.segRemaining}' : fmtClock(view.segRemaining),
                textAlign: TextAlign.center,
                softWrap: false,
                maxLines: 1,
              ),
            ),
          ),
        ),
        if (showMeta)
          SizedBox(
            height: 22,
            child: Center(
              child: Text(
                phaseTag,
                style: TextStyle(
                  color: _phaseColor,
                  fontSize: compact ? 10 : 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 2,
                ),
              ),
            ),
          ),
        if (engine.status == EngineStatus.paused)
          PulsingLabel(text: l.livePaused),
        if (showMeta && view.segment != null)
          ProgressBar(
            fraction: view.segElapsed / math.max(1, view.segment!.duration),
            color: _phaseColor,
          ),
      ],
    );
  }
}

// The flexible phase content (combo chain, free-round label, rest/prep).
// Kept separate from [TimerBlock] so the landscape layout can place the combo
// on its own side, and drop it entirely when there is nothing to show.
class PhaseContent extends StatelessWidget {
  final SessionEngine engine;
  final ResolvedState view;
  final SessionPlan plan;
  final Lang lang;
  final bool compact;
  const PhaseContent({
    super.key,
    required this.engine,
    required this.view,
    required this.plan,
    required this.lang,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: PhaseBlock(
        engine: engine,
        view: view,
        plan: plan,
        lang: lang,
        compact: compact,
      ),
    ),
  );
}

class PulsingLabel extends StatefulWidget {
  final String text;
  const PulsingLabel({super.key, required this.text});
  @override
  State<PulsingLabel> createState() => _PulsingLabelState();
}

class _PulsingLabelState extends State<PulsingLabel>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )..repeat(reverse: true);
  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween(begin: 0.35, end: 1.0).animate(controller),
    child: Text(
      widget.text.toUpperCase(),
      style: const TextStyle(
        color: AppColors.mut,
        fontSize: 12,
        fontWeight: FontWeight.w800,
        letterSpacing: 2,
      ),
    ),
  );
}

class ProgressBar extends StatefulWidget {
  final double fraction;
  final Color color;
  const ProgressBar({super.key, required this.fraction, required this.color});

  @override
  State<ProgressBar> createState() => _ProgressBarState();
}

// Fluid bar: eases toward the live fraction so a segment completing glides
// 1.0 -> 0.0 instead of snapping, and the phase color cross-fades.
class _ProgressBarState extends State<ProgressBar>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 450),
  );
  late final CurvedAnimation _curve = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
  );

  double _start = 0;
  double _end = 0;
  Color _startColor = AppColors.accent;
  Color _endColor = AppColors.accent;

  double get _value => _start + (_end - _start) * _curve.value;
  Color get _valueColor => Color.lerp(_startColor, _endColor, _curve.value)!;

  @override
  void initState() {
    super.initState();
    _start = widget.fraction.clamp(0.0, 1.0);
    _end = _start;
    _startColor = widget.color;
    _endColor = widget.color;
    _controller.value = 1;
  }

  @override
  void didUpdateWidget(ProgressBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    final target = widget.fraction.clamp(0.0, 1.0);
    if ((target - _value).abs() < 0.0005 && widget.color == _endColor) return;
    _start = _value;
    _startColor = _valueColor;
    _end = target;
    _endColor = widget.color;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) {
      final v = _value.clamp(0.0, 1.0);
      final c = _valueColor;
      return Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.xl,
          vertical: AppSpacing.sm,
        ),
        child: SizedBox(
          height: 8,
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: AppColors.line,
              borderRadius: BorderRadius.circular(99),
            ),
            child: Align(
              alignment: Alignment.centerLeft,
              child: FractionallySizedBox(
                widthFactor: v,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: c,
                    borderRadius: BorderRadius.circular(99),
                    boxShadow: [
                      BoxShadow(
                        color: c.withAlpha(110),
                        blurRadius: 12,
                        spreadRadius: 1,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    },
  );
}

// ---------------- Phase / slots ----------------

String slotTitle(Slot slot, AppLocalizations l, [int? index]) {
  if (!slot.free) {
    if (slot.kind == SlotKind.random) return l.liveRandomSlot((index ?? 0) + 1);
    return slot.name.toUpperCase();
  }
  switch (slot.kind) {
    case SlotKind.defense:
      return l.liveDefenseSlot;
    case SlotKind.conditioning:
      return l.liveConditioningSlot;
    case SlotKind.custom:
      return slot.name.isEmpty ? l.liveCustomSlot : slot.name.toUpperCase();
    default:
      return l.liveFreeSlot;
  }
}

String? slotSubtitle(Slot slot, AppLocalizations l) {
  if (slot.free && slot.kind == SlotKind.free) return l.liveThrowEverything;
  if (slot.free && slot.kind == SlotKind.defense) return l.liveStaySharp;
  return null;
}

class AutoFitText extends StatelessWidget {
  final String text;
  final double maxFontSize;
  final Color color;
  final TextAlign align;
  const AutoFitText(
    this.text, {
    super.key,
    this.maxFontSize = 44,
    this.color = Colors.white,
    this.align = TextAlign.center,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        var size = maxFontSize;
        while (size > 12) {
          final tp = TextPainter(
            text: TextSpan(
              text: text,
              style: TextStyle(
                fontSize: size,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.5,
              ),
            ),
            maxLines: 3,
            textDirection: TextDirection.ltr,
          )..layout(maxWidth: constraints.maxWidth);
          if (!tp.didExceedMaxLines) break;
          size -= 4;
        }
        return Text(
          text,
          textAlign: align,
          style: TextStyle(
            fontSize: size,
            fontWeight: FontWeight.w900,
            height: 1.05,
            letterSpacing: -0.5,
            color: color,
          ),
        );
      },
    );
  }
}

class PhaseBlock extends StatefulWidget {
  final SessionEngine engine;
  final ResolvedState view;
  final SessionPlan plan;
  final Lang lang;
  final bool compact;
  const PhaseBlock({
    super.key,
    required this.engine,
    required this.view,
    required this.plan,
    required this.lang,
    this.compact = false,
  });

  @override
  State<PhaseBlock> createState() => _PhaseBlockState();
}

class _PhaseBlockState extends State<PhaseBlock>
    with SingleTickerProviderStateMixin {
  late final controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 240),
  );
  late Object _lastKey;

  @override
  void initState() {
    super.initState();
    _lastKey = _keyOf();
    controller.forward(from: 0);
  }

  Object _keyOf() {
    final v = widget.view;
    return (v.segIndex, v.slotIndex);
  }

  @override
  void didUpdateWidget(PhaseBlock old) {
    super.didUpdateWidget(old);
    final k = _keyOf();
    if (k != _lastKey) {
      _lastKey = k;
      controller.forward(from: 0);
    }
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final v = widget.view;
    final seg = v.segment;
    if (seg == null) return const SizedBox.shrink();

    Widget content;
    if (seg.kind == SegmentKind.work && seg.slots.isNotEmpty) {
      final idx = v.slotIndex.clamp(0, seg.slots.length - 1);
      final slot = seg.slots[idx];
      content = Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          FadeTransition(
            opacity: CurvedAnimation(parent: controller, curve: Curves.easeOut),
            child: ScaleTransition(
              scale: Tween(begin: 0.94, end: 1.0).animate(
                CurvedAnimation(parent: controller, curve: Curves.easeOutBack),
              ),
              child: SlotContent(
                slot: slot,
                index: idx,
                total: seg.slots.length,
                label: seg.label,
                compact: widget.compact,
              ),
            ),
          ),
          if (seg.slots.length > 1)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < seg.slots.length; i++)
                    Container(
                      width: i == idx ? 16 : 6,
                      height: 6,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i == idx ? Colors.white : AppColors.line,
                        borderRadius: BorderRadius.circular(99),
                      ),
                    ),
                ],
              ),
            ),
        ],
      );
    } else if (seg.kind == SegmentKind.prep) {
      content = Text(
        l.liveGetReady.toUpperCase(),
        style: const TextStyle(
          color: AppColors.warn,
          fontWeight: FontWeight.w900,
          fontSize: 22,
          letterSpacing: 2,
        ),
      );
    } else {
      content = Text(
        l.commonRest.toUpperCase(),
        style: const TextStyle(
          color: AppColors.rest,
          fontWeight: FontWeight.w900,
          fontSize: 26,
          letterSpacing: 2,
        ),
      );
    }

    final preview = nextSlotPreview(widget.plan, v.segIndex, v.slotIndex);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        children: [
          const SizedBox(height: 8),
          content,
          // Only surface the upcoming combo during the break before a round,
          // never while a combo is already on screen.
          if (seg.kind != SegmentKind.work) ...[
            const SizedBox(height: 18),
            NextPreviewRow(preview: preview, lang: widget.lang),
          ],
        ],
      ),
    );
  }
}

class SlotContent extends StatelessWidget {
  final Slot slot;
  final int index;
  final int total;
  final String? label;
  final bool compact;
  const SlotContent({
    super.key,
    required this.slot,
    required this.index,
    required this.total,
    this.label,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final lang = context.read<AppStore>().lang;
    final l = AppLocalizations.of(context)!;
    final title = slotTitle(slot, l, index);
    final subtitle = slotSubtitle(slot, l);

    if (slot.image != null) {
      final size = compact ? 120.0 : 170.0;
      return Column(
        children: [
          SvgPicture.asset(slot.image!, width: size, height: size),
          if (title.isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 20,
                letterSpacing: 1,
              ),
            ),
          ],
        ],
      );
    }

    final techniques = slot.techniqueIds.map((id) {
      final tech = context
          .read<AppStore>()
          .data
          .techniques
          .where((x) => x.id == id)
          .firstOrNullDart();
      return tech?.shortIn(lang) ?? l.sessionUnknown;
    }).toList();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null && label!.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Text(
              label!.toUpperCase(),
              style: const TextStyle(
                color: AppColors.mut,
                fontSize: 12,
                fontWeight: FontWeight.w800,
                letterSpacing: 2,
              ),
            ),
          ),
        if (techniques.isEmpty)
          AutoFitText(title, maxFontSize: compact ? 30 : 46)
        else
          Column(
            children: [
              for (var i = 0; i < techniques.length; i++) ...[
                AutoFitText(techniques[i], maxFontSize: compact ? 28 : 40),
                if (i < techniques.length - 1)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 3),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: AppColors.mut.withAlpha(150),
                    ),
                  ),
              ],
            ],
          ),
        if (subtitle != null)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.mut,
                fontSize: 13,
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
      ],
    );
  }
}

extension FirstOrNullDart<T> on Iterable<T> {
  T? firstOrNullDart() => isEmpty ? null : first;
}

class NextPreviewRow extends StatelessWidget {
  final NextPreview preview;
  final Lang lang;
  const NextPreviewRow({super.key, required this.preview, required this.lang});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    if (preview.kind == PreviewKind.none) return const SizedBox(height: 30);
    final label = preview.kind == PreviewKind.round
        ? l.liveNextRoundShort(preview.round ?? '').toUpperCase()
        : l.liveNext.toUpperCase();
    final slot = preview.slot;
    final String? detail;
    if (slot != null) {
      detail = slot.free
          ? slotTitle(slot, l)
          : slot.techniqueIds
                .map((id) {
                  final tech = context
                      .read<AppStore>()
                      .data
                      .techniques
                      .where((x) => x.id == id)
                      .firstOrNullDart();
                  return tech?.shortIn(lang) ?? l.sessionUnknown;
                })
                .join(' → ');
    } else {
      detail = null;
    }
    final image = slot?.image;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.panel.withAlpha(200),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.line),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.6,
              color: AppColors.mut,
            ),
          ),
          if (image != null) ...[
            const SizedBox(height: 8),
            SvgPicture.asset(image, width: 80, height: 80),
          ],
          if (detail != null) ...[
            const SizedBox(height: 6),
            Text(
              detail,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.ink,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ---------------- Controls ----------------

class ControlsBar extends StatelessWidget {
  final SessionEngine engine;
  final VoidCallback onExit;
  const ControlsBar({super.key, required this.engine, required this.onExit});

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final running = engine.status == EngineStatus.running;
    final done = engine.status == EngineStatus.done;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ControlCircle(
                icon: Icons.skip_previous_rounded,
                size: 72,
                onTap: done
                    ? null
                    : () {
                        Haptics.light();
                        engine.prev();
                      },
                tooltip: l.livePrevious,
              ),
              const SizedBox(width: AppSpacing.lg),
              GestureDetector(
                onTap: done
                    ? null
                    : () {
                        Haptics.light();
                        engine.toggle();
                      },
                child: Container(
                  width: 108,
                  height: 108,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: done
                        ? AppColors.panel2
                        : (running ? AppColors.go : AppColors.accent),
                  ),
                  child: Icon(
                    done
                        ? Icons.check_rounded
                        : (running
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded),
                    size: 54,
                    color: done ? AppColors.mut : Colors.white,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.lg),
              ControlCircle(
                icon: Icons.skip_next_rounded,
                size: 72,
                onTap: done
                    ? null
                    : () {
                        Haptics.light();
                        engine.skip();
                      },
                tooltip: l.liveSkip,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              PillButton(
                label: l.liveRestart,
                icon: Icons.replay_rounded,
                onTap: engine.status == EngineStatus.idle
                    ? null
                    : () async {
                        final ok = await showConfirm(
                          context,
                          title: l.liveRestartTitle,
                          message: l.liveRestartMsg,
                          cancelLabel: l.commonCancel,
                          confirmLabel: l.liveRestart,
                        );
                        if (!ok) return;
                        Haptics.light();
                        engine.restart();
                      },
              ),
              const SizedBox(width: 14),
              PillButton(
                label: l.liveExitWorkout,
                icon: Icons.close,
                onTap: () {
                  Haptics.light();
                  onExit();
                },
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class ControlCircle extends StatelessWidget {
  final IconData icon;
  final double size;
  final VoidCallback? onTap;
  final String tooltip;
  const ControlCircle({
    super.key,
    required this.icon,
    required this.size,
    this.onTap,
    required this.tooltip,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onTap == null ? 0.4 : 1,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          color: AppColors.panel,
        ),
        child: Icon(icon, size: size * 0.45, color: AppColors.ink),
      ),
    ),
  );
}

class PillButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback? onTap;
  const PillButton({
    super.key,
    required this.label,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) => Opacity(
    opacity: onTap == null ? 0.4 : 1,
    child: GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(99),
          border: Border.all(color: AppColors.line),
          color: AppColors.bg,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 15, color: AppColors.mut),
            const SizedBox(width: 7),
            Text(
              label.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.8,
                color: AppColors.mut,
              ),
            ),
          ],
        ),
      ),
    ),
  );
}
