// PROTOTYPE — throwaway. Not production code. Delete after the decision.
//
// Question: does a lateral slide-to-start where the BAR ITSELF is the unlock
// track read as premium, or as a gimmick?
//
// Variant B: idle shows Allenati·AVVIA (bouncing when ready) + the other 3
// tabs. Start dragging the bar -> the tabs morph away and the capsule becomes a
// single full-width glass unlock track. Release past ~70% starts the session;
// release early springs back and the tabs return.
//
// Built on the REAL widget set (liquid_glass_widgets) so it looks like the app,
// not a flat mock. Run:
//   flutter run -t .scratch/bar-explore/prototype.dart

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:liquid_glass_widgets/liquid_glass_widgets.dart';

import 'package:fight_camp/ui/theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LiquidGlassWidgets.initialize();
  runApp(
    LiquidGlassWidgets.wrap(
      child: const PrototypeApp(),
      brightnessResolver: Theme.maybeBrightnessOf,
    ),
  );
}

/// Matches the app's dark matte glass preset (`_navGlassSettings` in main.dart).
const _navGlassSettings = LiquidGlassSettings(
  bodyMode: GlassBodyMode.clear,
  glassColor: Color(0xE6121216),
  blur: 16,
  chromaticAberration: 0,
  refractiveIndex: 1.15,
  saturation: 1.0,
  lightIntensity: 0.12,
  ambientStrength: 0.2,
  glowIntensity: 0.15,
  edgeAbsorption: 0.12,
  backerColor: Color(0x73000000),
);

class PrototypeApp extends StatelessWidget {
  const PrototypeApp({super.key});
  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    theme: buildTheme(),
    home: const BarUnlockPrototype(),
  );
}

class BarUnlockPrototype extends StatefulWidget {
  const BarUnlockPrototype({super.key});
  @override
  State<BarUnlockPrototype> createState() => _BarUnlockPrototypeState();
}

