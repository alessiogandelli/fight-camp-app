// Session engine runtime ported from src/engine/useSessionEngine.ts.
import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../lib/audio.dart';
import '../lib/vibrate.dart';
import 'plan.dart';
import 'resolve.dart';

enum EngineStatus { idle, running, paused, done }

class SessionEngine extends ChangeNotifier {
  final SessionPlan plan;
  final bool soundOn;
  final bool vibrationOn;
  final void Function(int elapsedMs, EngineStatus status)? onSnapshot;
  final VoidCallback? onDone;

  EngineStatus _status;
  ResolvedState _view;
  int _accMs;
  int? _resumeAtMs; // epoch ms
  double _lastT;
  bool _done = false;
  Timer? _timer;

  SessionEngine(
    this.plan, {
    required this.soundOn,
    required this.vibrationOn,
    int initialElapsedMs = 0,
    this.onSnapshot,
    this.onDone,
  })  : _status = initialElapsedMs > 0 ? EngineStatus.paused : EngineStatus.idle,
        _accMs = initialElapsedMs.clamp(0, plan.totalSeconds * 1000),
        _view = resolvePlan(plan, initialElapsedMs / 1000.0),
        _lastT = (initialElapsedMs / 1000.0).clamp(0.0, plan.totalSeconds.toDouble());

  EngineStatus get status => _status;
  ResolvedState get view => _view;

  int get totalMs => _accMs + (_resumeAtMs != null ? DateTime.now().millisecondsSinceEpoch - _resumeAtMs! : 0);

  Future<void> cue(List<CueEvent> evs) async {
    if (evs.any((e) => e is DoneCue)) {
      if (soundOn) await Sound.done();
      await vibrate([300, 100, 300], vibrationOn);
      return;
    }
    final segs = evs.whereType<SegmentCue>().toList();
    if (segs.isNotEmpty) {
      final s = segs.last;
      if (s.kind == SegmentKind.work) {
        if (soundOn) await Sound.work();
        await vibrate(250, vibrationOn);
      } else if (s.kind == SegmentKind.rest) {
        if (soundOn) await Sound.rest();
        await vibrate(120, vibrationOn);
      } else {
        if (soundOn) await Sound.prep();
        await vibrate(120, vibrationOn);
      }
    }
    if (evs.any((e) => e is WarnCue)) {
      if (soundOn) await Sound.warn();
      await vibrate([80, 60, 80], vibrationOn);
    }
    if (evs.any((e) => e is CountCue)) {
      if (soundOn) await Sound.count();
      await vibrate(40, vibrationOn);
    }
    if (segs.isEmpty && evs.any((e) => e is SlotCue)) {
      if (soundOn) await Sound.slot();
      await vibrate(30, vibrationOn);
    }
  }

  void finish() {
    if (_done) return;
    _done = true;
    _accMs = plan.totalSeconds * 1000;
    _resumeAtMs = null;
    _lastT = plan.totalSeconds.toDouble();
    _timer?.cancel();
    WakelockPlus.disable();
    _status = EngineStatus.done;
    _view = resolvePlan(plan, plan.totalSeconds);
    notifyListeners();
    cue([DoneCue()]);
    onSnapshot?.call(plan.totalSeconds * 1000, EngineStatus.done);
    onDone?.call();
  }

  void jumpTo(int sec) {
    var target = sec;
    if (target < 0) target = 0;
    if (target > plan.totalSeconds) target = plan.totalSeconds;
    _accMs = target * 1000;
    if (_resumeAtMs != null) _resumeAtMs = DateTime.now().millisecondsSinceEpoch;
    _lastT = target.toDouble();
    if (target >= plan.totalSeconds) {
      finish();
      return;
    }
    final st = resolvePlan(plan, target.toDouble());
    _view = st;
    notifyListeners();
    if (_resumeAtMs != null && st.segment != null) {
      cue([SegmentCue(st.segment!.kind, st.segment!.round, st.segIndex)]);
    }
    onSnapshot?.call(target * 1000, _resumeAtMs != null ? EngineStatus.running : EngineStatus.paused);
  }

  void _tick() {
    final ms = totalMs;
    final t = ms / 1000.0;
    if (t >= plan.totalSeconds) {
      finish();
      return;
    }
    final evs = eventsBetween(plan, _lastT, t);
    _lastT = t;
    if (evs.isNotEmpty) cue(evs);
    _view = resolvePlan(plan, t);
    notifyListeners();
    onSnapshot?.call(ms, EngineStatus.running);
  }

  void start() {
    if (_status != EngineStatus.idle) return;
    Sound.unlock();
    _done = false;
    _accMs = 0;
    _lastT = 0;
    _resumeAtMs = DateTime.now().millisecondsSinceEpoch;
    _status = EngineStatus.running;
    _view = resolvePlan(plan, 0);
    WakelockPlus.enable();
    notifyListeners();
    if (plan.segments.isNotEmpty) {
      final first = plan.segments.first;
      cue([SegmentCue(first.kind, first.round, 0)]);
    }
    onSnapshot?.call(0, EngineStatus.running);
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void pause() {
    if (_status != EngineStatus.running) return;
    _accMs = totalMs;
    _resumeAtMs = null;
    _timer?.cancel();
    WakelockPlus.disable();
    _status = EngineStatus.paused;
    notifyListeners();
    onSnapshot?.call(_accMs, EngineStatus.paused);
  }

  void resume() {
    if (_status != EngineStatus.paused) return;
    if (_lastT >= plan.totalSeconds) return;
    Sound.unlock();
    _resumeAtMs = DateTime.now().millisecondsSinceEpoch;
    _status = EngineStatus.running;
    WakelockPlus.enable();
    notifyListeners();
    _timer = Timer.periodic(const Duration(milliseconds: 100), (_) => _tick());
  }

  void toggle() {
    switch (_status) {
      case EngineStatus.running:
        pause();
      case EngineStatus.paused:
        resume();
      case EngineStatus.idle:
        start();
      default:
        break;
    }
  }

  void skip() {
    if (_status == EngineStatus.idle || _status == EngineStatus.done) return;
    final t = _lastT;
    var acc = 0;
    var target = plan.totalSeconds;
    for (final s in plan.segments) {
      final end = acc + s.duration;
      if (t < end - 0.001) {
        target = end;
        break;
      }
      acc = end;
    }
    jumpTo(target);
  }

  void prev() {
    if (_status == EngineStatus.idle || _status == EngineStatus.done) return;
    final t = _lastT;
    final st = resolvePlan(plan, t);
    final target =
        (st.segElapsed > 2 || st.segIndex == 0) ? segmentStart(plan, st.segIndex) : segmentStart(plan, st.segIndex - 1);
    jumpTo(target);
  }

  void restart() {
    if (_status == EngineStatus.idle) return;
    _done = false;
    _accMs = 0;
    _lastT = 0;
    if (_status == EngineStatus.running) {
      _resumeAtMs = DateTime.now().millisecondsSinceEpoch;
    } else {
      _resumeAtMs = null;
    }
    _view = resolvePlan(plan, 0);
    notifyListeners();
    onSnapshot?.call(0, _status == EngineStatus.running ? EngineStatus.running : EngineStatus.paused);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
