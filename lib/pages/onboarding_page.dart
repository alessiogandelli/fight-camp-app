// First-run onboarding: three animated slides introducing the timer,
// combinations and progress. Self-contained; routed at /onboarding.
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../l10n/app_localizations.dart';
import '../ui/theme.dart';
import '../ui/widgets.dart';

class OnboardingPage extends StatefulWidget {
  const OnboardingPage({super.key});

  @override
  State<OnboardingPage> createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  final PageController _controller = PageController();
  int _index = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _finish() async {
    await context.read<AppStore>().markOnboardingSeen();
    if (!mounted) return;
    // First run is a redirect (nothing to pop): land on Home. Replayed from
    // Settings is a push: return to where the user was.
    if (context.canPop()) {
      context.pop();
    } else {
      context.go('/');
    }
  }

  void _next() {
    if (_index >= 2) {
      _finish();
      return;
    }
    _controller.nextPage(
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    final slides = <({String title, String body, Widget visual})>[
      (
        title: l.onboardingTitle1,
        body: l.onboardingBody1,
        visual: const _CountdownVisual(),
      ),
      (
        title: l.onboardingTitle2,
        body: l.onboardingBody2,
        visual: const _TechniqueChainVisual(),
      ),
      (
        title: l.onboardingTitle3,
        body: l.onboardingBody3,
        visual: const _ProgressVisual(),
      ),
    ];
    final isLast = _index == slides.length - 1;

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md,
                AppSpacing.sm,
                AppSpacing.sm,
                0,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton(
                    onPressed: _finish,
                    style: TextButton.styleFrom(
                      foregroundColor: AppColors.mut,
                      textStyle: const TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                        letterSpacing: 1,
                      ),
                    ),
                    child: Text(l.onboardingSkip.toUpperCase()),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: slides.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final s = slides[i];
                  return _Slide(title: s.title, body: s.body, visual: s.visual);
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < slides.length; i++)
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      curve: Curves.easeOut,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: i == _index ? 24 : 8,
                      decoration: BoxDecoration(
                        color: i == _index ? AppColors.accent : AppColors.line,
                        borderRadius: BorderRadius.circular(AppSpacing.pill),
                      ),
                    ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.lg,
                0,
                AppSpacing.lg,
                AppSpacing.lg,
              ),
              child: SizedBox(
                width: double.infinity,
                child: Button(
                  label: isLast ? l.onboardingStart : l.onboardingNext,
                  size: BtnSize.lg,
                  expanded: true,
                  onTap: _next,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {
  final String title;
  final String body;
  final Widget visual;
  const _Slide({required this.title, required this.body, required this.visual});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 420),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              visual,
              const SizedBox(height: AppSpacing.xl),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w900,
                  height: 1.1,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Text(
                body,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: AppColors.mut,
                  fontSize: 14.5,
                  height: 1.55,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------- Shared card frame ----------

class _VisualCard extends StatelessWidget {
  final Widget child;
  final double width;
  final double? height;
  final Color glow;
  const _VisualCard({
    required this.child,
    required this.width,
    this.height,
    required this.glow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color.lerp(AppColors.panel, glow, 0.10)!, AppColors.panel],
        ),
        border: Border.all(color: AppColors.line),
        boxShadow: [
          BoxShadow(
            color: glow.withAlpha(45),
            blurRadius: 44,
            spreadRadius: -10,
          ),
        ],
      ),
      child: child,
    );
  }
}

// ---------- Slide 1: animated work/rest countdown ----------

class _CountdownVisual extends StatefulWidget {
  const _CountdownVisual();