class _BarUnlockPrototypeState extends State<BarUnlockPrototype>
    with TickerProviderStateMixin {
  int _tab = 0;
  double _progress = 0; // 0..1 slide progress
  bool _ready = true;
  bool _started = false;

  late final AnimationController _bounce = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 700),
  )..repeat(reverse: true);

  // 0 = tabs visible, 1 = full unlock track.
  late final AnimationController _morph = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 220),
  );

  // Auto-runs the slide once on launch so the morph can be recorded without
  // input; the manual gesture stays live afterwards.
  late final AnimationController _demo = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 900),
  )
    ..addListener(() => setState(() => _progress = _demo.value))
    ..addStatusListener((s) {
      if (s == AnimationStatus.completed) _start();
    });

  // Repeats until the user takes over (first drag cancels it), so the morph is
  // easy to record/see.
  Timer? _demoTimer;

  @override
  void initState() {
    super.initState();
    _demoTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || _started) return;
      _morph.forward();
      _demo.forward(from: 0);
    });
  }

  @override
  void dispose() {
    _demoTimer?.cancel();
    _bounce.dispose();
    _morph.dispose();
    _demo.dispose();
    super.dispose();
  }

  void _start() {
    if (_started) return;
    setState(() {
      _started = true;
      _ready = false;
      _progress = 0;
    });
    _morph.reverse();
    ScaffoldMessenger.of(context)
      ..clearSnackBars()
      ..showSnackBar(
        const SnackBar(
          content: Text('SESSIONE AVVIATA'),
          duration: Duration(milliseconds: 1300),
        ),
      );
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        setState(() {
          _started = false;
          _ready = true;
        });
      }
    });
  }

  void _configChanged() => setState(() => _ready = true);

  void _dragStart() {
    _demoTimer?.cancel(); // user took over; stop the auto demo
    if (_tab == 0) _morph.forward();
  }

  void _dragUpdate(double dx, double trackWidth) {
    if (_tab != 0 || trackWidth <= 0) return;
    setState(() {
      _progress = (_progress + dx / trackWidth).clamp(0.0, 1.0);
    });
  }

  void _dragEnd() {
    if (_progress >= 0.7) {
      _start();
    } else {
      setState(() => _progress = 0);
      _morph.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            _hint(),
            Expanded(child: _fakeTrainPage()),
          ],
        ),
      ),
      bottomNavigationBar: _bar(),
    );
  }

  Widget _hint() => Padding(
    padding: const EdgeInsets.fromLTRB(20, 10, 20, 4),
    child: Row(
      children: [
        const Expanded(
          child: Text(
            'Trascina la barra verso destra per avviare. '
            'Il resto dei tab sparisce durante lo slide.',
            style: TextStyle(fontSize: 12, color: AppColors.mut),
          ),
        ),
        Text(
          'tab=${_tab == 0 ? "Allenati" : "altro"}  '
          'label=${_tab == 0 ? "AVVIA" : "TIMER"}  '
          'progress=${_progress.toStringAsFixed(2)}  '
          'ready=$_ready',
          style: const TextStyle(fontSize: 10, color: AppColors.mut),
        ),
      ],
    ),
  );

  Widget _fakeTrainPage() => ListView(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
    children: [
      const Text(
        'PRONTO\na combattere?',
        style: TextStyle(
          fontSize: 28,
          height: 1.05,
          fontWeight: FontWeight.w900,
          fontStyle: FontStyle.italic,
        ),
      ),
      const SizedBox(height: 16),
      _card('LAVORO', '03:00'),
      const SizedBox(height: 10),
      _card('RIPOSO', '01:00'),
      const SizedBox(height: 10),
      _card('ROUND', '5'),
    ],
  );

  Widget _card(String label, String value) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    decoration: BoxDecoration(
      color: AppColors.panel,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.line),
    ),
    child: Row(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
            color: AppColors.mut,
            fontSize: 12,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
        ),
        const SizedBox(width: 10),
        GestureDetector(
          onTap: _configChanged,
          child: Container(
            width: 34,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.panel2,
              border: Border.all(color: AppColors.line),
            ),
            child: const Icon(
              Icons.add_rounded,
              size: 18,
              color: AppColors.ink,
            ),
          ),
        ),
      ],
    ),
  );

  Widget _bar() {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        12,
        0,
        12,
        8 + MediaQuery.paddingOf(context).bottom,
      ),
      child: GlassContainer(
        useOwnLayer: true,
        settings: _navGlassSettings,
        shape: const LiquidRoundedSuperellipse(borderRadius: 28),
        height: 64,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final trackWidth = constraints.maxWidth - 24;
            return GestureDetector(
              behavior: HitTestBehavior.opaque,
              onHorizontalDragStart: (_) => _dragStart(),
              onHorizontalDragUpdate: (d) =>
                  _dragUpdate(d.delta.dx, trackWidth),
              onHorizontalDragEnd: (_) => _dragEnd(),
              onHorizontalDragCancel: _dragEnd,
              child: AnimatedBuilder(
                animation: _morph,
                builder: (context, _) {
                  final m = _morph.value;
                  return Stack(
                    children: [
                      // Tabs (fade out while morphing).
                      Positioned.fill(
                        child: IgnorePointer(
                          ignoring: m > 0.5,
                          child: Opacity(opacity: 1 - m, child: _tabs()),
                        ),
                      ),
                      // Unlock track (fade in while morphing).
                      if (m > 0)
                        Positioned.fill(
                          child: Opacity(opacity: m, child: _track(trackWidth)),
                        ),
                    ],
                  );
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _tabs() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 8),
    child: Row(
      children: [
        Expanded(flex: 3, child: _startTab()),
        Expanded(flex: 2, child: _plainTab(Icons.calendar_month_outlined, 'WORKOUT', 1)),
        Expanded(flex: 2, child: _plainTab(Icons.format_list_numbered_outlined, 'LIBRERIA', 2)),
        Expanded(flex: 2, child: _plainTab(Icons.bar_chart_outlined, 'PROGRESSI', 3)),
      ],
    ),
  );

  Widget _plainTab(IconData icon, String label, int index) => GestureDetector(
    behavior: HitTestBehavior.opaque,
    onTap: () => setState(() => _tab = index),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 22, color: AppColors.mut),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.w700,
            color: AppColors.mut,
          ),
        ),
      ],
    ),
  );

  Widget _startTab() {
    final selected = _tab == 0;
    final label = selected ? 'AVVIA' : 'TIMER';
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: selected ? null : () => setState(() => _tab = 0),
      // Accessible fallback: a long-press starts even without the slide.
      onLongPress: selected ? _start : null,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 6, vertical: 8),
        decoration: BoxDecoration(
          color: selected ? Colors.white.withValues(alpha: 0.06) : null,
          borderRadius: BorderRadius.circular(20),
          border: selected
              ? Border.all(color: AppColors.primary.withValues(alpha: 0.35))
              : null,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedBuilder(
              animation: _bounce,
              builder: (context, child) {
                final s = (_ready && selected)
                    ? 1 + 0.12 * Curves.easeInOut.transform(_bounce.value)
                    : 1.0;
                return Transform.scale(scale: s, child: child);
              },
              child: Icon(
                _started ? Icons.check_rounded : Icons.play_arrow_rounded,
                size: 24,
                color: selected ? AppColors.primary : AppColors.mut,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: selected ? AppColors.primary : AppColors.mut,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _track(double trackWidth) {
    const thumbW = 34.0;
    const thumbH = 24.0;
    final travel = (trackWidth - thumbW).clamp(0.0, double.infinity);
    final x = (_progress * travel);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Stack(
        alignment: Alignment.centerLeft,
        children: [
          // Track
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.18),
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Active fill
          Container(
            height: 6,
            width: trackWidth * _progress,
            decoration: BoxDecoration(
              color: AppColors.primary,
              borderRadius: BorderRadius.circular(3),
            ),
          ),
          // Centre label
          Center(
            child: Text(
              _started ? '' : 'AVVIA',
              style: TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.5,
                color: Colors.white.withValues(alpha: 0.55),
              ),
            ),
          ),
          // Thumb (material white pill, like the real iOS slider)
          Positioned(
            left: x,
            child: Container(
              width: thumbW,
              height: thumbH,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(thumbH / 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.25),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Icon(
                _started ? Icons.check_rounded : Icons.arrow_forward_rounded,
                size: 16,
                color: AppColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
