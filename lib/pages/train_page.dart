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
    context.push('/live', extra: LiveArgs(cfg));
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
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
          padding: const EdgeInsets.fromLTRB(20, kAppHeaderHeight + 28, 20, 32),
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
    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
    child: Column(
      children: [
        _settingRow(
          icon: Icons.fitness_center_rounded,
          color: AppColors.accent,
          label: l.commonWork,
          value: fmtClock(_setup.work),
          current: _setup.work,
          min: 5,
          max: 600,
          step: 5,
          onChanged: (v) => setState(() => _setup.work = v),
        ),
        const _RowDivider(),
        _settingRow(
          icon: Icons.local_cafe_rounded,
          color: AppColors.rest,
          label: l.commonRest,
          value: _setup.rest > 0 ? fmtClock(_setup.rest) : '—',
          current: _setup.rest,
          min: 0,
          max: 300,
          step: 5,
          onChanged: (v) => setState(() => _setup.rest = v),
        ),
        const _RowDivider(),
        _settingRow(
          icon: Icons.refresh_rounded,
          color: AppColors.ink,
          label: l.commonRounds,
          value: '${_setup.rounds}',
          current: _setup.rounds,
          min: 1,
          max: 30,
          step: 1,
          onChanged: (v) => setState(() => _setup.rounds = v),
        ),
      ],
    ),
  );

  Widget _settingRow({
    required IconData icon,
    required Color color,
    required String label,
    required String value,
    required int current,
    required int min,
    required int max,
    required int step,
    required ValueChanged<int> onChanged,
  }) {
    final canDec = current > min;
    final canInc = current < max;
    void apply(int delta) {
      final v = (current + delta).clamp(min, max);
      if (v == current) return;
      onChanged(v);
      Haptics.selection();
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, color: color, size: 21),
          ),
          const SizedBox(width: AppSpacing.sm + 6),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 12, color: AppColors.mut),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.ink,
                    fontFeatures: [FontFeature.tabularFigures()],
                  ),
                ),
              ],
            ),
          ),
          _CircleStep(plus: false, enabled: canDec, onTap: () => apply(-step)),
          const SizedBox(width: AppSpacing.sm),
          _CircleStep(plus: true, enabled: canInc, onTap: () => apply(step)),
        ],
      ),
    );
  }

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

class _RowDivider extends StatelessWidget {
  const _RowDivider();

  @override
  Widget build(BuildContext context) => const Padding(
    padding: EdgeInsets.only(left: 64, right: 14),
    child: Divider(height: 1, thickness: 1, color: AppColors.line),
  );
}

class _CircleStep extends StatelessWidget {
  final bool plus;
  final bool enabled;
  final VoidCallback onTap;
  const _CircleStep({
    required this.plus,
    required this.enabled,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: enabled ? onTap : null,
    child: Container(
      width: 40,
      height: 40,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.panel2,
        border: Border.all(color: AppColors.line),
      ),
      child: Icon(
        plus ? Icons.add_rounded : Icons.remove_rounded,
        size: 20,
        color: enabled ? AppColors.ink : AppColors.line,
      ),
    ),
  );
}
