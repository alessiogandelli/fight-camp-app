// Train page rebuilt around the unified Timer (ADR 0001).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_args.dart';
import '../data/storage.dart';
import '../data/store.dart';
import '../lib/format.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../widgets/combo_picker.dart';
import '../l10n/app_localizations.dart';

class TimerSetup {
  int rounds;
  int work;
  int rest;

  TimerSetup({required this.rounds, required this.work, required this.rest});

  Map<String, dynamic> toJson() => {
    'rounds': rounds,
    'work': work,
    'rest': rest,
  };
  factory TimerSetup.fromJson(Map<String, dynamic> j) => TimerSetup(
    rounds: (j['rounds'] ?? 5) as int,
    work: (j['work'] ?? 180) as int,
    rest: (j['rest'] ?? 60) as int,
  );
}

class TrainPage extends StatefulWidget {
  const TrainPage({super.key});

  @override
  State<TrainPage> createState() => _TrainPageState();
}

class _TrainPageState extends State<TrainPage> {
  ActiveSnapshot? _active;
  late TimerSetup _setup;
  bool _useCombos = false;
  List<String> _comboIds = [];
  int _rotationInterval = 30;
  RotationOrder _rotationOrder = RotationOrder.sequential;

  @override
  void initState() {
    super.initState();
    _setup = TimerSetup(rounds: 5, work: 180, rest: 60);
    loadActive().then((s) {
      if (mounted && s != null) setState(() => _active = s);
    });
    loadLastTimer().then((j) {
      if (!mounted || j == null) return;
      final last = TimerSetup.fromJson(j);
      setState(() {
        _setup = TimerSetup(
          rounds: last.rounds,
          work: last.work,
          rest: last.rest,
        );
        if (j['comboIds'] is List && (j['comboIds'] as List).isNotEmpty) {
          _useCombos = true;
          _comboIds = [...(j['comboIds'] as List).map((e) => e.toString())];
          _rotationInterval = (j['rotationInterval'] ?? 30) as int;
          _rotationOrder = j['rotationOrder'] == 'random'
              ? RotationOrder.random
              : RotationOrder.sequential;
        }
      });
    });
  }

  void refreshActive() async {
    final snap = await loadActive();
    if (mounted) setState(() => _active = snap);
  }

