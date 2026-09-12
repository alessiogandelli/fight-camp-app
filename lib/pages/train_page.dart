// Train page rebuilt around the unified Timer (ADR 0001).
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../app_args.dart';
import '../data/storage.dart';
import '../data/store.dart';
import '../lib/format.dart';
import '../lib/haptics.dart';
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
  List<String> _comboIds = [];

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
          _comboIds = [...(j['comboIds'] as List).map((e) => e.toString())];
        }
      });
    });
  }

  int get _totalSeconds =>
      _setup.rounds * _setup.work + (_setup.rounds - 1) * _setup.rest;

  Future<void> _start() async {
    final l = AppLocalizations.of(context)!;
    final store = context.read<AppStore>();
    if (_setup.work < 5) return context.showToast(l.builderMinSeconds);

    final useCombos = _comboIds.isNotEmpty;
    unawaited(
      saveLastTimer({
        ..._setup.toJson(),
        'comboIds': useCombos ? _comboIds : <String>[],
      }),
    );

    final cfg = LiveConfig(
      name: useCombos ? l.trainHeavyBagName : l.trainFreeRounds,
      type: WorkoutType.heavyBag,
      prepSeconds: store.data.settings.prepSeconds,
      rounds: List.generate(
        _setup.rounds,
        (i) => RoundBase(
          duration: _setup.work,
          restDuration: i < _setup.rounds - 1 ? _setup.rest : 0,
          type: useCombos ? RoundType.combination : RoundType.free,
          combinationIds: _comboIds,
          rotationInterval: 30,
          rotationOrder: RotationOrder.sequential,
        ),
      ),
    );
    context.push('/live', extra: LiveArgs(cfg, autostart: true));
  }

  Future<void> _editValue({
    required String title,
    required int value,
    required int min,
    required int max,
    required bool isTime,
    required ValueChanged<int> onSet,
  }) async {
    final l = AppLocalizations.of(context)!;
    final controller = TextEditingController(
      text: isTime ? fmtClock(value) : '$value',
    );
    int? parse(String raw) =>
        isTime ? parseTimeInput(raw) : int.tryParse(raw.trim());

    final result = await showDialog<int>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: isTime ? TextInputType.datetime : TextInputType.number,
          decoration: InputDecoration(hintText: isTime ? 'mm:ss' : null),
          onSubmitted: (_) => Navigator.pop(ctx, parse(controller.text)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(l.commonCancel),
          ),
          TextButton(
            onPressed: () => Navigator.pop(ctx, parse(controller.text)),
            style: TextButton.styleFrom(
              foregroundColor: AppColors.accent,
              textStyle: const TextStyle(fontWeight: FontWeight.w800),
            ),
            child: Text(l.commonSave.toUpperCase()),
          ),
        ],
      ),
    );
    if (!mounted || result == null) return;
    final v = result.clamp(min, max);
    if (v == value) return;
    setState(() => onSet(v));
    Haptics.selection();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) => FittedBox(
              fit: BoxFit.scaleDown,
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: constraints.maxWidth,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _hero(l),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                        AppSpacing.md,
                        0,
                        AppSpacing.md,
                        AppSpacing.md,
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_active != null) ...[
                            _activeBanner(l),
                            const SizedBox(height: AppSpacing.md),
                          ],
                          _settingsCard(l),
                          const SizedBox(height: AppSpacing.sm + 4),
                          _combosRow(l),
                          const SizedBox(height: AppSpacing.sm + 4),
                          _statsRow(l),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        _constrain(
          Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.md,
              0,
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

  Widget _hero(AppLocalizations l) => Container(
    width: double.infinity,
    decoration: const BoxDecoration(
      gradient: LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Color(0xFF2A1416), AppColors.bg],
      ),
    ),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 672),
        child: Padding(
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.of(context).padding.top + kAppHeaderHeight + 20,
            20,
            24,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                l.trainReady.toUpperCase(),
                style: const TextStyle(
                  fontSize: 34,
                  height: 1.05,
                  fontWeight: FontWeight.w900,
                  fontStyle: FontStyle.italic,
                  letterSpacing: 0.5,
                  color: AppColors.ink,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                l.trainReadySub,
                style: const TextStyle(fontSize: 14, color: AppColors.mut),
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _activeBanner(AppLocalizations l) => CardWidget(
    color: AppColors.accent.withAlpha(24),
    padding: const EdgeInsets.all(14),
    child: Row(
      children: [
        const Icon(Icons.play_circle_outline_rounded, color: AppColors.accent),
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

  Widget _settingsCard(AppLocalizations l) => CardWidget(
    padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
    child: Column(
      children: [
        _HeroTime(
          keyId: 'work',
          icon: Icons.fitness_center_rounded,
          color: AppColors.accent,
          label: l.commonWork,
          value: fmtClock(_setup.work),
          current: _setup.work,
          min: 5,
          max: 300,
          cap: 3600,
          step: 5,
          onChanged: (v) => setState(() => _setup.work = v),
          onTapValue: () => _editValue(
            title: l.commonWork,
            value: _setup.work,
            min: 5,
            max: 3600,
            isTime: true,
            onSet: (v) => _setup.work = v,
          ),
        ),
        const SizedBox(height: 16),
        _HeroTime(
          keyId: 'rest',
          icon: Icons.bedtime_rounded,
          color: AppColors.rest,
          label: l.commonRest,
          value: _setup.rest > 0 ? fmtClock(_setup.rest) : '—',
          current: _setup.rest,
          min: 0,
          max: 180,
          cap: 1800,
          step: 5,
          onChanged: (v) => setState(() => _setup.rest = v),
          onTapValue: () => _editValue(
            title: l.commonRest,
            value: _setup.rest,
            min: 0,
            max: 1800,
            isTime: true,
            onSet: (v) => _setup.rest = v,
          ),
        ),
        const SizedBox(height: 16),
        const Divider(height: 1, thickness: 1, color: AppColors.line),
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.repeat_rounded, size: 16, color: AppColors.mut),
            const SizedBox(width: 8),
            Text(
              l.commonRounds.toUpperCase(),
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.2,
                color: AppColors.mut,
              ),
            ),
            const Spacer(),
            _CircleStep(
              key: const Key('rounds-minus'),
              plus: false,
              enabled: _setup.rounds > 1,
              size: 34,
              onTap: () => _bump(
                _setup.rounds,
                -1,
                1,
                99,
                (v) => setState(() => _setup.rounds = v),
              ),
            ),
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () => _editValue(
                title: l.commonRounds,
                value: _setup.rounds,
                min: 1,
                max: 99,
                isTime: false,
                onSet: (v) => _setup.rounds = v,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  '${_setup.rounds}',
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            _CircleStep(
              key: const Key('rounds-plus'),
              plus: true,
              enabled: _setup.rounds < 99,
              size: 34,
              onTap: () => _bump(
                _setup.rounds,
                1,
                1,
                99,
                (v) => setState(() => _setup.rounds = v),
              ),
            ),
          ],
        ),
      ],
    ),
  );

  Widget _combosRow(AppLocalizations l) {
    final subtitle = _comboIds.isEmpty
        ? '${l.trainFreeRounds} · ${l.commonEdit.toUpperCase()}'
        : '${l.trainSelections(_comboIds.length).toUpperCase()} · '
              '${l.commonEdit.toUpperCase()}';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: () async {
        final sel = await showComboPicker(context, selected: _comboIds);
        if (sel != null && mounted) setState(() => _comboIds = sel);
      },
      child: CardWidget(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        child: Row(
          children: [
            Icon(
              Icons.format_list_numbered_rounded,
              color: _comboIds.isEmpty ? AppColors.mut : AppColors.ink,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm + 6),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l.trainCombinations,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.0,
                      color: AppColors.mut,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.mut),
          ],
        ),
      ),
    );
  }

  Widget _statsRow(AppLocalizations l) => CardWidget(
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
    child: Row(
      children: [
        Expanded(
          child: _stat(
            icon: Icons.access_time_rounded,
            value: fmtClock(_totalSeconds),
            label: l.trainTotalDuration,
          ),
        ),
        Container(width: 1, height: 38, color: AppColors.line),
        Expanded(
          child: _stat(
            icon: Icons.repeat_rounded,
            value: '${_setup.rounds}',
            label: l.commonRounds,
          ),
        ),
      ],
    ),
  );

  Widget _stat({
    required IconData icon,
    required String value,
    required String label,
  }) => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Icon(icon, size: 22, color: AppColors.mut),
      const SizedBox(width: AppSpacing.sm + 2),
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w900,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
          Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w700,
              letterSpacing: 1.1,
              color: AppColors.mut,
            ),
          ),
        ],
      ),
    ],
  );

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
}

