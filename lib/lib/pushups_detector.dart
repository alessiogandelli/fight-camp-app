// Push-up detector algorithm ported verbatim from src/lib/pushups.ts.
class PushupPhase {
  static const up = 'up';
  static const down = 'down';
}

class DetectorParams {
  final double minDelta;
  final double downFrac;
  final double upFrac;
  final int minDownMs;
  final int cooldownMs;
  final double emaAlpha;
  const DetectorParams({
    required this.minDelta,
    required this.downFrac,
    required this.upFrac,
    required this.minDownMs,
    required this.cooldownMs,
    required this.emaAlpha,
  });
}

const defaultParams = DetectorParams(
  minDelta: 25,
  downFrac: 0.35,
  upFrac: 0.65,
  minDownMs: 150,
  cooldownMs: 500,
  emaAlpha: 0.35,
);

DetectorParams paramsForSensitivity(int sensitivity) {
  var s = sensitivity.clamp(0, 100);
  return DetectorParams(
    minDelta: 60 - (s / 100) * 52,
    downFrac: defaultParams.downFrac,
    upFrac: defaultParams.upFrac,
    minDownMs: defaultParams.minDownMs,
    cooldownMs: defaultParams.cooldownMs,
    emaAlpha: defaultParams.emaAlpha,
  );
}

class DetectorState {
  final String phase;
  final double refBright;
  final double refDark;
  final double smoothed;
  final double lastCountAt;
  final int downSince;

  const DetectorState({
    required this.phase,
    required this.refBright,
    required this.refDark,
    required this.smoothed,
    required this.lastCountAt,
    required this.downSince,
  });

  factory DetectorState.initial() => const DetectorState(
    phase: PushupPhase.up,
    refBright: 128,
    refDark: 128,
    smoothed: 128,
    lastCountAt: 0,
    downSince: 0,
  );

  double get delta => refBright - refDark;
}

class StepResult {
  final DetectorState state;
  final bool counted;
  const StepResult(this.state, this.counted);
}

StepResult stepDetector(
  DetectorState prev,
  double luminance,
  double now,
  DetectorParams p,
) {
  final lum = luminance.clamp(0.0, 255.0).toDouble();
  final smoothed = prev.smoothed + (lum - prev.smoothed) * p.emaAlpha;

  // Slowly adapting references for the "bright" (up) and "dark" (down) ends.
  const adapt = 0.02;
  final refBright = smoothed > prev.refBright
      ? smoothed
      : prev.refBright + (smoothed - prev.refBright) * adapt;
  final refDark = smoothed < prev.refDark
      ? smoothed
      : prev.refDark + (smoothed - prev.refDark) * adapt;

  final delta = refBright - refDark;
  if (delta < p.minDelta) {
    return StepResult(
      DetectorState(
        phase: PushupPhase.up,
        refBright: refBright,
        refDark: refDark,
        smoothed: smoothed,
        lastCountAt: prev.lastCountAt,
        downSince: 0,
      ),
      false,
    );
  }

  final downThreshold = refDark + delta * p.downFrac;
  final upThreshold = refDark + delta * p.upFrac;

  var phase = prev.phase;
  var downSince = prev.downSince;
  var lastCountAt = prev.lastCountAt;
  var counted = false;

  if (phase == PushupPhase.up) {
    if (smoothed < downThreshold) {
      phase = PushupPhase.down;
      downSince = now.round();
    }
  } else {
    if (smoothed > upThreshold) {
      final downDuration = now - downSince;
      if (downDuration >= p.minDownMs && now - lastCountAt >= p.cooldownMs) {
        counted = true;
        lastCountAt = now;
      }
      phase = PushupPhase.up;
      downSince = 0;
    }
  }

  return StepResult(
    DetectorState(
      phase: phase,
      refBright: refBright,
      refDark: refDark,
      smoothed: smoothed,
      lastCountAt: lastCountAt,
      downSince: downSince,
    ),
    counted,
  );
}