  @override
  State<_CountdownVisual> createState() => _CountdownVisualState();
}

class _CountdownVisualState extends State<_CountdownVisual>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2600),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _VisualCard(
      width: 220,
      height: 250,
      glow: AppColors.accent,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final v = _ctrl.value;
          final isWork = v < 0.5;
          final phase = isWork ? v * 2 : (v - 0.5) * 2;
          final color = isWork ? AppColors.accent : AppColors.rest;
          final label = (isWork ? l.commonWork : l.commonRest).toUpperCase();
          final seconds = (3 - phase * 3).ceil().clamp(1, 3);
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    CustomPaint(
                      size: const Size.square(150),
                      painter: _RingPainter(
                        progress: 1 - phase,
                        color: color,
                        track: AppColors.panel2,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '$seconds',
                          style: const TextStyle(
                            fontSize: 52,
                            fontWeight: FontWeight.w900,
                            height: 1,
                            fontFeatures: [FontFeature.tabularFigures()],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          label,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w800,
                            letterSpacing: 2,
                            color: color,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < 5; i++)
                    Container(
                      width: 24,
                      height: 5,
                      margin: const EdgeInsets.symmetric(horizontal: 3),
                      decoration: BoxDecoration(
                        color: i <= (phase * 5).floor()
                            ? color
                            : AppColors.panel2,
                        borderRadius: BorderRadius.circular(AppSpacing.pill),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  _RingPainter({
    required this.progress,
    required this.color,
    required this.track,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const stroke = 10.0;
    final rect =
        Offset(stroke / 2, stroke / 2) &
        Size(size.width - stroke, size.height - stroke);
    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke;
    final arcPaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, 0, math.pi * 2, false, trackPaint);
    canvas.drawArc(
      rect,
      -math.pi / 2,
      math.pi * 2 * progress.clamp(0.0, 1.0),
      false,
      arcPaint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.color != color ||
      oldDelegate.track != track;
}

// ---------- Slide 2: animated technique chain ----------

class _TechniqueChainVisual extends StatefulWidget {
  const _TechniqueChainVisual();

  @override
  State<_TechniqueChainVisual> createState() => _TechniqueChainVisualState();
}

class _TechniqueChainVisualState extends State<_TechniqueChainVisual>
    with SingleTickerProviderStateMixin {
  static const _moves = ['JAB', 'CROSS', 'HOOK', 'UPPERCUT'];
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _VisualCard(
      width: 250,
      glow: AppColors.accent,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          final head = _ctrl.value * _moves.length;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(l.comboTechnique.toUpperCase(), style: AppText.overline),
              const SizedBox(height: AppSpacing.md),
              for (var i = 0; i < _moves.length; i++) _chainRow(i, head),
              const SizedBox(height: AppSpacing.xs),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppSpacing.pill),
                child: LinearProgressIndicator(
                  value: _ctrl.value,
                  minHeight: 4,
                  backgroundColor: AppColors.panel2,
                  valueColor: const AlwaysStoppedAnimation(AppColors.accent),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _chainRow(int i, double head) {
    final d = (head - i).abs().clamp(0.0, 1.0);
    final t = 1 - d;
    final bg = Color.lerp(AppColors.panel2, AppColors.accent, t * 0.85)!;
    final border = Color.lerp(AppColors.line, AppColors.accent, t)!;
    final fg = Color.lerp(AppColors.mut, Colors.white, t)!;
    return Transform.scale(
      scale: 1 + 0.04 * t,
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.sm),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 9),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: border),
          boxShadow: t > 0.5
              ? [
                  BoxShadow(
                    color: AppColors.accent.withAlpha((60 * t).round()),
                    blurRadius: 18,
                    spreadRadius: -4,
                  ),
                ]
              : null,
        ),
        child: Row(
          children: [
            Container(
              width: 22,
              height: 22,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withAlpha((40 * t).round()),
                border: Border.all(color: fg),
              ),
              child: Text(
                '${i + 1}',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  color: fg,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Text(
              _moves[i],
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w800,
                letterSpacing: 1,
                color: fg,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ---------- Slide 3: animated bars / streak ----------

class _ProgressVisual extends StatefulWidget {
  const _ProgressVisual();

  @override
  State<_ProgressVisual> createState() => _ProgressVisualState();
}

class _ProgressVisualState extends State<_ProgressVisual>
    with SingleTickerProviderStateMixin {
  static const _bars = <double>[0.45, 0.72, 0.35, 0.86, 0.58, 0.95, 0.5];
  late final AnimationController _ctrl = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2000),
  )..repeat();

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l = AppLocalizations.of(context)!;
    return _VisualCard(
      width: 260,
      height: 250,
      glow: AppColors.accent,
      child: AnimatedBuilder(
        animation: _ctrl,
        builder: (context, _) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.local_fire_department_rounded,
                    color: AppColors.warn,
                    size: 22,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    '12',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      fontFeatures: [FontFeature.tabularFigures()],
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l.statsCurrentStreak.toUpperCase(),
                      style: AppText.micro,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 104,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [for (var i = 0; i < _bars.length; i++) _bar(i)],
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  for (var i = 0; i < 7; i++)
                    Container(
                      width: 10,
                      height: 10,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i < 5 ? AppColors.go : AppColors.panel2,
                        border: Border.all(
                          color: i < 5 ? AppColors.go : AppColors.line,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _bar(int i) {
    final phase = (_ctrl.value + i * 0.11) % 1.0;
    final pulse = 0.82 + 0.18 * math.sin(phase * math.pi * 2);
    final h = (_bars[i] * pulse).clamp(0.08, 1.0);
    return Expanded(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 3),
        child: Align(
          alignment: Alignment.bottomCenter,
          child: Container(
            height: 104 * h,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [Color(0x99FF4D4D), AppColors.accent],
              ),
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(6),
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withAlpha(40),
                  blurRadius: 12,
                  spreadRadius: -4,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
