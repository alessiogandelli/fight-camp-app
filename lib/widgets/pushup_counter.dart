// Push-up counter ported from src/components/PushupCounter.tsx + lib/pushups.ts.
import 'dart:async';
import 'dart:math' as math;

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../data/store.dart';
import '../lib/audio.dart';
import '../lib/format.dart';
import '../lib/pushups_detector.dart';
import '../lib/stats.dart' show computeLoad;
import '../lib/vibrate.dart';
import '../models/types.dart';
import '../ui/theme.dart';
import '../ui/toast.dart';
import '../ui/widgets.dart';
import '../l10n/app_localizations.dart';

class PushupCounterSection extends StatefulWidget {
  const PushupCounterSection({super.key});

  @override
  State<PushupCounterSection> createState() => _PushupCounterSectionState();
}

class _PushupCounterSectionState extends State<PushupCounterSection> {
  CameraController? _controller;
  bool _running = false;
  int _count = 0;
  int _startedAt = 0;
  String? _error;
  DetectorState _detector = DetectorState.initial();
  int _sensitivity = 50;
  Timer? _timer;
  late final ValueListenable<TickerModeData> _ticker;

  @override
  void initState() {
    super.initState();
    // The Library branch is kept alive in an IndexedStack (TickerMode=false
    // when another tab is shown): auto-stop so a started counter can never
    // keep beeping on other pages.
    _ticker = TickerMode.getValuesNotifier(context);
    _ticker.addListener(_onVisibility);
  }

  void _onVisibility() {
    if (!_ticker.value.enabled) _stopCamera();
  }

  @override
  void dispose() {
    _ticker.removeListener(_onVisibility);
    _stopCamera();
    super.dispose();
  }