void _bump(
  int current,
  int delta,
  int min,
  int max,
  ValueChanged<int> onChanged,
) {
  final v = (current + delta).clamp(min, max);
  if (v == current) return;
  onChanged(v);
  Haptics.selection();
}

class _HeroTime extends StatelessWidget {
  final String keyId;
  final IconData icon;
  final Color color;
  final String label;
  final String value;
  final int current, min, max, cap, step;
  final ValueChanged<int> onChanged;
  final VoidCallback onTapValue;
  const _HeroTime({
    required this.keyId,
    required this.icon,
    required this.color,
    required this.label,
    required this.value,
    required this.current,
    required this.min,
    required this.max,
    required this.cap,
    required this.step,
    required this.onChanged,
    required this.onTapValue,
  });

  @override
  Widget build(BuildContext context) => Row(
    crossAxisAlignment: CrossAxisAlignment.end,
    children: [
      Expanded(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 15, color: color),
                const SizedBox(width: 7),
                Text(
                  label.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.2,
                    color: AppColors.mut,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            GestureDetector(
              key: Key('$keyId-value'),
              behavior: HitTestBehavior.opaque,
              onTap: onTapValue,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  value,
                  style: const TextStyle(
                    fontSize: 36,
                    height: 0.95,
                    fontWeight: FontWeight.w900,
                    fontStyle: FontStyle.italic,
                    color: AppColors.ink,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            _Scrubber(
              key: Key('$keyId-scrubber'),
              current: current,
              min: min,
              max: max,
              step: step,
              color: color,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
      Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _CircleStep(
            key: Key('$keyId-plus'),
            plus: true,
            enabled: current < cap,
            onTap: () => _bump(current, step, min, cap, onChanged),
          ),
          const SizedBox(height: 10),
          _CircleStep(
            key: Key('$keyId-minus'),
            plus: false,
            enabled: current > min,
            onTap: () => _bump(current, -step, min, cap, onChanged),
          ),
        ],
      ),
    ],
  );
}

class _Scrubber extends StatefulWidget {
  final int current, min, max, step;
  final Color color;
  final ValueChanged<int> onChanged;
  const _Scrubber({
    super.key,
    required this.current,
    required this.min,
    required this.max,
    required this.step,
    required this.color,
    required this.onChanged,
  });

  @override
  State<_Scrubber> createState() => _ScrubberState();
}

class _ScrubberState extends State<_Scrubber> {
  bool _dragging = false;

  void _setFromDx(double dx, double width) {
    if (width <= 0) return;
    final frac = (dx / width).clamp(0.0, 1.0);
    final raw = widget.min + frac * (widget.max - widget.min);
    final v = ((raw / widget.step).round() * widget.step).clamp(
      widget.min,
      widget.max,
    );
    if (v == widget.current) return;
    widget.onChanged(v);
    Haptics.selection();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final width = constraints.maxWidth;
      final span = widget.max - widget.min;
      final frac = span <= 0
          ? 0.0
          : ((widget.current - widget.min) / span).clamp(0.0, 1.0);
      final thickness = _dragging ? 8.0 : 4.0;
      final duration = _dragging
          ? Duration.zero
          : const Duration(milliseconds: 160);
      return GestureDetector(
        behavior: HitTestBehavior.opaque,
        onHorizontalDragStart: (_) => setState(() => _dragging = true),
        onHorizontalDragUpdate: (d) => _setFromDx(d.localPosition.dx, width),
        onHorizontalDragEnd: (_) => setState(() => _dragging = false),
        onHorizontalDragCancel: () => setState(() => _dragging = false),
        child: SizedBox(
          height: 24,
          child: Stack(
            alignment: Alignment.centerLeft,
            children: [
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOut,
                height: thickness,
                decoration: BoxDecoration(
                  color: AppColors.line,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              AnimatedContainer(
                duration: duration,
                curve: Curves.easeOut,
                width: frac * width,
                height: thickness,
                decoration: BoxDecoration(
                  color: widget.color,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

class _CircleStep extends StatelessWidget {
  final bool plus;
  final bool enabled;
  final VoidCallback onTap;
  final double size;
  const _CircleStep({
    super.key,
    required this.plus,
    required this.enabled,
    required this.onTap,
    this.size = 40,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: enabled ? onTap : null,
    child: Container(
      width: size,
      height: size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.panel2,
        border: Border.all(color: AppColors.line),
      ),
      child: Icon(
        plus ? Icons.add_rounded : Icons.remove_rounded,
        size: size * 0.5,
        color: enabled ? AppColors.ink : AppColors.line,
      ),
    ),
  );
}