  Future<void> _start() async {
    final l = AppLocalizations.of(context)!;
    final store = context.read<AppStore>();
    if (_setup.work < 5) return context.showToast(l.builderMinSeconds);

    unawaited(
      saveLastTimer({
        ..._setup.toJson(),
        'comboIds': _useCombos ? _comboIds : <String>[],
        'rotationInterval': _rotationInterval,
        'rotationOrder': _rotationOrder.name,
      }),
    );

    final cfg = LiveConfig(
      name: _useCombos && _comboIds.isNotEmpty
          ? l.trainHeavyBagName
          : l.trainFreeRounds,
      type: WorkoutType.heavyBag,
      prepSeconds: store.data.settings.prepSeconds,
      rounds: List.generate(
        _setup.rounds,
        (i) => RoundBase(
          duration: _setup.work,
          restDuration: i < _setup.rounds - 1 ? _setup.rest : 0,
          type: _useCombos && _comboIds.isNotEmpty
              ? RoundType.combination
              : RoundType.free,
          combinationIds: _comboIds,
          rotationInterval: _rotationInterval,
          rotationOrder: _rotationOrder,
        ),
      ),
    );
    context.push('/live', extra: LiveArgs(cfg));
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final lang = store.lang;

    return Column(
      children: [
        if (_active != null)
          _constrain(
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: _activeBanner(lang),
            ),
          ),
        _constrain(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.md,
              AppSpacing.sm,
            ),
            child: _numbersSection(lang),
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: _constrain(
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _combosSection(lang),
                  const SizedBox(height: AppSpacing.lg),
                ],
              ),
            ),
          ),
        ),
        _constrain(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              AppSpacing.sm,
              AppSpacing.md,
              AppSpacing.md,
            ),
            child: _startButton(),
          ),
        ),
      ],
    );
  }

  Widget _constrain(Widget child) => Center(
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 672),
      child: child,
    ),
  );

  Widget _activeBanner(Lang lang) {
    final l = AppLocalizations.of(context)!;
    return CardWidget(
      color: AppColors.accent.withAlpha(24),
      padding: const EdgeInsets.all(14),
      child: Row(
        children: [
          const Icon(
            Icons.play_circle_outline_rounded,
            color: AppColors.accent,
          ),
          const SizedBox(width: AppSpacing.sm + 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l.trainInProgress.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.2,
                    color: AppColors.accent,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _active!.config.name.toUpperCase(),
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
          Button(
            label: l.commonResume,
            size: BtnSize.sm,
            onTap: () => context.push(
              '/live',
              extra: LiveArgs(
                _active!.config,
                resumeElapsedMs: _active!.totalElapsedMs,
              ),
            ),
          ),
          IconButton2(
            Icons.close,
            onTap: () async {
              await clearActive();
              if (mounted) setState(() => _active = null);
            },
          ),
        ],
      ),
    );
  }

  Widget _numbersSection(Lang lang) {
    final l = AppLocalizations.of(context)!;
    if (MediaQuery.orientationOf(context) == Orientation.landscape) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: _StepperValue(
              step: 5,
              min: 5,
              max: 600,
              current: _setup.work,
              onChanged: (v) => setState(() {
                _setup.work = v;
              }),
              child: _bigNumber(
                fmtClock(_setup.work),
                l.commonWork.toUpperCase(),
                AppColors.accent,
              ),
            ),
          ),
          _roundsControl(),
          Expanded(
            child: _StepperValue(
              step: 5,
              min: 0,
              max: 300,
              current: _setup.rest,
              onChanged: (v) => setState(() {
                _setup.rest = v;
              }),
              child: _bigNumber(
                _setup.rest > 0 ? fmtClock(_setup.rest) : '—',
                l.commonRest.toUpperCase(),
                AppColors.rest,
              ),
            ),
          ),
        ],
      );
    }
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _StepperValue(
          step: 5,
          min: 5,
          max: 600,
          current: _setup.work,
          onChanged: (v) => setState(() {
            _setup.work = v;
          }),
          child: _bigNumber(
            fmtClock(_setup.work),
            l.commonWork.toUpperCase(),
            AppColors.accent,
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        _StepperValue(
          step: 5,
          min: 0,
          max: 300,
          current: _setup.rest,
          onChanged: (v) => setState(() {
            _setup.rest = v;
          }),
          child: _bigNumber(
            _setup.rest > 0 ? fmtClock(_setup.rest) : '—',
            l.commonRest.toUpperCase(),
            AppColors.rest,
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        _roundsControl(),
      ],
    );
  }

  Widget _combosSection(Lang lang) {
    final l = AppLocalizations.of(context)!;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                l.trainCombosToggle,
                style: const TextStyle(fontSize: 13.5),
              ),
            ),
            Toggle(
              value: _useCombos,
              onChanged: (v) => setState(() => _useCombos = v),
            ),
          ],
        ),
        AnimatedCrossFade(
          duration: const Duration(milliseconds: 160),
          crossFadeState: _useCombos
              ? CrossFadeState.showSecond
              : CrossFadeState.showFirst,
          firstChild: const SizedBox(width: double.infinity),
          secondChild: Padding(
            padding: const EdgeInsets.only(top: AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Button(
                  label: _comboIds.isEmpty
                      ? l.pickerTitle
                      : '${l.trainSelected(_comboIds.length)} · ${l.commonEdit}',
                  variant: BtnVariant.outline,
                  size: BtnSize.sm,
                  expanded: true,
                  icon: Icons.format_list_numbered_rounded,
                  onTap: () async {
                    final sel = await showComboPicker(
                      context,
                      selected: _comboIds,
                    );
                    if (sel != null && mounted) setState(() => _comboIds = sel);
                  },
                ),
                if (_comboIds.length > 1) ...[
                  const SizedBox(height: AppSpacing.sm + 4),
                  Row(
                    children: [
                      Expanded(
                        child: Field(
                          label: l.trainRotateEvery,
                          child: TimeField(
                            value: _rotationInterval,
                            min: 5,
                            max: 600,
                            step: 5,
                            onChanged: (v) =>
                                setState(() => _rotationInterval = v),
                          ),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Field(
                          label: l.trainOrder,
                          child: Segmented<RotationOrder>(
                            value: _rotationOrder,
                            options: [
                              (
                                value: RotationOrder.sequential,
                                label: l.commonSequential,
                              ),
                              (
                                value: RotationOrder.random,
                                label: l.commonRandom,
                              ),
                            ],
                            onChanged: (v) =>
                                setState(() => _rotationOrder = v),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _startButton() {
    final l = AppLocalizations.of(context)!;
    return Button(
      label: l.commonStart,
      size: BtnSize.xl,
      icon: Icons.play_arrow_rounded,
      expanded: true,
      onTap: _start,
    );
  }

  Widget _roundsControl() {
    final l = AppLocalizations.of(context)!;
    final landscape =
        MediaQuery.orientationOf(context) == Orientation.landscape;
    final number = _bigNumber(
      '×${_setup.rounds}',
      l.commonRounds.toUpperCase(),
      AppColors.ink,
    );
    if (landscape) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _roundButton(false),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '×${_setup.rounds}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                  ),
                ),
                Text(
                  l.commonRounds.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.4,
                    color: AppColors.mut,
                  ),
                ),
              ],
            ),
          ),
          _roundButton(true),
        ],
      );
    }
    return _StepperValue(
      step: 1,
      min: 1,
      max: 30,
      current: _setup.rounds,
      swipeEnabled: false,
      onChanged: (v) => setState(() {
        _setup.rounds = v;
      }),
      child: number,
    );
  }

  Widget _roundButton(bool plus) {
    final delta = plus ? 1 : -1;
    final disabled = plus ? _setup.rounds >= 30 : _setup.rounds <= 1;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled
          ? null
          : () {
              var v = _setup.rounds + delta;
              if (v < 1) v = 1;
              if (v > 30) v = 30;
              if (v == _setup.rounds) return;
              setState(() {
                _setup.rounds = v;
              });
              HapticFeedback.selectionClick();
            },
      child: Container(
        width: 40,
        height: 40,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          color: AppColors.panel,
        ),
        child: Icon(
          plus ? Icons.add_rounded : Icons.remove_rounded,
          size: 20,
          color: disabled ? AppColors.line : AppColors.ink,
        ),
      ),
    );
  }

  Widget _bigNumber(String value, String label, Color color) => Column(
    children: [
      FittedBox(
        fit: BoxFit.scaleDown,
        child: Text(
          value,
          softWrap: false,
          maxLines: 1,
          style: TextStyle(
            fontSize: 46,
            fontWeight: FontWeight.w900,
            color: color,
            height: 1.0,
            fontFeatures: const [],
          ),
        ),
      ),
      const SizedBox(height: AppSpacing.xs),
      Text(
        label,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.6,
          color: AppColors.mut,
        ),
      ),
    ],
  );
}

