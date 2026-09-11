// Auto-save summary truncation + completion-screen editing (no re-duplication).
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/app_args.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/engine/plan.dart';
import 'package:fight_camp/l10n/app_localizations.dart';
import 'package:fight_camp/lib/session.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/models/types.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<AppStore> bootApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(800, 1800);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);
  SharedPreferences.setMockInitialValues({
    'fight-camp:lang': 'it',
    'fight-camp:onboarding-seen': true,
  });
  await tester.pumpWidget(const FightCampApp());
  await tester.pumpAndSettle(const Duration(seconds: 1));
  GoRouter.of(tester.element(find.byType(Text).first)).go('/');
  await tester.pumpAndSettle(const Duration(seconds: 1));
  return tester.element(find.byType(MaterialApp)).read<AppStore>();
}

LiveConfig _cfg() => const LiveConfig(
  name: 'AUTOSAVE',
  type: WorkoutType.heavyBag,
  prepSeconds: 0,
  rounds: [],
);

SessionSummary _summary() => const SessionSummary(
  totalRounds: 3,
  totalSeconds: 300,
  workSeconds: 300,
  restSeconds: 0,
  combosUsed: [],
  techniqueUsage: [],
);

SessionRecord _record(String id) => SessionRecord(
  id: id,
  date: DateTime.now().millisecondsSinceEpoch,
  type: WorkoutType.heavyBag,
  source: 'timer',
  name: 'AUTOSAVE',
  roundsCompleted: 3,
  totalRounds: 3,
  duration: 300,
  workDuration: 300,
  load: 0,
);

void main() {
  test(
    'buildSummary truncates totals to elapsed time for endless sessions',
    () {
      final plan = buildPlan(
        const LiveConfig(
          name: 'T',
          type: WorkoutType.intervals,
          prepSeconds: 0,
          rounds: [
            RoundBase(duration: 10, restDuration: 5, type: RoundType.free),
            RoundBase(duration: 10, restDuration: 5, type: RoundType.free),
            RoundBase(duration: 10, restDuration: 0, type: RoundType.free),
          ],
        ),
        const [],
        const [],
      );
      // Full plan.
      final full = buildSummary(
        plan,
        <String>{},
        const [],
        const [],
        lookupAppLocalizations(const Locale('en')),
      );
      expect(full.totalSeconds, 40);
      expect(full.workSeconds, 30);
      expect(full.totalRounds, 3);

      // Stopped at 12s: 10s work + 2s of the first rest.
      final cut = buildSummary(
        plan,
        <String>{},
        const [],
        const [],
        lookupAppLocalizations(const Locale('en')),
        elapsedSeconds: 12,
      );
      expect(cut.workSeconds, 10);
      expect(cut.restSeconds, 2);
      expect(cut.totalSeconds, 12);
      expect(cut.totalRounds, 1);
    },
  );

  testWidgets('completion edits the auto-saved record in place', (
    tester,
  ) async {
    final store = await bootApp(tester);
    store.addSession(_record('sess-auto'));

    GoRouter.of(tester.element(find.byType(Text).first)).go(
      '/complete',
      extra: CompleteArgs(_cfg(), _summary(), sessionId: 'sess-auto'),
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    expect(find.text('Salvato in Progressi'), findsOneWidget);

    await tester.tap(find.text('8'));
    await tester.pumpAndSettle();
    expect(store.data.sessions.length, 1);
    expect(store.data.sessions.first.rpe, 8);
    expect(store.data.sessions.first.load, 40);

    await tester.tap(find.text('FATTO').hitTestable().last);
    await tester.pumpAndSettle(const Duration(seconds: 1));
    expect(store.data.sessions.length, 1);
    expect(find.text('STREAK SETTIMANALE'), findsOneWidget);
  });

  testWidgets('completion fallback creates once and then updates', (
    tester,
  ) async {
    final store = await bootApp(tester);
    expect(store.data.sessions, isEmpty);

    GoRouter.of(tester.element(find.byType(Text).first)).go(
      '/complete',
      extra: CompleteArgs(
        _cfg(),
        _summary(),
      ), // sessionId null (auto-save failed)
    );
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.text('7'));
    await tester.pumpAndSettle();
    expect(store.data.sessions.length, 1);

    await tester.tap(find.text('9'));
    await tester.pumpAndSettle();
    // Still a single record, updated.
    expect(store.data.sessions.length, 1);
    expect(store.data.sessions.first.rpe, 9);
  });
}
