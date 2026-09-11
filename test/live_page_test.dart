// Live session screen: landscape layout and swipe navigation.
import 'package:fight_camp/app_args.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fight_camp/data/store.dart';
import 'package:fight_camp/lib/session.dart';
import 'package:fight_camp/main.dart';
import 'package:fight_camp/models/types.dart';
import 'package:fight_camp/pages/live_page.dart';
import 'package:fight_camp/ui/widgets.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> bootApp(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues({
    'fight-camp:lang': 'it',
    'fight-camp:onboarding-seen': true,
  });
  await tester.pumpWidget(const FightCampApp());
  await tester.pumpAndSettle(const Duration(seconds: 1));
  GoRouter.of(tester.element(find.byType(Text).first)).go('/');
  await tester.pumpAndSettle(const Duration(seconds: 1));
}

Future<void> startFreeRound(WidgetTester tester) async {
  // Train-page start button → the session auto-starts (no idle screen).
  final startBtn = find.widgetWithText(Button, 'AVVIA').hitTestable().last;
  await tester.ensureVisible(startBtn);
  await tester.pumpAndSettle();
  await tester.tap(startBtn);
  await tester.pumpAndSettle();
}

Future<void> startCombinationRound(WidgetTester tester) async {
  final router = GoRouter.of(tester.element(find.byType(Text).first));
  router.go(
    '/live',
    extra: LiveArgs(
      const LiveConfig(
        name: 'Combo test',
        type: WorkoutType.heavyBag,
        prepSeconds: 0,
        rounds: [
          RoundBase(
            duration: 60,
            restDuration: 0,
            type: RoundType.combination,
            combinationIds: ['combo-01'],
          ),
        ],
      ),
    ),
  );
  await tester.pumpAndSettle();
  await tester.tap(find.text('AVVIA').hitTestable().last);
  await tester.pumpAndSettle();
}

Future<void> startStretchingWorkout(WidgetTester tester) async {
  final store = tester.element(find.byType(MaterialApp)).read<AppStore>();
  final workout = store.data.workouts.firstWhere((w) => w.routineId != null);
  final cfg = configFromWorkout(
    workout,
    store.data.combinations,
    store.data.techniques,
    0,
  );
  final router = GoRouter.of(tester.element(find.byType(Text).first));
  router.go('/live', extra: LiveArgs(cfg));
  await tester.pumpAndSettle();
  await tester.tap(find.text('AVVIA').hitTestable().last);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('live screen renders in landscape without overflow', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);
    await startFreeRound(tester);

    // Rotate to landscape mid-session.
    tester.view.physicalSize = const Size(1800, 800);
    await tester.pumpAndSettle();

    // Both long sides of the phone get a readable timer face. Their opposite
    // quarter-turns mean each face is upright to the person facing it.
    expect(find.byType(TimerBlock), findsNWidgets(2));
    final turns = tester
        .widgetList<RotatedBox>(find.byType(RotatedBox))
        .map((box) => box.quarterTurns)
        .toSet();
    expect(turns, containsAll(<int>{1, 3}));

    // Keep the session chrome tied to the physical ends of the phone: the
    // title at one short edge, and the controls at the charging-port edge.
    expect(find.text('ROUND LIBERI'), findsOneWidget);
    expect(tester.getCenter(find.text('ROUND LIBERI')).dx, greaterThan(1500));
    expect(
      tester.getCenter(find.byIcon(Icons.pause_rounded)).dx,
      lessThan(300),
    );
    expect(find.byIcon(Icons.skip_next_rounded), findsOneWidget);
    expect(find.byIcon(Icons.pause_rounded), findsOneWidget);
    expect(find.byIcon(Icons.skip_previous_rounded), findsOneWidget);
  });

  testWidgets('swiping on the timer does not skip the round', (tester) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);
    await startFreeRound(tester);

    // Prep (3s) is active: header shows PREPARAZIONE.
    expect(find.text('PREPARAZIONE'), findsWidgets);

    // Swipe left across the timer: state must not change (no accidental skips).
    await tester.fling(find.text('3'), const Offset(-300, 0), 1000);
    await tester.pumpAndSettle();

    expect(find.text('PREPARAZIONE'), findsWidgets);
  });

  testWidgets('combination follows the readable landscape timer face', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(800, 1800);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);
    await bootApp(tester);
    await startCombinationRound(tester);

    tester.view.physicalSize = const Size(1800, 800);
    await tester.pumpAndSettle();

    final comboOrientation = find.ancestor(
      of: find.byType(PhaseContent),
      matching: find.byWidgetPredicate(
        (widget) => widget is RotatedBox && widget.quarterTurns == 3,
      ),
    );
    expect(comboOrientation, findsOneWidget);
    expect(
      tester
          .widgetList<TimerBlock>(find.byType(TimerBlock))
          .every((timer) => timer.compact),
      isTrue,
    );
  });

  testWidgets(
    'stretching workout shows the exercise image and name during work',
    (tester) async {
      tester.view.physicalSize = const Size(800, 1800);
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
      await bootApp(tester);
      await startStretchingWorkout(tester);

      // First stretching exercise: SVG illustration + exercise name on screen.
      expect(find.byType(SvgPicture), findsWidgets);
      expect(find.text('PANCAKE'), findsOneWidget);
    },
  );
}