/// A widget whose value is adjusted with −/+ buttons flanking its child.
/// When [swipeEnabled], dragging horizontally on [child] also steps the value
/// (right = increase, left = decrease) — handy with boxing gloves on.
class _StepperValue extends StatefulWidget {
  final Widget child;
  final int step;
  final int min;
  final int max;
  final int current;
  final ValueChanged<int> onChanged;
  final bool swipeEnabled;
  const _StepperValue({
    required this.child,
    required this.step,
    required this.min,
    required this.max,
    required this.current,
    required this.onChanged,
    this.swipeEnabled = true,
  });

  @override
  State<_StepperValue> createState() => _StepperValueState();
}

class _StepperValueState extends State<_StepperValue> {
  static const _swipeStepPx = 56.0;
  double _dragAccum = 0;

  void _apply(int delta) {
    var v = widget.current + delta;
    if (v < widget.min) v = widget.min;
    if (v > widget.max) v = widget.max;
    if (v == widget.current) return;
    widget.onChanged(v);
    HapticFeedback.selectionClick();
  }

  Widget _stepButton(bool plus) {
    final delta = plus ? widget.step : -widget.step;
    final disabled = plus
        ? widget.current >= widget.max
        : widget.current <= widget.min;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: disabled ? null : () => _apply(delta),
      child: Container(
        width: 44,
        height: 44,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.line),
          color: AppColors.panel,
        ),
        child: Icon(
          plus ? Icons.add_rounded : Icons.remove_rounded,
          size: 22,
          color: disabled ? AppColors.line : AppColors.ink,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final middle = widget.swipeEnabled
        ? GestureDetector(
            behavior: HitTestBehavior.opaque,
            onHorizontalDragUpdate: (d) {
              _dragAccum += d.delta.dx;
              while (_dragAccum.abs() >= _swipeStepPx) {
                final dir = _dragAccum > 0 ? 1 : -1;
                _dragAccum -= dir * _swipeStepPx;
                _apply(dir * widget.step);
              }
            },
            onHorizontalDragEnd: (_) => _dragAccum = 0,
            onHorizontalDragCancel: () => _dragAccum = 0,
            child: widget.child,
          )
        : widget.child;
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepButton(false),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(child: middle),
        const SizedBox(width: AppSpacing.sm + 4),
        _stepButton(true),
      ],
    );
  }
}