  Future<void> _start() async {
    setState(() => _error = null);
    await Sound.unlock();
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() => _error = 'no-camera');
        return;
      }
      // prefer front camera
      CameraDescription desc = cameras.first;
      for (final c in cameras) {
        if (c.lensDirection == CameraLensDirection.front) desc = c;
      }
      final controller = CameraController(
        desc,
        ResolutionPreset.low,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.yuv420,
      );
      await controller.initialize();
      _controller = controller;
      _detector = DetectorState.initial();
      _startedAt = DateTime.now().millisecondsSinceEpoch;
      setState(() => _running = true);
      controller.startImageStream(_processFrame);
    } on CameraException catch (e) {
      if (e.code == 'cameraPermission' || e.code == 'CameraAccessDenied') {
        setState(() => _error = 'permission');
      } else {
        setState(() => _error = 'generic');
      }
    } catch (_) {
      setState(() => _error = 'generic');
    }
  }

  void _processFrame(CameraImage image) {
    // Throttle to ~30fps.
    final now = DateTime.now().millisecondsSinceEpoch;
    if (_lastFrame != null && now - _lastFrame! < 33) return;
    _lastFrame = now;
    try {
      // Y plane average luminance (Rec.601-ish luma is already the Y channel).
      final y = image.planes.first.bytes;
      var sum = 0;
      const step = 4; // sample every 4th pixel
      var n = 0;
      for (var i = 0; i < y.length; i += step) {
        sum += y[i];
        n++;
      }
      final lum = n == 0 ? 0.0 : sum / n;
      final params = paramsForSensitivity(_sensitivity);
      final res = stepDetector(_detector, lum, now.toDouble(), params);
      _detector = res.state;
      if (!mounted) return;
      // Only rebuild when a rep is counted; per-frame luminance stays local
      // so the UI doesn't rebuild at ~30fps.
      if (res.counted) {
        setState(() => _count += 1);
        Sound.count();
        vibrate(60, context.read<AppStore>().data.settings.vibration);
        HapticFeedback.lightImpact();
      }
    } catch (_) {}
  }

  int? _lastFrame;

  Future<void> _stopCamera() async {
    _timer?.cancel();
    try {
      await _controller?.stopImageStream();
      await _controller?.dispose();
    } catch (_) {}
    _controller = null;
    if (mounted && _running) setState(() => _running = false);
  }

  @override
  Widget build(BuildContext context) {
    final store = context.watch<AppStore>();
    final l = AppLocalizations.of(context)!;
    final calibrated =
        _detector.delta >= paramsForSensitivity(_sensitivity).minDelta;
    final elapsedSec = _running || _count > 0
        ? ((DateTime.now().millisecondsSinceEpoch - _startedAt) / 1000).round()
        : 0;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l.pushupsHint,
          style: const TextStyle(fontSize: 12, color: AppColors.mut),
        ),
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Container(
            height: 180,
            color: AppColors.panel2,
            child: _running && _controller?.value.isInitialized == true
                ? Stack(
                    fit: StackFit.expand,
                    children: [
                      CameraPreview(_controller!),
                      Positioned.fill(
                        child: IgnorePointer(
                          child: Container(
                            alignment: Alignment.topCenter,
                            padding: const EdgeInsets.only(top: 8),
                            color: Colors.black26,
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: AppColors.bg.withAlpha(200),
                                borderRadius: BorderRadius.circular(99),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.circle,
                                    size: 8,
                                    color: calibrated
                                        ? AppColors.go
                                        : AppColors.warn,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    calibrated
                                        ? l.pushupsDetecting
                                        : l.pushupsMoveCloser,
                                    style: TextStyle(
                                      fontSize: 10.5,
                                      fontWeight: FontWeight.w700,
                                      color: calibrated
                                          ? AppColors.go
                                          : AppColors.warn,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Center(
                    child: _error == null
                        ? Icon(
                            Icons.videocam_off_rounded,
                            size: 34,
                            color: AppColors.mut,
                          )
                        : Padding(
                            padding: const EdgeInsets.all(16),
                            child: Text(
                              switch (_error) {
                                'permission' => l.pushupsErrorPermission,
                                'no-camera' => l.pushupsErrorNoCamera,
                                _ => l.pushupsErrorGeneric,
                              },
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: AppColors.mut,
                              ),
                            ),
                          ),
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Field(
                label: l.pushupsSensitivity,
                child: SliderTheme(
                  data: SliderTheme.of(context).copyWith(
                    trackHeight: 4,
                    activeTrackColor: AppColors.accent,
                    inactiveTrackColor: AppColors.line,
                    thumbColor: Colors.white,
                    overlayShape: SliderComponentShape.noOverlay,
                  ),
                  child: Slider(
                    value: _sensitivity.toDouble(),
                    min: 0,
                    max: 100,
                    divisions: 100,
                    onChanged: (v) => setState(() => _sensitivity = v.round()),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 140),
              transitionBuilder: (child, anim) =>
                  ScaleTransition(scale: anim, child: child),
              child: Text(
                '$_count',
                key: ValueKey(_count),
                style: const TextStyle(
                  fontSize: 64,
                  fontWeight: FontWeight.w900,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              l.pushupsCount,
              style: const TextStyle(color: AppColors.mut, fontSize: 13),
            ),
            if (elapsedSec > 0) ...[
              const SizedBox(width: 12),
              Text(
                '· ${fmtClock(elapsedSec)}',
                style: const TextStyle(
                  color: AppColors.mut,
                  fontSize: 13,
                  fontFeatures: [FontFeature.tabularFigures()],
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: Button(
                label: l.commonClear,
                variant: BtnVariant.ghost,
                onTap: () => setState(() {
                  _count = 0;
                  _detector = DetectorState.initial();
                  _startedAt = DateTime.now().millisecondsSinceEpoch;
                }),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Button(
                label: _running ? l.pushupsStop : l.commonStart,
                variant: BtnVariant.outline,
                onTap: () => _running ? _stopCamera() : _start(),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Button(
                label: l.pushupsSave,
                onTap: _count == 0
                    ? () => context.showToast(l.pushupsNothingToSave)
                    : () => _save(store),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _save(AppStore store) async {
    final l = AppLocalizations.of(context)!;
    final durationSec = math.max(
      60,
      ((DateTime.now().millisecondsSinceEpoch - _startedAt) / 1000).round(),
    );
    store.addSession(
      SessionRecord(
        id: uid(),
        date: DateTime.now().millisecondsSinceEpoch,
        type: WorkoutType.strength,
        source: 'manual',
        name: l.pushupsName,
        duration: durationSec,
        load: computeLoad(durationSec, null),
        strength: [
          StrengthEntry(exercise: l.pushupsExercise, sets: 1, reps: _count),
        ],
      ),
    );
    context.showToast(l.pushupsSaved);
    setState(() => _count = 0);
    await _stopCamera();
  }
}
