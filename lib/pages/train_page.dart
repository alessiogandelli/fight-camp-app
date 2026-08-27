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
import '../widgets/pushup_counter.dart';
import '../l10n/app_localizations.dart';

class _TimerPresetDef {
  final String id;
  final String nameIt;
  final String nameEn;
  final int rounds;
  final int work;
  final int rest;
  const _TimerPresetDef(
    this.id,
    this.nameIt,
    this.nameEn,
    this.rounds,
    this.work,
    this.rest,
  );
}

const _presets = <_TimerPresetDef>[
  _TimerPresetDef('sacco-31', "Sacco 3'/1'", "Bag 3'/1'", 5, 180, 60),
  _TimerPresetDef('sacco-21', "Sacco 2'/1'", "Bag 2'/1'", 6, 120, 60),
  _TimerPresetDef('sacco-51', "Sacco 5'/1'", "Bag 5'/1'", 3, 300, 60),
  _TimerPresetDef('tabata-2010', 'Tabata 20"/10"', 'Tabata 20"/10"', 8, 20, 10),
  _TimerPresetDef('hiit-4020', 'HIIT 40"/20"', 'HIIT 40"/20"', 8, 40, 20),
  _TimerPresetDef('free', 'Libero', 'Free', 5, 180, 0),
];

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
  String _presetId = 'sacco-31';
  late TimerSetup _setup;
  bool _useCombos = false;
  List<String> _comboIds = [];
  int _rotationInterval = 30;
  RotationOrder _rotationOrder = RotationOrder.sequential;
  bool _toolsOpen = false;
  TimerSetup? _lastUsed;

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
        _lastUsed = last;
        _setup = TimerSetup(
          rounds: last.rounds,
          work: last.work,
          rest: last.rest,
        );
        _presetId = 'last';
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

  void _applyPreset(_TimerPresetDef p) {
    setState(() {
      _presetId = p.id;
      _setup = TimerSetup(rounds: p.rounds, work: p.work, rest: p.rest);
      if (p.id == 'free') _useCombos = false;
    });
  }

  Future<void> _start() async {
    final l = AppLocalizations.of(context)!;
    final store = context.read<AppStore>();
    final lang = store.lang;
    if (_setup.work < 5) return context.showToast(l.builderMinSeconds);

    unawaited(
      saveLastTimer({
        ..._setup.toJson(),
        'comboIds': _useCombos ? _comboIds : <String>[],
        'rotationInterval': _rotationInterval,
        'rotationOrder': _rotationOrder.name,
      }),
    );

    final def = _presets.firstWhere(
      (p) => p.id == _presetId,
      orElse: () => _presets.first,
    );
    final cfg = LiveConfig(
      name: lang == Lang.en ? def.nameEn : def.nameIt,
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
                  _presetsRow(lang),
                  const SizedBox(height: AppSpacing.lg),
                  _combosSection(lang),
                  const SizedBox(height: AppSpacing.lg),
                  _toolsCard(lang),
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
                _presetId = 'custom';
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
                _presetId = 'custom';
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
            _presetId = 'custom';
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
            _presetId = 'custom';
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

  Widget _presetsRow(Lang lang) {
    final l = AppLocalizations.of(context)!;
    return ShaderMask(
      shaderCallback: (bounds) => const LinearGradient(
        colors: [
          Colors.transparent,
          Colors.black,
          Colors.black,
          Colors.transparent,
        ],
        stops: [0.0, 0.07, 0.93, 1.0],
      ).createShader(bounds),
      blendMode: BlendMode.dstIn,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            const SizedBox(width: AppSpacing.xs),
            if (_lastUsed != null)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChipWidget(
                  label: l.trainLastUsed,
                  active: _presetId == 'last',
                  onTap: () => setState(() {
                    _presetId = 'last';
                    _setup = TimerSetup(
                      rounds: _lastUsed!.rounds,
                      work: _lastUsed!.work,
                      rest: _lastUsed!.rest,
                    );
                  }),
                ),
              ),
            for (final p in _presets)
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: ChipWidget(
                  label: _presetChipLabel(p, lang),
                  active: _presetId == p.id,
                  onTap: () => _applyPreset(p),
                ),
              ),
            const SizedBox(width: AppSpacing.xs),
          ],
        ),
      ),
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

  String _presetChipLabel(_TimerPresetDef p, Lang lang) {
    if (p.id == 'free') return lang == Lang.en ? p.nameEn : p.nameIt;
    return '${_fmtPresetValue(p.work)}💪 ${_fmtPresetValue(p.rest)}💤';
  }

  String _fmtPresetValue(int seconds) {
    if (seconds % 60 == 0) return '${seconds ~/ 60}';
    return '$seconds';
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
      onChanged: (v) => setState(() {
        _setup.rounds = v;
        _presetId = 'custom';
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
                _presetId = 'custom';
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
            fontSize: 52,
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

  Widget _toolsCard(Lang lang) {
    final l = AppLocalizations.of(context)!;
    return CardWidget(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          InkWell(
            onTap: () => setState(() => _toolsOpen = !_toolsOpen),
            borderRadius: BorderRadius.circular(16),
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(
                children: [
                  const Text('💪', style: TextStyle(fontSize: 20)),
                  const SizedBox(width: AppSpacing.sm + 4),
                  Expanded(
                    child: Text(
                      l.trainTools.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 13,
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Icon(
                    _toolsOpen
                        ? Icons.keyboard_arrow_up_rounded
                        : Icons.keyboard_arrow_down_rounded,
                    color: AppColors.mut,
                  ),
                ],
              ),
            ),
          ),
          AnimatedCrossFade(
            duration: const Duration(milliseconds: 180),
            crossFadeState: _toolsOpen
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            firstChild: const SizedBox(width: double.infinity),
            secondChild: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                0,
                AppSpacing.md,
                AppSpacing.md,
              ),
              child: PushupCounterSection(),
            ),
          ),
        ],
      ),
    );
  }
}

/// A widget whose value is adjusted with −/+ buttons flanking its child.
class _StepperValue extends StatelessWidget {
  final Widget child;
  final int step;
  final int min;
  final int max;
  final int current;
  final ValueChanged<int> onChanged;
  const _StepperValue({
    required this.child,
    required this.step,
    required this.min,
    required this.max,
    required this.current,
    required this.onChanged,
  });

  void _apply(int delta) {
    var v = current + delta;
    if (v < min) v = min;
    if (v > max) v = max;
    if (v == current) return;
    onChanged(v);
    HapticFeedback.selectionClick();
  }

  Widget _stepButton(bool plus) {
    final delta = plus ? step : -step;
    final disabled = plus ? current >= max : current <= min;
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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _stepButton(false),
        const SizedBox(width: AppSpacing.sm + 4),
        Expanded(child: child),
        const SizedBox(width: AppSpacing.sm + 4),
        _stepButton(true),
      ],
    );
  }
}
